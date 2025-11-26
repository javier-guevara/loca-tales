import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'color_palette.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: ColorPalette.primary,
        secondary: ColorPalette.secondary,
        surface: ColorPalette.surface,
        error: ColorPalette.error,
        onPrimary: ColorPalette.textLight,
        onSecondary: ColorPalette.textLight,
        onSurface: ColorPalette.textPrimary,
        onError: ColorPalette.textLight,
      ),
      scaffoldBackgroundColor: ColorPalette.background,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: ColorPalette.surface,
        foregroundColor: ColorPalette.textPrimary,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: ColorPalette.surface,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: ColorPalette.textPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: ColorPalette.textPrimary,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: ColorPalette.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: ColorPalette.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: ColorPalette.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: ColorPalette.textSecondary,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: ColorPalette.primaryLight,
        secondary: ColorPalette.secondaryLight,
        surface: ColorPalette.surfaceDark,
        error: ColorPalette.error,
        onPrimary: ColorPalette.textPrimary,
        onSecondary: ColorPalette.textPrimary,
        onSurface: ColorPalette.textLight,
        onError: ColorPalette.textLight,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: ColorPalette.textLight,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: ColorPalette.surfaceDark,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: ColorPalette.surfaceDark,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: ColorPalette.textLight,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: ColorPalette.textLight,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: ColorPalette.textLight,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: ColorPalette.textLight,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: ColorPalette.textLight,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: ColorPalette.textSecondary,
        ),
      ),
    );
  }
}

