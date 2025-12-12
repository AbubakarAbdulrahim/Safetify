import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // App Logo
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.safetyBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shield_rounded,
                size: 64,
                color: AppColors.safetyBlue,
              ),
            ),
            const SizedBox(height: 24),

            // App Name
            Text(
              'Safetify',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.safetyBlue,
              ),
            ),
            const SizedBox(height: 8),
            
            // Version
            Text(
              'Version 1.0.0',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 40),
            
            // Developer Info
            const Text(
              'Developed by',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/images/mypic.jpg'),
            ),
            const SizedBox(height: 12),
            Text(
              'Abubakar Abdulrahim',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Software Engineer',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 12),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'I am a software engineer with a passion for building innovative and user-friendly applications. I have a strong background in software development and a deep understanding of the latest technologies. As a student of Bayero University, Kano, I am always looking for opportunities to apply my skills and make a positive impact on the world.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  height: 1.5,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                )),
            ),
            const SizedBox(height: 12),
            Text(
              'Email: abubakarabdulrahim@gmail.com',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.grey
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Phone: 08169920252, 09013113304',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.grey
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'GitHub: Https://www.github.com/AbubakarAbdulrahim',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.grey
              ),
            ),

            const SizedBox(height: 40),
            
            // Description
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Text(
                'Safetify is a community safety application designed to keep you informed and connected. Report incidents, view real-time updates, and stay safe with our comprehensive safety tools.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  height: 1.5,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            Text(
              '© 2025 Safetify. All rights reserved.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
