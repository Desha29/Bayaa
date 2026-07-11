import 'dart:async';
import 'package:bayaa_pos/core/components/screen_header.dart';
import 'package:bayaa_pos/core/di/dependency_injection.dart';
import 'package:bayaa_pos/core/functions/messege.dart';
import 'package:bayaa_pos/features/auth/presentation/cubit/user_cubit.dart';
import 'package:bayaa_pos/features/auth/data/models/user_model.dart';
import 'package:bayaa_pos/features/products/data/models/product_model.dart';
import 'package:bayaa_pos/features/products/presentation/cubit/product_cubit.dart';
import 'package:bayaa_pos/features/products/presentation/cubit/product_states.dart';
import 'package:bayaa_pos/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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

  List<Product> products = [];

  Color statusColor(int qty, int min) {
    if (qty == 0) return AppColors.errorColor;
    if (qty <= min) return AppColors.warningColor;
    return AppColors.successColor;
  }

  List<String> _availabilities(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return [l10n.all, l10n.available, l10n.lowStock, l10n.outOfStock];
  }

  String Function(int, int) _statusTextFn(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return (int qty, int min) {
      if (qty == 0) return l10n.outOfStock;
      if (qty <= min) return l10n.lowStock;
      return l10n.available;
    };
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
    final l10n = AppLocalizations.of(context);
    return BlocProvider<ProductCubit>.value(
      value: getIt<ProductCubit>(),
      child: Directionality(
        textDirection:
            l10n.localeName == 'ar' ? TextDirection.rtl : TextDirection.ltr,
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
                      ScreenHeader(
                        title: l10n.products,
                        subtitle: l10n.productsManagement,
                        icon: Icons.inventory_2_outlined,
                        iconColor: AppColors.primaryColor,
                        titleColor: AppColors.kDarkChip,
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: BlocConsumer<ProductCubit, ProductStates>(
                          listener: (context, state) {
                            if (state is ProductSuccessState) {
                              MotionSnackBarSuccess(context, _translateMsg(context, state.msg));
                            }
                            if (state is ProductErrorState) {
                              MotionSnackBarError(context, state.message);
                            }
                            if (state is CategorySuccessState) {
                              MotionSnackBarSuccess(context, _translateMsg(context, state.msg));
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
                                if (products.isNotEmpty ||
                                    cubit.selectedCategory != '*') {
                                  categoryFilter = cubit.selectedCategory == '*'
                                      ? l10n.all
                                      : cubit.selectedCategory;
                                } else if (cubit.selectedCategory == '*' &&
                                    products.isEmpty) {
                                  categoryFilter = null;
                                }
                              }

                              // Repeat for Availability Filter
                              if (availabilityFilter !=
                                  cubit.selectedAvailability) {
                                if (products.isNotEmpty ||
                                    cubit.selectedAvailability != '*') {
                                  availabilityFilter =
                                      cubit.selectedAvailability == '*'
                                          ? l10n.all
                                          : cubit.selectedAvailability;
                                } else if (cubit.selectedAvailability ==
                                        '*' &&
                                    products.isEmpty) {
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
                              categories = [l10n.all, ...state.categories];
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
                                    availabilities: _availabilities(context),
                                    onCategoryChanged: (v) {
                                      final cubitValue = (v == l10n.all) ? '*' : v;
                                      setState(() => categoryFilter = v);
                                      ProductCubit.get(context)
                                          .filterByCategory(cubitValue);
                                    },
                                    onAvailabilityChanged: (v) {
                                      final cubitValue = (v == l10n.all) ? '*' : v;
                                      setState(() => availabilityFilter = v);
                                      ProductCubit.get(context)
                                          .filterByAvailability(cubitValue);
                                    },
                                    onAddPressed: () {
                                      showAddEditDialog();
                                    },
                                    onSearchChanged: () {},
                                    productCount:
                                        currentFilteredProducts.length,
                                    isTableView: isTableView,
                                    onViewToggle: (v) =>
                                        setState(() => isTableView = v),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: SubtleSwitcher(
                                    child: KeyedSubtree(
                                      key: ValueKey(
                                          '${currentFilteredProducts.length}_$isTableView'),
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          side: const BorderSide(
                                            color: AppColors.borderColor,
                                          ),
                                        ),
                                        color: Colors.white,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          child: isTableView
                                              ? ProductsTableView(
                                                  products:
                                                      currentFilteredProducts,
                                                  onDelete: (p) =>
                                                      getIt<ProductCubit>()
                                                          .deleteProduct(
                                                              p.barcode),
                                                  onEdit: (p) =>
                                                      showAddEditDialog(p),
                                                  statusColorFn: statusColor,
                                                  statusTextFn: _statusTextFn(context),
                                                  scrollController:
                                                      _scrollController,
                                                  isLoadingMore:
                                                      ProductCubit.get(context)
                                                          .isLoadingMore,
                                                  isManager: getIt<UserCubit>()
                                                          .currentUser
                                                          .userType ==
                                                      UserType.manager,
                                                )
                                              : ProductsGridView(
                                                  products:
                                                      currentFilteredProducts,
                                                  onDelete: (p) =>
                                                      getIt<ProductCubit>()
                                                          .deleteProduct(
                                                              p.barcode),
                                                  onEdit: (p) {
                                                    showAddEditDialog(p);
                                                  },
                                                  statusColorFn: statusColor,
                                                  statusTextFn: _statusTextFn(context),
                                                  scrollController:
                                                      _scrollController,
                                                  isLoadingMore:
                                                      ProductCubit.get(context)
                                                          .isLoadingMore,
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

  String _translateMsg(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context);
    switch (key) {
      case 'productSavedSuccess': return l10n.productSavedSuccess;
      case 'msgProductDeleted': return l10n.msgProductDeleted;
      case 'categoryAddedSuccess': return l10n.categoryAddedSuccess;
      case 'categoryDeletedSuccess': return l10n.categoryDeletedSuccess;
      default: return key;
    }
  }
}

Future<Map<String, String>?> showCategoryActionDialog({
  required BuildContext context,
  required String category,
  required String? categoryFilter,
  required List<String> categorie,
}) {
  final l10n = AppLocalizations.of(context);
  List<String> categories =
      categorie.where((c) => (c != category && c != l10n.all)).toList();
  if (categories.isEmpty) {
    MotionSnackBarInfo(context, l10n.noOtherCategoriesToMove);
    return Future.value(null);
  }
  categoryFilter = categories[0];

  return showDialog<Map<String, String>>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      String selectedCategory = categoryFilter!;
      String? errorText;
      final l10n = AppLocalizations.of(context);

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
                    LucideIcons.triangleAlert,
                    color: AppColors.warningColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    l10n.selectCategoryBeforeAction,
                    style: const TextStyle(
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
                  label: l10n.chooseCategory,
                  value: selectedCategory,
                  items: categories,
                  onChanged: (v) {
                    setState(() {
                      selectedCategory = v;
                      errorText = null;
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
              OutlinedButton.icon(
                onPressed: () => Navigator.pop(context,
                    {'action': 'cancel', 'category': selectedCategory}),
                icon: const Icon(LucideIcons.x),
                label: Text(l10n.cancel),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  if (selectedCategory.isEmpty) {
                    setState(() {
                      errorText = l10n.mustSelectCategoryFirst;
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
                label: Text(l10n.moveProducts),
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
              ElevatedButton.icon(
                onPressed: () {
                  if (selectedCategory.isEmpty) {
                    setState(() {
                      errorText = l10n.mustSelectCategoryFirst;
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
                label: Text(l10n.permanentDelete),
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
