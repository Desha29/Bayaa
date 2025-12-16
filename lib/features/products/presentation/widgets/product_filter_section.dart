import 'package:flutter/material.dart';
import 'desktop_layout_filter.dart';
import 'mobile_layout_filter.dart';

import 'package:crazy_phone_pos/core/constants/app_colors.dart';

class ProductsFilterSection extends StatelessWidget {
  final TextEditingController searchController;
  final String categoryFilter;
  final String availabilityFilter;
  final List<String> categories;
  final List<String> availabilities;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onAvailabilityChanged;
  final VoidCallback onAddPressed;
  final VoidCallback onSearchChanged;

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
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.white, AppColors.mutedColor.withOpacity(0.1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 800) {
                return DesktopLayout(
                  searchController: searchController,
                  onSearchChanged: onSearchChanged,
                  categoryFilter: categoryFilter,
                  categories: categories,
                  onCategoryChanged: onCategoryChanged,
                  availabilityFilter: availabilityFilter,
                  availabilities: availabilities,
                  onAvailabilityChanged: onAvailabilityChanged,
                  onAddPressed: onAddPressed,
                );
              } else {
                return MobileLayout(
                  searchController: searchController,
                  onSearchChanged: onSearchChanged,
                  categoryFilter: categoryFilter,
                  categories: categories,
                  onCategoryChanged: onCategoryChanged,
                  availabilityFilter: availabilityFilter,
                  availabilities: availabilities,
                  onAvailabilityChanged: onAvailabilityChanged,
                  onAddPressed: onAddPressed,
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
