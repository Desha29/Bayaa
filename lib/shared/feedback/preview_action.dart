import 'package:flutter/material.dart';

/// Shared feedback for controls whose real operations were removed.
void showPreviewAction(BuildContext context) {
  final arabic = Localizations.localeOf(context).languageCode == 'ar';
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(arabic
        ? 'معاينة الواجهة فقط — بيانات تجريبية، لن يتم حفظ أي تغييرات.'
        : 'UI preview only — sample data; changes are not saved.'),
    duration: const Duration(seconds: 2),
  ));
}
