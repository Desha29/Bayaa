import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import 'cart_item.dart';

class CartList extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final void Function(int) onRemove;
  final void Function(int) onQtyIncrease;
  final void Function(int) onQtyDecrease;

  const CartList({
    super.key,
    required this.items,
    required this.onRemove,
    required this.onQtyIncrease,
    required this.onQtyDecrease,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text("لا توجد منتجات في السلة"));
    }
    final isMobile = MediaQuery.of(context).size.width < 1000;
    return Card(
      color: AppColors.kCardBackground,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 12 : 20,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Text(
                      'قائمة المنتجات',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 16 : 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xffeef6f6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '(${items.length})',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: items.length,
              separatorBuilder: (_, __) =>
                  const Divider(indent: 20, endIndent: 20),
              itemBuilder: (context, index) {
                final item = items[index];
                return CartItemRow(
                  id: item['id'],
                  name: item['name'],
                  price: item['price'],
                  quantity: item['qty'],
                  date: item['date'],
                  onRemove: () => onRemove(index),
                  onQtyIncrease: () => onQtyIncrease(index),
                  onQtyDecrease: () => onQtyDecrease(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
