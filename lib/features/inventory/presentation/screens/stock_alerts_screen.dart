import 'package:bayaa_pos/app/bootstrap/service_locator.dart';
import 'package:bayaa_pos/features/auth/presentation/controllers/user_cubit.dart';
import 'package:bayaa_pos/features/auth/presentation/models/user_view_data.dart';
import 'package:bayaa_pos/features/products/presentation/models/product_view_data.dart';
import 'package:bayaa_pos/l10n/app_localizations.dart';
import 'package:bayaa_pos/shared/feedback/preview_action.dart';
import 'package:bayaa_pos/shared/layout/layout_tokens.dart';
import 'package:bayaa_pos/shared/theme/app_colors.dart';
import 'package:bayaa_pos/shared/widgets/empty_state.dart';
import 'package:bayaa_pos/shared/widgets/loading/skeleton.dart';
import 'package:bayaa_pos/shared/widgets/workspace/workspace_panel.dart';
import 'package:bayaa_pos/shared/widgets/workspace/workspace_summary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../controllers/stock_alerts_cubit.dart';
import '../controllers/stock_alerts_state.dart';
import '../widgets/filter_button.dart';
import '../widgets/product_card.dart';
import '../widgets/restock_dialog.dart';

class StockAlertsScreen extends StatefulWidget {
  const StockAlertsScreen({super.key});
  @override
  State<StockAlertsScreen> createState() => _StockAlertsScreenState();
}

class _StockAlertsScreenState extends State<StockAlertsScreen> {
  final _search = TextEditingController();
  String _query = '';
  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _restock(ProductViewData product) async {
    final result = await showDialog<int>(
        context: context, builder: (_) => RestockDialog(product: product));
    if (result != null && mounted) showPreviewAction(context);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final ar = l.localeName == 'ar';
    String tr(String en, String arabic) => ar ? arabic : en;
    final cubit = context.read<StockAlertsCubit>();
    final canRestock =
        getIt<UserCubit>().currentUser.userType == PreviewRole.manager;
    return BlocBuilder<StockAlertsCubit, StockAlertsState>(
        builder: (context, state) => LayoutBuilder(builder: (context, size) {
              final padding = LayoutTokens.pagePadding(size.maxWidth);
              if (state is StockErrorState) {
                return ListView(padding: padding, children: [
                  EmptyState(
                      title: l.unexpectedError,
                      message: state.msg,
                      actionText: tr('Try again', 'إعادة المحاولة'),
                      onAction: cubit.loadData),
                ]);
              }
              if (state is! StockLoadedState) {
                return ListView(
                    padding: padding, children: const [SkeletonList()]);
              }
              final records = state.products
                  .where((product) =>
                      '${product.name} ${product.barcode} ${product.category}'
                          .toLowerCase()
                          .contains(_query))
                  .toList()
                ..sort((a, b) {
                  final byQuantity = a.quantity.compareTo(b.quantity);
                  return byQuantity != 0
                      ? byQuantity
                      : a.name.compareTo(b.name);
                });
              return ListView(padding: padding, children: [
                WorkspacePanel(
                    prominent: true,
                    title: tr('Stock alerts', 'تنبيهات المخزون'),
                    caption: tr(
                        'Review empty shelves and products at or below their minimum.',
                        'راجع المنتجات النافدة والتي بلغت الحد الأدنى للمخزون.'),
                    icon: Icons.warning_amber_rounded,
                    child: WorkspaceSummary(metrics: [
                      WorkspaceMetric(tr('Stock alerts', 'التنبيهات'),
                          '${cubit.totalCount}', Icons.inventory_2_outlined),
                      WorkspaceMetric(l.outOfStock, '${cubit.outOfStockCount}',
                          Icons.remove_shopping_cart_outlined,
                          color: AppColors.errorColor),
                      WorkspaceMetric(l.lowStock, '${cubit.lowStockCount}',
                          Icons.trending_down,
                          color: AppColors.warningColor),
                    ])),
                const SizedBox(height: 16),
                WorkspacePanel(
                    title: tr('Replenishment queue', 'قائمة إعادة التخزين'),
                    caption: tr(
                        '${records.length} results · lowest stock first',
                        '${records.length} نتيجة · الأقل مخزوناً أولاً'),
                    icon: Icons.fact_check_outlined,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                              controller: _search,
                              onChanged: (v) => setState(
                                  () => _query = v.trim().toLowerCase()),
                              decoration: InputDecoration(
                                  labelText: tr(
                                      'Search name, barcode or category',
                                      'ابحث بالاسم أو الباركود أو الفئة'),
                                  prefixIcon: const Icon(Icons.search),
                                  suffixIcon: _search.text.isEmpty
                                      ? null
                                      : IconButton(
                                          tooltip:
                                              tr('Clear search', 'مسح البحث'),
                                          onPressed: () => setState(() {
                                                _search.clear();
                                                _query = '';
                                              }),
                                          icon: const Icon(Icons.close)))),
                          const SizedBox(height: 10),
                          FilterButtonsWidget(
                              filter: cubit.filter,
                              totalCount: cubit.totalCount,
                              lowStockCount: cubit.lowStockCount,
                              outOfStockCount: cubit.outOfStockCount,
                              onFilterChanged: (value) {
                                cubit.filter = value;
                                cubit.filterProducts();
                              }),
                        ])),
                const SizedBox(height: 14),
                if (records.isEmpty)
                  EmptyState(
                      variant: EmptyStateVariant.products,
                      title: tr(
                          'No matching stock alerts', 'لا توجد تنبيهات مطابقة'),
                      message: tr('Try another filter or search term.',
                          'جرّب فلترًا آخر أو كلمة بحث مختلفة.'))
                else
                  AdaptiveColumns(minWidth: 290, maxColumns: 3, children: [
                    for (final product in records)
                      StockAlertCard(
                          product: product,
                          onRestock:
                              canRestock ? () => _restock(product) : null),
                  ]),
              ]);
            }));
  }
}
