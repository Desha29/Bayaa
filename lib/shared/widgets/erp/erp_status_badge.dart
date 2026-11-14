import 'package:flutter/material.dart';
import 'package:bayaa_pos/shared/theme/app_colors.dart';
import 'erp_view_spec.dart';

class ErpStatusBadge extends StatelessWidget {
  const ErpStatusBadge({super.key, required this.label, required this.tone});
  final String label;
  final ErpStatusTone tone;
  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    final color = switch (tone) {
      ErpStatusTone.success => AppColors.successColor,
      ErpStatusTone.warning => AppColors.warningColor,
      ErpStatusTone.danger => AppColors.errorColor,
      ErpStatusTone.info => AppColors.secondaryColor
    };
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
            color: color.withValues(alpha: .09),
            borderRadius: BorderRadius.circular(7)),
        child: Text(label,
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.bold)));
  }
}
