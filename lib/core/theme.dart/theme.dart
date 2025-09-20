import 'package:flutter/material.dart';
import 'appPalette.dart';

class AppTheme {
  // Light Theme
  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppPalette.primary,
    scaffoldBackgroundColor: AppPalette.background,
    cardColor: AppPalette.card,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: AppPalette.textPrimary,
      elevation: 0,
      centerTitle: true,
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppPalette.textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
        color: AppPalette.textSecondary,
      ),
    ),
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: AppPalette.primary,
      secondary: AppPalette.secondary,
      error: AppPalette.error,
    ),
  );

  // Dark Theme
  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppDarkPalette.primary,
    scaffoldBackgroundColor: AppDarkPalette.background,
    cardColor: AppDarkPalette.accent,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppDarkPalette.primary,
      foregroundColor: AppDarkPalette.textPrimary,
      elevation: 0,
      centerTitle: true,
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppDarkPalette.textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
        color: AppDarkPalette.textSecondary,
      ),
    ),
    colorScheme: ColorScheme.dark(
      primary: AppDarkPalette.primary,
      secondary: AppDarkPalette.secondary,
      error: Colors.redAccent,
    ),
  );
}
