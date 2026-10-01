import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.primaryBackground,
      primaryColor: AppColors.textPrimary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.textPrimary,
        secondary: AppColors.textSecondary,
        surface: AppColors.primaryBackground,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.textPrimary),
        bodyMedium: TextStyle(color: AppColors.textSecondary),
        titleLarge: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryBackground,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
    );
  }
}
