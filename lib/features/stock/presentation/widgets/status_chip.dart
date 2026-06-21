import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class StatusChip extends StatelessWidget {
  final bool isOut;
  final bool isLow;

  const StatusChip({super.key, required this.isOut, required this.isLow});

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String label;

    if (isOut) {
      color = AppColors.errorColor;
      label = 'نفذ';
    } else if (isLow) {
      color = AppColors.warningColor;
      label = 'منخفض';
    } else {
      color = AppColors.successColor;
      label = 'متوفر';
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
