import 'package:flutter/material.dart';
import 'desktop_layout_filter.dart';

import 'package:crazy_phone_pos/core/constants/app_colors.dart';

class ProductsFilterSection extends StatelessWidget {
  final TextEditingController searchController;
  final String? categoryFilter;
  final String? availabilityFilter;
  final List<String> categories;
  final List<String> availabilities;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onAvailabilityChanged;
  final VoidCallback onAddPressed;
  final VoidCallback onSearchChanged;
  final int productCount;
  final bool isTableView;
  final ValueChanged<bool> onViewToggle;

  const ProductsFilterSection({
    super.key,
    required this.searchController,
    required this.categoryFilter,
    required this.availabilityFilter,
    required this.categories,
    required this.availabilities,
    required this.onCategoryChanged,
    required this.onAvailabilityChanged,
    required this.onAddPressed,
    required this.onSearchChanged,
    required this.productCount,
    required this.isTableView,
    required this.onViewToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: DesktopLayout(
        searchController: searchController,
        onSearchChanged: onSearchChanged,
        categoryFilter: categoryFilter,
        categories: categories,
        onCategoryChanged: onCategoryChanged,
        availabilityFilter: availabilityFilter,
        availabilities: availabilities,
        onAvailabilityChanged: onAvailabilityChanged,
        onAddPressed: onAddPressed,
        productCount: productCount,
        isTableView: isTableView,
        onViewToggle: onViewToggle,
      ),
    );
  }
}
