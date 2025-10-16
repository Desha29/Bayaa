import 'package:crazy_phone_pos/core/constants/app_colors.dart';
import 'package:crazy_phone_pos/features/products/presentation/widgets/enhanced_add_edit_Dialog.dart'
    show EnhancedAddEditProductDialog, AddCategories;
import 'package:flutter/material.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../data/models/product_model.dart';
import '../cubit/product_cubit.dart';
import 'add_button.dart';
import 'dropdown_filter.dart';

class DesktopLayout extends StatelessWidget {
  const DesktopLayout({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.categoryFilter,
    required this.categories,
    required this.onCategoryChanged,
    required this.availabilityFilter,
    required this.availabilities,
    required this.onAvailabilityChanged,
    required this.onAddPressed,
  });

  final TextEditingController searchController;
  final VoidCallback onSearchChanged;
  final String categoryFilter;
  final List<String> categories;
  final ValueChanged<String> onCategoryChanged;
  final String availabilityFilter;
  final List<String> availabilities;
  final ValueChanged<String> onAvailabilityChanged;
  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: searchController,
            onChanged: (s) {
              getIt<ProductCubit>().searchProducts(s);
            },
            decoration: InputDecoration(
              hintText: 'ابحث عن منتج بالاسم، الكود، الباركود أو السعر...',
              hintStyle: TextStyle(color: Colors.grey[500]),
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.primaryColor,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Filters Row
        Row(
          children: [
            Expanded(
              flex: 2,
              child: DropDownFilter(
                label: 'حسب الفئة',
                value: categoryFilter,
                items: categories,
                onChanged: onCategoryChanged,
                icon: Icons.category_outlined,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: DropDownFilter(
                label: 'حسب التوفر',
                value: availabilityFilter,
                items: availabilities,
                onChanged: onAvailabilityChanged,
                icon: Icons.inventory_outlined,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
                flex: 1,
                child: AddButton(
                  onAddPressed: onAddPressed,
                  text: "إضافة منتج جديد",
                )),
            SizedBox(width: 15),
            Expanded(
                flex: 1,
                child: AddButton(
                  onAddPressed: () {
                    showAddEditDialog(context);
                  },
                  text: "إضافة صنف جديد",
                  color: Color(0xff8b5cf6),
                )),
          ],
        ),
      ],
    );
  }
}

Future<void> showAddEditDialog(context, [Product? product]) async {
  await showDialog(context: context, builder: (_) => AddCategories());
}
