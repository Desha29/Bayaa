import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:bayaa_pos/l10n/app_localizations.dart';

class RecentSalesSection extends StatelessWidget {
  final List<Map<String, dynamic>> recentSales;
  final VoidCallback? onToggleCollapse;

  const RecentSalesSection({
    super.key,
    required this.recentSales,
    this.onToggleCollapse,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      height: double.infinity,
      constraints: const BoxConstraints(minHeight: 500),
      padding: const EdgeInsets.all(24),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryColor.withOpacity(0.1),
                      AppColors.primaryColor.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  LucideIcons.history,
                  color: AppColors.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.recentSalesTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (onToggleCollapse != null)
                IconButton(
                  icon: Transform.flip(
                    flipX: l10n.localeName == 'ar',
                    child: const Icon(
                      LucideIcons.chevronRight,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  tooltip: l10n.hideRecentSales,
                  onPressed: onToggleCollapse,
                ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: recentSales.isEmpty
                ? _buildEmptyState(context)
                : ListView.separated(
                    itemCount: recentSales.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 24,
                      color: AppColors.borderColor.withOpacity(0.5),
                    ),
                    itemBuilder: (context, index) {
                      final sale = recentSales[index];
                      final date = sale['date'] as DateTime;
                      return _buildRecentSaleItem(context, sale, date);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
              Icons.receipt_long_outlined,
              size: 48,
              color: AppColors.mutedColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noSales,
            style: TextStyle(
              color: AppColors.mutedColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSaleItem(BuildContext context, Map<String, dynamic> sale, DateTime date) {
    final l10n = AppLocalizations.of(context);
    final isRefund = sale['isRefund'] == true;
    final color = isRefund ? AppColors.warningColor : AppColors.successColor;
    final icon = isRefund ? LucideIcons.cornerUpLeft : LucideIcons.shoppingCart;
    final timeFormat = DateFormat('hh:mm a');

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.15),
                  color.withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isRefund ? l10n.refundProcess : l10n.saleProcess,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.saleItemsSummary(sale['items'], sale['total'].toStringAsFixed(0), l10n.currencyEg),
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            timeFormat.format(date),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
