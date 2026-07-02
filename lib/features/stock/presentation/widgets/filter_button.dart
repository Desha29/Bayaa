// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:bayaa_pos/l10n/app_localizations.dart';
import '../../../../core/components/hover_wrapper.dart';
import '../../../../core/constants/app_colors.dart';


class FilterButtonsWidget extends StatelessWidget {
  final String filter;
  final int totalCount;
  final int lowStockCount;
  final int outOfStockCount;
  final Function(String) onFilterChanged;

  const FilterButtonsWidget({
    super.key,
    required this.filter,
    required this.totalCount,
    required this.lowStockCount,
    required this.outOfStockCount,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: _buildFilterChip(
            l10n.all,
            totalCount,
            'all',
            LucideIcons.layers,
            AppColors.primaryColor,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildFilterChip(
            l10n.lowStock,
            lowStockCount,
            'low',
            LucideIcons.triangleAlert,
            AppColors.warningColor,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildFilterChip(
            l10n.outOfStock,
            outOfStockCount,
            'out',
            LucideIcons.xCircle,
            AppColors.errorColor,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    String title,
    int count,
    String filterValue,
    IconData icon,
    Color color,
  ) {
    final isSelected = filter == filterValue;

    return HoverWrapper(
      builder: (hovering) {
        return GestureDetector(
          onTap: () => onFilterChanged(filterValue),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withOpacity(hovering ? 0.12 : 0.08)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? color.withOpacity(0.5)
                    : hovering
                        ? AppColors.borderColor
                        : AppColors.borderColor.withOpacity(0.6),
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? color.withOpacity(hovering ? 0.12 : 0.08)
                      : Colors.black.withOpacity(hovering ? 0.04 : 0.015),
                  blurRadius: isSelected ? 10 : 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: color.withOpacity(isSelected ? 0.15 : 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? color : AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color
                        : color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    count.toString(),
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.white : color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
