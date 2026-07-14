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
          final crossAxisCount = isDesktop ? 5 : isTablet ? 2 : 1;
          final childAspectRatio = isDesktop ? 1.6 : isTablet ? 1.8 : 2.2;

          return Column(children: [
            GridView.count(
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
                title: l10n.localeName == 'ar' ? 'المصروفات التشغيلية' : 'Operating expenses',
                value: '${summary.totalExpenses.toStringAsFixed(2)} ${l10n.currencyEg}',
                icon: Icons.account_balance_wallet_outlined,
                color: const Color(0xFFEF4444),
                subtitle: l10n.localeName == 'ar'
                    ? 'مخصومة من صافي الربح'
                    : 'Deducted from net profit',
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
            ),
            const SizedBox(height: 18),
            _buildFinancialFlow(context),
          ]);
        },
      ),
    );
  }

  Widget _buildFinancialFlow(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final values = [
      (l10n.localeName == 'ar' ? 'صافي المبيعات' : 'Net sales', summary.totalRevenue, const Color(0xFF10B981)),
      (l10n.localeName == 'ar' ? 'تكلفة المنتجات' : 'Product cost', summary.totalCost, const Color(0xFFF59E0B)),
      (l10n.localeName == 'ar' ? 'المصروفات' : 'Expenses', summary.totalExpenses, const Color(0xFFEF4444)),
      (l10n.localeName == 'ar' ? 'صافي الربح' : 'Net profit', summary.totalProfit.abs(), const Color(0xFF6366F1)),
    ];
    final maxValue = values.map((item) => item.$2).fold<double>(1, (max, value) => value > max ? value : max);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.borderColor)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l10n.localeName == 'ar' ? 'تدفق الإيرادات والتكاليف' : 'Revenue and cost flow', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 18),
        ...values.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 13),
          child: Row(children: [
            SizedBox(width: 110, child: Text(item.$1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: AppColors.mutedColor))),
            const SizedBox(width: 10),
            Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: item.$2 / maxValue, minHeight: 12, backgroundColor: item.$3.withOpacity(.08), valueColor: AlwaysStoppedAnimation(item.$3)))),
            const SizedBox(width: 10),
            SizedBox(width: 90, child: Text(item.$2.toStringAsFixed(0), textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.w800))),
          ]),
        )),
      ]),
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
