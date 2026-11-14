import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bayaa_pos/shared/theme/app_colors.dart';
import 'package:bayaa_pos/l10n/app_localizations.dart';
import '../controllers/invoice_state.dart';

class InvoiceFilterSection extends StatelessWidget {
  const InvoiceFilterSection({
    super.key,
    required this.barcodeSearchController,
    required this.searchQuery,
    required this.onSearch,
    required this.onChanged,
    required this.onClearSearch,
    required this.startDate,
    required this.endDate,
    required this.onSelectDate,
    required this.onClearFilters,
    required this.filterType,
    required this.onFilterTypeChanged,
    this.focusNode,
  });

  final TextEditingController barcodeSearchController;
  final FocusNode? focusNode;
  final String searchQuery;
  final ValueChanged<String> onSearch, onChanged;
  final VoidCallback onClearSearch, onClearFilters;
  final DateTime? startDate, endDate;
  final ValueChanged<bool> onSelectDate;
  final InvoiceFilterType filterType;
  final ValueChanged<InvoiceFilterType> onFilterTypeChanged;

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    final l = AppLocalizations.of(context);
    final ar = l.localeName == 'ar';
    final hasActiveFilter = filterType != InvoiceFilterType.all ||
        startDate != null ||
        endDate != null ||
        searchQuery.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderColor.withOpacity(0.9)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: TextField(
              controller: barcodeSearchController,
              focusNode: focusNode,
              onChanged: onChanged,
              onSubmitted: onSearch,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                hintText: l.searchInvoiceHint2,
                hintStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.mutedColor,
                  fontSize: 13,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: AppColors.primaryColor,
                ),
                suffixIcon: searchQuery.isEmpty
                    ? null
                    : IconButton(
                        tooltip: ar ? 'مسح البحث' : 'Clear search',
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () {
                          onClearSearch();
                          focusNode?.requestFocus();
                        },
                      ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final e in [
                      (InvoiceFilterType.all, l.all),
                      (InvoiceFilterType.sales, l.salesFilter),
                      (InvoiceFilterType.refunded, l.refundsFilter)
                    ])
                      InkWell(
                        onTap: () => onFilterTypeChanged(e.$1),
                        borderRadius: BorderRadius.circular(9),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: filterType == e.$1
                                ? AppColors.surfaceColor
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(9),
                            boxShadow: filterType == e.$1
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.06),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    )
                                  ]
                                : null,
                          ),
                          child: Text(
                            e.$2,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: filterType == e.$1
                                  ? FontWeight.w700
                                  : FontWeight.bold,
                              color: filterType == e.$1
                                  ? AppColors.primaryColor
                                  : AppColors.mutedColor,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              _dateChip(
                context,
                label: l.fromDate,
                date: startDate,
                isActive: startDate != null,
                onTap: () => onSelectDate(true),
              ),
              _dateChip(
                context,
                label: l.toDate,
                date: endDate,
                isActive: endDate != null,
                onTap: () => onSelectDate(false),
              ),
              if (hasActiveFilter)
                InkWell(
                  onTap: onClearFilters,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.errorColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppColors.errorColor.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.restart_alt_rounded,
                            size: 15, color: AppColors.errorColor),
                        const SizedBox(width: 5),
                        Text(
                          ar ? 'إعادة تعيين' : 'Reset',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.errorColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dateChip(
    BuildContext context, {
    required String label,
    required DateTime? date,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primaryColor.withOpacity(0.08)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive
                ? AppColors.primaryColor.withOpacity(0.3)
                : AppColors.borderColor,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 14,
              color: isActive ? AppColors.primaryColor : AppColors.mutedColor,
            ),
            const SizedBox(width: 7),
            Text(
              date == null ? label : DateFormat('dd/MM/yyyy').format(date),
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.bold,
                color:
                    isActive ? AppColors.primaryColor : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
