import 'package:flutter/material.dart';
import '../constants.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support'), leading: const BackButton()),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'How can we help you?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildFaqItem(
            'How do I report an incident?',
            'Go to the Report page, select the incident type, add details and location, and tap Submit.',
          ),
          _buildFaqItem(
            'Is my location data safe?',
            'Yes, we only share your location when you submit a report or enable location sharing with trusted contacts.',
          ),
          _buildFaqItem(
            'How do I change my password?',
            'Go to Account & Settings > Account > Change Password.',
          ),
          _buildFaqItem(
            'How do I update my profile?',
            'Go to Account & Settings > Account > Update Profile.',
          ),
          const SizedBox(height: 30),
          const Text(
            'Contact Us',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.email, color: AppColors.safetyBlue),
            title: const Text('Email Support'),
            subtitle: const Text('safetifyapps@gmail.com'),
            onTap: () {
              // to Implement email launch later
            },
          ),
          ListTile(
            leading: const Icon(Icons.phone, color: AppColors.safetyBlue),
            title: const Text('Call Emergency Hotline'),
            subtitle: const Text('112'),
            onTap: () {
              // later
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return ExpansionTile(
      title: Text(question, style: const TextStyle(fontWeight: FontWeight.w600)),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(answer),
        ),
      ],
    );
  }
}
