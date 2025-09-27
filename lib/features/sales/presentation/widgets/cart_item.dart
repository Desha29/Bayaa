import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';

class CartItemRow extends StatelessWidget {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final DateTime date;
  final VoidCallback onRemove;
  final VoidCallback onQtyIncrease;
  final VoidCallback onQtyDecrease;

  const CartItemRow({super.key, 
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.date,
    required this.onRemove,
    required this.onQtyIncrease,
    required this.onQtyDecrease,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = price * quantity;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  child: Text(
                    "$name (كود: $id)",
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  "تاريخ: ${date.year}/${date.month}/${date.day}",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text('${price.toStringAsFixed(0)} ج.م'),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildQtyButton(LucideIcons.minus, onQtyDecrease),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '$quantity',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                _buildQtyButton(LucideIcons.plus, onQtyIncrease),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text('${total.toStringAsFixed(0)} ج.م'),
            ),
          ),
          IconButton(
            icon: const Icon(LucideIcons.trash2, size: 18),
            onPressed: onRemove,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.kDangerRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
 Widget _buildQtyButton(IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: 30,
      height: 30,
      child: IconButton(
        icon: Icon(icon, size: 14),
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: Colors.grey[200],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }