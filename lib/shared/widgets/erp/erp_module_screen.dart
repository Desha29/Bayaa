import 'package:bayaa_pos/shared/widgets/charts/feature_insights_panel.dart';
import 'package:bayaa_pos/preview/branch_preview_controller.dart';
import 'package:intl/intl.dart';
import 'package:bayaa_pos/shared/widgets/charts/feature_insights_spec.dart';
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
  const ErpModuleScreen({super.key, required this.spec, this.insights});
  final ErpViewSpec spec;
  final FeatureInsightsSpec? insights;
  @override
  State<ErpModuleScreen> createState() => _ErpModuleScreenState();
}

class _ErpModuleScreenState extends State<ErpModuleScreen> {
  final _searchController = TextEditingController();
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _query = '';
  String? _filter;
  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    final spec = widget.spec;
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    final query = _query.trim().toLowerCase();
    final branch = BranchPreviewController.instance;
    final branchRecords = branch.scope(spec.records, (record) => record.id);
    final metrics = branch.isAll
        ? spec.metrics
        : spec.metrics
            .map((metric) => ErpMetricSpec(
                metric.label,
                _branchMetricValue(metric.value, branch.previewFactor),
                metric.icon,
                note: const UiLabel('Branch example', 'مثال الفرع')))
            .toList();
    final records = branchRecords
        .where((record) =>
            (_filter == null || record.status.en == _filter) &&
            (query.isEmpty ||
                '${record.id} ${record.title} ${record.subtitle} ${record.cells.join(' ')}'
                    .toLowerCase()
                    .contains(query)))
        .toList();
    final header =
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(spec.title.of(context),
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary)),
      const SizedBox(height: 5),
      Text(spec.subtitle.of(context),
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              height: 1.6,
              color: AppColors.mutedColor)),
    ]);
    final create = FilledButton.icon(
        style: FilledButton.styleFrom(
            backgroundColor: AppColors.accentColor,
            foregroundColor: AppColors.accentForeground,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10))),
        onPressed: () => showErpForm(context, spec),
        icon: const Icon(Icons.add, size: 18),
        label: Text(spec.action.of(context)));
    return SkeletonReveal(
        child: LayoutBuilder(
            builder: (context, size) => SingleChildScrollView(
                padding: LayoutTokens.pagePadding(size.maxWidth),
                child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                        constraints: const BoxConstraints(
                            maxWidth: LayoutTokens.contentMaxWidth),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (size.maxWidth >= 650)
                                Row(children: [
                                  Expanded(child: header),
                                  const SizedBox(width: 24),
                                  create
                                ])
                              else
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      header,
                                      const SizedBox(height: 14),
                                      create
                                    ]),
                              const SizedBox(height: 20),
                              AdaptiveColumns(
                                  minWidth: 220,
                                  children: metrics
                                      .map((metric) =>
                                          ErpMetricCard(spec: metric))
                                      .toList()),
                              if (widget.insights != null) ...[
                                const SizedBox(height: 20),
                                FeatureInsightsPanel(spec: widget.insights!)
                              ],
                              const SizedBox(height: 20),
                              Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                      color: AppColors.surfaceColor,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                          color: AppColors.borderColor)),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        LayoutBuilder(
                                            builder: (context, toolbar) {
                                          final search = TextField(
                                              controller: _searchController,
                                              onChanged: (value) => setState(
                                                  () => _query = value),
                                              decoration: InputDecoration(
                                                  hintText: arabic
                                                      ? 'ابحث بالاسم أو الرقم أو المرجع...'
                                                      : 'Search name, number, or reference...',
                                                  filled: true,
                                                  fillColor:
                                                      AppColors.backgroundColor,
                                                  prefixIcon: const Icon(
                                                      Icons.search,
                                                      size: 19),
                                                  suffixIcon: _query.isEmpty
                                                      ? null
                                                      : IconButton(
                                                          tooltip: arabic
                                                              ? 'مسح البحث'
                                                              : 'Clear search',
                                                          icon: const Icon(
                                                              Icons.close,
                                                              size: 17),
                                                          onPressed: () =>
                                                              setState(() {
                                                                _searchController
                                                                    .clear();
                                                                _query = '';
                                                              })),
                                                  isDense: true));
                                          final export = OutlinedButton.icon(
                                              onPressed: () =>
                                                  showPreviewAction(context),
                                              icon: const Icon(
                                                  Icons.file_download_outlined,
                                                  size: 17),
                                              label: Text(
                                                  arabic ? 'تصدير' : 'Export'));
                                          if (toolbar.maxWidth < 480) {
                                            return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                children: [
                                                  search,
                                                  const SizedBox(height: 10),
                                                  Align(
                                                      alignment:
                                                          AlignmentDirectional
                                                              .centerEnd,
                                                      child: export)
                                                ]);
                                          }
                                          return Row(children: [
                                            Expanded(child: search),
                                            const SizedBox(width: 12),
                                            export
                                          ]);
                                        }),
                                        const SizedBox(height: 14),
                                        Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            crossAxisAlignment:
                                                WrapCrossAlignment.center,
                                            children: [
                                              for (var i = 0; i < spec.filters.length; i++)
                                                ChoiceChip(
                                                    showCheckmark: false,
                                                    label: Text(spec.filters[i].of(context),
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 12)),
                                                    selected: i == 0
                                                        ? _filter == null
                                                        : _filter ==
                                                            spec.filters[i].en,
                                                    selectedColor:
                                                        AppColors.primaryColor,
                                                    labelStyle: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: (i == 0 ? _filter == null : _filter == spec.filters[i].en)
                                                            ? AppColors
                                                                .primaryForeground
                                                            : AppColors
                                                                .textSecondary),
                                                    onSelected: (_) => setState(
                                                        () => _filter = i == 0
                                                            ? null
                                                            : spec.filters[i].en)),
                                              if (_query.isNotEmpty ||
                                                  _filter != null)
                                                TextButton.icon(
                                                    onPressed: () =>
                                                        setState(() {
                                                          _searchController
                                                              .clear();
                                                          _query = '';
                                                          _filter = null;
                                                        }),
                                                    icon: const Icon(
                                                        Icons.restart_alt,
                                                        size: 16),
                                                    label: Text(arabic
                                                        ? 'إعادة تعيين'
                                                        : 'Reset')),
                                            ]),
                                      ])),
                              const SizedBox(height: 18),
                              Row(children: [
                                Icon(spec.icon,
                                    size: 17, color: AppColors.primaryColor),
                                const SizedBox(width: 8),
                                Expanded(
                                    child: Text(
                                        '${records.length} ${arabic ? 'سجل' : 'records'}${branch.isAll ? '' : ' · ${branch.label(arabic)}'}',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.mutedColor)))
                              ]),
                              ErpRecordsView(spec: spec, records: records),
                              const SizedBox(height: 24),
                            ]))))));
  }

  /// Display fixtures only; financial totals are not calculated or persisted.
  String _branchMetricValue(String value, double factor) {
    final match = RegExp(r'[\d,]+(?:\.\d+)?').firstMatch(value);
    if (match == null) return value;
    final original = match.group(0)!;
    final amount = double.tryParse(original.replaceAll(',', ''));
    if (amount == null) return value;
    final number =
        NumberFormat(original.contains('.') ? '#,##0.00' : '#,##0', 'en')
            .format(amount * factor);
    return value.replaceRange(match.start, match.end, number);
  }
}
