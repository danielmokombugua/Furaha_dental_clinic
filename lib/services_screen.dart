import 'package:flutter/material.dart';
import 'shared_widgets.dart';
import 'booking_screen.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  final List<Map<String, dynamic>> clinicServices = const [
    {
      'title': 'General Checkup',
      'desc': 'Comprehensive dental exam to evaluate your oral health and catch issues early.',
      'icon': Icons.medical_information,
    },
    {
      'title': 'Teeth Cleaning',
      'desc': 'Professional plaque and tartar removal for a brighter, healthier smile.',
      'icon': Icons.wash,
    },
    {
      'title': 'Teeth Whitening',
      'desc': 'Advanced laser whitening treatments to remove stains and discoloration.',
      'icon': Icons.tag_faces,
    },
    {
      'title': 'Tooth Extraction',
      'desc': 'Safe and painless removal of decayed or problematic teeth, including wisdom teeth.',
      'icon': Icons.healing,
    },
    {
      'title': 'Orthodontics (Braces)',
      'desc': 'Alignment correction services using traditional braces or clear aligners.',
      'icon': Icons.sentiment_satisfied_alt,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: const CustomAppBar(title: 'Clinic Services'),
      drawer: const CustomDrawer(),
      body: ListView.builder(
        padding: const EdgeInsets.all(20.0),
        itemCount: clinicServices.length,
        itemBuilder: (context, index) {
          final service = clinicServices[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(service['icon'], size: 28, color: const Color(0xFF0D47A1)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          service['title'],
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    service['desc'],
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const BookingScreen()));
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2E7D32),
                        side: const BorderSide(color: Color(0xFF2E7D32)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Book Now', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}