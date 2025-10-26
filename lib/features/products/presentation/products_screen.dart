import 'package:crazy_phone_pos/core/components/screen_header.dart';
import 'package:crazy_phone_pos/core/di/dependency_injection.dart';
import 'package:crazy_phone_pos/core/functions/messege.dart';
import 'package:crazy_phone_pos/features/products/data/models/product_model.dart';
import 'package:crazy_phone_pos/features/products/presentation/cubit/product_cubit.dart';
import 'package:crazy_phone_pos/features/products/presentation/cubit/product_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/components/anim_wrappers.dart';
import '../../../core/constants/app_colors.dart';
import 'widgets/enhanced_add_edit_dialog.dart';
import 'widgets/product_filter_section.dart';
import 'widgets/product_grid_view.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => ProductsScreenState();
}

class ProductsScreenState extends State<ProductsScreen> {
  final TextEditingController searchController = TextEditingController();
  String categoryFilter = 'الكل';
  String availabilityFilter = 'الكل';
  List<String> categories = ['الكل'];
  final List<String> availabilities = ['الكل', 'متوفر', 'منخفض', 'غير متوفر'];

  List<Product> products = [];

  List<Product> get filteredProducts {
    final q = searchController.text.trim();
    return products.where((p) {
      if (categoryFilter != 'الكل' && (p.category) != categoryFilter) {
        return false;
      }
      final qty = p.quantity;
      if (availabilityFilter == 'غير متوفر' && qty != 0) return false;
      if (availabilityFilter == 'منخفض' && !(qty > 0 && qty <= (p.minQuantity)))
        return false;
      if (availabilityFilter == 'متوفر' && !(qty > (p.minQuantity)))
        return false;
      if (q.isNotEmpty) {
        final low = q.toLowerCase();
        return p.name.toString().toLowerCase().contains(low) ||
            p.barcode.contains(low) ||
            p.price.toString().contains(low);
      }
      return true;
    }).toList();
  }

  Color statusColor(int qty, int min) {
    if (qty == 0) return AppColors.errorColor;
    if (qty <= min) return AppColors.warningColor;
    return AppColors.successColor;
  }

  String statusText(int qty, int min) {
    if (qty == 0) return 'غير متوفر';
    if (qty <= min) return 'منخفض';
    return 'متوفر';
  }

  Future<void> showAddEditDialog([Product? product]) async {
    await showDialog(
      context: context,
      builder: (_) => EnhancedAddEditProductDialog(
        categories: categories,
        productToEdit: product,
      ),
    );
  }

  void onSearchChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProductCubit>.value(
      value: getIt<ProductCubit>()
        ..getAllProducts()
        ..getAllCategories(),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: AppColors.backgroundColor,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 800;
                final horizontalPadding = isMobile ? 12.0 : 20.0;

                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ScreenHeader(
                        title: 'المنتجات',
                        subtitle: 'إدارة المنتجات وعرض التفاصيل',
                        icon: Icons.inventory_2_outlined,
                        iconColor: AppColors.primaryColor,
                        titleColor: AppColors.kDarkChip,
                      ),
                      const SizedBox(height: 20),
                      BlocConsumer<ProductCubit, ProductStates>(
                        listener: (context, state) {
                          if (state is ProductSuccessState) {
                            MotionSnackBarSuccess(context, state.msg);
                          }
                          if (state is ProductErrorState) {
                            MotionSnackBarError(context, state.message);
                          }
                        },
                        buildWhen: (previous, current) =>
                            current is CategoryLoadedState ||
                            current is CategoryErrorState,
                        builder: (context, state) {
                          if (state is CategoryLoadedState) {
                            categories = ['الكل', ...state.categories];
                          }
                          return Column(
                            children: [
                              FadeSlideIn(
                                beginOffset: const Offset(0.06, 0),
                                child: ProductsFilterSection(
                                  searchController: searchController,
                                  categoryFilter: categoryFilter,
                                  availabilityFilter: availabilityFilter,
                                  categories: categories,
                                  availabilities: availabilities,
                                  onCategoryChanged: (v) {
                                    print(v);
                                    ProductCubit.get(context)
                                        .filterByCategory(v);
                                  },
                                  onAvailabilityChanged: (v) =>
                                      setState(() => availabilityFilter = v),
                                  onAddPressed: () {
                                    showAddEditDialog();
                                  },
                                  onSearchChanged: onSearchChanged,
                                ),
                              ),
                              const SizedBox(height: 10),
                              FadeScale(
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: const BorderSide(
                                        color: AppColors.borderColor),
                                  ),
                                  color: Colors.white,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isMobile ? 12 : 20,
                                      vertical: 14,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.inventory_outlined,
                                          color: AppColors.primaryColor,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              'عدد المنتجات',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: isMobile ? 16 : 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryColor
                                                .withOpacity(
                                              0.1,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              '${filteredProducts.length}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: AppColors.primaryColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          );
                        },
                      ),
                      BlocBuilder<ProductCubit, ProductStates>(
                        buildWhen: (previous, current) =>
                            current is ProductLoadingState ||
                            current is ProductLoadedState ||
                            current is ProductErrorState,
                        builder: (context, state) {
                          if (state is ProductLoadedState) {
                            products = state.products;
                          }
                          return Expanded(
                            child: SubtleSwitcher(
                              child: KeyedSubtree(
                                key: ValueKey(filteredProducts.length),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: const BorderSide(
                                      color: AppColors.borderColor,
                                    ),
                                  ),
                                  color: Colors.white,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: ProductsGridView(
                                      products: filteredProducts,
                                      onDelete: (p) => getIt<ProductCubit>()
                                          .deleteProduct(p.barcode),
                                      onEdit: (p) {
                                        showAddEditDialog(p);
                                      },
                                      statusColorFn: statusColor,
                                      statusTextFn: statusText,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
