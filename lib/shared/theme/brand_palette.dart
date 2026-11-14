import 'package:flutter/material.dart';
import 'theme_controller.dart';

/// Makes every brand role part of inherited ThemeData, including navigation.
/// Widgets depending on Theme.of rebuild even when only the sidebar changes.
class BrandPalette extends ThemeExtension<BrandPalette> {
  const BrandPalette(
      {required this.primary,
      required this.secondary,
      required this.accent,
      required this.navigation,
      required this.background,
      required this.surface});
  factory BrandPalette.current() {
    final controller = ThemeController.instance;
    return BrandPalette(
        primary: controller.color('primary'),
        secondary: controller.color('secondary'),
        accent: controller.color('accent'),
        navigation: controller.color('sidebar'),
        background: controller.color('background'),
        surface: controller.color('surface'));
  }
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color navigation;
  final Color background;
  final Color surface;
  @override
  BrandPalette copyWith(
          {Color? primary,
          Color? secondary,
          Color? accent,
          Color? navigation,
          Color? background,
          Color? surface}) =>
      BrandPalette(
          primary: primary ?? this.primary,
          secondary: secondary ?? this.secondary,
          accent: accent ?? this.accent,
          navigation: navigation ?? this.navigation,
          background: background ?? this.background,
          surface: surface ?? this.surface);
  @override
  BrandPalette lerp(covariant BrandPalette? other, double t) {
    if (other == null) return this;
    return BrandPalette(
        primary: Color.lerp(primary, other.primary, t)!,
        secondary: Color.lerp(secondary, other.secondary, t)!,
        accent: Color.lerp(accent, other.accent, t)!,
        navigation: Color.lerp(navigation, other.navigation, t)!,
        background: Color.lerp(background, other.background, t)!,
        surface: Color.lerp(surface, other.surface, t)!);
  }

  @override
  bool operator ==(Object other) =>
      other is BrandPalette &&
      primary == other.primary &&
      secondary == other.secondary &&
      accent == other.accent &&
      navigation == other.navigation &&
      background == other.background &&
      surface == other.surface;
  @override
  int get hashCode =>
      Object.hash(primary, secondary, accent, navigation, background, surface);
}
