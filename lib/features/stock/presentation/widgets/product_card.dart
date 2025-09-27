import 'package:flutter/material.dart';

import 'priorty_chip.dart';
import 'status_chip.dart';
class Product {
  String code;
  String name;
  int quantity;
  int min;
  String lastRestock;

  Product({
    required this.code,
    required this.name,
    required this.quantity,
    required this.min,
    required this.lastRestock,
  });

  String get status {
    if (quantity == 0) return 'غير متوفر';
    if (quantity < min) return 'مخزون منخفض';
    return 'متوفر';
  }

  String get priority {
    if (quantity == 0) return 'عاجل جداً';
    final diff = min - quantity;
    if (diff >= 3) return 'عاجل';
    if (diff == 1 || diff == 2) return 'متوسط';
    return 'منخفض';
  }
}
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onRestock;

  const ProductCard({
    super.key,
    required this.product,
    required this.onRestock,
  });

  @override
  Widget build(BuildContext context) {
    final isOut = product.quantity == 0;
    final isLow = product.quantity > 0 && product.quantity < product.min;

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOut
              ? Colors.red.withOpacity(0.3)
              : isLow
              ? Colors.orange.withOpacity(0.3)
              : Colors.grey.withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with product name and code
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          product.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'كود: ${product.code}',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                PriorityChip(priority: product.priority),
              ],
            ),

            const SizedBox(height: 16),

            // Quantity information
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('الكمية الحالية:'),
                      Text(
                        product.quantity.toString(),
                        style: TextStyle(
                          color: isOut
                              ? const Color(0xFFEF4444)
                              : (isLow
                                    ? const Color(0xFFF59E0B)
                                    : const Color(0xFF10B981)),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('الحد الأدنى:'),
                      Text(
                        product.min.toString(),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('آخر تخزين:'),
                      Text(
                        product.lastRestock,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Status and Action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StatusChip(isOut: isOut, isLow: isLow),
                ElevatedButton.icon(
                  onPressed: onRestock,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('إعادة التخزين'),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
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