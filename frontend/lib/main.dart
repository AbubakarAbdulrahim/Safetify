import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';
import 'Pages/login.dart';
import 'Pages/register.dart';
import 'Pages/forgotpassword.dart';
import 'Pages/welcome.dart';
import 'Pages/home.dart';
import 'Pages/report.dart';
import 'Pages/details.dart';
import 'Pages/profile.dart';
import 'Pages/settings.dart';
import 'Pages/analytics.dart';
import 'Pages/emergency_contacts.dart';
import 'Pages/community_updates.dart';
import 'Pages/startup.dart';
import 'pages/map.dart';

void main() {
  runApp(SafetifyApp());
}

class SafetifyApp extends StatelessWidget {
  const SafetifyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Safetify',
      theme: AppTheme.lightTheme().copyWith(
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/startup',
      routes: {
        '/': (_) => HomePage(),
        '/login': (_) => LoginPage(),
        '/register': (_) => RegisterPage(),
        '/forgotpassword': (_) => ForgotPasswordPage(),
        '/welcome': (_) => WelcomePage(),
        '/report': (_) => ReportPage(),
        '/details': (_) => DetailsPage(),
        '/map': (_) => MapPage(),
        '/profile': (_) => ProfilePage(),
        '/settings': (_) => SettingsPage(),
        '/analytics': (_) => AnalyticsPage(),
        '/emergency_contacts': (_) => EmergencyContactsPage(),
        '/community_updates': (_) => CommunityUpdatesPage(),
        '/startup': (_) => StartupPage(),
      },
    );
  }
}
