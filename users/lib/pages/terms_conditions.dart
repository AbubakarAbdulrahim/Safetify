import 'package:flutter/material.dart';
import '../constants.dart';

class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).iconTheme.color,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Last Updated: November 22, 2025',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 24),

              _buildSection(
                context,
                '1. Acceptance of Terms',
                'By accessing and using Safetify, you accept and agree to be bound by the terms and provision of this agreement. If you do not agree to these Terms & Conditions, please do not use this application.',
              ),

              _buildSection(
                context,
                '2. Use of Service',
                'Safetify is a crowdsourced incident reporting and safety alert platform. You agree to:\n\n'
                '• Provide accurate and truthful information when reporting incidents\n'
                '• Not misuse the service for false reports or malicious purposes\n'
                '• Respect the privacy and safety of other users\n'
                '• Use the app in compliance with all applicable laws and regulations',
              ),

              _buildSection(
                context,
                '3. User Accounts',
                'You are responsible for:\n\n'
                '• Maintaining the confidentiality of your account credentials\n'
                '• All activities that occur under your account\n'
                '• Notifying us immediately of any unauthorized use\n'
                '• Ensuring your account information is accurate and up-to-date',
              ),

              _buildSection(
                context,
                '4. Incident Reporting',
                'When reporting incidents:\n\n'
                '• Reports should be factual and based on real events\n'
                '• You grant Safetify the right to use, display, and share your reports with other users\n'
                '• False or malicious reports may result in account suspension\n'
                '• We reserve the right to verify and moderate all reports',
              ),

              _buildSection(
                context,
                '5. Location Services',
                'By using Safetify, you consent to:\n\n'
                '• Collection of your location data for incident reporting\n'
                '• Sharing your approximate location with nearby users for safety alerts\n'
                '• You can disable location services in your device settings, but this may limit app functionality',
              ),

              _buildSection(
                context,
                '6. User Content',
                'You retain ownership of content you submit, but grant Safetify a worldwide, non-exclusive license to use, reproduce, and display your content for the purpose of operating and improving the service.',
              ),

              _buildSection(
                context,
                '7. Prohibited Activities',
                'You may not:\n\n'
                '• Submit false, misleading, or fraudulent reports\n'
                '• Harass, threaten, or harm other users\n'
                '• Violate any laws or regulations\n'
                '• Attempt to gain unauthorized access to the service\n'
                '• Use the service for commercial purposes without permission',
              ),

              _buildSection(
                context,
                '8. Disclaimer of Warranties',
                'Safetify is provided "as is" without warranties of any kind. We do not guarantee:\n\n'
                '• The accuracy or reliability of user-submitted reports\n'
                '• Uninterrupted or error-free service\n'
                '• That the service will meet your specific requirements\n'
                '• The prevention of incidents or emergencies',
              ),

              _buildSection(
                context,
                '9. Limitation of Liability',
                'Safetify and its operators shall not be liable for:\n\n'
                '• Any indirect, incidental, or consequential damages\n'
                '• Loss of data or profits\n'
                '• Personal injury or property damage resulting from app use\n'
                '• Actions taken based on information from the app',
              ),

              _buildSection(
                context,
                '10. Emergency Services',
                'Safetify is NOT a replacement for emergency services. In case of emergency, always contact local emergency services (112, 911, etc.) immediately.',
              ),

              _buildSection(
                context,
                '11. Modifications to Terms',
                'We reserve the right to modify these terms at any time. Continued use of the service after changes constitutes acceptance of the new terms. We will notify users of significant changes.',
              ),

              _buildSection(
                context,
                '12. Account Termination',
                'We reserve the right to suspend or terminate accounts that violate these terms or engage in prohibited activities. You may also delete your account at any time through the app settings.',
              ),

              _buildSection(
                context,
                '13. Governing Law',
                'These terms shall be governed by and construed in accordance with the laws of Nigeria, without regard to its conflict of law provisions.',
              ),

              _buildSection(
                context,
                '14. Contact Us',
                'If you have any questions about these Terms & Conditions, please contact us at:\n\n'
                'Email: support@safetify.com\n'
                'Website: www.safetify.com',
              ),

              const SizedBox(height: 40),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.safetyBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.safetyBlue.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.safetyBlue,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'By using Safetify, you acknowledge that you have read, understood, and agree to be bound by these Terms & Conditions.',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }
}
