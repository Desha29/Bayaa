import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';

class TotalSectionCard extends StatelessWidget {
  final double totalAmount;
  final VoidCallback? onClearCart;
  final VoidCallback onCheckout;

  const TotalSectionCard({super.key, 
    required this.totalAmount,
    required this.onClearCart,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            ElevatedButton.icon(
              icon: const Icon(LucideIcons.shoppingCart, size: 18),
              label: const Text("إنهاء البيع"),
              onPressed: totalAmount > 0 ? onCheckout : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.kSuccessGreen,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey,
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              icon: const Icon(LucideIcons.trash2, size: 18),
              label: const Text("حذف الكل"),
              onPressed: onClearCart,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.kDangerRed,
                foregroundColor: Colors.white,
              ),
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text("الإجمالي النهائي"),
                FittedBox(
                  child: Text(
                    "${totalAmount.toStringAsFixed(0)} ج.م",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.kPrimaryBlue,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
