import 'package:flutter/material.dart';
import 'package:bayaa_pos/shared/theme/app_colors.dart';
import 'package:bayaa_pos/shared/feedback/preview_action.dart';
import 'package:bayaa_pos/shared/widgets/loading/skeleton.dart';
import 'package:bayaa_pos/shared/widgets/workspace/workspace_summary.dart';
import 'package:bayaa_pos/preview/sources/expense_preview_source.dart';
import '../models/expense_view_data.dart';
import '../widgets/expense_distribution.dart';
import '../widgets/expense_form_dialog.dart';
import '../widgets/expense_labels.dart';
import '../widgets/expense_records.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});
  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final _source = ExpensePreviewSource();
  late Future<List<ExpenseViewData>> _expenses = _source.getExpenses();
  final _search = TextEditingController();
  final _searchFocus = FocusNode();
  String _category = 'all';
  String _period = 'all';

  @override
  void dispose() {
    _search.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _reset() => setState(() {
        _search.clear();
        _category = 'all';
        _period = 'all';
      });

  List<ExpenseViewData> _filter(
      List<ExpenseViewData> records, ExpenseLabels labels) {
    final query = _search.text.trim().toLowerCase();
    final now = DateTime.now();
    return records.where((record) {
      final today = DateUtils.isSameDay(record.date, now);
      final thisMonth =
          record.date.month == now.month && record.date.year == now.year;
      return (_category == 'all' ||
              ExpenseLabels.categoryKey(record.category) == _category) &&
          (_period == 'all' || (_period == 'today' ? today : thisMonth)) &&
          (query.isEmpty ||
              '${record.title} ${record.id} ${record.notes ?? ''} ${labels.category(record.category)}'
                  .toLowerCase()
                  .contains(query));
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    final labels = ExpenseLabels.of(context);
    return FutureBuilder<List<ExpenseViewData>>(
        future: _expenses,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Padding(
                padding: EdgeInsets.all(20), child: SkeletonList());
          }
          if (snapshot.hasError) {
            return Center(
                child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.error_outline_rounded, size: 36),
                      const SizedBox(height: 12),
                      Text(labels.text(
                          'تعذر عرض المصروفات', 'Unable to display expenses')),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                          onPressed: () =>
                              setState(() => _expenses = _source.getExpenses()),
                          icon: const Icon(Icons.refresh),
                          label:
                              Text(labels.text('إعادة المحاولة', 'Try again'))),
                    ])));
          }
          final all = snapshot.data ?? [];
          final records = _filter(all, labels);
          final total = all.fold<double>(0, (sum, item) => sum + item.amount);
          final now = DateTime.now();
          final month = all
              .where((item) =>
                  item.date.year == now.year && item.date.month == now.month)
              .fold<double>(0, (sum, item) => sum + item.amount);
          final average = all.isEmpty ? 0.0 : total / all.length;
          return LayoutBuilder(
              builder: (context, size) => ListView(
                    padding: EdgeInsets.all(size.maxWidth < 600 ? 14 : 24),
                    children: [
                      _header(context, labels, size.maxWidth),
                      const SizedBox(height: 20),
                      WorkspaceSummary(metrics: [
                        WorkspaceMetric(
                            labels.text('إجمالي المصروفات', 'Total expenses'),
                            labels.money(total),
                            Icons.account_balance_wallet_outlined,
                            color: AppColors.primaryColor),
                        WorkspaceMetric(
                            labels.text('مصروفات الشهر', 'This month'),
                            labels.money(month),
                            Icons.calendar_month_outlined,
                            color: AppColors.secondaryColor),
                        WorkspaceMetric(
                            labels.text('عدد المصروفات', 'Expense count'),
                            '${all.length}',
                            Icons.receipt_long_outlined,
                            color: AppColors.accentColor),
                        WorkspaceMetric(
                            labels.text('متوسط المصروف', 'Average expense'),
                            labels.money(average),
                            Icons.query_stats_outlined,
                            color: AppColors.primaryColor),
                      ]),
                      const SizedBox(height: 20),
                      _filters(labels),
                      const SizedBox(height: 24),
                      ExpenseRecords(records: records, onReset: _reset),
                      const SizedBox(height: 24),
                      ExpenseDistribution(records: records),
                      const SizedBox(height: 8),
                    ],
                  ));
        });
  }

  Widget _header(BuildContext context, ExpenseLabels labels, double width) {
    final title =
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(labels.text('المصروفات التشغيلية', 'Operating expenses'),
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary)),
      const SizedBox(height: 5),
      Text(
          labels.text('راجع المصروفات ونظّم تكاليف المتجر.',
              'Review spending and organize store costs.'),
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: AppColors.mutedColor)),
    ]);
    final actions = Wrap(spacing: 10, runSpacing: 10, children: [
      OutlinedButton.icon(
          onPressed: () => showPreviewAction(context),
          icon: const Icon(Icons.file_download_outlined, size: 18),
          label: Text(labels.text('تصدير', 'Export'))),
      FilledButton.icon(
          onPressed: () => showExpenseForm(context),
          style: FilledButton.styleFrom(
              backgroundColor: AppColors.accentColor,
              foregroundColor: AppColors.accentForeground),
          icon: const Icon(Icons.add_rounded, size: 18),
          label: Text(labels.text('إضافة مصروف', 'Add expense'))),
    ]);
    if (width < 760) {
      return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [title, const SizedBox(height: 16), actions]);
    }
    return Row(
        children: [Expanded(child: title), const SizedBox(width: 20), actions]);
  }

  Widget _filters(ExpenseLabels labels) => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderColor)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        LayoutBuilder(builder: (context, size) {
          final search = TextField(
              controller: _search,
              focusNode: _searchFocus,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                  hintText: labels.text('ابحث بوصف المصروف أو المرجع...',
                      'Search description or reference...'),
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: _search.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: labels.text('مسح البحث', 'Clear search'),
                          onPressed: () {
                            setState(_search.clear);
                            _searchFocus.requestFocus();
                          },
                          icon: const Icon(Icons.close_rounded, size: 18))));
          final period = DropdownButtonFormField<String>(
              key: ValueKey(_period),
              initialValue: _period,
              isExpanded: true,
              decoration: InputDecoration(
                  labelText: labels.text('الفترة', 'Period'),
                  prefixIcon: const Icon(Icons.date_range_outlined, size: 20)),
              items: [
                DropdownMenuItem(
                    value: 'all',
                    child: Text(labels.text('كل الفترات', 'All time'))),
                DropdownMenuItem(
                    value: 'month',
                    child: Text(labels.text('هذا الشهر', 'This month'))),
                DropdownMenuItem(
                    value: 'today', child: Text(labels.text('اليوم', 'Today'))),
              ],
              onChanged: (value) => setState(() => _period = value ?? 'all'));
          if (size.maxWidth < 600) {
            return Column(
                children: [search, const SizedBox(height: 12), period]);
          }
          return Row(children: [
            Expanded(child: search),
            const SizedBox(width: 12),
            SizedBox(width: 220, child: period)
          ]);
        }),
        const SizedBox(height: 14),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final category in ['all', ...ExpenseLabels.categories])
            ChoiceChip(
                label: Text(category == 'all'
                    ? labels.text('الكل', 'All')
                    : labels.category(category)),
                selected: _category == category,
                showCheckmark: false,
                selectedColor: AppColors.primaryColor,
                labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _category == category
                        ? AppColors.primaryForeground
                        : AppColors.textSecondary),
                side: BorderSide(
                    color: _category == category
                        ? AppColors.primaryColor
                        : AppColors.borderColor),
                onSelected: (_) => setState(() => _category = category)),
        ]),
      ]));
}
