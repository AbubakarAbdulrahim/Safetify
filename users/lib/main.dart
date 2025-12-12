import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:safetify/Pages/home.dart';
import 'package:safetify/firebase_options.dart';
import 'package:safetify/pages/ai.dart';
import 'package:safetify/pages/analytics.dart';
import 'package:safetify/pages/incident_histoty.dart';
import 'package:safetify/services/theme_service.dart';
import 'package:safetify/services/notification_service.dart';
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
import 'pages/privacy.dart';
import 'pages/help_support.dart';
import 'pages/account_settings.dart';
import 'pages/change_password.dart';
import 'pages/terms_conditions.dart';
import 'pages/about.dart';
import 'pages/about.dart';
import 'initialization.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(SafetifyApp());
}


class SafetifyApp extends StatefulWidget {
  const SafetifyApp({super.key});



  @override
  State<SafetifyApp> createState() => _SafetifyAppState();
}

class _SafetifyAppState extends State<SafetifyApp> {
  @override
  void initState() {
    super.initState();
    AppInitialization.init();
    ThemeService().loadTheme();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService().themeMode,
      builder: (context, themeMode, child) {
        return MaterialApp(
          title: 'Safetify',
          theme: AppTheme.lightTheme().copyWith(
            textTheme: GoogleFonts.poppinsTextTheme(
              ThemeData.light().textTheme,
            ),
          ),
          darkTheme: AppTheme.darkTheme().copyWith(
            textTheme: GoogleFonts.poppinsTextTheme(
              ThemeData.dark().textTheme,
            ),
          ),
          themeMode: themeMode,
          debugShowCheckedModeBanner: false,
          navigatorKey: NotificationService.navigatorKey, // Set global navigator key
          initialRoute: '/', //startup byd default
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
            '/privacy': (_) => PrivacyPage(),
            '/help': (_) => HelpSupportPage(),
            '/account_settings': (_) => AccountSettingsPage(),
            '/change_password': (_) => ChangePasswordPage(),
            '/terms': (_) => TermsConditionsPage(),
            '/about': (_) => AboutPage(),
          },
        );
      },
    );
  }
}
