// lib/features/sales/presentation/sales_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/components/screen_header.dart';
import '../../../core/constants/app_colors.dart';
import '../../products/data/models/product_model.dart';

import 'widgets/barcode_scan_card.dart';
import 'widgets/cart_section.dart';
import 'widgets/total_section_card.dart';
import 'widgets/recent_sales.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> with TickerProviderStateMixin {
  // Animations (kept from your existing screen)
  late final AnimationController _fadeController;
  late final AnimationController _slideController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  // TextField controller inside your BarcodeScanCard
  final TextEditingController _barcodeController = TextEditingController();

  // HID keyboard-wedge listener (scanners that type like a keyboard)
  final StringBuffer _hidBuffer = StringBuffer();
  Timer? _hidTimer;

  // Local products box (already opened in main)
  late final Box<Product> _productsBox;

  // Simple in-memory cart; matches your CartSection map shape
  final List<Map<String, dynamic>> _cartItems = [];
  List<Map<String, dynamic>> _recentSales = [];

  double get _totalAmount => _cartItems.fold<double>(
        0.0,
        (sum, e) => sum + (e['price'] as double) * (e['qty'] as int),
      );

  @override
  void initState() {
    super.initState();

    _productsBox = Hive.box<Product>('productsBox'); // already opened at app start
    _fadeController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _slideController = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this);
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    _fadeController.forward();
    _slideController.forward();

    // Global HID listener: commits on Enter or brief idle after burst
    RawKeyboard.instance.addListener(_onRawKey);
  }

  @override
  void dispose() {
    RawKeyboard.instance.removeListener(_onRawKey);
    _hidTimer?.cancel();
    _barcodeController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  // Capture scanner keystrokes and commit to search
  void _onRawKey(RawKeyEvent event) {
    if (event is! RawKeyDownEvent) return;

    // Commit as soon as scanner sends Enter/NumpadEnter
    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.numpadEnter) {
      _hidTimer?.cancel();
      final code = _hidBuffer.toString().trim();
      _hidBuffer.clear();
      _commitBarcode(code);
      return;
    }

    // Prefer character; fallback to keyLabel for digits/letters on Windows
    String? ch = event.character;
    if ((ch == null || ch.isEmpty) && event.logicalKey.keyLabel.length == 1) {
      ch = event.logicalKey.keyLabel;
    }

    // Accept visible characters only
    if (ch != null && ch.isNotEmpty && ch.codeUnitAt(0) >= 32) {
      _hidBuffer.write(ch);
      _barcodeController.text = _hidBuffer.toString(); // mirror to TextField
    }

    // If no Enter suffix, commit shortly after the burst ends
    _hidTimer?.cancel();
    _hidTimer = Timer(const Duration(milliseconds: 120), () {
      final code = _hidBuffer.toString().trim();
      _hidBuffer.clear();
      _commitBarcode(code);
    });
  }

  // Central path: find product by barcode and add to cart
  void _commitBarcode(String code) {
    if (code.isEmpty) return;

    // Look up product by barcode in local Hive
    final product = _productsBox.values.firstWhere(
      (p) => p.barcode == code,
      orElse: () => null as Product, // will be caught below
    );

    if (product == null) {
      // Notify when not found
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('المنتج غير موجود: $code')),
      );
      _barcodeController.clear();
      setState(() {});
      return;
    }

    // Already in cart? increase qty; else add line
    final idx = _cartItems.indexWhere((e) => e['id'] == product.barcode);
    if (idx != -1) {
      _cartItems[idx]['qty'] = (_cartItems[idx]['qty'] as int) + 1;
    } else {
      _cartItems.add({
        'id': product.barcode,
        'name': product.name,
        'price': product.price,
        'qty': 1,
        'date': DateTime.now(),
        'minPrice': product is Product ? product.minPrice : 0.0,
      });
    }

    _barcodeController.clear();
    setState(() {});
  }

  // Manual add uses the same path (pressing your existing Add button)
  void _onAddPressed() {
    final code = _barcodeController.text.trim();
    _commitBarcode(code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 1200;
            final isTablet = constraints.maxWidth >= 768 && constraints.maxWidth <= 1200;
            return Padding(
              padding: EdgeInsets.all(isDesktop ? 32 : (isTablet ? 24 : 16)),
              child: (isDesktop || isTablet)
                  ? _buildDesktopTabletLayout(isDesktop)
                  : _buildMobileLayout(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDesktopTabletLayout(bool isDesktop) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: isDesktop ? 7 : 6,
          child: SingleChildScrollView(child: _buildMainContent()),
        ),
        SizedBox(width: isDesktop ? 32 : 24),
        Expanded(
          flex: isDesktop ? 3 : 4,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: RecentSalesSection(recentSales: _recentSales),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildMainContent(),
          const SizedBox(height: 24),
          SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: RecentSalesSection(recentSales: _recentSales),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ScreenHeader(
          title: 'شاشة المبيعات',
          subtitle: 'إدارة عمليات البيع والفواتير',
          fontSize: 32,
          icon: Icons.point_of_sale,
          iconColor: AppColors.primaryColor,
          titleColor: AppColors.kDarkChip,
        ),
        const SizedBox(height: 24),

        // Your existing barcode card; TextField reads scanner input via HID listener
        BarcodeScanCard(
          controller: _barcodeController,
          onAddPressed: _onAddPressed,
        ),

        const SizedBox(height: 20),

        // Your existing cart section
        CartSection(
          cartItems: _cartItems,
          onRemoveItem: (i) {
            _cartItems.removeAt(i);
            setState(() {});
          },
          onIncreaseQty: (i) {
            _cartItems[i]['qty'] = (_cartItems[i]['qty'] as int) + 1;
            setState(() {});
          },
          onDecreaseQty: (i) {
            final q = _cartItems[i]['qty'] as int;
            if (q > 1) {
              _cartItems[i]['qty'] = q - 1;
            } else {
              _cartItems.removeAt(i);
            }
            setState(() {});
          },
        ),

        const SizedBox(height: 20),

        // Your existing totals card
        TotalSectionCard(
          totalAmount: _totalAmount,
          itemCount: _cartItems.length,
          onCheckout: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('تمت عملية البيع - الإجمالي: ${_totalAmount.toStringAsFixed(2)} ج.م'),
                backgroundColor: AppColors.kSuccessGreen,
              ),
            );
            _recentSales = [
              {
                'total': _totalAmount,
                'items': _cartItems.length,
                'date': DateTime.now(),
              },
              ..._recentSales,
            ];
            _cartItems.clear();
            setState(() {});
          },
          onClearCart: () {
            _cartItems.clear();
            setState(() {});
          },
        ),
      ],
    );
  }
}
