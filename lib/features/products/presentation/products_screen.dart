import 'dart:async';
import 'package:crazy_phone_pos/core/components/screen_header.dart';
import 'package:crazy_phone_pos/core/di/dependency_injection.dart';
import 'package:crazy_phone_pos/core/functions/messege.dart';
import 'package:crazy_phone_pos/features/auth/presentation/cubit/user_cubit.dart';
import 'package:crazy_phone_pos/features/auth/data/models/user_model.dart';
import 'package:crazy_phone_pos/features/products/data/models/product_model.dart';
import 'package:crazy_phone_pos/features/products/presentation/cubit/product_cubit.dart';
import 'package:crazy_phone_pos/features/products/presentation/cubit/product_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/components/anim_wrappers.dart';
import '../../../core/constants/app_colors.dart';
import 'widgets/dropdown_filter.dart';
import 'widgets/enhanced_add_edit_dialog.dart';
import 'widgets/product_filter_section.dart';
import 'widgets/product_grid_view.dart';
import 'widgets/product_table_view.dart';


class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => ProductsScreenState();
}

class ProductsScreenState extends State<ProductsScreen> {
  final TextEditingController searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;
  
  // State for view mode
  bool isTableView = false;
  
  // Filter state - initialized to null for "Select Category" (requested change)
  String? categoryFilter; 
  String? availabilityFilter;
  List<String> categories = []; // Start empty, will load from cubit
  final List<String> availabilities = ['الكل', 'متوفر', 'منخفض', 'غير متوفر'];

  List<Product> products = [];

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

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    searchController.addListener(_onSearchChanged);
    
    // Clear any previous state (singleton cubit)
    final cubit = getIt<ProductCubit>();
    cubit.clearProducts();
    
