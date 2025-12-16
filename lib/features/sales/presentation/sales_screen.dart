// lib/features/sales/presentation/sales_screen.dart
import 'dart:async';
import 'package:crazy_phone_pos/core/di/dependency_injection.dart';
import 'package:crazy_phone_pos/core/functions/messege.dart';
import 'package:crazy_phone_pos/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/components/screen_header.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/presentation/cubit/user_cubit.dart';
import '../../products/data/models/product_model.dart';
import '../data/models/sale_model.dart';
import '../data/repository/sales_repository_impl.dart';
import '../domain/sales_repository.dart';
import '../../invoice/data/invoice_models.dart';
import '../../invoice/presentation/invoice_preview_screen.dart';

import 'widgets/barcode_scan_card.dart';
import 'widgets/cart_section.dart';
import 'widgets/total_section_card.dart';
import 'widgets/recent_sales.dart';

class SalesScreen extends StatefulWidget {
  final SalesRepository? repository; // optional, create if not passed

  const SalesScreen({super.key, this.repository});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen>
    with TickerProviderStateMixin {
  // Animations
  late final AnimationController _fadeController;
  late final AnimationController _slideController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  // TextField controller
  final TextEditingController _barcodeController = TextEditingController();

  // HID keyboard-wedge listener (scanners that type like a keyboard)
  final StringBuffer _hidBuffer = StringBuffer();
  Timer? _hidTimer;

  // Local products box (already opened in main)
  late final Box<Product> _productsBox;

  // Repository for saving sales
  late final SalesRepository _repository;

  // Simple in-memory cart
  final List<Map<String, dynamic>> _cartItems = [];
  List<Map<String, dynamic>> _recentSales = [];

  double get _totalAmount => _cartItems.fold<double>(
        0.0,
        (sum, e) => sum + (e['price'] as double) * (e['qty'] as int),
      );
  Timer? _searchDebounce;
  @override
  void initState() {
    super.initState();

    _productsBox = Hive.box<Product>('productsBox');
    _repository = widget.repository ??
        SalesRepositoryImpl(
          productsBox: _productsBox,
          salesBox: Hive.box<Sale>('salesBox'),
        );

    _fadeController = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);
    _slideController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _slideController, curve: Curves.easeOutCubic));
    _fadeController.forward();
    _slideController.forward();

    // Global HID listener: commits on Enter or brief idle after burst
    RawKeyboard.instance.addListener(_onRawKey);
    _barcodeController.addListener(_onSearchTextChanged);
    // Load recent sales
    _loadRecentSales();
  }

  void _onSearchTextChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      final text = _barcodeController.text.trim();
      if (text.isEmpty) return;

      final productFound = _productsBox.values.any((p) =>
          p.barcode == text ||
          p.name.toLowerCase().contains(text.toLowerCase()));

      if (!productFound) {
        MotionSnackBarError(context, "المنتج غير موجود: $text");
        _barcodeController.clear();
        setState(() {});
      }
    });
  }

  Future<void> _loadRecentSales() async {
    final result = await _repository.getRecentSales(limit: 10);
    result.fold(
      (_) {},
      (sales) {
        setState(() {
          _recentSales = sales
              .map((s) => {
                    'total': s.total,
                    'items': s.items,
                    'date': s.date,
                  })
              .toList();
        });
      },
    );
  }

  @override
  void dispose() {
    RawKeyboard.instance.removeListener(_onRawKey);
    _hidTimer?.cancel();
    _searchDebounce?.cancel();
    _barcodeController.removeListener(_onSearchTextChanged);
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
      orElse: () => Product(
        minQuantity: 0,
        wholesalePrice: 0,
        barcode: '',
        name: '',
        price: 0,
        quantity: 0,
        minPrice: 0,
        category: '',
      ),
    );

    if (product.barcode.isEmpty) {
      // Notify when not found
      MotionSnackBarError(context, "المنتج غير موجود: $code");

      _barcodeController.clear();
      setState(() {});
      return;
    }

    // Already in cart? increase qty; else add line
    final idx = _cartItems.indexWhere((e) => e['id'] == product.barcode);
    if (idx != -1) {
      if (_cartItems[idx]["qty"] == product.quantity) {
        MotionSnackBarError(
            context, "لقد وصلت إلى الحد الأقصى للكمية المتاحة من هذا المنتج");
      } else {
        _cartItems[idx]['qty'] = (_cartItems[idx]['qty'] as int) + 1;
      }
    } else {
      _cartItems.add({
        'id': product.barcode,
        'name': product.name,
        'price': product.price,
        'qty': 1,
        'quantity': product.quantity,
        'wholesalePrice': product.wholesalePrice,
        'date': DateTime.now(),
        'minPrice': product.minPrice,
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

  /// Checkout with invoice auto-open
  Future<void> _onCheckout() async {
    if (_cartItems.isEmpty) {
      MotionSnackBarError(context, 'السلة فارغة');
      return;
    }

    for (final item in _cartItems) {
      final productBarcode = item['id'] as String;
      final qtySold = item['qty'] as int;

      final product = _productsBox.get(
        productBarcode,
      );

      if (product!.barcode.isNotEmpty) {
        final newQuantity = product.quantity - qtySold;

        final updatedProduct = Product(
          barcode: product.barcode,
          name: product.name,
          price: product.price,
          quantity: newQuantity < 0 ? 0 : newQuantity,
          minPrice: product.minPrice,
          category: product.category,
          minQuantity: product.minQuantity,
          wholesalePrice: product.wholesalePrice,
        );

        await _productsBox.put(product.barcode, updatedProduct);
        await getIt<NotificationsCubit>().addItem(updatedProduct);
      }
    }

    final sale = Sale(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      cashierName: getIt<UserCubit>().currentUser.name,
      total: _totalAmount,
      items: _cartItems.length,
      date: DateTime.now(),
      saleItems: _cartItems
          .map((item) => SaleItem(
                productId: item['id'] as String,
                name: item['name'] as String,
                price: (item['price'] as num).toDouble(),
                quantity: item['qty'] as int,
                total: (item['price'] as num).toDouble() * (item['qty'] as int),
                wholesalePrice:
                    (item['wholesalePrice'] as num?)?.toDouble() ?? 0.0,
              ))
          .toList(),
    );

    final result = await _repository.saveSale(sale);

    result.fold(
      (failure) {
        MotionSnackBarError(context, "فشل حفظ البيع: ${failure.message}");
        setState(() {});
      },
      (_) {
        MotionSnackBarSuccess(
          context,
          'تمت عملية البيع - الإجمالي: ${_totalAmount.toStringAsFixed(2)} ج.م',
        );

        // Update recent sales
        _recentSales = [
          {
            'total': _totalAmount,
            'items': _cartItems.length,
            'date': DateTime.now(),
          },
          ..._recentSales,
        ];

        // Clear cart
        _cartItems.clear();
        setState(() {});

        // Auto-open invoice
        _openInvoice(sale);
      },
    );
  }

  // Open invoice preview screen
  Future<void> _openInvoice(Sale sale) async {
    final subtotal = sale.saleItems.fold<double>(0, (s, it) => s + it.total);
    final cashierName = sale.cashierName ?? 'الكاشير';

    final data = InvoiceData(
      invoiceId: sale.id,
      date: sale.date,
      storeName: 'Amr Store',
      storeAddress: ' الخانكة امام شارع الحجار   - القليوبية ',
      storePhone: '01002546124',
      cashierName: cashierName,
      lines: sale.saleItems
          .map((it) => InvoiceLine(
                name: it.name,
                price: it.price,
                qty: it.quantity,
              ))
          .toList(),
      subtotal: subtotal,
      discount: 0.0,
      tax: 0.0,
      grandTotal: sale.total,
      logoAsset: 'assets/images/logo.jpg',
    );

    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            InvoicePreviewScreen(data: data, receiptMode: false),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.1),
                end: Offset.zero,
              ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut)),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 1200;
            final isTablet =
                constraints.maxWidth >= 768 && constraints.maxWidth <= 1200;
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
        BarcodeScanCard(
          controller: _barcodeController,
          onAddPressed: _onAddPressed,
        ),
        const SizedBox(height: 20),
        CartSection(
          cartItems: _cartItems,
          onRemoveItem: (i) {
            _cartItems.removeAt(i);
            setState(() {});
          },
          onIncreaseQty: (i) {
            final currentQty = _cartItems[i]['qty'] as int;
            final stockQuantity = _cartItems[i]['quantity'] as int;

            if (currentQty < stockQuantity) {
              _cartItems[i]['qty'] = currentQty + 1;
              setState(() {});
            } else {
              MotionSnackBarWarning(context,
                  "لا يمكن إضافة المزيد! الكمية المتاحة في المخزون: $stockQuantity");
            }
          },
          onDecreaseQty: (i) {
            final q = _cartItems[i]['qty'] as int;
            if (q > 1) {
              _cartItems[i]['qty'] = q - 1;
              setState(() {});
            } else {
              _cartItems.removeAt(i);
              setState(() {});
            }
          },
          onEditPrice: (i, newPrice) {
            _cartItems[i]['price'] = newPrice;
            setState(() {});
          },
        ),
        const SizedBox(height: 20),
        TotalSectionCard(
          totalAmount: _totalAmount,
          itemCount: _cartItems.length,
          onCheckout: _onCheckout,
          onClearCart: () {
            _cartItems.clear();
            setState(() {});
          },
        ),
      ],
    );
  }
}
