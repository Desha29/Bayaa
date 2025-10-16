import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

import 'cart_item.dart';


class CartSection extends StatelessWidget {
  final List<Map<String, dynamic>> cartItems;
  final Function(int)? onRemoveItem;
  final Function(int)? onIncreaseQty;
  final Function(int)? onDecreaseQty;

  const CartSection({
    super.key,
    required this.cartItems,
    this.onRemoveItem,
    this.onIncreaseQty,
    this.onDecreaseQty,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1000),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.95 + (0.05 * value),
            child: child,
          ),
        );
      },
      child: Container(
        height: 450,
        decoration: BoxDecoration(
          color: AppColors.kCardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.shopping_cart_outlined,
                      color: AppColors.primaryColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'قائمة المنتجات',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondaryColor,
                        ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '(${cartItems.length})',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: AppColors.borderColor),
            Expanded(
              child: cartItems.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: cartItems.length,
                      separatorBuilder: (_, __) => Divider(
                        indent: 20,
                        endIndent: 20,
                        color: AppColors.borderColor.withOpacity(0.5),
                      ),
                      itemBuilder: (context, index) {
                        final item = cartItems[index];
                        return CartItemRow(
                          name: item['name'],
                          id: item['id'],
                          price: item['price'],
                          quantity: item['qty'],
                          date: item['date'],
                          onRemove: () => onRemoveItem?.call(index),
                          onIncrease: () => onIncreaseQty?.call(index),
                          onDecrease: () => onDecreaseQty?.call(index),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: AppColors.mutedColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'السلة فارغة',
            style: TextStyle(
              color: AppColors.mutedColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'قم بمسح المنتجات لإضافتها',
            style: TextStyle(
              color: AppColors.mutedColor.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
