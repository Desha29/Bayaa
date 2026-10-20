import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../invoice/presentation/cubit/invoice_cubit.dart';
import '../../../invoice/presentation/cubit/invoice_state.dart';

class RecentOperationsTable extends StatefulWidget {
  final VoidCallback onShowAll;

  const RecentOperationsTable({super.key, required this.onShowAll});

  @override
  State<RecentOperationsTable> createState() => _RecentOperationsTableState();
}

class _RecentOperationsTableState extends State<RecentOperationsTable> {
  int _selectedFilter = 0; // 0: All, 1: Sales, 2: Refunds

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = l10n.localeName == 'ar';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with filters and Show all
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isArabic ? 'العمليات الأخيرة' : 'Recent Operations',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              InkWell(
                onTap: widget.onShowAll,
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    isArabic ? 'عرض الكل >' : 'Show all >',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Filter pills (Behance Arrival / Available tabs style)
          Row(
            children: [
              _buildFilterChip(
                label: isArabic ? 'الكل' : 'All',
                index: 0,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: isArabic ? 'المبيعات' : 'Sales',
                index: 1,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: isArabic ? 'المرتجعات' : 'Refunds',
                index: 2,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Data table
          BlocBuilder<InvoiceCubit, InvoiceState>(
            bloc: getIt<InvoiceCubit>(),
            builder: (context, state) {
              var sales = state.sales;

              if (_selectedFilter == 1) {
                sales = sales.where((s) => !s.isRefund).toList();
              } else if (_selectedFilter == 2) {
                sales = sales.where((s) => s.isRefund).toList();
              }

              if (sales.isEmpty) {
                return Container(
                  height: 140,
                  alignment: Alignment.center,
                  child: Text(
                    isArabic ? 'لا توجد حركات مسجلة' : 'No recent operations',
                    style: const TextStyle(color: AppColors.mutedColor, fontSize: 13),
                  ),
                );
              }

              // Show latest 5 items
              final latestSales = sales.take(5).toList();

              return Column(
                children: [
                  // Table Header
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            isArabic ? 'رقم الفاتورة' : 'Invoice #',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.mutedColor,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            isArabic ? 'الكاشير / العميل' : 'Cashier / User',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.mutedColor,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            isArabic ? 'الوقت' : 'Time',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.mutedColor,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            isArabic ? 'الإجمالي' : 'Total',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.mutedColor,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: Text(
                              isArabic ? 'الحالة' : 'Status',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.mutedColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Rows
                  ...latestSales.map((sale) {
                    final timeStr = DateFormat('hh:mm a', l10n.localeName).format(sale.date);
                    final isRefund = sale.isRefund;
                    final invoiceNum = sale.id;
                    final customerOrCashier = sale.cashierName?.isNotEmpty == true
                        ? sale.cashierName!
                        : (sale.cashierUsername?.isNotEmpty == true
                            ? sale.cashierUsername!
                            : '-');

                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              '#$invoiceNum',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              customerOrCashier,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              timeStr,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.mutedColor,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              '${sale.total.toStringAsFixed(2)} ${l10n.currencyEg}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isRefund ? AppColors.errorColor : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Align(
                              alignment: AlignmentDirectional.centerEnd,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isRefund
                                      ? const Color(0xFFFEF2F2)
                                      : const Color(0xFFECFDF5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  isRefund
                                      ? (isArabic ? 'مرتجع' : 'Refund')
                                      : (isArabic ? 'مكتمل' : 'Paid'),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: isRefund
                                        ? const Color(0xFFDC2626)
                                        : const Color(0xFF059669),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({required String label, required int index}) {
    final isSelected = _selectedFilter == index;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = index),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondaryColor : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.mutedColor,
          ),
        ),
      ),
    );
  }
}
