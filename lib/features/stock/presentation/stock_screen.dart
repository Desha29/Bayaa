import 'package:crazy_phone_pos/core/constants/app_colors.dart';
import 'package:crazy_phone_pos/features/products/presentation/cubit/product_cubit.dart';
import 'package:crazy_phone_pos/features/stock/presentation/cubit/stock_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/components/screen_header.dart';

import '../../../core/di/dependency_injection.dart';
import '../../products/data/models/product_model.dart';
import 'cubit/stock_states.dart';
import 'widgets/filter_button.dart';
import 'widgets/product_card.dart';
import 'widgets/products_grid_view.dart';
import 'widgets/restock_dialog.dart';

class StockScreen extends StatelessWidget {
  const StockScreen({super.key});

  void _openRestockDialog(Product product,context) async {
    final result = await showDialog<int>(
      context: context,
      builder: (context) => RestockDialog(product: product),
    );

    if (result != null) {
      product.quantity += result;
      getIt<ProductCubit>().saveProduct(product);
      getIt<StockCubit>().loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;
    final isDesktop = MediaQuery.of(context).size.width >= 1000;
    double horizontalPadding = 12;
    if (isTablet) horizontalPadding = 4;
    if (isDesktop) horizontalPadding = 24;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SafeArea(child: BlocBuilder<StockCubit, StockStates>(
          builder: (context, state) {
            if (state is StockSucssesState) {
              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Header + Filter + Title
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: 24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const ScreenHeader(
                            title: 'المنتجات الناقصة',
                            subtitle: 'متابعة المنتجات التي تحتاج إعادة تخزين',
                            icon: Icons.warning_amber_rounded,
                            iconColor: AppColors.primaryColor,
                            titleColor: AppColors.kDarkChip,
                          ),
                          const SizedBox(height: 32),
                          FilterButtonsWidget(
                            filter: getIt<StockCubit>().filter,
                            totalCount: getIt<StockCubit>().totalCount,
                            lowStockCount: getIt<StockCubit>().lowStockCount,
                            outOfStockCount: getIt<StockCubit>().outOfStockCount,
                            onFilterChanged: (newFilter) {
                              getIt<StockCubit>().filter = newFilter;
                              getIt<StockCubit>().filterProducts();
                            },
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: Color(0xFFF59E0B),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    'المنتجات التي تحتاج إعادة تخزين (${state.products.length})',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),

                  // Products Grid or Empty State
                  SliverPadding(
                    padding:
                        EdgeInsets.symmetric(horizontal: horizontalPadding),
                    sliver: SliverFillRemaining(
                      hasScrollBody: true,
                      child: state.products.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.inventory_2_outlined,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'لا توجد منتجات تطابق الفلتر المحدد',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ProductsGridView(
                              products: state.products,
                              onRestock: (index) {
                                final originalIndex = state.products.indexWhere(
                                  (p) =>
                                      p.barcode ==
                                      state.products[index].barcode,
                                );
                                if (originalIndex >= 0) {
                                  _openRestockDialog(
                                      state.products[originalIndex],context);
                                }
                              },
                            ),
                    ),
                  ),
                ],
              );
            } else if (state is StockErrorState) {
              return errorWidget(state, context);
            } else {
              return lodingWidget();
            }
          },
        )),
      ),
    );
  }

  Center lodingWidget() {
    return Center(
      child: CircularProgressIndicator(
        color: AppColors.primaryColor,
      ),
    );
  }

  Center errorWidget(StockErrorState state, BuildContext context) {
    return Center(
      child: Text(
        state.msg,
        style: Theme.of(context)
            .textTheme
            .displayMedium
            ?.copyWith(color: AppColors.errorColor),
      ),
    );
  }
}
