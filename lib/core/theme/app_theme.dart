import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color background = Color(0xFF0D0A1A);
  static const Color backgroundAlt = Color(0xFF181036);
  static const Color surface = Color(0xFF211A45);
  static const Color surfaceHigh = Color(0xFF2B2260);

  static const Color accent = Color(0xFF8B5CF6);
  static const Color accentSoft = Color(0xFFC0A6FF);
  static const Color accentDeep = Color(0xFF5B3FE0);

  static const Color textPrimary = Color(0xFFF6F4FF);
  static const Color textSecondary = Color(0xFFA79FD1);

  static const Color onLightSurface = Color(0xFF1E1B33);
  static const Color error = Color(0xFFFF7A93);
}

class AppTheme {
  AppTheme._();

  static ThemeData dark() {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      brightness: Brightness.dark,
    ).copyWith(surface: AppColors.surface, error: AppColors.error);

    final TextTheme text = ThemeData(brightness: Brightness.dark).textTheme.apply(
          bodyColor: AppColors.textPrimary,
          displayColor: AppColors.textPrimary,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: scheme,
      textTheme: text,
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.surfaceHigh,
        contentTextStyle: TextStyle(color: AppColors.textPrimary),
        behavior: SnackBarBehavior.floating,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}