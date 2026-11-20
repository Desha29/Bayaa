import 'package:flutter/material.dart';
import 'package:bayaa_pos/app/bootstrap/service_locator.dart';
import 'package:bayaa_pos/features/auth/presentation/controllers/user_cubit.dart';
import 'package:bayaa_pos/features/invoices/presentation/models/invoice_document_view_data.dart';
import 'package:bayaa_pos/features/invoices/presentation/screens/invoice_preview_screen.dart';
import 'package:bayaa_pos/features/pos/presentation/sources/invoice_catalog_source.dart';
import 'package:bayaa_pos/features/pos/presentation/widgets/cart_section.dart';
import 'package:bayaa_pos/features/pos/presentation/widgets/total_section_card.dart';
import 'package:bayaa_pos/features/pos/presentation/widgets/pos_product_tile.dart';
import 'package:bayaa_pos/features/products/presentation/models/product_view_data.dart';
import 'package:bayaa_pos/preview/data/preview_data.dart';
import 'package:bayaa_pos/features/pos/presentation/widgets/pos_checkout_dialog.dart';
import 'package:bayaa_pos/features/pos/presentation/widgets/recent_sales_sheet.dart';
import 'package:bayaa_pos/shared/theme/app_colors.dart';

/// A sample retail workstation; only presentation state changes here.
class PosScreen extends StatefulWidget {
  const PosScreen({super.key, this.repository});
  final InvoiceCatalogSource? repository;
  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen>
    with SingleTickerProviderStateMixin {
  final _search = TextEditingController();
  final _searchFocus = FocusNode();
  final _products = PreviewData.products;
  final List<Map<String, dynamic>> _cart = [];
  String? _category;
  late final TabController _tabController;
  bool get _ar => Localizations.localeOf(context).languageCode == 'ar';
  String _copy(String ar, String en) => _ar ? ar : en;
  double get _total => _cart.fold(0.0,
      (sum, item) => sum + (item['price'] as double) * (item['qty'] as int));

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    for (final product in _products.take(2)) {
      _add(product, notify: false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _search.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _add(ProductViewData product, {bool notify = true}) {
    if (product.quantity <= 0) return;
    final index = _cart.indexWhere((item) => item['id'] == product.barcode);
    if (index >= 0) {
      _cart[index]['qty'] = (_cart[index]['qty'] as int) + 1;
    } else {
      _cart.add({
        'id': product.barcode,
        'name': product.name,
        'price': product.price,
        'qty': 1,
        'quantity': product.quantity,
        'date': PreviewData.today,
        'minPrice': product.minPrice
      });
    }
    if (notify) setState(() {});
  }

  void _changeQuantity(int index, int delta) => setState(() {
        final next = (_cart[index]['qty'] as int) + delta;
        if (next <= 0) {
          _cart.removeAt(index);
        } else {
          _cart[index]['qty'] = next;
        }
      });

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(child: LayoutBuilder(builder: (context, constraints) {
        final wide = constraints.maxWidth >= 1000;
        final compact = constraints.maxWidth < 600;
        return Padding(
            padding: EdgeInsets.all(compact ? 12 : 20),
            child: Column(children: [
              if (!wide) ...[
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderColor),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: AppColors.primaryForeground,
                    unselectedLabelColor: AppColors.mutedColor,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 0),
                    dividerHeight: 0,
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.grid_view_rounded, size: 17),
                            const SizedBox(width: 6),
                            Text(_copy('المنتجات', 'Products'),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 13)),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.shopping_bag_rounded, size: 17),
                            const SizedBox(width: 6),
                            Text(
                              '${_copy('الفاتورة', 'Order')} (${_cart.length})',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],
              Expanded(
                  child: wide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                              Expanded(child: _catalog()),
                              const SizedBox(width: 20),
                              SizedBox(width: 380, child: _order())
                            ])
                      : TabBarView(
                          controller: _tabController,
                          children: [_catalog(), _order()],
                        )),
            ]));
      })),
    );
  }

  Widget _catalog() {
    final query = _search.text.trim().toLowerCase();
    final filtered = _products
        .where((p) =>
            (_category == null || p.category == _category) &&
            (query.isEmpty ||
                '${p.name} ${p.barcode} ${p.category}'
                    .toLowerCase()
                    .contains(query)))
        .toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        Expanded(
            child: TextField(
          controller: _search,
          focusNode: _searchFocus,
          textInputAction: TextInputAction.search,
          onChanged: (_) => setState(() {}),
          onSubmitted: (value) {
            final exact = _products.where((p) => p.barcode == value.trim());
            if (exact.isNotEmpty) _add(exact.first);
          },
          decoration: InputDecoration(
              hintText: _copy('ابحث عن منتج أو اكتب الباركود...',
                  'Search products or enter a barcode...'),
              prefixIcon:
                  Icon(Icons.search_rounded, color: AppColors.mutedColor),
              suffixIcon: query.isEmpty
                  ? Icon(Icons.qr_code_scanner_rounded,
                      size: 20, color: AppColors.mutedColor)
                  : IconButton(
                      tooltip: _copy('مسح البحث', 'Clear search'),
                      onPressed: () {
                        _search.clear();
                        setState(() {});
                        _searchFocus.requestFocus();
                      },
                      icon: const Icon(Icons.close_rounded)),
              fillColor: AppColors.surfaceColor,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16)),
        )),
        const SizedBox(width: 8),
        IconButton(
            tooltip: _copy('آخر المبيعات', 'Recent sales'),
            onPressed: _recentSales,
            icon: Icon(Icons.history_rounded, color: AppColors.secondaryColor))
      ]),
      const SizedBox(height: 12),
      SizedBox(
          height: 40,
          child: ListView(scrollDirection: Axis.horizontal, children: [
            _categoryChip(null, _copy('الكل', 'All products')),
            ..._products
                .map((p) => p.category)
                .toSet()
                .map((category) => _categoryChip(category, category)),
          ])),
      const SizedBox(height: 12),
      Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(children: [
            Text(_copy('دليل المنتجات', 'Product catalog'),
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary)),
            const Spacer(),
            Text(
                _copy('${filtered.length} منتج', '${filtered.length} products'),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: AppColors.mutedColor))
          ])),
      Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.search_off_rounded,
                      size: 36, color: AppColors.mutedColor),
                  const SizedBox(height: 12),
                  Text(_copy('لا توجد منتجات مطابقة', 'No matching products'),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  TextButton(
                      onPressed: () {
                        _search.clear();
                        setState(() => _category = null);
                      },
                      child: Text(_copy('مسح الفلاتر', 'Clear filters')))
                ]))
              : LayoutBuilder(builder: (context, size) {
                  final columns = (size.maxWidth / 140).floor().clamp(1, 5);
                  final scaledText = MediaQuery.textScalerOf(context).scale(13);
                  return GridView.builder(
                      padding: const EdgeInsets.only(bottom: 4),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          mainAxisExtent: 206 + (scaledText > 17 ? 30 : 0)),
                      itemCount: filtered.length,
                      itemBuilder: (context, i) => PosProductTile(
                          product: filtered[i],
                          onSelected: () => _add(filtered[i])));
                })),
    ]);
  }

  Widget _categoryChip(String? value, String label) => Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: ChoiceChip(
          label: Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
          selected: _category == value,
          onSelected: (_) => setState(() => _category = value),
          showCheckmark: false,
          selectedColor: AppColors.primaryColor,
          labelStyle: TextStyle(
              fontWeight: FontWeight.bold,
              color: _category == value
                  ? AppColors.primaryForeground
                  : AppColors.textSecondary),
          backgroundColor: AppColors.surfaceColor,
          side: BorderSide(
              color: _category == value
                  ? AppColors.primaryColor
                  : AppColors.borderColor),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(9))));

  Widget _order() => LayoutBuilder(builder: (context, size) {
        final cart = CartSection(
            cartItems: _cart,
            onRemoveItem: (i) => setState(() => _cart.removeAt(i)),
            onIncreaseQty: (i) => _changeQuantity(i, 1),
            onDecreaseQty: (i) => _changeQuantity(i, -1),
            onEditPrice: (i, price) =>
                setState(() => _cart[i]['price'] = price));
        final summary = TotalSectionCard(
            totalAmount: _total,
            itemCount: _cart.length,
            onCheckout: _checkout,
            onClearCart: () => setState(() => _cart.clear()));
        if (size.maxHeight < 470) {
          return SingleChildScrollView(
              child: Column(children: [
            SizedBox(height: 240, child: cart),
            const SizedBox(height: 12),
            summary
          ]));
        }
        return Column(children: [
          Expanded(child: cart),
          const SizedBox(height: 12),
          summary
        ]);
      });

  Future<void> _checkout() async {
    final total = _total;
    final lines = [
      for (final item in _cart)
        InvoiceLine(
          name: item['name'] as String,
          barcode: item['id'] as String,
          price: item['price'] as double,
          qty: item['qty'] as int,
        ),
    ];
    final selection = await showPosCheckoutDialog(context,
        total: total, itemCount: lines.length);
    if (!mounted || selection == null) return;
    final store = PreviewData.store;
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => InvoicePreviewScreen(
        data: InvoiceData(
          invoiceId: 'PREVIEW',
          date: DateTime.now(),
          storeName: store.name,
          storeAddress: store.address,
          storePhone: store.phone,
          cashierName: getIt<UserCubit>().currentUser.name,
          lines: lines,
          subtotal: total,
          discount: 0,
          tax: 0,
          grandTotal: total,
          branchId: selection.branchId,
          paymentMethod: selection.paymentMethod,
          isDraftPreview: true,
        ),
      ),
    ));
  }

  void _recentSales() => RecentSalesSheet.show(context,
      sales: PreviewData.sales.take(24).toList());
}
