// ignore_for_file: deprecated_member_use

import 'package:crazy_phone_pos/core/constants/app_colors.dart';
import 'package:crazy_phone_pos/features/stock/presentation/cubit/stock_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/components/screen_header.dart';
import '../../../core/di/dependency_injection.dart';
import '../../products/data/models/product_model.dart';
import 'cubit/stock_states.dart';
import 'widgets/filter_button.dart';
import 'widgets/products_grid_view.dart';
import 'widgets/restock_dialog.dart';

class StockScreen extends StatelessWidget {
  const StockScreen({super.key});

  void _openRestockDialog(Product product, BuildContext context) async {
    final result = await showDialog<int>(
      context: context,
      builder: (context) => RestockDialog(product: product),
    );

    if (result != null) {
      getIt<StockCubit>().restockProduct(product, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: BlocBuilder<StockCubit, StockStates>(
                builder: (context, state) {
                  if (state is StockSucssesState) {
                    return Column(
                      children: [
                        // Header + Filter (Fixed)
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? 32 : 16,
                            vertical: 16,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const ScreenHeader(
                                title: 'إدارة مخزون السلع',
                                subtitle: 'متابعة المنتجات منخفضة الكمية وتحديث التوريدات وسد العجز بالمخازن',
                                icon: LucideIcons.warehouse,
                                iconColor: AppColors.primaryColor,
                                titleColor: AppColors.textPrimary,
                              ),
                              const SizedBox(height: 16),
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
                              const SizedBox(height: 16),
                              // Results alert bar
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.warningColor.withOpacity(0.06),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: AppColors.warningColor.withOpacity(0.18),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      LucideIcons.alertTriangle,
                                      color: AppColors.warningColor,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'المنتجات التي تتطلب إعادة تخزين حالياً (${state.products.length})',
                                        style: const TextStyle(
                                          fontFamily: 'Cairo',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12.5,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Products List (Scrollable)
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: isDesktop ? 32 : 16,
                            ),
                            child: state.products.isEmpty
                                ? _buildEmptyState()
                                : ProductsGridView(
                                    products: state.products,
                                    onRestock: (index) {
                                      final originalIndex = state.products.indexWhere(
                                        (p) => p.barcode == state.products[index].barcode,
                                      );
                                      if (originalIndex >= 0) {
                                        _openRestockDialog(
                                          state.products[originalIndex],
                                          context,
                                        );
                                      }
                                    },
                                  ),
                          ),
                        ),
                      ],
                    );
                  } else if (state is StockErrorState) {
                    return _buildErrorWidget(state, context);
                  } else {
                    return _buildLoadingWidget();
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.successColor.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.packageCheck,
              size: 48,
              color: AppColors.successColor,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'المخزون مكتمل ولا توجد عواجز',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'جميع السلع متوفرة بكميات تتجاوز الحد الأدنى للمخزون الموصى به',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              color: AppColors.mutedColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              color: AppColors.primaryColor,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'جاري جرد وتحديث بيانات المخزن اليومي...',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12.5,
              color: AppColors.mutedColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(StockErrorState state, BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.errorColor.withOpacity(0.06),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.alertCircle,
              size: 40,
              color: AppColors.errorColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            state.msg,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              color: AppColors.errorColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
