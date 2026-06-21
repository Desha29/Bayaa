import 'package:flutter/material.dart';
import 'package:crazy_phone_pos/core/constants/app_colors.dart';

class PriorityChip extends StatelessWidget {
  final String priority;

  const PriorityChip({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (priority) {
      case "عاجل جداً":
        color = AppColors.errorColor;
        break;
      case "عاجل":
        color = AppColors.warningColor;
        break;
      case "متوسط":
        color = AppColors.primaryColor;
        break;
      default:
        color = AppColors.successColor;
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
        priority,
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
