import 'package:flutter/material.dart';

class AppColors {
  static const Color safetyBlue = Color(0xFF0056D2);
  static const Color alertRed = Color(0xFFE74C3C);
  static const Color successGreen = Color(0xFF1ABC9C);
  static const Color amber = Color(0xFFF39C12);
  static const Color darkCharcoal = Color(0xFF2C3E50);
  static const Color bg = Color(0xFFF9FAFB);
  static const Color card = Colors.white;
  static const Color subtle = Color(0xFFF1F3F6);
}

class AppTheme {
  static ThemeData lightTheme() { // Light Theme
    return ThemeData(
      scaffoldBackgroundColor: AppColors.bg,
      primaryColor: AppColors.safetyBlue,
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: AppColors.safetyBlue,
        secondary: AppColors.successGreen,
      ),
      textTheme: Typography.blackMountainView,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.card,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.darkCharcoal),
        titleTextStyle: TextStyle(
          color: AppColors.darkCharcoal,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.safetyBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: EdgeInsets.symmetric(vertical: 14),
          textStyle: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.subtle,
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

//   static ThemeData darkTheme() { // Dark Theme
//     return ThemeData(
//       brightness: Brightness.dark,
//       scaffoldBackgroundColor: Color(0xFF0B1220),
//       primaryColor: AppColors.safetyBlue,
//       cardColor: Color(0xFF0E1624),
//       colorScheme: ColorScheme.fromSwatch(brightness: Brightness.dark).copyWith(
//         primary: AppColors.safetyBlue,
//         secondary: AppColors.successGreen,
//       ),
//       textTheme: Typography.whiteMountainView,
//       appBarTheme: AppBarTheme(
//         backgroundColor: Color(0xFF0E1624),
//         elevation: 0,
//         iconTheme: IconThemeData(color: Colors.white),
//         titleTextStyle: TextStyle(
//           color: Colors.white,
//           fontWeight: FontWeight.bold,
//           fontSize: 20,
//         ),
//       ),
//       elevatedButtonTheme: ElevatedButtonThemeData(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: AppColors.safetyBlue,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           padding: EdgeInsets.symmetric(vertical: 24),
//           textStyle: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
//         ),
//       ),
//       inputDecorationTheme: InputDecorationTheme(
//         filled: true,
//         fillColor: Color(0xFF14202B),
//         contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 14),
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
//         hintStyle: TextStyle(color: Colors.white70),
//       ),
//     );
//   }

//   // Helper to get theme by mode
//   static ThemeData themeFor(ThemeMode mode) => mode == ThemeMode.dark ? darkTheme() : lightTheme();
}


// import 'package:flutter/material.dart';

// class AppColors {
//   // Brand Colors
//   static const Color safetyBlue = Color(0xFF0056D2);
//   static const Color alertRed = Color(0xFFE74C3C);
//   static const Color successGreen = Color(0xFF1ABC9C);
//   static const Color amber = Color(0xFFF39C12);

//   // Light Theme
//   static const Color darkCharcoal = Color(0xFF2C3E50);
//   static const Color bg = Color(0xFFF9FAFB);
//   static const Color card = Colors.white;
//   static const Color subtle = Color(0xFFF1F3F6);

//   // Dark Theme
//   static const Color darkBg = Color(0xFF0E1624);
//   static const Color darkCard = Color(0xFF1A2433);
//   static const Color darkSubtle = Color(0xFF233044);
//   static const Color textLight = Colors.white;
//   static const Color textMuted = Colors.white70;
// }

// class AppTheme {
//   /// 🌞 Light Theme
//   static ThemeData lightTheme() {
//     return ThemeData(
//       brightness: Brightness.light,
//       scaffoldBackgroundColor: AppColors.bg,
//       primaryColor: AppColors.safetyBlue,
//       cardColor: AppColors.card,
//       colorScheme: ColorScheme.fromSwatch().copyWith(
//         primary: AppColors.safetyBlue,
//         secondary: AppColors.successGreen,
//       ),
//       textTheme: Typography.blackMountainView,
//       appBarTheme: AppBarTheme(
//         backgroundColor: AppColors.card,
//         elevation: 0,
//         iconTheme: const IconThemeData(color: AppColors.darkCharcoal),
//         titleTextStyle: const TextStyle(
//           color: AppColors.darkCharcoal,
//           fontWeight: FontWeight.bold,
//           fontSize: 20,
//         ),
//       ),
//       elevatedButtonTheme: ElevatedButtonThemeData(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: AppColors.safetyBlue,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           padding: const EdgeInsets.symmetric(vertical: 14),
//           textStyle: const TextStyle(fontWeight: FontWeight.w600),
//         ),
//       ),
//       inputDecorationTheme: InputDecorationTheme(
//         filled: true,
//         fillColor: AppColors.subtle,
//         contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide.none,
//         ),
//       ),
//     );
//   }

//   /// 🌚 Dark Theme
//   static ThemeData darkTheme() {
//     return ThemeData(
//       brightness: Brightness.dark,
//       scaffoldBackgroundColor: AppColors.darkBg,
//       primaryColor: AppColors.safetyBlue,
//       cardColor: AppColors.darkCard,
//       colorScheme: ColorScheme.dark(
//         primary: AppColors.safetyBlue,
//         secondary: AppColors.successGreen,
//         surface: AppColors.darkCard,
//         background: AppColors.darkBg,
//         error: AppColors.alertRed,
//       ),
//       textTheme: Typography.whiteMountainView.apply(
//         bodyColor: AppColors.textLight,
//         displayColor: AppColors.textLight,
//       ),
//       appBarTheme: AppBarTheme(
//         backgroundColor: AppColors.darkCard,
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.white),
//         titleTextStyle: const TextStyle(
//           color: Colors.white,
//           fontWeight: FontWeight.bold,
//           fontSize: 20,
//         ),
//       ),
//       elevatedButtonTheme: ElevatedButtonThemeData(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: AppColors.safetyBlue,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           padding: const EdgeInsets.symmetric(vertical: 14),
//           textStyle: const TextStyle(
//             fontWeight: FontWeight.w600,
//             color: Colors.white,
//           ),
//         ),
//       ),
//       inputDecorationTheme: InputDecorationTheme(
//         filled: true,
//         fillColor: AppColors.darkSubtle,
//         contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide.none,
//         ),
//         hintStyle: const TextStyle(color: AppColors.textMuted),
//       ),
//     );
//   }

//   /// Helper – Switches automatically
//   static ThemeData themeFor(ThemeMode mode) =>
//       mode == ThemeMode.dark ? darkTheme() : lightTheme();
// }
