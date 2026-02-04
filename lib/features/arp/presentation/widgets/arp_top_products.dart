// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

import '../../data/models/product_performance_model.dart';

import 'package:crazy_phone_pos/core/constants/app_colors.dart';

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
        horizontal: isDesktop
            ? 32
            : isTablet
                ? 24
                : 16,
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
                      style: TextStyle(color: AppColors.mutedColor),
                    ),
                  ),
                )
              else
                Builder(
                  builder: (context) {
                    final maxRev = products.isNotEmpty ? products.first.revenue : 0.0;
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: products.length,
                      separatorBuilder: (context, index) => const Divider(height: 24),
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return _buildProductItem(product, index + 1, maxRev); 
                      },
                    );
                  }
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductItem(ProductPerformanceModel product, int rank, double maxRevenue) {
    // Avoid division by zero
    final ratio = maxRevenue > 0 ? (product.revenue / maxRevenue) : 0.0;
    
    return Column(
      children: [
        Row(
          children: [
            // Rank
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: rank <= 3 ? AppColors.primaryColor : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: rank <= 3 ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Info Row
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      product.productName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${product.revenue.toStringAsFixed(0)} ج.م',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryColor),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Bar
        Row(
          children: [
             const SizedBox(width: 40), // Offset for rank
             Expanded(
               child: Stack(
                 children: [
                   Container(
                     height: 8,
                     decoration: BoxDecoration(
                       color: Colors.grey.shade100,
                       borderRadius: BorderRadius.circular(4),
                     ),
                   ),
                   FractionallySizedBox(
                     widthFactor: ratio,
                     child: Container(
                       height: 8,
                       decoration: BoxDecoration(
                         gradient: LinearGradient(
                           colors: [
                             rank <= 3 ? AppColors.secondaryColor : Colors.grey.shade400,
                             rank <= 3 ? AppColors.primaryColor : Colors.grey.shade500,
                           ],
                         ),
                         borderRadius: BorderRadius.circular(4),
                       ),
                     ),
                   ),
                 ],
               ),
             ),
          ],
        ),
        const SizedBox(height: 4),
        // Detail (Quantity)
        Padding(
          padding: const EdgeInsets.only(right: 40),
          child: Text(
            'بيع: ${product.quantitySold} قطعة',
            style: const TextStyle(fontSize: 12, color: AppColors.mutedColor),
          ),
        ),
      ],
    );
  }
}
