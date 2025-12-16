import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class StatusChip extends StatelessWidget {
  final bool isOut;
  final bool isLow;

  const StatusChip({super.key, required this.isOut, required this.isLow});

  @override
  Widget build(BuildContext context) {
    if (isOut) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.errorColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'غير متوفر',
            style: TextStyle(color: AppColors.errorColor, fontSize: 13),
          ),
        ),
      );
    } else if (isLow) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.warningColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'مخزون منخفض',
            style: TextStyle(color: AppColors.warningColor, fontSize: 13),
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.successColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'متوفر',
            style: TextStyle(color: AppColors.successColor, fontSize: 13),
          ),
        ),
      );
    }
  }
}
