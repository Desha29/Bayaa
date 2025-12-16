import 'package:flutter/material.dart';

import 'package:crazy_phone_pos/core/constants/app_colors.dart';

class PriorityChip extends StatelessWidget {
  final String priority;

  const PriorityChip({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color textColor;
    switch (priority) {
      case "عاجل جداً":
        bg = AppColors.errorColor.withOpacity(0.15);
        textColor = AppColors.errorColor;
        break;
      case "عاجل":
        bg = AppColors.warningColor.withOpacity(0.15);
        textColor = AppColors.warningColor;
        break;
      case "متوسط":
        bg = AppColors.primaryColor.withOpacity(0.15);
        textColor = AppColors.primaryColor;
        break;
      default:
        bg = AppColors.successColor.withOpacity(0.15);
        textColor = AppColors.successColor;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          priority,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
