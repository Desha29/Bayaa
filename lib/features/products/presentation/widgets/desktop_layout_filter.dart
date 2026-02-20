import 'package:crazy_phone_pos/core/constants/app_colors.dart';
import 'package:crazy_phone_pos/features/auth/data/models/user_model.dart';
import 'package:crazy_phone_pos/features/auth/presentation/cubit/user_cubit.dart';
import 'package:crazy_phone_pos/features/products/presentation/widgets/enhanced_add_edit_Dialog.dart'
    show AddCategories;
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
    required this.productCount,
    required this.isTableView,
    required this.onViewToggle,
  });

  final TextEditingController searchController;
  final VoidCallback onSearchChanged;
  final String? categoryFilter;
  final List<String> categories;
  final ValueChanged<String> onCategoryChanged;
  final String? availabilityFilter;
  final List<String> availabilities;
  final ValueChanged<String> onAvailabilityChanged;
  final VoidCallback onAddPressed;
  final int productCount;
  final bool isTableView;
  final ValueChanged<bool> onViewToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.mutedColor.withOpacity(0.4)),
            boxShadow: [
              BoxShadow(
                color: AppColors.mutedColor.withOpacity(0.08),
                blurRadius: 3,
                offset: const Offset(0, 1),
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
              hintStyle: TextStyle(color: AppColors.mutedColor, fontSize: 13),
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.primaryColor,
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Filters Row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            getIt<UserCubit>().currentUser.userType == UserType.cashier
                ? const SizedBox()
                : Expanded(
                    flex: 1,
                    child: AddButton(
                      onAddPressed: () {
                        showAddEditDialog(context);
                      },
                      text: "إضافة صنف جديد",
                      color: const Color(0xff8b5cf6),
                    )),
            const SizedBox(width: 10),
            getIt<UserCubit>().currentUser.userType == UserType.cashier
                ? const SizedBox()
                : Expanded(
                    flex: 1,
                    child: AddButton(
                      onAddPressed: onAddPressed,
                      text: "إضافة منتج جديد",
                      color: AppColors.primaryColor,
                    )),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: DropDownFilter(
                label: 'حسب التوفر',
                value: availabilityFilter,
                items: availabilities,
                onChanged: onAvailabilityChanged,
                icon: Icons.inventory_outlined,
                hint: 'اختر التوفر',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: DropDownFilter(
                label: 'حسب الفئة',
                value: categoryFilter,
                items: categories,
                onChanged: onCategoryChanged,
                icon: Icons.category_outlined,
                iconRemove: Icons.cancel,
                hint: 'اختر الفئة',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // Info & View Toggle Row
        Row(
          children: [
            // Product Count
            Row(
              children: [
                Icon(
                  Icons.inventory_outlined,
                  color: AppColors.primaryColor,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'المنتجات',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$productCount',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            // View Toggle
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.grid_view, size: 16),
                    color: !isTableView ? AppColors.primaryColor : Colors.grey,
                    onPressed: () => onViewToggle(false),
                    tooltip: 'عرض الشبكة',
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    padding: const EdgeInsets.all(4),
                  ),
                  Container(width: 1, height: 14, color: Colors.grey.shade300),
                  IconButton(
                    icon: const Icon(Icons.table_chart_outlined, size: 16),
                    color: isTableView ? AppColors.primaryColor : Colors.grey,
                    onPressed: () => onViewToggle(true),
                    tooltip: 'عرض الجدول',
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    padding: const EdgeInsets.all(4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

Future<void> showAddEditDialog(context, [Product? product]) async {
  await showDialog(context: context, builder: (_) => AddCategories());
}
