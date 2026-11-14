import 'package:flutter/material.dart';

/// UI configuration only: labels, display strings, and form presentation.
class UiLabel {
  const UiLabel(this.en, this.ar);
  final String en;
  final String ar;
  String of(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'ar' ? ar : en;
}

class ErpMetricSpec {
  const ErpMetricSpec(this.label, this.value, this.icon, {this.note});
  final UiLabel label;
  final String value;
  final IconData icon;
  final UiLabel? note;
}

class ErpFieldSpec {
  const ErpFieldSpec(this.label, {this.hint, this.wide = false});
  final UiLabel label;
  final UiLabel? hint;
  final bool wide;
}

class ErpRecordView {
  const ErpRecordView(
      {required this.id,
      required this.title,
      required this.subtitle,
      required this.cells,
      required this.status,
      this.tone = ErpStatusTone.success});
  final String id;
  final String title;
  final String subtitle;
  final List<String> cells;
  final UiLabel status;
  final ErpStatusTone tone;
}

enum ErpStatusTone { success, warning, info, danger }

class ErpViewSpec {
  const ErpViewSpec(
      {required this.id,
      required this.title,
      required this.subtitle,
      required this.icon,
      required this.action,
      required this.columns,
      required this.records,
      required this.metrics,
      required this.fields,
      this.filters = const [
        UiLabel('All', 'الكل'),
        UiLabel('Active', 'نشط'),
        UiLabel('Pending', 'قيد الانتظار')
      ]});
  final String id;
  final UiLabel title;
  final UiLabel subtitle;
  final IconData icon;
  final UiLabel action;
  final List<UiLabel> columns;
  final List<ErpRecordView> records;
  final List<ErpMetricSpec> metrics;
  final List<ErpFieldSpec> fields;
  final List<UiLabel> filters;
}
