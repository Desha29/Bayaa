# Shared Flutter UI
### lib/shared/widgets/erp/erp_module_screen.dart

```dart
import 'package:flutter/material.dart';
import 'package:bayaa_pos/shared/theme/app_colors.dart';
import 'package:bayaa_pos/shared/layout/layout_tokens.dart';
import 'package:bayaa_pos/shared/feedback/preview_action.dart';
import 'package:bayaa_pos/shared/widgets/loading/skeleton.dart';
import 'erp_view_spec.dart';
import 'erp_metric_card.dart';
import 'erp_records_view.dart';
import 'erp_form_dialog.dart';

class ErpModuleScreen extends StatefulWidget {
  const ErpModuleScreen({super.key, required this.spec});
  final ErpViewSpec spec;
  @override
  State<ErpModuleScreen> createState() => _ErpModuleScreenState();
}

class _ErpModuleScreenState extends State<ErpModuleScreen> {
  String _query = '';
  String? _filter;
  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    final spec = widget.spec;
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    final query = _query.trim().toLowerCase();
    final records = spec.records.where((record) =>
      (_filter == null || record.status.en == _filter) &&
      (query.isEmpty || '${record.id} ${record.title} ${record.subtitle} ${record.cells.join(' ')}'
        .toLowerCase().contains(query))).toList();
    return SkeletonReveal(child: LayoutBuilder(builder: (context, size) => SingleChildScrollView(
      padding: LayoutTokens.pagePadding(size.maxWidth),
      child: Align(alignment: Alignment.topCenter, child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: LayoutTokens.contentMaxWidth),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Wrap(alignment: WrapAlignment.spaceBetween, crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 20, runSpacing: 16, children: [
              SizedBox(width: (size.maxWidth - 260).clamp(200, 680),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(spec.title.of(context), style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  const SizedBox(height: 6), Text(spec.subtitle.of(context), style: TextStyle(color: AppColors.mutedColor, fontSize: 12))])),
              FilledButton.icon(style: FilledButton.styleFrom(backgroundColor: AppColors.accentColor, foregroundColor: Colors.white),
                onPressed: () => showErpForm(context, spec), icon: const Icon(Icons.add, size: 18), label: Text(spec.action.of(context))),
            ]),
          const SizedBox(height: 24),
          AdaptiveColumns(minWidth: 230, children: spec.metrics.map((metric) => ErpMetricCard(spec: metric)).toList()),
          const SizedBox(height: 24),
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.surfaceColor,
            borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.borderColor)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Wrap(spacing: 16, runSpacing: 12, crossAxisAlignment: WrapCrossAlignment.center, children: [
                SizedBox(width: (size.maxWidth - 80).clamp(160, 420), child: TextField(onChanged: (value) => setState(() => _query = value),
                  decoration: InputDecoration(hintText: arabic ? 'ابحث بالاسم أو الرقم أو المرجع...' : 'Search name, number, or reference...',
                    prefixIcon: const Icon(Icons.search, size: 20), isDense: true))),
                OutlinedButton.icon(onPressed: () => showPreviewAction(context), icon: const Icon(Icons.file_download_outlined, size: 18),
                  label: Text(arabic ? 'تصدير' : 'Export')),
              ]), const SizedBox(height: 14),
              Wrap(spacing: 8, runSpacing: 8, children: [for (var i = 0; i < spec.filters.length; i++)
                ChoiceChip(label: Text(spec.filters[i].of(context)), selected: i == 0 ? _filter == null : _filter == spec.filters[i].en,
                  onSelected: (_) => setState(() => _filter = i == 0 ? null : spec.filters[i].en))]),
            ])),
          const SizedBox(height: 18),
          Text('${records.length} ${arabic ? 'سجل' : 'records'}', style: TextStyle(fontSize: 12, color: AppColors.mutedColor)),
          const SizedBox(height: 12), ErpRecordsView(spec: spec, records: records),
          const SizedBox(height: 24),
        ]))))));
  }
}

```

