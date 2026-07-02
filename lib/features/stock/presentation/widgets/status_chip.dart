import 'package:flutter/material.dart';
import 'package:bayaa_pos/l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';

class StatusChip extends StatelessWidget {
  final bool isOut;
  final bool isLow;

  const StatusChip({super.key, required this.isOut, required this.isLow});

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String label;
    final l10n = AppLocalizations.of(context);

    if (isOut) {
      color = AppColors.errorColor;
      label = l10n.outOfStock;
    } else if (isLow) {
      color = AppColors.warningColor;
      label = l10n.lowStock;
    } else {
      color = AppColors.successColor;
      label = l10n.available;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Cairo',
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

