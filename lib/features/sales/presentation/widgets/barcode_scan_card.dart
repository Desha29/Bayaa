import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';

class BarcodeScanCard extends StatelessWidget {
  const BarcodeScanCard({super.key, 
    required this.barcodeController,
    required this.onAddProduct,
  });

  final TextEditingController barcodeController;
  final VoidCallback onAddProduct;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.kCardBackground,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(LucideIcons.qrCode, color: Colors.grey),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: barcodeController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'امسح الباركود أو أدخل رقم المنتج...',
                ),
                onSubmitted: (_) => onAddProduct(),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              icon: const Icon(LucideIcons.plus, size: 18),
              label: const Text("إضافة منتج"),
              onPressed: onAddProduct,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.kPrimaryBlue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}