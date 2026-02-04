import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

import '../cubit/invoice_state.dart';

class InvoiceFilterSection extends StatelessWidget {
  final bool isDesktop;
  final TextEditingController barcodeSearchController;
  final String searchQuery;
  final Function(String) onSearch;
  final VoidCallback onClearSearch;
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(bool) onSelectDate;
  final VoidCallback onClearFilters;
  final VoidCallback onDeleteInvoices;
  final InvoiceFilterType filterType;
  final Function(InvoiceFilterType) onFilterTypeChanged;
  final bool isManager;
  final FocusNode? focusNode;
  final Function(String)? onChanged;

  const InvoiceFilterSection({
    Key? key,
    required this.isDesktop,
    required this.barcodeSearchController,
    required this.searchQuery,
    required this.onSearch,
    required this.onClearSearch,
    required this.startDate,
    required this.endDate,
    required this.onSelectDate,
    required this.onClearFilters,
    required this.onDeleteInvoices,
    required this.filterType,
    required this.onFilterTypeChanged,
    required this.isManager,
    this.focusNode,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
      padding: const EdgeInsets.all(20),
      child: isDesktop
          ? Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.qr_code_scanner,
                        color: AppColors.primaryColor, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      'بحث بالباركود',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.kDarkChip,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        focusNode: focusNode,
                        controller: barcodeSearchController,
                        decoration: InputDecoration(
                          hintText: 'امسح الباركود أو اكتب رقم الفاتورة',
                          prefixIcon:
                              Icon(Icons.search, color: AppColors.primaryColor),
                          suffixIcon: null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: AppColors.mutedColor.withOpacity(0.4)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: AppColors.mutedColor.withOpacity(0.4)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: AppColors.primaryColor, width: 2),
                          ),
                        ),
                        onSubmitted: onSearch,
                        onChanged: onChanged,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
                if (searchQuery.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search,
                            color: AppColors.primaryColor, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'البحث عن: $searchQuery',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                _buildFilterTypeSelector(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                        child: _buildDateButton('من تاريخ', startDate, true)),
                    const SizedBox(width: 16),
                    Expanded(
                        child: _buildDateButton('إلى تاريخ', endDate, false)),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: onClearFilters,
                      icon: const Icon(Icons.clear_all, size: 20),
                      label: const Text('مسح الفلاتر'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mutedColor.withOpacity(0.15),
                        foregroundColor: AppColors.kDarkChip,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),
                    if (isManager)
                      Tooltip(
                        message: startDate == null || endDate == null
                            ? 'يجب تحديد نطاق التاريخ أولاً'
                            : 'حذف الفواتير',
                        child: ElevatedButton.icon(
                          onPressed: (startDate != null && endDate != null)
                              ? onDeleteInvoices
                              : null,
                          icon: const Icon(Icons.delete_sweep, size: 20),
                          label: const Text('مسح الفواتير'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.errorColor,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: AppColors.mutedColor.withOpacity(0.3),
                            disabledForegroundColor: AppColors.mutedColor,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            )
          : Column(
              children: [
                _buildFilterTypeSelector(),
                const SizedBox(height: 16),
                _buildDateButton('من تاريخ', startDate, true),
                const SizedBox(height: 12),
                _buildDateButton('إلى تاريخ', endDate, false),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onClearFilters,
                    icon: const Icon(Icons.clear_all, size: 20),
                    label: const Text('مسح الفلاتر'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mutedColor.withOpacity(0.15),
                      foregroundColor: AppColors.mutedColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterTypeSelector() {
    return Row(
      children: [
        const Text(
          'تصفية حسب:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.kDarkChip,
          ),
        ),
        const SizedBox(width: 12),
        Wrap(
          spacing: 8,
          children: [
            _buildFilterChip('الكل', InvoiceFilterType.all),
            _buildFilterChip('مبيعات', InvoiceFilterType.sales),
            _buildFilterChip('مرتجعات', InvoiceFilterType.refunded),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, InvoiceFilterType type) {
    final isSelected = filterType == type;
    return InkWell(
      onTap: () => onFilterTypeChanged(type),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor
                : AppColors.mutedColor.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.mutedColor,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildDateButton(String label, DateTime? date, bool isStart) {
    return InkWell(
      onTap: () => onSelectDate(isStart),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.mutedColor.withOpacity(0.4)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: AppColors.primaryColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.mutedColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date != null
                        ? '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}'
                        : 'اختر التاريخ',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.kDarkChip,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
