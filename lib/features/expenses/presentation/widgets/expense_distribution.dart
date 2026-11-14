import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:bayaa_pos/shared/theme/app_colors.dart';
import '../models/expense_view_data.dart';
import 'expense_labels.dart';

class ExpenseDistribution extends StatelessWidget {
  const ExpenseDistribution({super.key, required this.records});
  final List<ExpenseViewData> records;

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    final labels = ExpenseLabels.of(context);
    final totals = <String, double>{};
    for (final record in records) {
      final key = ExpenseLabels.categoryKey(record.category);
      totals[key] = (totals[key] ?? 0) + record.amount;
    }
    final entries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = records.fold<double>(0, (sum, record) => sum + record.amount);
    final colors = [
      AppColors.primaryColor,
      AppColors.accentColor,
      AppColors.secondaryColor,
      AppColors.successColor,
      AppColors.warningColor,
      AppColors.mutedColor
    ];
    return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: AppColors.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderColor)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(labels.text('توزيع المصروفات', 'Expense distribution'),
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text(
              labels.text('توزيع الفئات في النتائج المعروضة',
                  'Category breakdown of the displayed records'),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: AppColors.mutedColor)),
          const SizedBox(height: 20),
          if (total <= 0)
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                    child: Text(
                        labels.text('لا توجد بيانات للرسم البياني',
                            'No chart data for these filters'),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.mutedColor))))
          else
            LayoutBuilder(builder: (context, size) {
              final chart = Semantics(
                  label: labels.text('رسم توزيع المصروفات حسب الفئة',
                      'Expense distribution by category'),
                  image: true,
                  child: SizedBox(
                      width: 210,
                      height: 190,
                      child: Stack(alignment: Alignment.center, children: [
                        PieChart(
                            PieChartData(
                                centerSpaceRadius: 55,
                                sectionsSpace: 3,
                                borderData: FlBorderData(show: false),
                                sections: [
                                  for (var i = 0; i < entries.length; i++)
                                    PieChartSectionData(
                                        value: entries[i].value,
                                        color: colors[i % colors.length],
                                        radius: 23,
                                        showTitle: false)
                                ]),
                            duration: MediaQuery.disableAnimationsOf(context)
                                ? Duration.zero
                                : const Duration(milliseconds: 250)),
                        Column(mainAxisSize: MainAxisSize.min, children: [
                          Text('${records.length}',
                              style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary)),
                          Text(labels.text('مصروف', 'expenses'),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  color: AppColors.mutedColor)),
                        ]),
                      ])));
              final legend = Column(children: [
                for (var i = 0; i < entries.length; i++)
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Row(children: [
                        Container(
                            width: 9,
                            height: 9,
                            decoration: BoxDecoration(
                                color: colors[i % colors.length],
                                borderRadius: BorderRadius.circular(3))),
                        const SizedBox(width: 10),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Row(children: [
                                Expanded(
                                    child: Text(labels.category(entries[i].key),
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary))),
                                Text(
                                    '${(entries[i].value / total * 100).round()}%',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                        color: AppColors.mutedColor)),
                              ]),
                              const SizedBox(height: 5),
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                      value: entries[i].value / total,
                                      minHeight: 4,
                                      color: colors[i % colors.length],
                                      backgroundColor: AppColors.borderColor
                                          .withValues(alpha: .4))),
                            ])),
                      ])),
              ]);
              if (size.maxWidth >= 540) {
                return Row(children: [
                  chart,
                  const SizedBox(width: 32),
                  Expanded(child: legend)
                ]);
              }
              return Column(children: [
                Center(child: chart),
                const SizedBox(height: 14),
                legend
              ]);
            }),
        ]));
  }
}
