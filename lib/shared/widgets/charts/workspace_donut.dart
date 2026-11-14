import 'package:bayaa_pos/shared/theme/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show NumberFormat;

/// Positive-value composition, with a readable legend independent of color.
class WorkspaceDonut extends StatelessWidget {
  const WorkspaceDonut(
      {super.key,
      required this.values,
      required this.format,
      required this.empty});
  final List<(String, double)> values;
  final String Function(double) format;
  final String empty;

  @override
  Widget build(BuildContext context) {
    final entries = values.where((entry) => entry.$2 > 0).toList();
    final total = entries.fold(0.0, (sum, entry) => sum + entry.$2);
    if (total == 0) return Text(empty);
    final percent =
        NumberFormat.percentPattern(Localizations.localeOf(context).toString());
    final colors = [
      AppColors.primaryColor,
      AppColors.accentColor,
      AppColors.secondaryColor,
      AppColors.successColor,
      AppColors.warningColor,
      AppColors.errorColor,
    ];
    Color color(int i) => colors[i % colors.length];
    final chart = SizedBox(
        width: 124,
        height: 124,
        child: ExcludeSemantics(
          child: PieChart(
            PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 37,
                pieTouchData: PieTouchData(enabled: false),
                sections: [
                  for (final (i, entry) in entries.indexed)
                    PieChartSectionData(
                        color: color(i),
                        value: entry.$2,
                        radius: 20,
                        showTitle: false),
                ]),
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 180),
          ),
        ));
    final legend =
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      for (final (i, entry) in entries.indexed)
        Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Icon(Icons.circle, size: 9, color: color(i))),
              const SizedBox(width: 8),
              Expanded(
                  child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      spacing: 8,
                      runSpacing: 2,
                      children: [
                    Text(entry.$1),
                    Text(
                        '${format(entry.$2)} · ${percent.format(entry.$2 / total)}',
                        style: TextStyle(color: AppColors.textSecondary)),
                  ])),
            ])),
    ]);
    return LayoutBuilder(
        builder: (context, size) => size.maxWidth >= 420
            ? Row(children: [
                chart,
                const SizedBox(width: 16),
                Expanded(child: legend)
              ])
            : Column(children: [chart, const SizedBox(height: 14), legend]));
  }
}
