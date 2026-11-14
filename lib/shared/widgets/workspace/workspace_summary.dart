import 'package:flutter/material.dart';
import 'package:bayaa_pos/shared/theme/app_colors.dart';

class WorkspaceMetric {
  const WorkspaceMetric(this.label, this.value, this.icon, {this.color});
  final String label;
  final String value;
  final IconData icon;
  final Color? color;
}

/// A premium, responsive summary row used across workspaces (Invoices, Products, Expenses, etc.)
class WorkspaceSummary extends StatelessWidget {
  const WorkspaceSummary({super.key, required this.metrics});
  final List<WorkspaceMetric> metrics;

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      final int columns;
      if (width >= 1100) {
        columns = metrics.length.clamp(1, 6);
      } else if (width >= 700) {
        columns = metrics.length > 2 ? (metrics.length >= 4 ? 4 : 3) : 2;
      } else {
        columns = 2;
      }

      final itemWidth = (width - (columns - 1) * 12) / columns;
      return Wrap(spacing: 12, runSpacing: 12, children: [
        for (final metric in metrics)
          SizedBox(
            width: itemWidth,
            child: _MetricCard(metric: metric),
          ),
      ]);
    });
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.metric});
  final WorkspaceMetric metric;

  @override
  Widget build(BuildContext context) {
    final themeColor = metric.color ?? AppColors.primaryColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor.withOpacity(0.9)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  metric.icon,
                  size: 17,
                  color: themeColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  metric.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.mutedColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            metric.value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class WorkspacePill extends StatelessWidget {
  const WorkspacePill(
      {super.key, required this.label, required this.color, this.icon});
  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
            color: color.withValues(alpha: .08),
            borderRadius: BorderRadius.circular(7),
            border: Border.all(color: color.withValues(alpha: .18))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4)
          ],
          Flexible(
              child: Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.w700))),
        ]),
      );
}
