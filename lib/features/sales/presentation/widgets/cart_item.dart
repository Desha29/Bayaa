import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';


class CartItemRow extends StatelessWidget {
  final String name;
  final String id;
  final double price;
  final int quantity;
  final DateTime date;
  final VoidCallback? onRemove;
  final VoidCallback? onIncrease;
  final VoidCallback? onDecrease;

  const CartItemRow({
    super.key,
    required this.name,
    required this.id,
    required this.price,
    required this.quantity,
    required this.date,
    this.onRemove,
    this.onIncrease,
    this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    final total = price * quantity;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;

          return Row(
            children: [
              Expanded(
                flex: isWide ? 4 : 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$name (كود: $id)',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'تاريخ: ${date.year}/${date.month}/${date.day}',
                      style: TextStyle(
                        color: AppColors.mutedColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (isWide) const SizedBox(width: 12),
              Expanded(
                flex: isWide ? 2 : 2,
                child: Text(
                  '${price.toStringAsFixed(0)} ج.م',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              Expanded(
                flex: isWide ? 3 : 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildQtyButton(Icons.remove, onDecrease),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '$quantity',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    _buildQtyButton(Icons.add, onIncrease),
                  ],
                ),
              ),
              if (isWide) const SizedBox(width: 12),
              Expanded(
                flex: isWide ? 2 : 2,
                child: Text(
                  '${total.toStringAsFixed(0)} ج.م',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                onPressed: onRemove ?? () {},
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.kDangerRed,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildQtyButton(IconData icon, VoidCallback? onPressed) {
    return InkWell(
      onTap: onPressed ?? () {},
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Icon(icon, size: 16, color: AppColors.secondaryColor),
      ),
    );
  }
}
