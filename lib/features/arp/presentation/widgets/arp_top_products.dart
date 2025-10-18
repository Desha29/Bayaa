// lib/features/arp/presentation/widgets/arp_top_products.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/arp_summary_model.dart';


class ArpTopProducts extends StatelessWidget {
  final List<ProductPerformanceModel> products;

  const ArpTopProducts({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 32 : isTablet ? 24 : 16,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.star_outline,
                      color: Color(0xFF10B981),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'المنتجات الأكثر مبيعاً',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.kDarkChip,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (products.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'لا توجد منتجات',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: products.length,
                  separatorBuilder: (context, index) => const Divider(height: 24),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return _buildProductItem(product, index + 1);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductItem(ProductPerformanceModel product, int rank) {
    final isProfit = product.profit >= 0;

    return Row(
      children: [
        // Rank badge
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: rank <= 3
                ? AppColors.primaryColor.withOpacity(0.1)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '$rank',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: rank <= 3 ? AppColors.primaryColor : Colors.grey,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Product info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.productName,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.kDarkChip,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'الكمية: ${product.quantitySold} • التكلفة: ${product.cost.toStringAsFixed(2)} ج.م',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),

        // Profit/Loss
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${product.revenue.toStringAsFixed(2)} ج.م',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.kDarkChip,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isProfit
                    ? const Color(0xFF10B981).withOpacity(0.1)
                    : const Color(0xFFEF4444).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isProfit ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 12,
                    color: isProfit ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${product.profitMargin.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isProfit ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
