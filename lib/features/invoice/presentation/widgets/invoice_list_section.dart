import 'package:flutter/material.dart';
import '../../../sales/data/models/sale_model.dart';
import 'invoice_card.dart';

import 'package:crazy_phone_pos/core/constants/app_colors.dart';

class InvoiceListSection extends StatelessWidget {
  final bool loading;
  final List<Sale> sales;
  final DateTime? startDate;
  final DateTime? endDate;
  final AnimationController animationController;
  final Function(Sale) onOpenInvoice;
  final Function(Sale) onDeleteSale;
  final Function(Sale) onReturnSale;
  final Function(Sale) onPrintInvoice;
  final bool isManager;

  const InvoiceListSection({
    Key? key,
    required this.loading,
    required this.sales,
    required this.startDate,
    required this.endDate,
    required this.animationController,
    required this.onOpenInvoice,
    required this.onDeleteSale,
    required this.onReturnSale,
    required this.onPrintInvoice,
    required this.isManager,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.primaryColor),
            const SizedBox(height: 16),
            Text(
              'جاري تحميل الفواتير...',
              style: TextStyle(color: AppColors.mutedColor, fontSize: 13),
            ),
          ],
        ),
      );
    }
    if (sales.isEmpty) {
      return Center(
        child: FadeTransition(
          opacity: animationController,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.04),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.receipt_long_outlined,
                  size: 56,
                  color: AppColors.mutedColor.withOpacity(0.35),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                startDate != null || endDate != null
                    ? 'لا توجد فواتير في الفترة المحددة'
                    : 'لا توجد فواتير حديثة',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.mutedColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'جرب تغيير معايير البحث أو الفلتر',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.mutedColor.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return ListView.separated(
      itemCount: sales.length,
      padding: const EdgeInsets.only(bottom: 24),
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) => FadeTransition(
        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animationController,
            curve: Interval(
              (i * 0.06).clamp(0.0, 0.8),
              ((i * 0.06) + 0.2).clamp(0.0, 1.0),
              curve: Curves.easeOut,
            ),
          ),
        ),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.1),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animationController,
              curve: Interval(
                (i * 0.06).clamp(0.0, 0.8),
                ((i * 0.06) + 0.2).clamp(0.0, 1.0),
                curve: Curves.easeOut,
              ),
            ),
          ),
          child: InvoiceCard(
            sale: sales[i],
            onOpen: () => onOpenInvoice(sales[i]),
            onDelete: isManager ? () => onDeleteSale(sales[i]) : null,
            onReturn: (isManager && !sales[i].isRefund) ? () => onReturnSale(sales[i]) : null,
            onPrint: () => onPrintInvoice(sales[i]),
            isManager: isManager,
          ),
        ),
      ),
    );
  }
}
