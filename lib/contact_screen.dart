import 'package:flutter/material.dart';
import 'shared_widgets.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: const CustomAppBar(title: 'Contact Us'),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: const Color(0xFF0D47A1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.support_agent, size: 50, color: Colors.white),
                  SizedBox(height: 12),
                  Text(
                    'We are here to help!',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildContactCard(
              icon: Icons.location_on,
              title: 'Clinic Location',
              content: '123 Health Avenue, Medical District\nNairobi, Kenya',
            ),
            _buildContactCard(
              icon: Icons.phone,
              title: 'Phone Number',
              content: '+254 700 123 456\n+254 722 987 654',
            ),
            _buildContactCard(
              icon: Icons.email,
              title: 'Email Address',
              content: 'care@furahadental.com\nsupport@furahadental.com',
            ),
            _buildContactCard(
              icon: Icons.access_time,
              title: 'Working Hours',
              content: 'Mon - Fri: 8:00 AM - 6:00 PM\nSaturday: 9:00 AM - 2:00 PM\nSunday: Closed',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({required IconData icon, required String title, required String content}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 28, color: const Color(0xFF2E7D32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
                  const SizedBox(height: 6),
                  Text(content, style: TextStyle(fontSize: 15, color: Colors.grey.shade700, height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}