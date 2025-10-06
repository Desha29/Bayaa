import 'package:crazy_phone_pos/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import '../../../core/components/screen_header.dart';

import 'widgets/filter_button.dart';
import 'widgets/product_card.dart';
import 'widgets/products_grid_view.dart';
import 'widgets/restock_dialog.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  List<Product> products = [
    Product(
      code: 'SGS23',
      name: 'سامسونج جالاكسي S23',
      quantity: 3,
      min: 5,
      lastRestock: '12/07/2025',
    ),
    Product(
      code: 'IP13',
      name: 'آيفون 13',
      quantity: 0,
      min: 3,
      lastRestock: '12/07/2025',
    ),
    Product(
      code: 'HWP40',
      name: 'هواوي P40 لايت',
      quantity: 1,
      min: 4,
      lastRestock: '14/01/2024',
    ),
    Product(
      code: 'XM12',
      name: 'شاومي ريدمي نوت 12',
      quantity: 0,
      min: 6,
      lastRestock: '16/01/2024',
    ),
    Product(
      code: 'OPF5',
      name: 'أوبو فايند X5',
      quantity: 2,
      min: 5,
      lastRestock: '13/01/2024',
    ),
  ];

  String filter = 'all';

  int get totalCount => products.length;
  int get outOfStockCount => products.where((p) => p.quantity == 0).length;
  int get lowStockCount =>
      products.where((p) => p.quantity > 0 && p.quantity < p.min).length;

  void _openRestockDialog(int index) async {
    final result = await showDialog<int>(
      context: context,
      builder: (context) => RestockDialog(product: products[index]),
    );

    if (result != null) {
      setState(() {
        products[index].quantity += result;
        final now = DateTime.now();
        products[index].lastRestock =
            '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Product> filtered = products.where((p) {
      if (filter == 'all') return true;
      if (filter == 'low') return (p.quantity > 0 && p.quantity < p.min);
      if (filter == 'out') return p.quantity == 0;
      return true;
    }).toList();


    final isTablet = MediaQuery.of(context).size.width >= 600;
    final isDesktop = MediaQuery.of(context).size.width >= 1000;
    double horizontalPadding = 12;
    if (isTablet) horizontalPadding = 4;
    if (isDesktop) horizontalPadding = 24;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SafeArea(
          child: CustomScrollView(
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
                      ),
                      const SizedBox(height: 32),

                      FilterButtonsWidget(
                        filter: filter,
                        totalCount: totalCount,
                        lowStockCount: lowStockCount,
                        outOfStockCount: outOfStockCount,
                        onFilterChanged: (newFilter) {
                          setState(() {
                            filter = newFilter;
                          });
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
                                'المنتجات التي تحتاج إعادة تخزين (${filtered.length})',
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
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                sliver: SliverFillRemaining(
                  hasScrollBody: true,
                  child: filtered.isEmpty
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
                          products: filtered,
                          onRestock: (index) {
                            final originalIndex = products.indexWhere(
                              (p) => p.code == filtered[index].code,
                            );
                            if (originalIndex >= 0) {
                              _openRestockDialog(originalIndex);
                            }
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
