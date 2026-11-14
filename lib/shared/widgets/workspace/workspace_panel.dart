import 'dart:math' as math;
import 'package:bayaa_pos/shared/theme/app_colors.dart';
import 'package:flutter/material.dart';

class WorkspacePanel extends StatelessWidget {
  const WorkspacePanel(
      {super.key,
      required this.title,
      required this.caption,
      required this.icon,
      required this.child,
      this.prominent = false});
  final String title, caption;
  final IconData icon;
  final Widget child;
  final bool prominent;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: AppColors.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderColor)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(9)),
                child: Icon(icon, size: 19, color: AppColors.primaryColor)),
            const SizedBox(width: 10),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(title,
                      style: prominent
                          ? Theme.of(context).textTheme.titleLarge
                          : Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 3),
                  Text(caption,
                      style:
                          TextStyle(fontSize: 12, color: AppColors.mutedColor)),
                ])),
          ]),
          const SizedBox(height: 16),
          child,
        ]),
      );
}

class WorkspaceRankBars extends StatelessWidget {
  const WorkspaceRankBars(
      {super.key,
      required this.values,
      required this.format,
      required this.empty});
  final List<(String, double)> values;
  final String Function(double) format;
  final String empty;

  @override
  Widget build(BuildContext context) {
    final max =
        values.fold(0.0, (total, item) => math.max(total, item.$2.abs()));
    if (max == 0) {
      return Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Text(empty, style: TextStyle(color: AppColors.mutedColor)));
    }
    return Column(children: [
      for (final (i, entry) in values.indexed)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 12,
                runSpacing: 3,
                children: [
                  Text(entry.$1),
                  Text(format(entry.$2),
                      style: TextStyle(color: AppColors.primaryColor))
                ]),
            const SizedBox(height: 5),
            ExcludeSemantics(
                child: LinearProgressIndicator(
                    value: entry.$2.abs() / max,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(6),
                    backgroundColor:
                        AppColors.borderColor.withValues(alpha: .5),
                    color: entry.$2 < 0
                        ? AppColors.errorColor
                        : i == 0
                            ? AppColors.primaryColor
                            : AppColors.secondaryColor.withValues(alpha: .68))),
          ]),
        ),
    ]);
  }
}
