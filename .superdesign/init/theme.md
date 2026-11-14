# Bayaa design system

Preserve the existing assets and visual identity. Flutter Material 3.
Primary #1E3A8A; secondary #2563EB; accent #F97316; sidebar #182E45; background #F8FAFC; surface #FFFFFF.
Text #0F172A/#334155; muted #64748B; border #E2E8F0; success #22C55E; warning #F59E0B; error #EF4444.
Existing Cairo font declaration and bundled Amiri assets remain. Radius 12-16px; spacing 8/12/16/20/24/32.
Breakpoints: compact <600, medium 600-1023, desktop >=1024, wide >=1440. RTL Arabic and LTR English.
All operational actions preview-only. Static sample content. No backend.
### lib/shared/theme/app_colors.dart

```dart
import 'package:flutter/material.dart';
import 'theme_controller.dart';

abstract final class AppColors {
  static Color get primaryColor => ThemeController.instance.color('primary');
  static Color get secondaryColor => ThemeController.instance.color('secondary');
  static Color get accentColor => ThemeController.instance.color('accent');
  static Color get sidebarColor => ThemeController.instance.color('sidebar');
  static Color get backgroundColor => ThemeController.instance.color('background');
  static Color get surfaceColor => ThemeController.instance.color('surface');
  static Color get primaryForeground => ThemeData.estimateBrightnessForColor(primaryColor) == Brightness.dark ? Colors.white : const Color(0xFF0F172A);
  static const errorColor = Color(0xFFEF4444);
  static const successColor = Color(0xFF22C55E);
  static const warningColor = Color(0xFFF59E0B);
  static const mutedColor = Color(0xFF64748B);
  static const borderColor = Color(0xFFE2E8F0);
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF334155);
  static Color get accentGold => accentColor;
  static const darkGold = Color(0xFFEA580C);
  static Color get kPrimaryBlue => primaryColor;
  static const kSuccessGreen = successColor;
  static const kDangerRed = errorColor;
  static const kDarkChip = Color(0xFF0B0B0B);
  static Color get kCardBackground => surfaceColor;
}

```
### lib/shared/theme/app_theme.dart

```dart
import 'package:flutter/material.dart';

import 'package:bayaa_pos/shared/theme/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: AppColors.primaryColor,
        onPrimary: AppColors.primaryForeground,
        secondary: AppColors.accentColor, // Orange for Accents/FABs
        onSecondary: Colors.white,
        surface: AppColors.surfaceColor,
        onSurface: AppColors.textPrimary,
        error: AppColors.errorColor,
        onError: Colors.white,
      ),
      fontFamily: 'Cairo', 
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
        titleSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppColors.textSecondary,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: AppColors.mutedColor,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 1, // Cleaner, flatter look
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: AppColors.surfaceColor,
        surfaceTintColor: Colors.transparent, // Avoid tint on M3
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondaryColor, // Per user spec: Secondary Blue for Buttons
          foregroundColor: Colors.white,
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.secondaryColor,
          side: const BorderSide(color: AppColors.borderColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.secondaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primaryColor, // Deep Blue Headers
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          fontFamily: 'Cairo',
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
    );
  }
}

```
