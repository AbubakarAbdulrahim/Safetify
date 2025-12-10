import 'package:flutter/material.dart';
import '../constants.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Privacy Policy'),
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

              Text(
                'At Safetify, we are committed to protecting your privacy and ensuring the security of your personal information. This Privacy Policy explains how we collect, use, and safeguard your data.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 24),

              _buildSection(
                context,
                '1. Information We Collect',
                'We collect the following types of information:\n\n'
                '• Personal Information: Name, email address, phone number\n'
                '• Location Data: Real-time and historical location for incident reporting\n'
                '• Device Information: Device type, operating system, unique identifiers\n'
                '• Usage Data: How you interact with the app, features used\n'
                '• User Content: Incident reports, photos, descriptions you submit',
              ),

              _buildSection(
                context,
                '2. How We Use Your Information',
                'Your information is used to:\n\n'
                '• Provide and improve our safety alert services\n'
                '• Send notifications about nearby incidents\n'
                '• Verify and moderate incident reports\n'
                '• Analyze app usage and improve user experience\n'
                '• Communicate important updates and safety information\n'
                '• Comply with legal obligations',
              ),

              _buildSection(
                context,
                '3. Location Data',
                'Location information is critical to Safetify\'s functionality:\n\n'
                '• We collect your location when you report incidents\n'
                '• Your approximate location is shared with nearby users for safety alerts\n'
                '• Location data helps us map incident hotspots\n'
                '• You can disable location services, but this limits app functionality\n'
                '• We do not share your exact location publicly',
              ),

              _buildSection(
                context,
                '4. Data Sharing',
                'We share your information only in the following circumstances:\n\n'
                '• With other users: Incident reports and approximate location for safety alerts\n'
                '• With emergency services: When necessary for public safety\n'
                '• With service providers: Who help us operate the app (cloud hosting, analytics)\n'
                '• For legal compliance: When required by law or to protect rights and safety\n'
                '• We never sell your personal information to third parties',
              ),

              _buildSection(
                context,
                '5. Data Security',
                'We implement industry-standard security measures:\n\n'
                '• Encryption of data in transit and at rest\n'
                '• Secure authentication and password protection\n'
                '• Regular security audits and updates\n'
                '• Limited access to personal data by authorized personnel only\n'
                '• However, no method of transmission over the internet is 100% secure',
              ),

              _buildSection(
                context,
                '6. Data Retention',
                'We retain your information:\n\n'
                '• Account data: Until you delete your account\n'
                '• Incident reports: Indefinitely for safety records and analytics\n'
                '• Location history: For 90 days unless part of an incident report\n'
                '• You can request deletion of your data by contacting us',
              ),

              _buildSection(
                context,
                '7. Your Rights',
                'You have the right to:\n\n'
                '• Access your personal data\n'
                '• Correct inaccurate information\n'
                '• Request deletion of your account and data\n'
                '• Opt-out of non-essential data collection\n'
                '• Export your data in a portable format\n'
                '• Withdraw consent for data processing',
              ),

              _buildSection(
                context,
                '8. Children\'s Privacy',
                'Safetify is not intended for users under 13 years of age. We do not knowingly collect personal information from children. If we discover we have collected data from a child, we will delete it immediately.',
              ),

              _buildSection(
                context,
                '9. Cookies and Tracking',
                'We use cookies and similar technologies to:\n\n'
                '• Remember your preferences and settings\n'
                '• Analyze app usage and performance\n'
                '• Improve user experience\n'
                '• You can manage cookie preferences in your device settings',
              ),

              _buildSection(
                context,
                '10. Third-Party Services',
                'We use third-party services that may collect information:\n\n'
                '• Firebase (Google): Authentication, database, analytics\n'
                '• Cloudinary: Image storage and processing\n'
                '• Map providers: For location services\n'
                '• These services have their own privacy policies',
              ),

              _buildSection(
                context,
                '11. International Data Transfers',
                'Your data may be transferred to and stored on servers located outside your country. We ensure appropriate safeguards are in place to protect your information.',
              ),

              _buildSection(
                context,
                '12. Changes to Privacy Policy',
                'We may update this Privacy Policy periodically. We will notify you of significant changes through the app or via email. Continued use after changes constitutes acceptance.',
              ),

              _buildSection(
                context,
                '13. Contact Us',
                'For privacy-related questions or requests:\n\n'
                'Email: privacy@safetify.com\n'
                'Website: www.safetify.com/privacy\n'
                'Address: Safetify Inc., Nigeria',
              ),

              const SizedBox(height: 40),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.successGreen.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      color: AppColors.successGreen,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your privacy and safety are our top priorities. We are committed to protecting your personal information.',
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
