import 'package:crazy_phone_pos/core/components/screen_header.dart';
import 'package:flutter/material.dart';
import '../../../core/components/anim_wrappers.dart';
import '../../../core/constants/app_colors.dart';

import 'widgets/barcode_scan_card.dart';
import 'widgets/cart_list.dart';
import 'widgets/recent_sales.dart';
import 'widgets/total_section_card.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> with SingleTickerProviderStateMixin {
  final _barcodeController = TextEditingController();

  List<Map<String, dynamic>> cartItems = [
    {
      "id": "P001",
      "name": "آيفون 14 برو",
      "price": 4500.0,
      "qty": 1,
      "date": DateTime(2025, 9, 1),
    },
    {
      "id": "P002",
      "name": "سامسونج جالاكسي S23",
      "price": 3200.0,
      "qty": 2,
      "date": DateTime(2025, 9, 10),
    },
  ];

  List<Map<String, dynamic>> recentSales = [
    {"total": 2800.0, "items": 3, "date": DateTime(2025, 9, 23, 14, 30)},
    {"total": 4500.0, "items": 1, "date": DateTime(2025, 9, 23, 14, 15)},
  ];

  @override
  void dispose() {
    _barcodeController.dispose();
    super.dispose();
  }

  void _updateQuantity(int index, int change) {
    setState(() {
      if (cartItems[index]['qty'] + change > 0) {
        cartItems[index]['qty'] += change;
      }
    });
  }

  void _removeItem(int index) {
    setState(() {
      cartItems.removeAt(index);
    });
  }

  void _clearCart() {
    setState(() {
      cartItems.clear();
    });
  }

  void _addProduct() {
    final text = _barcodeController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      cartItems.add({
        "id": "P${cartItems.length + 1}".padLeft(4, "0"),
        "name": text,
        "price": 1000.0 + cartItems.length * 500,
        "qty": 1,
        "date": DateTime.now(),
      });
    });
    _barcodeController.clear();
  }

  void _checkout() {
    if (cartItems.isEmpty) return;

    final total = cartItems.fold<double>(
      0,
      (sum, item) => sum + (item['qty'] * item['price']),
    );

    setState(() {
      recentSales.insert(0, {
        "total": total,
        "items": cartItems.length,
        "date": DateTime.now(),
      });
      cartItems.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 1000;

    final totalAmount = cartItems.fold<double>(
      0,
      (sum, item) => sum + (item['qty'] * item['price']),
    );

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header subtle slide-in from top
        const FadeSlideIn(
          beginOffset: Offset(0, -0.06),
          child: ScreenHeader(
            title: "المبيعات",
            subtitle: "شاشة الكاشير لإدارة عمليات البيع",
          ),
        ),

        const SizedBox(height: 24),

        Column(
          children: [
            // Barcode card slide-in from right
            FadeSlideIn(
              beginOffset: const Offset(0.06, 0),
              child: BarcodeScanCard(
                barcodeController: _barcodeController,
                onAddProduct: _addProduct,
              ),
            ),
            const SizedBox(height: 16),

            // Cart list with switcher keyed by length
            SizedBox(
              height: 300,
              child: SubtleSwitcher(
                child: cartItems.isEmpty
                    ? const Center(
                        key: ValueKey("empty"),
                        child: Text("السلة فارغة"),
                      )
                    : KeyedSubtree(
                        key: ValueKey(cartItems.length),
                        child: CartList(
                          items: cartItems,
                          onRemove: _removeItem,
                          onQtyIncrease: (i) => _updateQuantity(i, 1),
                          onQtyDecrease: (i) => _updateQuantity(i, -1),
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // Totals fade-scale in
            FadeScale(
              child: TotalSectionCard(
                totalAmount: totalAmount,
                onClearCart: cartItems.isNotEmpty ? _clearCart : null,
                onCheckout: _checkout,
              ),
            ),

            if (!isDesktop) ...[
              const SizedBox(height: 24),
              // Recent sales fade-slide from bottom on mobile
              const FadeSlideIn(
                beginOffset: Offset(0, 0.06),
                child: SizedBox.shrink(), // placeholder, replaced below
              ),
            ],
          ],
        ),
      ],
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: isDesktop
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: SingleChildScrollView(child: content),
                  ),
                  const SizedBox(width: 24),
                  // Right column recent sales with fade-scale
                  Expanded(
                    flex: 1,
                    child: FadeScale(
                      child: RecentSalesWidget(sales: recentSales),
                    ),
                  ),
                ],
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    content,
                    // Actual recent sales on mobile with gentle fade-slide up
                    const SizedBox(height: 24),
                    FadeSlideIn(
                      beginOffset: const Offset(0, 0.06),
                      child: RecentSalesWidget(sales: recentSales),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
