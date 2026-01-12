import 'package:flutter/material.dart';

class TermsView extends StatelessWidget {
  const TermsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome to PLANIFY',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Last Updated: January 12, 2026',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            _buildSection(
              '1. Introduction',
              'By using PLANIFY, you agree to these terms and conditions. Please read them carefully. Our platform connects users with service providers for their events.',
            ),
            _buildSection(
              '2. User Responsibilities',
              'Users are responsible for providing accurate information when booking services. Any disputes between users and vendors should be resolved professionally.',
            ),
            _buildSection(
              '3. Vendor Obligations',
              'Vendors must provide the services as described in their profiles and quotations. They must maintain professionalism and fulfill bookings accepted through the platform.',
            ),
            _buildSection(
              '4. Payments',
              'PLANIFY acts as a connecting platform. Payment terms are negotiated directly between the user and the vendor unless specified otherwise by the platform.',
            ),
            _buildSection(
              '5. Privacy Policy',
              'Your privacy is important to us. We collect minimal data necessary for the app to function and do not share it with third parties without your consent.',
            ),
            const SizedBox(height: 32),
            const Center(
              child: Text(
                'Thank you for using PLANIFY!',
                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(height: 1.5, color: Colors.blueGrey),
          ),
        ],
      ),
    );
  }
}
