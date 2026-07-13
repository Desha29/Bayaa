import 'package:flutter/material.dart';

import '../../data/models/analytics_summary_model.dart';

import 'package:bayaa_pos/core/constants/app_colors.dart';
import 'package:bayaa_pos/l10n/app_localizations.dart';

class AnalyticsSummaryCards extends StatelessWidget {
  final AnalyticsSummaryModel summary;

  const AnalyticsSummaryCards({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 32 : isTablet ? 24 : 16,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = isDesktop ? 4 : isTablet ? 2 : 1;
          final childAspectRatio = isDesktop ? 1.6 : isTablet ? 1.8 : 2.2;

          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: childAspectRatio,
            children: [
              _buildSummaryCard(
                title: l10n.totalSalesAnalytics,
                value: '${summary.totalRevenue.toStringAsFixed(2)} ${l10n.currencyEg}',
                icon: Icons.trending_up,
                color: const Color(0xFF10B981),
                subtitle: l10n.salesCount(summary.totalSales),
              ),
              _buildSummaryCard(
                title: l10n.costAnalytics,
                value: '${summary.totalCost.toStringAsFixed(2)} ${l10n.currencyEg}',
                icon: Icons.shopping_cart_outlined,
                color: const Color(0xFFF59E0B),
                subtitle: l10n.productsCost,
              ),
              _buildSummaryCard(
                title: summary.isProfitable ? l10n.netProfitAnalytics : l10n.lossLabel,
                value: '${summary.totalProfit.abs().toStringAsFixed(2)} ${l10n.currencyEg}',
                icon: summary.isProfitable ? Icons.attach_money : Icons.money_off,
                color: summary.isProfitable ? const Color(0xFF6366F1) : const Color(0xFFEF4444),
                subtitle: l10n.marginLabel(summary.profitMargin.toStringAsFixed(1)),
              ),
              _buildSummaryCard(
                title: l10n.avgSaleAnalytics,
                value: '${summary.averageSaleValue.toStringAsFixed(2)} ${l10n.currencyEg}',
                icon: Icons.calculate_outlined,
                color: const Color(0xFF8B5CF6),
                subtitle: l10n.perSaleLabel,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Container(
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.mutedColor,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.mutedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
