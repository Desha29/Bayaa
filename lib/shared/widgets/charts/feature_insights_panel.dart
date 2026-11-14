import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:bayaa_pos/shared/theme/app_colors.dart';
import 'package:bayaa_pos/shared/layout/layout_tokens.dart';
import 'feature_insights_spec.dart';

class FeatureInsightsPanel extends StatelessWidget {
  const FeatureInsightsPanel({super.key, required this.spec});
  final FeatureInsightsSpec spec;
  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    final colors = [
      AppColors.secondaryColor,
      AppColors.accentColor,
      AppColors.primaryColor
    ];
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 250);
    Widget card(String title, Widget child) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: AppColors.surfaceColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderColor)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: AppColors.secondaryColor.withValues(alpha: .07),
                    borderRadius: BorderRadius.circular(9)),
                child: Icon(
                    title == (arabic ? spec.trendTitleAr : spec.trendTitle)
                        ? Icons.show_chart_rounded
                        : Icons.donut_small_outlined,
                    size: 18,
                    color: AppColors.secondaryColor)),
            const SizedBox(width: 10),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(title,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(
                      arabic
                          ? 'بيانات توضيحية • آخر 7 فترات'
                          : 'Static examples • Last 7 periods',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.mutedColor,
                          fontSize: 10)),
                ])),
          ]),
          const SizedBox(height: 20),
          child
        ]));
    return Semantics(
        label: arabic ? 'رسوم بيانية توضيحية' : 'Example insight charts',
        child: AdaptiveColumns(minWidth: 360, maxColumns: 2, children: [
          card(
              arabic ? spec.trendTitleAr : spec.trendTitle,
              SizedBox(
                  height: 170,
                  child: LineChart(
                      LineChartData(
                        minY: 0,
                        gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (_) => FlLine(
                                color:
                                    AppColors.borderColor.withValues(alpha: .5),
                                strokeWidth: 1)),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 34,
                                    getTitlesWidget: (value, _) => Text(
                                        value.toInt().toString(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 9,
                                            color: AppColors.mutedColor)))),
                            bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 24,
                                    interval: 1,
                                    getTitlesWidget: (value, _) => Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text('${value.toInt() + 1}',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.mutedColor,
                                                fontSize: 10)))))),
                        lineBarsData: [
                          LineChartBarData(
                              spots: [
                                for (var i = 0; i < spec.trend.length; i++)
                                  FlSpot(i.toDouble(), spec.trend[i])
                              ],
                              isCurved: true,
                              barWidth: 3,
                              color: AppColors.secondaryColor,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                  show: true,
                                  gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        AppColors.secondaryColor
                                            .withValues(alpha: .16),
                                        AppColors.secondaryColor
                                            .withValues(alpha: 0)
                                      ])))
                        ],
                      ),
                      duration: duration))),
          card(
              arabic ? spec.distributionTitleAr : spec.distributionTitle,
              SizedBox(
                  height: 170,
                  child: LayoutBuilder(
                      builder: (context, size) => Row(children: [
                            SizedBox(
                                width: size.maxWidth * .46,
                                child: PieChart(
                                    PieChartData(
                                        centerSpaceRadius: 24,
                                        sectionsSpace: 4,
                                        sections: [
                                          for (var i = 0;
                                              i < spec.distribution.length;
                                              i++)
                                            PieChartSectionData(
                                                value: spec.distribution[i],
                                                color:
                                                    colors[i % colors.length],
                                                radius: 24,
                                                showTitle: false)
                                        ]),
                                    duration: duration)),
                            const SizedBox(width: 14),
                            Expanded(
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                  for (var i = 0; i < spec.labels.length; i++)
                                    Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 6),
                                        child: Row(children: [
                                          Container(
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                  color:
                                                      colors[i % colors.length],
                                                  shape: BoxShape.circle)),
                                          const SizedBox(width: 8),
                                          Expanded(
                                              child: Text(
                                                  arabic
                                                      ? spec.labelsAr[i]
                                                      : spec.labels[i],
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 11))),
                                          Text(
                                              '${spec.distribution[i].toInt()}%',
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold)),
                                        ])),
                                ]))
                          ])))),
        ]));
  }
}
