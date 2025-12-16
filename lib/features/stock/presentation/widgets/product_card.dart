import 'package:crazy_phone_pos/core/di/dependency_injection.dart';
import 'package:crazy_phone_pos/core/functions/messege.dart';
import 'package:crazy_phone_pos/features/auth/data/models/user_model.dart';
import 'package:crazy_phone_pos/features/auth/presentation/cubit/user_cubit.dart';
import 'package:flutter/material.dart';
import 'package:crazy_phone_pos/core/constants/app_colors.dart';
import '../../../products/data/models/product_model.dart';
import 'priorty_chip.dart';
import 'status_chip.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback onRestock;

  const ProductCard({
    super.key,
    required this.product,
    required this.onRestock,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final isOut = product.quantity == 0;
    final isLow = product.quantity > 0 && product.quantity < product.minQuantity;

    // Fixed font sizes for consistent layout
    const double titleSize = 16;
    const double small = 12;
    const double value = 15;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isHovered
                ? AppColors.primaryColor.withOpacity(0.5)
                : isOut
                    ? AppColors.errorColor.withOpacity(0.5)
                    : isLow
                        ? AppColors.warningColor.withOpacity(0.5)
                        : AppColors.borderColor,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? Colors.black.withOpacity(0.08)
                  : Colors.black.withOpacity(0.02),
              blurRadius: _isHovered ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🔹 1. Product Name & Barcode
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: titleSize,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      PriorityChip(priority: product.priority),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'كود: ${product.barcode}',
                    style: TextStyle(
                      fontSize: small,
                      color: AppColors.mutedColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // 🔹 2. Price Section (Label + Value)
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                    children: [
                      Icon(Icons.monetization_on_outlined, size: 14, color: AppColors.mutedColor),
                      const SizedBox(width: 4),
                      Text("سعر البيع", style: TextStyle(fontSize: small, color: AppColors.mutedColor)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${product.price.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: value,
                      color: AppColors.successColor,
                    ),
                  ),
                ],
              ),
            ),

            // 🔹 3. Quantity Section (Label + Value)
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 14, color: AppColors.mutedColor),
                      const SizedBox(width: 4),
                      Text("الكمية", style: TextStyle(fontSize: small, color: AppColors.mutedColor)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        "${product.quantity}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: value,
                          color: isOut ? AppColors.errorColor : (isLow ? AppColors.warningColor : AppColors.textPrimary),
                        ),
                      ),
                      const SizedBox(width: 4),
                      StatusChip(isOut: isOut, isLow: isLow),
                    ],
                  ),
                ],
              ),
            ),

            // 🔹 4. Restock Action
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: getIt<UserCubit>().currentUser.userType == UserType.manager
                    ? widget.onRestock
                    : disableMesg,
                icon: const Icon(Icons.refresh, size: 16),
                label: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('إعادة التخزين'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void disableMesg() {
    MotionSnackBarWarning(context, "لا يوجد لديك صلاحيات");
  }
}