    // Only load categories
    cubit.getAllCategories();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      context.read<ProductCubit>().loadMoreProducts();
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<ProductCubit>().searchProducts(searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProductCubit>.value(
      value: getIt<ProductCubit>(),
      child: Directionality(
        textDirection: TextDirection.rtl, // Fixed rtl getter
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
                      const SizedBox(height: 12),
                      Expanded(
                        child: BlocConsumer<ProductCubit, ProductStates>(
                        listener: (context, state) {
                          if (state is ProductSuccessState) {
                            MotionSnackBarSuccess(context, state.msg);
                          }
                          if (state is ProductErrorState) {
                            MotionSnackBarError(context, state.message);
                          }
                          if (state is CategorySuccessState) {
                            MotionSnackBarSuccess(context, state.msg);
                          }
                          if (state is CategoryErrorState) {
                            MotionSnackBarError(context, state.message);
                          }
                          if (state is CategoryErrorDeleteState) {
                            MotionSnackBarError(context, state.message);
                            showCategoryActionDialog(
                              categorie: categories,
                              category: state.category,
                              categoryFilter: categoryFilter,
                              context: context,
                            );
                          }
                          if (state is ProductLoadedState) {
                            products = state.products;
                            
                    
                            final cubit = context.read<ProductCubit>();
                            if (categoryFilter != cubit.selectedCategory) {
                          
                                if (products.isNotEmpty || cubit.selectedCategory != 'الكل') {
                                   categoryFilter = cubit.selectedCategory;
                                } else if (cubit.selectedCategory == 'الكل' && products.isEmpty) {
                                  
                                  categoryFilter = null;
                                }
                            }
                            
                            // Repeat for Availability Filter
                            if (availabilityFilter != cubit.selectedAvailability) {
                                if (products.isNotEmpty || cubit.selectedAvailability != 'الكل') {
                                   availabilityFilter = cubit.selectedAvailability;
                                } else if (cubit.selectedAvailability == 'الكل' && products.isEmpty) {
                                  availabilityFilter = null;
                                }
                            }
                          }
                        },
                        buildWhen: (previous, current) =>
                            current is CategoryLoadedState ||
                            current is CategoryErrorState ||
                            current is ProductLoadedState,
                        builder: (context, state) {
                          if (state is CategoryLoadedState) {
                            categories = ['الكل', ...state.categories];
                          }
                          
                          // Use products list directly as it's filtered by server
                          final currentFilteredProducts = products;
                          
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
                                    setState(() => categoryFilter = v);
                                    ProductCubit.get(context)
                                        .filterByCategory(v);
                                  },
                                  onAvailabilityChanged: (v) {
                                      setState(() => availabilityFilter = v);
                                      ProductCubit.get(context)
                                          .filterByAvailability(v);
                                  },
                                  onAddPressed: () {
                                    showAddEditDialog();
                                  },
                                  onSearchChanged: () {},
                                  productCount: currentFilteredProducts.length,
                                  isTableView: isTableView,
                                  onViewToggle: (v) => setState(() => isTableView = v),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: SubtleSwitcher(
                                  child: KeyedSubtree(
                                    key: ValueKey('${currentFilteredProducts.length}_$isTableView'),
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
                                        child: isTableView 
                                          ? ProductsTableView(
                                              products: currentFilteredProducts,
                                              onDelete: (p) => getIt<ProductCubit>()
                                                  .deleteProduct(p.barcode),
                                              onEdit: (p) => showAddEditDialog(p),
                                              statusColorFn: statusColor,
                                              statusTextFn: statusText,
                                              scrollController: _scrollController,
                                              isLoadingMore: ProductCubit.get(context).isLoadingMore,
                                              isManager: getIt<UserCubit>().currentUser.userType == UserType.manager,
                                            )
                                          : ProductsGridView(
                                              products: currentFilteredProducts,
                                              onDelete: (p) => getIt<ProductCubit>()
                                                  .deleteProduct(p.barcode),
                                              onEdit: (p) {
                                                showAddEditDialog(p);
                                              },
                                              statusColorFn: statusColor,
                                              statusTextFn: statusText,
                                              scrollController: _scrollController,
                                              isLoadingMore: ProductCubit.get(context).isLoadingMore,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
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

Future<Map<String, String>?> showCategoryActionDialog({
  required BuildContext context,
  required String category,
  required String? categoryFilter,
  required List<String> categorie,
}) {
  List<String> categories =
      categorie.where((c) => (c != category && c != "الكل")).toList();
  if (categories.isEmpty) {
    MotionSnackBarInfo(context, "لا توجد فئات أخرى لنقل المنتجات إليها.");
    return Future.value(null);
  }
  categoryFilter = categories[0];

  return showDialog<Map<String, String>>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      String selectedCategory = categoryFilter!;
      String? errorText;

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.warningColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    LucideIcons.alertTriangle,
                    color: AppColors.warningColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'تحديد الفئة قبل تنفيذ الإجراء',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropDownFilter(
                  label: 'اختر الفئة',
                  value: selectedCategory,
                  items: categories,
                  onChanged: (v) {
                    setState(() {
                      selectedCategory = v;
                      errorText = null; // إزالة رسالة الخطأ عند الاختيار
                    });
                  },
                  icon: Icons.category_outlined,
                  iconRemove: Icons.cancel,
                ),
                if (errorText != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, right: 8),
                    child: Text(
                      errorText!,
                      style: const TextStyle(
                        color: AppColors.errorColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),
            actionsAlignment: MainAxisAlignment.spaceEvenly,
            actions: [
              // ❌ زر الإلغاء
              OutlinedButton.icon(
                onPressed: () => Navigator.pop(context,
                    {'action': 'cancel', 'category': selectedCategory}),
                icon: const Icon(LucideIcons.x),
                label: const Text('إلغاء'),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // 🔄 زر نقل المنتجات
              ElevatedButton.icon(
                onPressed: () {
                  if (selectedCategory.isEmpty) {
                    setState(() {
                      errorText = 'يجب اختيار فئة قبل المتابعة';
                    });
                    return;
                  }
                  getIt<ProductCubit>().deleteCategory(
                      category: category,
                      forceDelete: false,
                      newCategory: selectedCategory);
                  Navigator.pop(context, {
                    'action': 'move',
                    'category': selectedCategory,
                  });
                },
                icon: const Icon(LucideIcons.arrowRightLeft),
                label: const Text('نقل المنتجات'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warningColor,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // 🗑️ زر الحذف النهائي
              ElevatedButton.icon(
                onPressed: () {
                  if (selectedCategory.isEmpty) {
                    setState(() {
                      errorText = 'يجب اختيار فئة قبل المتابعة';
                    });
                    return;
                  }
                  getIt<ProductCubit>().deleteCategory(
                      category: selectedCategory, forceDelete: true);
                  Navigator.pop(context, {
                    'action': 'remove',
                    'category': selectedCategory,
                  });
                },
                icon: const Icon(LucideIcons.trash2),
                label: const Text('حذف نهائي'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.errorColor,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
