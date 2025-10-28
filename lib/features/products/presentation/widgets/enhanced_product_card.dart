import 'package:flutter/material.dart';
import 'package:crazy_phone_pos/features/products/data/models/product_model.dart';
import 'package:crazy_phone_pos/core/utils/responsive_helper.dart';
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

    final titleSize =
        ResponsiveHelper.fontSize(context, mobile: 15, tablet: 17, desktop: 19);
    final small =
        ResponsiveHelper.fontSize(context, mobile: 11, tablet: 12, desktop: 13);
    final value =
        ResponsiveHelper.fontSize(context, mobile: 13, tablet: 14, desktop: 15);

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOutOfStock
              ? Colors.redAccent.withOpacity(0.3)
              : isLowStock
                  ? Colors.orangeAccent.withOpacity(0.25)
                  : Colors.grey.withOpacity(0.15),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 🔹 Product Name
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 4),
            child: Text(
              product.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: titleSize,
                color: const Color(0xff1e293b),
              ),
            ),
          ),

          // 🔹 Category
          if (product.category.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2, bottom: 8),
              child: Text(
                product.category,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: small + 0.3,
                  color: Colors.blueGrey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

          const SizedBox(height: 8),

          // 🔹 Price + Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "السعر: ${product.price.toStringAsFixed(2)}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: value,
                  color: const Color(0xff059669),
                ),
              ),
              _StatusChip(
                text: statusText,
                color: statusColor,
                font: small + 1,
              ),
            ],
          ),

          const SizedBox(height: 10),

          // 🔹 Info Row (qty, min, optional wholesale)
          _InfoRow(
            small: small,
            value: value,
            qty: qty,
            min: min,
            product: product,
            isManager: userType == UserType.manager,
          ),

          const SizedBox(height: 10),

          // 🔹 Actions
          userType==UserType.cashier?SizedBox():
          _ActionsBar(edit: onEdit, del: onDelete, value: value),
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

class _InfoRow extends StatelessWidget {
  final double small;
  final double value;
  final int qty;
  final int min;
  final Product product;
  final bool isManager;

  const _InfoRow({
    required this.small,
    required this.value,
    required this.qty,
    required this.min,
    required this.product,
    required this.isManager,
  });

  Widget infoItem(String label, String val, IconData icon, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: value + 2),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    fontSize: small, color: Colors.grey[700], height: 1.2)),
            Text(val,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: value + 1,
                    color: color)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        infoItem(
          'المتوفر',
          qty.toString(),
          Icons.inventory_2_rounded,
          qty == 0 ? Colors.redAccent : const Color(0xff0fa2a9),
        ),
        infoItem(
          'الحد الأدنى',
          min.toString(),
          Icons.trending_down_rounded,
          Colors.orangeAccent,
        ),
        if (isManager)
          infoItem(
            'جملة',
            product.wholesalePrice.toStringAsFixed(2),
            Icons.local_offer_rounded,
            Colors.teal,
          ),
      ],
    );
  }
}

class _ActionsBar extends StatelessWidget {
  final VoidCallback edit;
  final VoidCallback del;
  final double value;

  const _ActionsBar({
    required this.edit,
    required this.del,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ActionButton(
            text: 'تعديل',
            icon: Icons.edit_rounded,
            baseColor: Colors.blueAccent,
            onPressed: edit,
            fontSize: value + 1,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: ActionButton(
            text: 'حذف',
            icon: Icons.delete_rounded,
            baseColor: Colors.redAccent,
            onPressed: del,
            fontSize: value + 1,
          ),
        ),
      ],
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
