import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../sales/data/models/sale_model.dart';

import 'package:crazy_phone_pos/core/constants/app_colors.dart';

class InvoiceCard extends StatelessWidget {
  final Sale sale;
  final VoidCallback onOpen;
  final VoidCallback? onDelete;
  final VoidCallback? onReturn;
  final VoidCallback onPrint;
  final bool isManager;

  const InvoiceCard({
    Key? key,
    required this.sale,
    required this.onOpen,
    this.onReturn,
    required this.onPrint,
    this.onDelete,
    required this.isManager,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('yyyy-MM-dd  HH:mm');
    final cashierName = sale.cashierName ?? 'الكاشير';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onOpen,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.receipt_long,
                    color: AppColors.primaryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'فاتورة #${sale.id}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.kDarkChip,
                            ),
                          ),
                          if (sale.isRefund) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.errorColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'مرتجع',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.errorColor,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 14,
                            color: AppColors.mutedColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            cashierName,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.mutedColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            ' • ',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.mutedColor,
                            ),
                          ),
                          Text(
                            '${sale.items} صنف',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.mutedColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        df.format(sale.date),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.mutedColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${sale.total.toStringAsFixed(2)} ج.م',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (onReturn != null) ...[
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.undo,
                                  color: AppColors.primaryColor, size: 20),
                              tooltip: 'مرتجع الفاتورة',
                              onPressed: onReturn,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (isManager && onDelete != null)
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.errorColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.delete,
                                  color: AppColors.errorColor, size: 20),
                              tooltip: 'حذف الفاتورة',
                              onPressed: onDelete,
                            ),
                          ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.print,
                                color: AppColors.primaryColor, size: 20),
                            tooltip: 'طباعة الفاتورة',
                            onPressed: onPrint,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