### lib/shared/widgets/erp/erp_metric_card.dart

```dart
import 'package:flutter/material.dart';
import 'package:bayaa_pos/shared/theme/app_colors.dart';
import 'erp_view_spec.dart';

class ErpMetricCard extends StatelessWidget {
  const ErpMetricCard({super.key, required this.spec});
  final ErpMetricSpec spec;
  @override
  Widget build(BuildContext context) => Builder(builder: (context) { Theme.of(context); return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: AppColors.surfaceColor,
      borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.borderColor)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Expanded(child: Text(spec.label.of(context),
        style: TextStyle(fontSize: 13, color: AppColors.mutedColor))),
        Container(padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(color: AppColors.secondaryColor.withValues(alpha: .08), borderRadius: BorderRadius.circular(10)),
          child: Icon(spec.icon, size: 19, color: AppColors.secondaryColor))]),
      const SizedBox(height: 18),
      Text(spec.value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
      if (spec.note != null) ...[const SizedBox(height: 5), Text(spec.note!.of(context),
        style: TextStyle(color: AppColors.mutedColor, fontSize: 11))],
    ])); });
}

```

### lib/shared/widgets/erp/erp_records_view.dart

```dart
import 'package:flutter/material.dart';
import 'package:bayaa_pos/shared/theme/app_colors.dart';
import 'erp_view_spec.dart';
import 'erp_status_badge.dart';
import 'erp_record_avatar.dart';
import 'erp_record_details_screen.dart';

class ErpRecordsView extends StatelessWidget {
  const ErpRecordsView({super.key, required this.spec, required this.records});
  final ErpViewSpec spec;
  final List<ErpRecordView> records;
  void _open(BuildContext context, ErpRecordView record) => Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => ErpRecordDetailsScreen(spec: spec, record: record)));
  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    if (records.isEmpty) return Padding(padding: const EdgeInsets.all(48), child: Center(child: Column(children: [
      Icon(Icons.search_off_rounded, size: 44, color: AppColors.mutedColor), const SizedBox(height: 16),
      Text(arabic ? 'لا توجد نتائج مطابقة' : 'No matching records', style: const TextStyle(fontWeight: FontWeight.w700)),
      const SizedBox(height: 8), Text(arabic ? 'جرّب تغيير البحث أو الفلاتر' : 'Try another search or filter',
        style: TextStyle(color: AppColors.mutedColor)),
    ])));
    return LayoutBuilder(builder: (context, size) {
      if (size.maxWidth < 900 || MediaQuery.textScalerOf(context).scale(1) > 1.4) {
        return Column(children: records.map((record) => Padding(padding: const EdgeInsets.only(bottom: 12),
          child: Material(color: AppColors.surfaceColor, borderRadius: BorderRadius.circular(14),
            child: InkWell(borderRadius: BorderRadius.circular(14), onTap: () => _open(context, record),
              child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderColor), borderRadius: BorderRadius.circular(14)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [ErpRecordAvatar(tag: '${spec.id}-${record.id}', icon: spec.icon), const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(record.title, style: const TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 4),
                      Text(record.id, style: TextStyle(fontSize: 11, color: AppColors.mutedColor))])),
                    const SizedBox(width: 8), Icon(Icons.chevron_right, textDirection: Directionality.of(context), color: AppColors.mutedColor)]),
                  const SizedBox(height: 16),
                  Wrap(spacing: 24, runSpacing: 14, children: [
                    for (var i = 1; i < spec.columns.length && i < record.cells.length; i++)
                      SizedBox(width: (size.maxWidth - 64) < 280 ? double.infinity : (size.maxWidth - 80) / 2,
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(spec.columns[i].of(context), style: TextStyle(fontSize: 11, color: AppColors.mutedColor)),
                          const SizedBox(height: 4), Text(record.cells[i], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))])),
                  ]), const SizedBox(height: 14), ErpStatusBadge(label: record.status.of(context), tone: record.tone),
                ])))))).toList());
      }
      return Container(decoration: BoxDecoration(color: AppColors.surfaceColor, border: Border.all(color: AppColors.borderColor),
          borderRadius: BorderRadius.circular(14)),
        child: ClipRRect(borderRadius: BorderRadius.circular(14), child: SingleChildScrollView(scrollDirection: Axis.horizontal,
          child: ConstrainedBox(constraints: BoxConstraints(minWidth: size.maxWidth), child: DataTable(
            headingRowColor: WidgetStatePropertyAll(AppColors.backgroundColor), dataRowMinHeight: 72, dataRowMaxHeight: 86,
            columnSpacing: 28, showCheckboxColumn: false,
            columns: [...spec.columns.map((column) => DataColumn(label: Text(column.of(context)))),
              DataColumn(label: Text(arabic ? 'الحالة' : 'Status')), const DataColumn(label: SizedBox(width: 24))],
            rows: records.map((record) => DataRow(onSelectChanged: (_) => _open(context, record), cells: [
              for (var i = 0; i < spec.columns.length; i++) DataCell(i == 0
                ? Row(mainAxisSize: MainAxisSize.min, children: [ErpRecordAvatar(tag: '${spec.id}-${record.id}', icon: spec.icon, size: 36),
                  const SizedBox(width: 10), Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text(record.cells[i], style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 3), Text(record.id, style: TextStyle(fontSize: 10, color: AppColors.mutedColor))])])
                : Text(record.cells.length > i ? record.cells[i] : '—')),
              DataCell(ErpStatusBadge(label: record.status.of(context), tone: record.tone)),
              DataCell(IconButton(tooltip: arabic ? 'عرض التفاصيل' : 'View details', icon: const Icon(Icons.arrow_forward, size: 18),
                onPressed: () => _open(context, record))),
            ])).toList(),
          )))));
    });
  }
}

```

