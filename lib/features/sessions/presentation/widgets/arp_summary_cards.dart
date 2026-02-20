import 'package:flutter/material.dart';

import '../../data/models/arp_summary_model.dart';

import 'package:crazy_phone_pos/core/constants/app_colors.dart';

class ArpSummaryCards extends StatelessWidget {
  final ArpSummaryModel summary;

  const ArpSummaryCards({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
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
                title: 'إجمالي المبيعات',
                value: '${summary.totalRevenue.toStringAsFixed(2)} ج.م',
                icon: Icons.trending_up,
                color: const Color(0xFF10B981),
                subtitle: '${summary.totalSales} عملية بيع',
              ),
              _buildSummaryCard(
                title: 'التكلفة الكلية',
                value: '${summary.totalCost.toStringAsFixed(2)} ج.م',
                icon: Icons.shopping_cart_outlined,
                color: const Color(0xFFF59E0B),
                subtitle: 'تكلفة المنتجات',
              ),
              _buildSummaryCard(
                title: summary.isProfitable ? 'صافي الربح' : 'الخسارة',
                value: '${summary.totalProfit.abs().toStringAsFixed(2)} ج.م',
                icon: summary.isProfitable ? Icons.attach_money : Icons.money_off,
                color: summary.isProfitable ? const Color(0xFF6366F1) : const Color(0xFFEF4444),
                subtitle: '${summary.profitMargin.toStringAsFixed(1)}% هامش',
              ),
              _buildSummaryCard(
                title: 'متوسط البيعة',
                value: '${summary.averageSaleValue.toStringAsFixed(2)} ج.م',
                icon: Icons.calculate_outlined,
                color: const Color(0xFF8B5CF6),
                subtitle: 'لكل عملية بيع',
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
