import 'package:flutter/material.dart';

/// Presentation preference, kept only for this preview session.
class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('ar');
  Locale get locale => _locale;
  bool get isArabic => _locale.languageCode == 'ar';

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
  }

  void toggleLocale() => setLocale(Locale(isArabic ? 'en' : 'ar'));
}
