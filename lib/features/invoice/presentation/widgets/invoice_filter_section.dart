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
        border: Border.all(color: AppColors.borderColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(isDesktop ? 20 : 16),
      child: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
    );
  }

  Widget _buildDesktopLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Row
        Row(
          children: [
            Expanded(
              child: _buildSearchField(),
            ),
            if (searchQuery.isNotEmpty) ...[
              const SizedBox(width: 12),
              _buildSearchBadge(),
            ],
          ],
        ),
        const SizedBox(height: 16),
        // Filter + Date + Actions Row
        Row(
          children: [
            _buildFilterTypeSelector(),
            const SizedBox(width: 20),
            Container(
              width: 1,
              height: 36,
              color: AppColors.borderColor.withOpacity(0.3),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Row(
                children: [
                  Flexible(child: _buildDateButton('من تاريخ', startDate, true)),
                  const SizedBox(width: 12),
                  Flexible(child: _buildDateButton('إلى تاريخ', endDate, false)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _buildClearButton(),
            if (isManager) ...[
              const SizedBox(width: 8),
              _buildDeleteButton(),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSearchField(),
        if (searchQuery.isNotEmpty) ...[
          const SizedBox(height: 10),
          _buildSearchBadge(),
        ],
        const SizedBox(height: 14),
        _buildFilterTypeSelector(),
        const SizedBox(height: 14),
        _buildDateButton('من تاريخ', startDate, true),
        const SizedBox(height: 10),
        _buildDateButton('إلى تاريخ', endDate, false),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: _buildClearButton()),
            if (isManager) ...[
              const SizedBox(width: 8),
              Expanded(child: _buildDeleteButton()),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor.withOpacity(0.4)),
      ),
      child: TextField(
        focusNode: focusNode,
        controller: barcodeSearchController,
        decoration: InputDecoration(
          hintText: 'امسح الباركود أو اكتب رقم الفاتورة...',
          hintStyle: TextStyle(color: AppColors.mutedColor.withOpacity(0.6), fontSize: 13),
          prefixIcon: Icon(Icons.search_rounded, color: AppColors.primaryColor.withOpacity(0.6), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
        onSubmitted: onSearch,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSearchBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_rounded, color: AppColors.primaryColor, size: 14),
          const SizedBox(width: 6),
          Text(
            'بحث: $searchQuery',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: onClearSearch,
            child: Icon(Icons.close_rounded, size: 14, color: AppColors.primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTypeSelector() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildFilterChip('الكل', InvoiceFilterType.all),
        const SizedBox(width: 6),
        _buildFilterChip('مبيعات', InvoiceFilterType.sales),
        const SizedBox(width: 6),
        _buildFilterChip('مرتجعات', InvoiceFilterType.refunded),
      ],
    );
  }

  Widget _buildFilterChip(String label, InvoiceFilterType type) {
    final isSelected = filterType == type;
    return InkWell(
      onTap: () => onFilterTypeChanged(type),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [AppColors.primaryColor, AppColors.secondaryColor],
                )
              : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.borderColor.withOpacity(0.4),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: date != null
              ? AppColors.primaryColor.withOpacity(0.04)
              : AppColors.backgroundColor,
          border: Border.all(
            color: date != null
                ? AppColors.primaryColor.withOpacity(0.2)
                : AppColors.borderColor.withOpacity(0.4),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              color: date != null ? AppColors.primaryColor : AppColors.mutedColor.withOpacity(0.5),
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 11, color: AppColors.mutedColor, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date != null
                        ? '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}'
                        : 'اختر التاريخ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: date != null ? AppColors.textPrimary : AppColors.mutedColor,
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

  Widget _buildClearButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onClearFilters,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.backgroundColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderColor.withOpacity(0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.clear_all_rounded, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              const Text(
                'مسح الفلاتر',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    final enabled = startDate != null && endDate != null;
    return Tooltip(
      message: !enabled ? 'يجب تحديد نطاق التاريخ أولاً' : 'حذف الفواتير',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onDeleteInvoices : null,
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: enabled ? AppColors.errorColor : AppColors.mutedColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.delete_sweep_rounded, size: 18, color: enabled ? Colors.white : AppColors.mutedColor),
                const SizedBox(width: 6),
                Text(
                  'مسح الفواتير',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: enabled ? Colors.white : AppColors.mutedColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
