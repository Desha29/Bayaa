import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class RecentSalesSection extends StatelessWidget {
  final List<Map<String, dynamic>> recentSales;

  const RecentSalesSection({
    super.key,
    required this.recentSales,
  });

  @override
  Widget build(BuildContext context) {
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.warningColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.history,
                  color: AppColors.warningColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'المبيعات الأخيرة',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondaryColor,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: recentSales.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    itemCount: recentSales.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 24,
                      color: AppColors.borderColor.withOpacity(0.5),
                    ),
                    itemBuilder: (context, index) {
                      final sale = recentSales[index];
                      final date = sale['date'] as DateTime;
                      return _buildRecentSaleItem(sale, date);
                    },
                  ),
          ),
        ],
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
              Icons.receipt_long_outlined,
              size: 48,
              color: AppColors.mutedColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد مبيعات',
            style: TextStyle(
              color: AppColors.mutedColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSaleItem(Map<String, dynamic> sale, DateTime date) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (sale['isRefund'] == true)
              ? Colors.red.withOpacity(0.5)
              : Colors.green.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${sale['total'].toStringAsFixed(0)} ج.م',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.secondaryColor,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: (sale['isRefund'] == true) ? Colors.red : Colors.green,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  (sale['isRefund'] == true)
                      ? 'مرتجع (${sale['items']})'
                      : '${sale['items']} منتج',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 14,
                color: AppColors.mutedColor,
              ),
              const SizedBox(width: 6),
              Text(
                '${date.year}/${date.month}/${date.day} - ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  color: AppColors.mutedColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
