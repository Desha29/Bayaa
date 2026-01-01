import 'package:flutter/material.dart';

class AppColors {

  // Bayaa Brand Colors
  static const Color primaryColor = Color(0xFF1E3A8A);    // Primary Blue (AppBar, Headers)
  static const Color primaryForeground = Colors.white;
  static const Color secondaryColor = Color(0xFF2563EB);  // Secondary Blue (Primary Buttons)
  
  static const Color accentColor = Color(0xFFF97316);     // Accent Orange (CTAs, Highlights)
  
  // Surfaces
  static const Color backgroundColor = Color(0xFFF8FAFC); // Very light grey (Slate 50)
  static const Color surfaceColor = Color(0xFFFFFFFF);    // Pure White
  
  // Status Colors
  static const Color errorColor = Color(0xFFEF4444);
  static const Color successColor = Color(0xFF22C55E);    // Green 500
  static const Color warningColor = Color(0xFFF59E0B);    // Amber 500

  // Text Colors
  static const Color mutedColor = Color(0xFF64748B);      // Slate 500
  static const Color borderColor = Color(0xFFE2E8F0);     // Slate 200
  static const Color textPrimary = Color(0xFF0F172A);     // Slate 900 (Rich Black)
  static const Color textSecondary = Color(0xFF334155);   // Slate 700

  // Legacy/Feature Specific (Mapped to new brand)
  static const Color accentGold = accentColor;            // Map legacy gold to Orange
  static const Color darkGold = Color(0xFFEA580C);        // Darker Orange
  
  static const Color kPrimaryBlue = primaryColor;
  static const Color kSuccessGreen = successColor;
  static const Color kDangerRed = errorColor;
  static const Color kDarkChip = Color(0xFF0B0B0B);
  static const Color kCardBackground = surfaceColor;
}
