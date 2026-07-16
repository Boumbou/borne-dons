/// theme.dart
///
/// This file defines the Shadcn-inspired minimalist visual theme for the Flutter application.
/// It overrides standard Material elevation, introduces 1px slate borders, sharp corners,
/// and uses a high-contrast neutral slate color palette for desktop and tablet screens.
import 'package:flutter/material.dart';
import 'constants.dart';

class AppTheme {
  /// Returns a clean, high-contrast light theme aligned with Shadcn UI aesthetics.
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppConstants.primary,
        onPrimary: AppConstants.primaryForeground,
        secondary: AppConstants.secondary,
        onSecondary: AppConstants.secondaryForeground,
        error: AppConstants.error,
        onError: Colors.white,
        surface: AppConstants.card,
        onSurface: AppConstants.cardForeground,
      ),
      scaffoldBackgroundColor: Colors.transparent, // Let repeating pattern background show through
      
      // Card Theme (No elevation, thin 1px border, 8px rounded corners)
      cardTheme: CardThemeData(
        color: AppConstants.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppConstants.border, width: 1.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      
      // Dialog Theme (Flat, sleek, 12px corners, thin border)
      dialogTheme: DialogThemeData(
        backgroundColor: AppConstants.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppConstants.border, width: 1.0),
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      
      // Button Theme (Flat, high contrast, sharp or slightly rounded)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppConstants.primary,
          foregroundColor: AppConstants.primaryForeground,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.0),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14.0,
          ),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.hovered)) {
              return AppConstants.primary.withOpacity(0.08);
            }
            return null;
          }),
        ),
      ),
      
      // Text Button Style (Sleek minimalist style)
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppConstants.foreground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.0),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14.0,
          ),
        ),
      ),

      // Outlined Button Style (Slate border, subtle background on hover)
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppConstants.foreground,
          backgroundColor: Colors.transparent,
          side: const BorderSide(color: AppConstants.border, width: 1.0),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.0),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14.0,
          ),
        ),
      ),

      // Input Decoration Theme (Border slate-200, focuses slate-900, elegant padding)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.0),
          borderSide: const BorderSide(color: AppConstants.border, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.0),
          borderSide: const BorderSide(color: AppConstants.border, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.0),
          borderSide: const BorderSide(color: AppConstants.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.0),
          borderSide: const BorderSide(color: AppConstants.error, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.0),
          borderSide: const BorderSide(color: AppConstants.error, width: 1.5),
        ),
        hintStyle: const TextStyle(
          color: AppConstants.mutedForeground,
          fontSize: 14.0,
        ),
        labelStyle: const TextStyle(
          color: AppConstants.mutedForeground,
          fontSize: 14.0,
        ),
      ),
      
      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -1.0, color: AppConstants.foreground),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -0.5, color: AppConstants.foreground),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppConstants.foreground),
        bodyLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: AppConstants.foreground),
        bodyMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: AppConstants.mutedForeground),
      ),
    );
  }
}
