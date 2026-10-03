import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'shared_widgets.dart';

class EditAppointmentScreen extends StatefulWidget {
  final String docId;
  final String currentService;
  final DateTime currentDate;
  final String currentTime;
  final String currentNotes;

  const EditAppointmentScreen({
    super.key,
    required this.docId,
    required this.currentService,
    required this.currentDate,
    required this.currentTime,
    required this.currentNotes,
  });

  @override
  State<EditAppointmentScreen> createState() => _EditAppointmentScreenState();
}

class _EditAppointmentScreenState extends State<EditAppointmentScreen> {
  String? selectedService;
  DateTime? selectedDate;
  String? selectedTime;
  late TextEditingController _notesController;

  final List<Map<String, dynamic>> services = [
    {'title': 'Checkup', 'icon': Icons.medical_information},
    {'title': 'Cleaning', 'icon': Icons.wash},
    {'title': 'Whitening', 'icon': Icons.tag_faces},
    {'title': 'Extraction', 'icon': Icons.healing},
  ];

  final List<String> timeSlots = [
    '09:00 AM', '10:00 AM', '11:30 AM',
    '01:00 PM', '02:30 PM', '04:00 PM'
  ];

  @override
  void initState() {
    super.initState();
    // Pre-fill the state with the existing appointment data passed from the records screen
    selectedService = widget.currentService;
    selectedDate = widget.currentDate;
    selectedTime = widget.currentTime;
    _notesController = TextEditingController(text: widget.currentNotes);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0D47A1),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
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

  Future<void> _updateAppointment() async {
    if (selectedService == null || selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a service, date, and time.'), backgroundColor: Colors.red),
      );
      return;
    }

    try {
      // Find the exact document in Firestore and update its fields
      await FirebaseFirestore.instance.collection('appointments').doc(widget.docId).update({
        'service': selectedService,
        'date': Timestamp.fromDate(selectedDate!),
        'time': selectedTime,
        'notes': _notesController.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment updated successfully!'),
            backgroundColor: Color(0xFF2E7D32), // Theme Green
          ),
        );
        Navigator.pop(context); // Go back to the records screen
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating: $e'), backgroundColor: Colors.red),
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
      appBar: const CustomAppBar(title: 'Edit Appointment'),
      drawer: const CustomDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Update your booking details',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF0D47A1)),
              ),
              const SizedBox(height: 24),

              // 1. Service Selection
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
                      onTap: () => setState(() => selectedService = services[index]['title']),
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

              // 2. Date Picker
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

              // 3. Time Slot Grid
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
                    selectedColor: const Color(0xFF2E7D32),
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

              // 4. Notes
              const Text('4. Additional Notes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
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

              // 5. Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _updateAppointment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D47A1),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(
                    'Save Changes',
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