import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:bayaa_pos/l10n/app_localizations.dart';

import '../../../core/constants/app_colors.dart';
import '../data/expense_model.dart';
import '../data/expense_repository.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final _repository = ExpenseRepository();
  late Future<List<Expense>> _expenses = _repository.getExpenses();

  bool get _isArabic => Localizations.localeOf(context).languageCode == 'ar';
  AppLocalizations get _l10n => AppLocalizations.of(context);

  String _categoryLabel(String key) {
    const aliases = {
      'تشغيل': 'operations',
      'إيجار': 'rent',
      'مرافق': 'utilities',
      'صيانة': 'maintenance',
      'مشتريات': 'supplies',
      'أخرى': 'other',
      'General': 'other',
    };
    final normalized = aliases[key] ?? key;
    final labels = _isArabic
        ? const {
            'operations': 'تشغيل', 'rent': 'إيجار', 'utilities': 'مرافق',
            'maintenance': 'صيانة', 'supplies': 'مشتريات', 'other': 'أخرى',
          }
        : const {
            'operations': 'Operations', 'rent': 'Rent', 'utilities': 'Utilities',
            'maintenance': 'Maintenance', 'supplies': 'Supplies', 'other': 'Other',
          };
    return labels[normalized] ?? key;
  }
  void _reload() => setState(() => _expenses = _repository.getExpenses());

  Future<void> _addExpense() async {
    final title = TextEditingController();
    final amount = TextEditingController();
    final notes = TextEditingController();
    String category = 'operations';
    const categories =
        ['operations', 'rent', 'utilities', 'maintenance', 'supplies', 'other'];

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surfaceColor,
          surfaceTintColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.borderColor),
          ),
          titlePadding: EdgeInsets.zero,
          title: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
            decoration: BoxDecoration(
              color: AppColors.secondaryColor.withOpacity(.055),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              border: const Border(bottom: BorderSide(color: AppColors.borderColor)),
            ),
            child: Row(children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.secondaryColor.withOpacity(.11),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(LucideIcons.walletCards,
                    size: 20, color: AppColors.secondaryColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_isArabic ? 'إضافة مصروف جديد' : 'Add expense',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(
                      _isArabic
                          ? 'سجّل المصروف ليظهر في التقارير والتحليلات'
                          : 'Record it in reports and analytics',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.mutedColor),
                    ),
                  ],
                ),
              ),
            ]),
          ),
          contentPadding: const EdgeInsets.fromLTRB(22, 20, 22, 8),
          content: SizedBox(
            width: 430,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                  controller: title,
                  autofocus: true,
                  decoration: InputDecoration(
                      labelText: _isArabic ? 'وصف المصروف' : 'Description',
                      prefixIcon: const Icon(LucideIcons.fileText))),
              const SizedBox(height: 12),
              TextField(
                  controller: amount,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                      labelText: _isArabic ? 'المبلغ' : 'Amount',
                      prefixIcon: const Icon(LucideIcons.banknote))),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: category,
                decoration: InputDecoration(
                    labelText: _isArabic ? 'الفئة' : 'Category',
                    prefixIcon: const Icon(LucideIcons.tags)),
                items: categories
                    .map((item) => DropdownMenuItem(
                        value: item, child: Text(_categoryLabel(item))))
                    .toList(),
                onChanged: (value) =>
                    setDialogState(() => category = value ?? category),
              ),
              const SizedBox(height: 12),
              TextField(
                  controller: notes,
                  maxLines: 2,
                  decoration: InputDecoration(
                      labelText:
                          _isArabic ? 'ملاحظات (اختياري)' : 'Notes (optional)',
                      prefixIcon: const Icon(LucideIcons.notebookPen))),
            ]),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(_isArabic ? 'إلغاء' : 'Cancel')),
            FilledButton.icon(
              icon: const Icon(LucideIcons.save, size: 18),
              label: Text(_isArabic ? 'حفظ المصروف' : 'Save expense'),
              onPressed: () async {
                final value = double.tryParse(amount.text.trim());
                if (title.text.trim().isEmpty || value == null || value <= 0)
                  return;
                await _repository.add(Expense(
                  id: 'expense_${DateTime.now().microsecondsSinceEpoch}',
                  title: title.text.trim(),
                  amount: value,
                  category: category,
                  notes: notes.text.trim().isEmpty ? null : notes.text.trim(),
                  date: DateTime.now(),
                ));
                if (dialogContext.mounted) Navigator.pop(dialogContext, true);
              },
            ),
          ],
          actionsPadding: const EdgeInsets.fromLTRB(22, 10, 22, 20),
        ),
      ),
    );
    title.dispose();
    amount.dispose();
    notes.dispose();
    if (saved == true) _reload();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<Expense>>(
        future: _expenses,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final expenses = snapshot.data ?? [];
          final now = DateTime.now();
          final total =
              expenses.fold<double>(0, (sum, item) => sum + item.amount);
          final monthTotal = expenses
              .where((item) =>
                  item.date.year == now.year && item.date.month == now.month)
              .fold<double>(0, (sum, item) => sum + item.amount);
          final categoryTotals = <String, double>{};
          for (final item in expenses) {
            categoryTotals[item.category] =
                (categoryTotals[item.category] ?? 0) + item.amount;
          }

          return LayoutBuilder(builder: (context, constraints) {
            final desktop = constraints.maxWidth >= 980;
            return ListView(
              padding: EdgeInsets.fromLTRB(
                desktop ? 24 : 16,
                8,
                desktop ? 24 : 16,
                desktop ? 24 : 16,
              ),
              children: [
                Row(children: [
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(
                            _isArabic
                                ? 'إدارة المصروفات التشغيلية'
                                : 'Operating expenses',
                            style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary)),
                        const SizedBox(height: 3),
                        Text(
                            _isArabic
                                ? 'تابع التدفقات الخارجة وتأثيرها على صافي الربح'
                                : 'Track outgoing cash and its impact on net profit',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.mutedColor)),
                      ])),
                  FilledButton.icon(
                      onPressed: _addExpense,
                      icon: const Icon(LucideIcons.plus, size: 18),
                      label: Text(_isArabic ? 'إضافة مصروف' : 'Add expense')),
                ]),
                const SizedBox(height: 18),
                Wrap(spacing: 14, runSpacing: 14, children: [
                  _metric(
                      _isArabic ? 'إجمالي المصروفات' : 'Total expenses',
                      total,
                      LucideIcons.walletCards,
                      AppColors.errorColor,
                      desktop),
                  _metric(
                      _isArabic ? 'مصروفات الشهر' : 'This month',
                      monthTotal,
                      LucideIcons.calendarRange,
                      AppColors.accentColor,
                      desktop),
                  _metric(
                      _isArabic ? 'عدد العمليات' : 'Transactions',
                      expenses.length.toDouble(),
                      LucideIcons.receiptText,
                      AppColors.secondaryColor,
                      desktop,
                      money: false),
                ]),
                const SizedBox(height: 18),
                if (desktop)
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(flex: 4, child: _categoryChart(categoryTotals)),
                    const SizedBox(width: 16),
                    Expanded(flex: 6, child: _expenseList(expenses)),
                  ])
                else ...[
                  _categoryChart(categoryTotals),
                  const SizedBox(height: 16),
                  _expenseList(expenses),
                ],
              ],
            );
          });
        },
      );

  Widget _metric(
          String title, double value, IconData icon, Color color, bool desktop,
          {bool money = true}) =>
      Container(
        width: desktop ? 260 : double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withOpacity(.16)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(.04),
                  blurRadius: 16,
                  offset: const Offset(0, 6))
            ]),
        child: Row(children: [
          Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: color.withOpacity(.1),
                  borderRadius: BorderRadius.circular(13)),
              child: Icon(icon, color: color, size: 22)),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.mutedColor)),
                const SizedBox(height: 4),
                Text(
                    money
                        ? '${value.toStringAsFixed(2)} ${_l10n.currencyEg}'
                        : value.toInt().toString(),
                    style: const TextStyle(
                        fontSize: 19, fontWeight: FontWeight.w800))
              ])),
        ]),
      );

  Widget _categoryChart(Map<String, double> totals) {
    final colors = [
      AppColors.errorColor,
      AppColors.accentColor,
      AppColors.secondaryColor,
      const Color(0xFF14B8A6),
      const Color(0xFF8B5CF6)
    ];
    return Container(
      height: 330,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderColor)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(_isArabic ? 'توزيع المصروفات حسب الفئة' : 'Expenses by category',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        Expanded(
            child: totals.isEmpty
                ? const Center(
                    child: Icon(LucideIcons.chartPie,
                        size: 50, color: AppColors.borderColor))
                : PieChart(PieChartData(
                    centerSpaceRadius: 48,
                    sectionsSpace: 3,
                    sections: totals.entries
                        .toList()
                        .asMap()
                        .entries
                        .map((entry) => PieChartSectionData(
                            value: entry.value.value,
                            title: _categoryLabel(entry.value.key),
                            radius: 62,
                            color: colors[entry.key % colors.length],
                            titleStyle: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.w700)))
                        .toList()))),
      ]),
    );
  }

  Widget _expenseList(List<Expense> expenses) => Container(
        constraints: const BoxConstraints(minHeight: 330),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.borderColor)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_isArabic ? 'سجل المصروفات' : 'Expense history',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          if (expenses.isEmpty)
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 80),
                child: Center(
                    child: Text(
                        _isArabic ? 'لا توجد مصروفات بعد' : 'No expenses yet')))
          else
            ...expenses.take(12).map((item) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                      backgroundColor: Color(0xFFFFF1F2),
                      child: Icon(LucideIcons.receiptText,
                          color: AppColors.errorColor, size: 19)),
                  title: Text(item.title,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(
                      '${_categoryLabel(item.category)}  •  ${DateFormat('dd/MM/yyyy').format(item.date)}'),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text('${item.amount.toStringAsFixed(2)} ${_l10n.currencyEg}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.errorColor)),
                    IconButton(
                        tooltip: _isArabic ? 'حذف' : 'Delete',
                        icon: const Icon(LucideIcons.trash2,
                            size: 18, color: AppColors.mutedColor),
                        onPressed: () async {
                          await _repository.delete(item.id);
                          _reload();
                        }),
                  ]),
                )),
        ]),
      );
}