### lib/shared/widgets/erp/erp_form_dialog.dart

```dart
import 'package:flutter/material.dart';
import 'package:bayaa_pos/shared/feedback/preview_action.dart';
import 'package:bayaa_pos/shared/theme/app_colors.dart';
import 'package:bayaa_pos/shared/layout/layout_tokens.dart';
import 'erp_view_spec.dart';

Future<void> showErpForm(BuildContext context, ErpViewSpec spec) => showDialog<void>(
  context: context, builder: (_) => ErpFormDialog(spec: spec));

class ErpFormDialog extends StatelessWidget {
  const ErpFormDialog({super.key, required this.spec});
  final ErpViewSpec spec;
  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    final size = MediaQuery.sizeOf(context);
    return Dialog(insetPadding: EdgeInsets.all(size.width < 600 ? 12 : 32),
      backgroundColor: AppColors.surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(constraints: BoxConstraints(maxWidth: 760, maxHeight: size.height * .9),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(padding: const EdgeInsets.all(20), child: Row(children: [
            Icon(spec.icon, color: AppColors.secondaryColor), const SizedBox(width: 12),
            Expanded(child: Text(spec.action.of(context), style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700))),
            IconButton(tooltip: arabic ? 'إغلاق' : 'Close', onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close))])),
          Divider(height: 1, color: AppColors.borderColor),
          Flexible(child: SingleChildScrollView(padding: const EdgeInsets.all(20),
            child: AdaptiveColumns(minWidth: 280, maxColumns: 2, children: spec.fields.map((field) =>
              TextFormField(minLines: field.wide ? 3 : 1, maxLines: field.wide ? 4 : 1,
                decoration: InputDecoration(labelText: field.label.of(context), hintText: field.hint?.of(context)))).toList()))),
          Padding(padding: const EdgeInsets.all(20), child: Wrap(spacing: 12, runSpacing: 8,
            alignment: WrapAlignment.end, children: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text(arabic ? 'إلغاء' : 'Cancel')),
              FilledButton.icon(onPressed: () => showPreviewAction(context), icon: const Icon(Icons.check, size: 18),
                label: Text(arabic ? 'حفظ' : 'Save'))])),
        ])));
  }
}

```
