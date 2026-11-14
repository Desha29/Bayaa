import 'package:bayaa_pos/shared/theme/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat, NumberFormat;
import '../models/analytics_snapshot.dart';

class ReportTrend extends StatelessWidget {
  const ReportTrend(
      {super.key,
      required this.buckets,
      required this.salesLabel,
      required this.expensesLabel,
      required this.empty,
      required this.money});
  final List<TrendBucket> buckets;
  final String salesLabel, expensesLabel, empty;
  final String Function(double) money;

  @override
  Widget build(BuildContext context) {
    if (buckets.every((b) => b.$3 == 0 && b.$4 == 0)) return Text(empty);
    final locale = Localizations.localeOf(context).toString();
    final date = DateFormat.MMMd(locale);
    final compact = NumberFormat.compact(locale: locale);
    final primary = AppColors.primaryColor;
    final accent = AppColors.accentColor;
    List<BarChartGroupData> barGroups(double width) => [
          for (final (i, b) in buckets.indexed)
            BarChartGroupData(x: i, barsSpace: 3, barRods: [
              BarChartRodData(
                  toY: b.$3,
                  color: primary,
                  width: width,
                  borderRadius: BorderRadius.circular(3)),
              BarChartRodData(
                  toY: b.$4,
                  color: accent,
                  width: width,
                  borderRadius: BorderRadius.circular(3)),
            ]),
        ];
    const hidden = AxisTitles(sideTitles: SideTitles(showTitles: false));
    final labelStyle = TextStyle(fontSize: 10, color: AppColors.mutedColor);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Wrap(spacing: 18, runSpacing: 6, children: [
        _legend(primary, salesLabel),
        _legend(accent, expensesLabel),
      ]),
      const SizedBox(height: 16),
      LayoutBuilder(builder: (context, limits) {
        final rodWidth =
            ((limits.maxWidth - 48) / buckets.length / 4).clamp(3.0, 16.0);
        final stride =
            (buckets.length / (limits.maxWidth < 450 ? 3 : 6)).ceil();
        return Semantics(
          label: [
            for (final b in buckets)
              '${date.format(b.$1)} – ${date.format(b.$2)}: $salesLabel ${money(b.$3)}, $expensesLabel ${money(b.$4)}',
          ].join('; '),
          child: Directionality(
              textDirection: TextDirection.ltr,
              child: SizedBox(
                height: limits.maxWidth < 450 ? 192 : 248,
                child: BarChart(
                    BarChartData(
                      barGroups: barGroups(rodWidth),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (_) => FlLine(
                              color: AppColors.borderColor, strokeWidth: 1)),
                      titlesData: FlTitlesData(
                          topTitles: hidden,
                          rightTitles: hidden,
                          leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 48,
                                  maxIncluded: false,
                                  getTitlesWidget: (value, _) => Text(
                                      compact.format(value),
                                      style: labelStyle,
                                      maxLines: 1))),
                          bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 32,
                                  getTitlesWidget: (value, _) {
                                    final i = value.toInt();
                                    if (i < 0 ||
                                        i >= buckets.length ||
                                        i % stride != 0) {
                                      return const SizedBox.shrink();
                                    }
                                    return Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(date.format(buckets[i].$1),
                                            style: labelStyle, maxLines: 1));
                                  }))),
                      barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                              fitInsideHorizontally: true,
                              fitInsideVertically: true,
                              getTooltipItem: (group, i, rod, rodIndex) {
                                final bucket = buckets[group.x];
                                final start = date.format(bucket.$1);
                                final range = bucket.$1 == bucket.$2
                                    ? start
                                    : '$start – ${date.format(bucket.$2)}';
                                return BarTooltipItem(
                                    '$range\n${rodIndex == 0 ? salesLabel : expensesLabel}\n${money(rod.toY)}',
                                    const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11));
                              })),
                    ),
                    duration: MediaQuery.disableAnimationsOf(context)
                        ? Duration.zero
                        : const Duration(milliseconds: 180)),
              )),
        );
      }),
    ]);
  }

  Widget _legend(Color color, String label) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.circle, size: 9, color: color),
        const SizedBox(width: 6),
        Flexible(child: Text(label)),
      ]);
}
