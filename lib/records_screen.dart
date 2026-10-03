import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'shared_widgets.dart';
import 'edit_appointment_screen.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  String username = "Patient";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsername();
  }

  // Fetch the username for the top right greeting
  Future<void> _fetchUsername() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('patients')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists && mounted) {
          setState(() {
            username = userDoc.get('username') ?? "Patient";
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // Helper method to format Firestore timestamps into readable dates
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // Handle appointment deletion with a confirmation dialog
  Future<void> _confirmDelete(String docId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Delete Appointment?'),
          content: const Text('Are you sure you want to cancel this appointment? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Cancel
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog
                await FirebaseFirestore.instance.collection('appointments').doc(docId).delete();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Appointment deleted'), backgroundColor: Colors.red),
                  );
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: const CustomAppBar(title: 'MY RECORDS'),
      drawer: const CustomDrawer(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0D47A1)))
          : Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Right-aligned personalized greeting using Theme Green
          Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 24.0, left: 24.0, bottom: 8.0),
            child: Text(
              ' $username',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2E468F),
              ),
            ),
          ),

          // Live stream of appointments from Firestore
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('appointments')
                  .where('patientId', isEqualTo: currentUser?.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF0D47A1)));
                }

                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading records.'));
                }

                final appointments = snapshot.data?.docs ?? [];

                // Separate appointments into upcoming and past based on the current date
                final now = DateTime.now();
                final List<QueryDocumentSnapshot> upcoming = [];
                final List<QueryDocumentSnapshot> past = [];

                for (var doc in appointments) {
                  final data = doc.data() as Map<String, dynamic>;
                  final date = (data['date'] as Timestamp).toDate();

                  // Treat today and future dates as upcoming
                  if (date.isAfter(DateTime(now.year, now.month, now.day - 1))) {
                    upcoming.add(doc);
                  } else {
                    past.add(doc);
                  }
                }

                // Sort upcoming (closest first) and past (most recent first)
                upcoming.sort((a, b) => (a['date'] as Timestamp).compareTo(b['date'] as Timestamp));
                past.sort((a, b) => (b['date'] as Timestamp).compareTo(a['date'] as Timestamp));

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  children: [
                    // UPCOMING APPOINTMENTS SECTION
                    const Text(
                      'My Appointments',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
                    ),
                    const SizedBox(height: 12),

                    if (upcoming.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 20),
                        child: Text('No upcoming appointments scheduled.', style: TextStyle(color: Colors.grey)),
                      )
                    else
                      ...upcoming.map((doc) => _buildAppointmentCard(doc, isUpcoming: true)),

                    const SizedBox(height: 10),
                    const Divider(thickness: 1.5),
                    const SizedBox(height: 20),

                    // PREVIOUS APPOINTMENTS SECTION
                    const Text(
                      'Previous Appointments',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),

                    if (past.isEmpty)
                      const Text('No past appointments found.', style: TextStyle(color: Colors.grey))
                    else
                      ...past.map((doc) => _buildAppointmentCard(doc, isUpcoming: false)),

                    const SizedBox(height: 30),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Reusable widget to build the appointment cards
  Widget _buildAppointmentCard(QueryDocumentSnapshot doc, {required bool isUpcoming}) {
    final data = doc.data() as Map<String, dynamic>;
    final date = (data['date'] as Timestamp).toDate();
    final service = data['service'] ?? 'Consultation';
    final time = data['time'] ?? 'TBD';
    final status = data['status'] ?? 'Pending';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isUpcoming ? const Color(0xFF0D47A1).withOpacity(0.3) : Colors.grey.shade300),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  service,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isUpcoming ? const Color(0xFF0D47A1) : Colors.grey.shade700,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isUpcoming ? const Color(0xFF2E7D32).withOpacity(0.1) : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: isUpcoming ? const Color(0xFF2E7D32) : Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(_formatDate(date), style: const TextStyle(fontSize: 15)),
                const SizedBox(width: 24),
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(time, style: const TextStyle(fontSize: 15)),
              ],
            ),

            // Only show Edit and Delete buttons for Upcoming appointments
            if (isUpcoming) ...[
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditAppointmentScreen(
                            docId: doc.id,
                            currentService: service,
                            currentDate: date,
                            currentTime: time,
                            currentNotes: data['notes'] ?? '',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit, size: 18, color: Color(0xFF0D47A1)),
                    label: const Text('Edit', style: TextStyle(color: Color(0xFF0D47A1))),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _confirmDelete(doc.id),
                    icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                    label: const Text('Delete', style: TextStyle(color: Colors.red)),
                  ),
                ],
              )
            ]
          ],
        ),
      ),
    );
  }
}