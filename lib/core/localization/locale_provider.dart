import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import '../data/services/persistence_initializer.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('ar');

  Locale get locale => _locale;
  bool get isArabic => _locale.languageCode == 'ar';

  LocaleProvider() {
    _loadPersistedLocale();
  }

  String _getFilePath() {
    if (PersistenceInitializer.persistenceManager != null) {
      final dataRoot = PersistenceInitializer.persistenceManager!.pathResolver.dataRootPath;
      return path.join(dataRoot, 'language.txt');
    }
    return '';
  }

  Future<void> _loadPersistedLocale() async {
    try {
      final filePath = _getFilePath();
      if (filePath.isNotEmpty) {
        final file = File(filePath);
        if (await file.exists()) {
          final lang = (await file.readAsString()).trim();
          if (lang == 'en' || lang == 'ar') {
            _locale = Locale(lang);
            notifyListeners();
          }
        }
      }
    } catch (e) {
      // Silently ignore load errors
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();

    try {
      final filePath = _getFilePath();
      if (filePath.isNotEmpty) {
        final file = File(filePath);
        await file.writeAsString(locale.languageCode);
      }
    } catch (e) {
      // Silently ignore save errors
    }
  }

  void toggleLocale() {
    if (isArabic) {
      setLocale(const Locale('en'));
    } else {
      setLocale(const Locale('ar'));
    }
  }
}
