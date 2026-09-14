import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Base surfaces — deep space navy.
  static const Color background = Color(0xFF070A14);
  static const Color backgroundAlt = Color(0xFF101830);
  static const Color surface = Color(0xFF17203B);
  static const Color surfaceHigh = Color(0xFF212D52);

  // Brand — electric blue and silver.
  static const Color accent = Color(0xFF4D9FFF);
  static const Color accentSoft = Color(0xFF9CC8FF);
  static const Color accentDeep = Color(0xFF2A5BD7);
  static const Color silver = Color(0xFFE9EFF9);

  // Text.
  static const Color textPrimary = Color(0xFFF2F6FD);
  static const Color textSecondary = Color(0xFF97A2BE);

  // On the white Google button.
  static const Color onLightSurface = Color(0xFF16203A);

  static const Color error = Color(0xFFFF7590);
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