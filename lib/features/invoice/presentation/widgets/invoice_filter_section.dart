import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../cubit/invoice_state.dart';
import 'package:bayaa_pos/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(isDesktop ? 20 : 16),
      child: isDesktop ? _buildDesktopLayout(l10n) : _buildMobileLayout(l10n),
    );
  }

  Widget _buildDesktopLayout(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Row
        Row(
          children: [
            Expanded(
              child: _buildSearchField(l10n),
            ),
            if (searchQuery.isNotEmpty) ...[
              const SizedBox(width: 12),
              _buildSearchBadge(l10n),
            ],
          ],
        ),
        const SizedBox(height: 16),
        // Filter + Date + Actions Row
        Row(
          children: [
            _buildFilterTypeSelector(l10n),
            const SizedBox(width: 20),
            Container(
              width: 1.2,
              height: 36,
              color: AppColors.borderColor.withOpacity(0.6),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Row(
                children: [
                  Flexible(child: _buildDateButton(l10n.fromDate, startDate, true, l10n: l10n)),
                  const SizedBox(width: 12),
                  Flexible(child: _buildDateButton(l10n.toDate, endDate, false, l10n: l10n)),
                ],
              ),
            ),
            const SizedBox(width: 16),
            _buildClearButton(l10n),
            if (isManager) ...[
              const SizedBox(width: 8),
              _buildDeleteButton(l10n),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildMobileLayout(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSearchField(l10n),
        if (searchQuery.isNotEmpty) ...[
          const SizedBox(height: 10),
          _buildSearchBadge(l10n),
        ],
        const SizedBox(height: 14),
        _buildFilterTypeSelector(l10n),
        const SizedBox(height: 14),
        _buildDateButton(l10n.fromDate, startDate, true, l10n: l10n),
        const SizedBox(height: 10),
        _buildDateButton(l10n.toDate, endDate, false, l10n: l10n),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildClearButton(l10n)),
            if (isManager) ...[
              const SizedBox(width: 8),
              Expanded(child: _buildDeleteButton(l10n)),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildSearchField(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor.withOpacity(0.6)),
      ),
      child: TextField(
        focusNode: focusNode,
        controller: barcodeSearchController,
        style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: l10n.searchInvoiceHint,
          hintStyle: TextStyle(color: AppColors.mutedColor.withOpacity(0.6), fontSize: 13, fontFamily: 'Cairo'),
          prefixIcon: Icon(LucideIcons.search, color: AppColors.primaryColor.withOpacity(0.6), size: 18),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
        onSubmitted: onSearch,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSearchBadge(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.search, color: AppColors.primaryColor, size: 13),
          const SizedBox(width: 6),
          Text(
            l10n.searchLabel(searchQuery),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              fontFamily: 'Cairo',
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: onClearSearch,
            child: const Icon(LucideIcons.x, size: 13, color: AppColors.primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTypeSelector(AppLocalizations l10n) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildFilterChip(l10n.all, InvoiceFilterType.all),
        const SizedBox(width: 6),
        _buildFilterChip(l10n.salesFilter, InvoiceFilterType.sales),
        const SizedBox(width: 6),
        _buildFilterChip(l10n.refundsFilter, InvoiceFilterType.refunded),
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
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [AppColors.primaryColor, AppColors.secondaryColor],
                )
              : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.borderColor.withOpacity(0.8),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w700,
            fontFamily: 'Cairo',
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildDateButton(String label, DateTime? date, bool isStart, {required AppLocalizations l10n}) {
    return InkWell(
      onTap: () => onSelectDate(isStart),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: date != null
              ? AppColors.primaryColor.withOpacity(0.04)
              : AppColors.backgroundColor,
          border: Border.all(
            color: date != null
                ? AppColors.primaryColor.withOpacity(0.24)
                : AppColors.borderColor.withOpacity(0.6),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              LucideIcons.calendar,
              color: date != null ? AppColors.primaryColor : AppColors.mutedColor.withOpacity(0.6),
              size: 16,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 10, color: AppColors.mutedColor, fontWeight: FontWeight.w600, fontFamily: 'Cairo'),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date != null
                        ? '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}'
                        : l10n.selectDate,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
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

  Widget _buildClearButton(AppLocalizations l10n) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onClearFilters,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.backgroundColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderColor.withOpacity(0.6)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.rotateCcw, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                l10n.clearFilters,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Cairo',
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton(AppLocalizations l10n) {
    final enabled = startDate != null && endDate != null;
    return Tooltip(
      message: !enabled ? l10n.selectDateRangeFirst : l10n.deleteInvoices,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onDeleteInvoices : null,
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: enabled ? AppColors.errorColor : AppColors.mutedColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.trash2, size: 16, color: enabled ? Colors.white : AppColors.mutedColor),
                const SizedBox(width: 8),
                Text(
                  l10n.clearInvoices,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Cairo',
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
