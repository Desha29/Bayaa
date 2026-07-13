// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

import '../../../sessions/data/models/product_performance_model.dart';



class AnalyticsTopProducts extends StatelessWidget {
  final List<ProductPerformanceModel> products;
  final bool usePadding;

  const AnalyticsTopProducts({super.key, required this.products, this.usePadding = true});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: usePadding
            ? (isDesktop
                ? 32
                : isTablet
                    ? 24
                    : 16)
            : 0.0,
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
                  Text(
                    l10n.topSellingProducts,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.kDarkChip,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: isDesktop ? 200 : isTablet ? 160 : null,
                child: products.isEmpty
                    ? Center(
                        child: Text(
                          l10n.noProducts,
                          style: const TextStyle(color: AppColors.mutedColor),
                        ),
                      )
                    : Builder(
                        builder: (context) {
                          final maxRev = products.isNotEmpty ? products.first.revenue : 0.0;
                          return ListView.separated(
                            shrinkWrap: true,
                            physics: (isDesktop || isTablet)
                                ? const AlwaysScrollableScrollPhysics()
                                : const NeverScrollableScrollPhysics(),
                            itemCount: products.length,
                            separatorBuilder: (context, index) => const Divider(height: 24),
                            itemBuilder: (context, index) {
                              final product = products[index];
                              return _buildProductItem(context, product, index + 1, maxRev); 
                            },
                          );
                        }
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductItem(BuildContext context, ProductPerformanceModel product, int rank, double maxRevenue) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.productName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${product.revenue.toStringAsFixed(0)} ${l10n.currencyEg}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.soldCount(product.quantitySold),
                    style: const TextStyle(fontSize: 11, color: AppColors.mutedColor),
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
