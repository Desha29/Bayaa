import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bayaa_pos/app/bootstrap/service_locator.dart';
import 'package:bayaa_pos/shared/theme/app_colors.dart';
import 'package:bayaa_pos/shared/feedback/preview_action.dart';
import 'package:bayaa_pos/shared/widgets/screen_header.dart';
import 'package:bayaa_pos/shared/widgets/workspace/workspace_summary.dart';
import 'package:bayaa_pos/l10n/app_localizations.dart';
import 'package:bayaa_pos/preview/data/preview_data.dart';
import '../controllers/product_cubit.dart';
import '../controllers/product_state.dart';
import '../models/product_view_data.dart';
import '../widgets/product_form_dialog.dart';
import '../widgets/product_filter_section.dart';
import '../widgets/product_list_view.dart';
import '../widgets/product_table_view.dart';
import '../widgets/category_form_dialog.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});
  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _search = TextEditingController();
  final _searchFocus = FocusNode();
  bool _table = false;
  late final ProductCubit _cubit = getIt<ProductCubit>();
  @override
  void initState() {
    super.initState();
    _search.text = _cubit.currentSearchQuery;
    _cubit.getAllCategories();
    _cubit.getAllProducts();
  }

  @override
  void dispose() {
    _search.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _edit([ProductViewData? product]) => showDialog<void>(
      context: context,
      builder: (_) => ProductFormDialog(
          categories: _cubit.categories, productToEdit: product));
  void _reset() {
    _search.clear();
    _cubit.selectedCategory = '*';
    _cubit.selectedAvailability = '*';
    _cubit.searchProducts('');
  }

  void _addCategory({bool subcategory = false}) => showDialog<void>(
      context: context,
      builder: (_) => CategoryFormDialog(
          categories: _cubit.categories, subcategory: subcategory));

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final ar = l10n.localeName == 'ar';
    final examples = PreviewData.products;
    return BlocProvider.value(
        value: _cubit,
        child:
            BlocBuilder<ProductCubit, ProductState>(builder: (context, state) {
          final products =
              state is ProductLoadedState ? state.products : _cubit.allProducts;
          return LayoutBuilder(
              builder: (context, size) => SingleChildScrollView(
                  padding: EdgeInsets.all(size.maxWidth < 600 ? 12 : 24),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ScreenHeader(
                            title: l10n.products,
                            subtitle: l10n.productsManagement,
                            icon: Icons.inventory_2_outlined,
                            iconColor: AppColors.primaryColor),
                        const SizedBox(height: 12),
                        Wrap(spacing: 8, runSpacing: 8, children: [
                          OutlinedButton.icon(
                              onPressed: () => _addCategory(),
                              icon:
                                  const Icon(Icons.category_outlined, size: 18),
                              label: Text(ar ? 'إضافة تصنيف' : 'Add category')),
                          OutlinedButton.icon(
                              onPressed: () => _addCategory(subcategory: true),
                              icon: const Icon(Icons.account_tree_outlined,
                                  size: 18),
                              label: Text(
                                  ar ? 'إضافة تصنيف فرعي' : 'Add subcategory')),
                        ]),
                        const SizedBox(height: 20),
                        WorkspaceSummary(metrics: [
                          WorkspaceMetric(
                              ar ? 'إجمالي المنتجات' : 'Total products',
                              '${examples.length}',
                              Icons.inventory_2_outlined),
                          WorkspaceMetric(
                              l10n.available,
                              '${examples.where((p) => p.quantity > p.minQuantity).length}',
                              Icons.check_circle_outline,
                              color: AppColors.successColor),
                          WorkspaceMetric(
                              l10n.lowStock,
                              '${examples.where((p) => p.quantity > 0 && p.quantity <= p.minQuantity).length}',
                              Icons.trending_down,
                              color: AppColors.warningColor),
                          WorkspaceMetric(
                              l10n.outOfStock,
                              '${examples.where((p) => p.quantity == 0).length}',
                              Icons.remove_shopping_cart_outlined,
                              color: AppColors.errorColor),
                        ]),
                        const SizedBox(height: 20),
                        ProductsFilterSection(
                            searchController: _search,
                            focusNode: _searchFocus,
                            categoryFilter: _cubit.selectedCategory == '*'
                                ? l10n.all
                                : _cubit.selectedCategory,
                            availabilityFilter: _cubit.selectedAvailability,
                            categories: [l10n.all, ..._cubit.categories],
                            availabilities: [
                              l10n.all,
                              l10n.available,
                              l10n.lowStock,
                              l10n.outOfStock
                            ],
                            onCategoryChanged: (v) => _cubit
                                .filterByCategory(v == l10n.all ? '*' : v),
                            onAvailabilityChanged: _cubit.filterByAvailability,
                            onAddPressed: () => _edit(),
                            onSearchChanged: () =>
                                _cubit.searchProducts(_search.text),
                            onClearAll: _reset,
                            productCount: products.length,
                            isTableView: _table,
                            onViewToggle: (v) => setState(() => _table = v)),
                        const SizedBox(height: 16),
                        if (state is ProductErrorState)
                          Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(children: [
                                Text(state.message),
                                TextButton(
                                    onPressed: _cubit.getAllProducts,
                                    child: Text(
                                        ar ? 'إعادة المحاولة' : 'Try again'))
                              ]))
                        else if (_table && size.maxWidth >= 600)
                          ProductTableView(
                              products: products,
                              onEdit: _edit,
                              onDelete: (_) => showPreviewAction(context),
                              statusColorFn: _statusColor,
                              statusTextFn: (q, m) => q == 0
                                  ? l10n.outOfStock
                                  : q <= m
                                      ? l10n.lowStock
                                      : l10n.available,
                              isManager: true)
                        else
                          ProductListView(
                              products: products,
                              onEdit: _edit,
                              onDelete: (_) => showPreviewAction(context),
                              statusColorFn: _statusColor,
                              statusTextFn: (q, m) => q == 0
                                  ? l10n.outOfStock
                                  : q <= m
                                      ? l10n.lowStock
                                      : l10n.available),
                      ])));
        }));
  }

  Color _statusColor(int q, int m) => q == 0
      ? AppColors.errorColor
      : q <= m
          ? AppColors.warningColor
          : AppColors.successColor;
}
