import 'package:flutter/material.dart';
import 'theme_controller.dart';

abstract final class AppColors {
  static Color get primaryColor => ThemeController.instance.color('primary');
  static Color get secondaryColor =>
      ThemeController.instance.color('secondary');
  static Color get accentColor => ThemeController.instance.color('accent');
  static Color get sidebarColor => ThemeController.instance.color('sidebar');
  static Color get backgroundColor =>
      ThemeController.instance.color('background');
  static Color get surfaceColor => ThemeController.instance.color('surface');
  static Color get primaryForeground =>
      ThemeData.estimateBrightnessForColor(primaryColor) == Brightness.dark
          ? Colors.white
          : const Color(0xFF0F172A);
  static const errorColor = Color(0xFFEF4444);
  static const successColor = Color(0xFF22C55E);
  static const warningColor = Color(0xFFF59E0B);
  static Color get mutedColor =>
      ThemeData.estimateBrightnessForColor(surfaceColor) == Brightness.dark
          ? const Color(0xFF94A3B8)
          : const Color(0xFF64748B);
  static Color get borderColor =>
      ThemeData.estimateBrightnessForColor(surfaceColor) == Brightness.dark
          ? const Color(0xFF475569)
          : const Color(0xFFE2E8F0);
  static Color get textPrimary =>
      ThemeData.estimateBrightnessForColor(surfaceColor) == Brightness.dark
          ? const Color(0xFFF8FAFC)
          : const Color(0xFF0F172A);
  static Color get textSecondary =>
      ThemeData.estimateBrightnessForColor(surfaceColor) == Brightness.dark
          ? const Color(0xFFCBD5E1)
          : const Color(0xFF334155);
  static Color get sidebarForeground =>
      ThemeData.estimateBrightnessForColor(sidebarColor) == Brightness.dark
          ? Colors.white
          : const Color(0xFF0F172A);
  static Color get accentGold => accentColor;
  static Color get secondaryForeground =>
      ThemeData.estimateBrightnessForColor(secondaryColor) == Brightness.dark
          ? Colors.white
          : const Color(0xFF0F172A);
  static Color get accentForeground => accentColor == const Color(0xFFF97316)
      ? Colors.white
      : (ThemeData.estimateBrightnessForColor(accentColor) == Brightness.dark
          ? Colors.white
          : const Color(0xFF0F172A));
  static Color get darkGold => accentColor == const Color(0xFFF97316)
      ? const Color(0xFFEA580C)
      : Color.lerp(accentColor, Colors.black, .15)!;
  static Color get kPrimaryBlue => primaryColor;
  static const kSuccessGreen = successColor;
  static const kDangerRed = errorColor;
  static const kDarkChip = Color(0xFF0B0B0B);
  static Color get kCardBackground => surfaceColor;
}
