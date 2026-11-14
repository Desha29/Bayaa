import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExpenseLabels {
  const ExpenseLabels(this.arabic);
  final bool arabic;
  factory ExpenseLabels.of(BuildContext context) =>
      ExpenseLabels(Localizations.localeOf(context).languageCode == 'ar');

  String text(String ar, String en) => arabic ? ar : en;
  String get currency => arabic ? 'ج.م' : 'EGP';
  String money(double amount) =>
      '${NumberFormat('#,##0.00', arabic ? 'ar' : 'en').format(amount)} $currency';
  String date(DateTime date) =>
      DateFormat('dd MMM yyyy', arabic ? 'ar' : 'en').format(date);

  static const categories = [
    'operations',
    'rent',
    'utilities',
    'maintenance',
    'supplies',
    'other'
  ];
  static String categoryKey(String key) =>
      const {
        'تشغيل': 'operations',
        'إيجار': 'rent',
        'مرافق': 'utilities',
        'صيانة': 'maintenance',
        'مشتريات': 'supplies',
        'أخرى': 'other',
        'General': 'other',
      }[key] ??
      key;

  String category(String key) {
    const ar = {
      'operations': 'تشغيل',
      'rent': 'إيجار',
      'utilities': 'مرافق',
      'maintenance': 'صيانة',
      'supplies': 'مشتريات',
      'other': 'أخرى'
    };
    const en = {
      'operations': 'Operations',
      'rent': 'Rent',
      'utilities': 'Utilities',
      'maintenance': 'Maintenance',
      'supplies': 'Supplies',
      'other': 'Other'
    };
    return (arabic ? ar : en)[categoryKey(key)] ?? key;
  }
}
