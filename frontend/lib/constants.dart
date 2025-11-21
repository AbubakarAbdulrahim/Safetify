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
}