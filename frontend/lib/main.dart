import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:safetify/Pages/home.dart';
import 'package:safetify/firebase_options.dart';
import 'package:safetify/pages/ai.dart';
import 'package:safetify/pages/analytics.dart';
import 'package:safetify/widgets/alert_card.dart';
import 'constants.dart';
import 'Pages/login.dart';
import 'Pages/register.dart';
import 'Pages/forgotpassword.dart';
import 'Pages/welcome.dart';
import 'Pages/report.dart';
import 'Pages/details.dart';
import 'Pages/profile.dart';
import 'Pages/settings.dart';
import 'Pages/emergency_contacts.dart';
import 'Pages/community_updates.dart';
import 'Pages/startup.dart';
import 'pages/map.dart';
import 'pages/notification.dart';
import 'pages/incident_histoty.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp (

    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      initialRoute: '/',
      routes: {
        '/': (_) => StartupPage(),
        '/home': (_) => HomePage(),
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
        '/notifications': (_) => NotificationPage(),
        '/history': (_) => IncidentsHistoryPage(),
        '/ai': (_) => AiPage(),
      },
    );
  }
}
