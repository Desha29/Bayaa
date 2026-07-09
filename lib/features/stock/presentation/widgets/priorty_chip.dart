import 'package:flutter/material.dart';
import 'package:bayaa_pos/core/constants/app_colors.dart';

import 'package:bayaa_pos/l10n/app_localizations.dart';

class PriorityChip extends StatelessWidget {
  final String priority;

  const PriorityChip({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Color color;
    String displayLabel;
    switch (priority) {
      case "very_urgent":
        color = AppColors.errorColor;
        displayLabel = l10n.priorityVeryUrgent;
        break;
      case "urgent":
        color = AppColors.warningColor;
        displayLabel = l10n.priorityUrgent;
        break;
      case "medium":
        color = AppColors.primaryColor;
        displayLabel = l10n.priorityMedium;
        break;
      default:
        color = AppColors.successColor;
        displayLabel = l10n.priorityMedium; // Fallback or could add low priority string
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
        displayLabel,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
