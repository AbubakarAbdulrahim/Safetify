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

  static var blue;
}

class AppTheme {
  static ThemeData lightTheme() { // Light Theme
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.bg,
      primaryColor: AppColors.safetyBlue,
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: AppColors.safetyBlue,
        secondary: AppColors.successGreen,
        surface: AppColors.card,
        brightness: Brightness.light,
      ),
      textTheme: Typography.blackMountainView,
      appBarTheme: const AppBarTheme(
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
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.subtle,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  static ThemeData darkTheme() { // Dark Theme
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF121212),
      primaryColor: AppColors.safetyBlue,
      colorScheme: ColorScheme.fromSwatch(brightness: Brightness.dark).copyWith(
        primary: AppColors.safetyBlue,
        secondary: AppColors.successGreen,
        surface: const Color(0xFF1E1E1E),
      ),
      textTheme: Typography.whiteMountainView,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.safetyBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        hintStyle: TextStyle(color: Colors.grey[400]),
      ),
      cardColor: const Color(0xFF1E1E1E),
      dividerColor: Colors.grey[800],
    );
  }
}