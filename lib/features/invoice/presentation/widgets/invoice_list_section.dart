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
    required this.isManager,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (sales.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: AppColors.mutedColor.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            Text(
              startDate != null || endDate != null
                  ? 'لا توجد فواتير في الفترة المحددة'
                  : 'لا توجد فواتير حديثة',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.mutedColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      itemCount: sales.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) => FadeTransition(
        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animationController,
            curve: Interval(
              (i * 0.1).clamp(0.0, 1.0),
              ((i * 0.1) + 0.3).clamp(0.0, 1.0),
              curve: Curves.easeOut,
            ),
          ),
        ),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.2),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animationController,
              curve: Interval(
                (i * 0.1).clamp(0.0, 1.0),
                ((i * 0.1) + 0.3).clamp(0.0, 1.0),
                curve: Curves.easeOut,
              ),
            ),
          ),
          child: InvoiceCard(
            sale: sales[i],
            onOpen: () => onOpenInvoice(sales[i]),
            onDelete: isManager ? () => onDeleteSale(sales[i]) : null,
            onReturn: () => onReturnSale(sales[i]),
            isManager: isManager,
          ),
        ),
      ),
    );
  }
}
