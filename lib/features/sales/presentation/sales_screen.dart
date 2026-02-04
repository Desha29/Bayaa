// lib/features/sales/presentation/sales_screen.dart
import 'dart:async';
import 'package:crazy_phone_pos/core/di/dependency_injection.dart';
import 'package:crazy_phone_pos/core/functions/messege.dart';
import 'package:crazy_phone_pos/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:crazy_phone_pos/features/products/presentation/cubit/product_cubit.dart'; // Explicit absolute import

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
import 'widgets/product_search_overlay.dart';

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
  final FocusNode _barcodeFocusNode = FocusNode();

  // HID keyboard-wedge listener (scanners that type like a keyboard)
  final StringBuffer _hidBuffer = StringBuffer();
  Timer? _hidTimer;

  // No local products box
  
  // Repository for scanning/lookup
  late final SalesRepository _repository;

  // Simple in-memory cart
  final List<Map<String, dynamic>> _cartItems = [];
  List<Map<String, dynamic>> _recentSales = [];
  List<Product> _filteredProducts = [];

  double get _totalAmount => _cartItems.fold<double>(
        0.0,
        (sum, e) => sum + (e['price'] as double) * (e['qty'] as int),
      );
  Timer? _searchDebounce;
  
  @override
  void initState() {
    super.initState();

    _repository = widget.repository ?? getIt<SalesRepositoryImpl>();

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
    // Load recent sales
    _loadRecentSales();
  }

  void _onSearchChanged(String text) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 150), () async {
      final q = text.trim();
      if (q.isEmpty) {
        setState(() => _filteredProducts = []);
        return;
      }
      
      // Use ProductCubit or Repository to search (for now using ProductCubit's cached list if available or repository search)
      // Since we want to search broadly, let's use the loaded products in ProductCubit if available
      final productCubit = getIt<ProductCubit>();
      
      // If products are loaded in memory, filter them. Else we might need a search API.
      // Assuming small catalogue for now as per previous logic.
      final allProducts = productCubit.allProducts; 
      
      final query = q.toLowerCase();
      final parsedNumber = double.tryParse(q.replaceAll(',', '.'));

      // Collect matches and score them
      final List<Map<String, dynamic>> scored = [];
      for (final p in allProducts) {
        var score = 0;
        final name = p.name.toLowerCase();
        final barcode = p.barcode.toLowerCase();
        final category = (p.category ?? '').toLowerCase();
        final priceStr = p.price.toStringAsFixed(2).toLowerCase();

        if (barcode == query) score += 100;
        if (barcode.startsWith(query)) score += 40;
        if (name == query) score += 80;
        if (name.contains(query)) score += 30;
        if (category.contains(query)) score += 20;
        if (priceStr.contains(query)) score += 30;
        if (parsedNumber != null) {
          if ((p.price - parsedNumber).abs() < 0.001) score += 60;
        }

        if (score > 0) scored.add({'product': p, 'score': score});
      }

      scored.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));

      setState(() => _filteredProducts = scored.map((s) => s['product'] as Product).toList());
    });
  }

  Future<void> _commitBarcode(String code) async {
    if (code.isEmpty) return;

    // Look up product by barcode via Repository (SQLite)
    final result = await _repository.findProductByBarcode(code);
    
    result.fold(
      (failure) {
         MotionSnackBarError(context, "خطأ في البحث: ${failure.message}");
      },
      (product) {
        if (product == null) {
          MotionSnackBarError(context, "المنتج غير موجود: $code");
          _barcodeController.clear();
          setState(() {});
          _barcodeFocusNode.requestFocus();
          return;
        }

        // Check strict availability
        if (product.quantity <= 0) {
          MotionSnackBarError(context, "الكمية نفذت من المخزن لهذا المنتج");
          _barcodeController.clear();
          setState(() {});
          _barcodeFocusNode.requestFocus();
          return;
        }

        // Already in cart? increase qty
        final idx = _cartItems.indexWhere((e) => e['id'] == product.barcode);
        if (idx != -1) {
          final currentQty = _cartItems[idx]['qty'] as int;
          if (currentQty >= product.quantity) {
             MotionSnackBarWarning(
                 context, "لقد وصلت إلى الحد الأقصى للكمية المتاحة (${product.quantity})");
          } else {
             _cartItems[idx]['qty'] = currentQty + 1;
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
        _barcodeFocusNode.requestFocus();
      }
    );
  }



  /// Checkout with invoice auto-open
  Future<void> _onCheckout() async {
    if (_cartItems.isEmpty) {
      MotionSnackBarError(context, 'السلة فارغة');
      return;
    }

    // Update stock via Repository
    for (final item in _cartItems) {
      final productBarcode = item['id'] as String;
      final qtySold = item['qty'] as int;
      final stockQuantity = item['quantity'] as int;
      
      final newQuant = stockQuantity - qtySold;
      
      // Update DB
      await _repository.updateProductQuantity(productBarcode, newQuant < 0 ? 0 : newQuant);
    }
    
    // Refresh Product Cubit to reflect stock changes across app
    getIt<ProductCubit>().getAllProducts();

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
            'isRefund': false,
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
      storeName: '',
      storeAddress: '',
      storePhone: '',
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
    );

    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            InvoicePreviewScreen(data: data, receiptMode: true),
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
          child: Column(
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
              const SizedBox(height: 16),
              TotalSectionCard(
                totalAmount: _totalAmount,
                itemCount: _cartItems.length,
                onCheckout: _onCheckout,
                onClearCart: () {
                  _cartItems.clear();
                  setState(() {});
                },
              ),
              const SizedBox(height: 12),
              const SizedBox(height: 12),
              Expanded(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Layout Column with Phantom Widget to reserve space
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Phantom ScanCard
                        Visibility(
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          visible: false,
                          child: const BarcodeScanCard(),
                        ),
                        const SizedBox(height: 16),
                        // The CartSection
                        Expanded(
                          child: CartSection(
                            cartItems: _cartItems,
                            onRemoveItem: (i) {
                              _cartItems.removeAt(i);
                              setState(() {});
                            },
                            onIncreaseQty: (i) {
                              final currentQty = _cartItems[i]['qty'] as int;
                              final stockQuantity =
                                  _cartItems[i]['quantity'] as int;

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
                        ),
                      ],
                    ),

                    // The Real Interactive Elements (ScanCard + Overlay) on Top
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          BarcodeScanCard(
                            controller: _barcodeController,
                            focusNode: _barcodeFocusNode,
                            onSubmitted: (val) => _commitBarcode(val),
                            onChanged: _onSearchChanged,
                          ),
                          if (_filteredProducts.isNotEmpty)
                            ProductSearchOverlay(
                              products: _filteredProducts,
                              allProducts: getIt<ProductCubit>().allProducts,
                              onProductSelected: _addProductFromSearch,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
    return Column(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ScreenHeader(
                title: 'شاشة المبيعات',
                subtitle: 'إدارة عمليات البيع والفواتير',
                fontSize: 28,
                icon: Icons.point_of_sale,
                iconColor: AppColors.primaryColor,
                titleColor: AppColors.kDarkChip,
              ),
              const SizedBox(height: 12),
              TotalSectionCard(
                totalAmount: _totalAmount,
                itemCount: _cartItems.length,
                onCheckout: _onCheckout,
                onClearCart: () {
                  _cartItems.clear();
                  setState(() {});
                },
              ),
              const SizedBox(height: 12),
              const SizedBox(height: 12),
              Expanded(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Layout with Phantom
                    Column(
                      children: [
                        Visibility(
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          visible: false,
                          child: const BarcodeScanCard(),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: CartSection(
                            cartItems: _cartItems,
                            onRemoveItem: (i) {
                              _cartItems.removeAt(i);
                              setState(() {});
                            },
                            onIncreaseQty: (i) {
                              final currentQty = _cartItems[i]['qty'] as int;
                              final stockQuantity =
                                  _cartItems[i]['quantity'] as int;

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
                        ),
                      ],
                    ),
                    // Real Interactive Elements on Top
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          BarcodeScanCard(
                            controller: _barcodeController,
                            focusNode: _barcodeFocusNode,
                            onSubmitted: (val) => _commitBarcode(val),
                            onChanged: _onSearchChanged,
                          ),
                          if (_filteredProducts.isNotEmpty)
                            ProductSearchOverlay(
                              products: _filteredProducts,
                              allProducts: getIt<ProductCubit>().allProducts,
                              onProductSelected: _addProductFromSearch,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: RecentSalesSection(recentSales: _recentSales),
          ),
        ),
      ],
    );
  }
  // Capture scanner keystrokes and commit to search
  void _onRawKey(RawKeyEvent event) {
    if (event is! RawKeyDownEvent) return;
    // If the text field has focus, let the system/TextField handle the input.
    if (_barcodeFocusNode.hasFocus) return;

    // If another widget has focus (e.g. dialog TextField), suppress HID handling
    final primary = FocusManager.instance.primaryFocus;
    if (primary != null && primary != _barcodeFocusNode) return;

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

  void _addProductFromSearch(Product product) {
    // Add directly to cart like scanning
    _commitBarcode(product.barcode);
    setState(() {
      _filteredProducts = [];
    });
  }

  Future<void> _loadRecentSales() async {
    final result = await _repository.getRecentSales(limit: 10);
    result.fold(
      (_) {},
      (sales) {
        if (mounted) {
           setState(() {
          _recentSales = sales
              .map((s) => {
                    'total': s.total,
                    'items': s.items,
                    'date': s.date,
                    'isRefund': s.isRefund,
                  })
              .toList();
        });
        }
      },
    );
  }

  @override
  void dispose() {
    RawKeyboard.instance.removeListener(_onRawKey);
    _hidTimer?.cancel();
    _searchDebounce?.cancel();
    _barcodeController.dispose();
    _barcodeFocusNode.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }
} // End of class
