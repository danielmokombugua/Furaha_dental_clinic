import 'package:flutter/material.dart';
import 'shared_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  // State variables to hold the user's selections
  String? selectedService;
  DateTime? selectedDate;
  String? selectedTime;
  final TextEditingController _notesController = TextEditingController();

  // List of available services for the clickable cards
  final List<Map<String, dynamic>> services = [
    {'title': 'Checkup', 'icon': Icons.medical_information},
    {'title': 'Cleaning', 'icon': Icons.wash},
    {'title': 'Whitening', 'icon': Icons.tag_faces},
    {'title': 'Extraction', 'icon': Icons.healing},
  ];

  // List of available time slots
  final List<String> timeSlots = [
    '07:00 AM', '9:00 AM', '11:30 AM',
    '02:00 PM', '03:30 PM'
  ];

  // Function to open the calendar date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)), // Starts tomorrow
      firstDate: DateTime.now(), // Cannot book in the past
      lastDate: DateTime.now().add(const Duration(days: 90)), // Book up to 3 months out
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0D47A1), // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black87, // Body text color
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  //sending to firestore func
  Future<void> _submitBooking() async {
    // 1. Validate that the user filled out the form
    if (selectedService == null || selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a service, date, and time.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // 2. Get the current logged-in patient UID
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception("No user logged in.");

      // 3. Fetch the patient's first and last name from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('patients')
          .doc(currentUser.uid)
          .get();

      String firstName = "Unknown";
      String lastName = "Patient";

      if (userDoc.exists) {
        firstName = userDoc.get('firstName') ?? "Unknown";
        lastName = userDoc.get('lastName') ?? "Patient";
      }

      // 4. Save the appointment with the names included
      await FirebaseFirestore.instance.collection('appointments').add({
        'patientId': currentUser.uid,
        'patientFirstName': firstName,    // Added for easy identification
        'patientLastName': lastName,      // Added for easy identification
        'service': selectedService,
        'date': Timestamp.fromDate(selectedDate!),
        'time': selectedTime,
        'notes': _notesController.text.trim(),
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 5. Show Success Pop-up
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: const Row(
                children: [
                  Icon(Icons.check_circle, color: Color(0xFF2E7D32)),
                  SizedBox(width: 8),
                  Text('Request Sent'),
                ],
              ),
              content: const Text('Your appointment has been saved to the clinic database!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(); // Return to dashboard
                  },
                  child: const Text('Back to Dashboard', style: TextStyle(color: Color(0xFF0D47A1))),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving appointment: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'Book an Appointment :)'),
      drawer: const CustomDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. The Header Statement
              const Text(
                'Book your appointment today',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0D47A1),
                ),
              ),
              const SizedBox(height: 24),

              // 2. Service Selection Cards (Horizontal Scroll)
              const Text('1. Select a Service', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              SizedBox(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    final isSelected = selectedService == services[index]['title'];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedService = services[index]['title'];
                        });
                      },
                      child: Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF0D47A1) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF0D47A1) : Colors.grey.shade300,
                            width: 2,
                          ),
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              services[index]['icon'],
                              size: 32,
                              color: isSelected ? Colors.white : const Color(0xFF0D47A1),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              services[index]['title'],
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),

              // 3. Date Picker
              const Text('2. Choose a Date', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              InkWell(
                onTap: () => _selectDate(context),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedDate == null
                            ? 'Tap to select date'
                            : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                        style: TextStyle(
                          fontSize: 16,
                          color: selectedDate == null ? Colors.grey.shade600 : Colors.black87,
                          fontWeight: selectedDate == null ? FontWeight.normal : FontWeight.bold,
                        ),
                      ),
                      const Icon(Icons.calendar_month, color: Color(0xFF0D47A1)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // 4. Time Slot Grid
              const Text('3. Select a Time', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: timeSlots.map((time) {
                  final isSelected = selectedTime == time;
                  return ChoiceChip(
                    label: Text(time),
                    selected: isSelected,
                    selectedColor: const Color(0xFF2E7D32), // Theme Green for active slot
                    backgroundColor: Colors.grey.shade100,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (bool selected) {
                      setState(() {
                        selectedTime = selected ? time : null;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),

              // 5. Patient Notes (Optional)
              const Text('4. Additional Notes (Optional)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Any specific symptoms or requests?',
                  filled: true,
                  fillColor: Colors.blue.shade50.withOpacity(0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blue.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blue.shade100),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF0D47A1), width: 1.8),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // 6. Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D47A1),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(
                    'Confirm Appointment',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}