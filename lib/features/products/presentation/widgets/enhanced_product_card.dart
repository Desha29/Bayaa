import 'package:flutter/material.dart';
import 'package:crazy_phone_pos/features/products/data/models/product_model.dart';
import 'package:crazy_phone_pos/core/constants/app_colors.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/presentation/cubit/user_cubit.dart';

class EnhancedProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final Color statusColor;
  final String statusText;

  const EnhancedProductCard({
    super.key,
    required this.product,
    required this.onDelete,
    required this.onEdit,
    required this.statusColor,
    required this.statusText,
  });

  @override
  Widget build(BuildContext context) {
    final qty = product.quantity;
    final min = product.minQuantity;
    final isLowStock = qty > 0 && qty <= min;
    final isOutOfStock = qty == 0;
    final userType = getIt<UserCubit>().currentUser.userType;
    final isManager = userType == UserType.manager;

    // Fixed font sizes for consistent layout
    const double titleSize = 16;
    const double small = 12;
    const double value = 14;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOutOfStock
              ? AppColors.errorColor.withOpacity(0.5)
              : isLowStock
                  ? AppColors.warningColor.withOpacity(0.5)
                  : AppColors.borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 🔹 Product Name, Category & Barcode
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: titleSize,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (product.category.isNotEmpty)
                  Text(
                    product.category,
                    style: TextStyle(
                      fontSize: small,
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                const SizedBox(height: 2),
                Text(
                  product.barcode,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.mutedColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 12),

          // 🔹 Price & Status
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
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
                  "${product.price.toStringAsFixed(2)} ج.م",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: value,
                    color: AppColors.successColor,
                  ),
                ),
                const SizedBox(height: 4),
                _StatusChip(
                  text: statusText,
                  color: statusColor,
                  font: small,
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // 🔹 Quantity & Stock info
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 14, color: AppColors.mutedColor),
                        const SizedBox(width: 4),
                        Text("الكمية", style: TextStyle(fontSize: small, color: AppColors.mutedColor)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text("$qty", style: TextStyle(fontWeight: FontWeight.bold, fontSize: value)),
                  ],
                ),
              ],
            ),
          ),

          // 🔹 Manager-only: Wholesale & Min Price
          if (isManager) ...[
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("جملة", style: TextStyle(fontSize: small, color: AppColors.mutedColor)),
                      const SizedBox(height: 2),
                      Text(
                        "${product.wholesalePrice.toStringAsFixed(2)}",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: value, color: AppColors.accentGold),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("أدنى سعر", style: TextStyle(fontSize: small, color: AppColors.mutedColor)),
                      const SizedBox(height: 2),
                      Text(
                        "${product.minPrice.toStringAsFixed(2)}",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: value, color: Colors.deepOrange),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(width: 8),

          // 🔹 Actions
          if (userType != UserType.cashier)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_rounded, color: AppColors.primaryColor),
                  tooltip: 'تعديل',
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_rounded, color: AppColors.errorColor),
                  tooltip: 'حذف',
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String text;
  final Color color;
  final double font;
  const _StatusChip({
    required this.text,
    required this.color,
    required this.font,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: font,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}



class ActionButton extends StatefulWidget {
  final String text;
  final IconData icon;
  final Color baseColor;
  final VoidCallback onPressed;
  final double? fontSize;

  const ActionButton({
    super.key,
    required this.text,
    required this.icon,
    required this.baseColor,
    required this.onPressed,
    this.fontSize,
  });

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    final f = (widget.fontSize ?? 13).clamp(11, 15).toDouble();
    final bgColor = hovering
        ? widget.baseColor.withOpacity(0.9)
        : widget.baseColor.withOpacity(0.12);
    final fgColor = hovering ? Colors.white : widget.baseColor;

    return MouseRegion(
      onEnter: (_) => setState(() => hovering = true),
      onExit: (_) => setState(() => hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 130),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          onTap: widget.onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.icon, color: fgColor, size: f + 2),
                const SizedBox(width: 5),
                Text(
                  widget.text,
                  style: TextStyle(
                    color: fgColor,
                    fontWeight: FontWeight.w700,
                    fontSize: f,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
