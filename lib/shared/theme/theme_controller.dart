import 'package:flutter/material.dart';

/// Appearance state only. No preference storage or business data.
class ThemeController extends ChangeNotifier {
  ThemeController._();
  static final instance = ThemeController._();

  static const defaults = <String, Color>{
    'primary': Color(0xFF1E3A8A),
    'secondary': Color(0xFF2563EB),
    'accent': Color(0xFFF97316),
    'sidebar': Color(0xFF182E45),
    'background': Color(0xFFF8FAFC),
    'surface': Color(0xFFFFFFFF),
  };
  final _colors = Map<String, Color>.from(defaults);
  Color color(String role) => _colors[role] ?? defaults['primary']!;
  void update(String role, Color value) {
    if (!defaults.containsKey(role) || _colors[role] == value) return;
    _colors[role] = value;
    notifyListeners();
  }

  void reset() {
    _colors
      ..clear()
      ..addAll(defaults);
    notifyListeners();
  }
}
