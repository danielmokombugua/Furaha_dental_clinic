import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'shared_widgets.dart';
import 'booking_screen.dart';
import 'records_screen.dart';
import 'contact_screen.dart';
import 'profile_screen.dart';
import 'services_screen.dart';
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String username = "Patient";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Retrieve the current user's profile from Firestore to get the username for the greeting
  Future<void> _fetchUserData() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('patients')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          if (mounted) {
            setState(() {
              username = userDoc.get('username') ?? "Patient";
              isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // 1. Utilizing the reusable App Bar
      appBar: const CustomAppBar(title: 'WELCOME TO FURAHA DENTAL CLINIC'),

      // 2. Utilizing the reusable Side Menu
      drawer: const CustomDrawer(),

      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0D47A1)))
          : Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Right-aligned personalized greeting using Theme Green
          Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 24.0, left: 24.0, bottom: 20.0),
            child: Text(
              'Hi $username',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2A4186),
              ),
            ),
          ),

          // The Main Dashboard Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildDashboardCard(
                    title: 'Book\nAppointment',
                    icon: Icons.calendar_month,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const BookingScreen()),
                      );
                    },
                  ),
                  _buildDashboardCard(
                    title: 'My\nRecords',
                    icon: Icons.folder_shared,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RecordsScreen()),
                      );
                    },
                  ),
                  _buildDashboardCard(
                    title: 'Clinic\nServices',
                    icon: Icons.medical_services,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ServicesScreen()),
                      );
                    },
                  ),
                  _buildDashboardCard(
                    title: 'Contact\nUs',
                    icon: Icons.support_agent,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ContactScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20), // Bottom padding
        ],
      ),
    );
  }

  // Reusable widget function for the grid cards
  Widget _buildDashboardCard({required String title, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.shade100.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.blue.shade50),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: const Color(0xFF0D47A1)),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}