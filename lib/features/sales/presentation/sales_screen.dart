// lib/features/sales/presentation/sales_screen.dart
import 'dart:async';
import 'package:bayaa_pos/l10n/app_localizations.dart';
import 'package:bayaa_pos/core/di/dependency_injection.dart';
import 'package:bayaa_pos/core/functions/messege.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bayaa_pos/features/products/presentation/cubit/product_cubit.dart';

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
import '../../../../core/services/activity_logger.dart';
import '../../../../core/data/models/activity_log.dart';
import '../../../../core/session/session_manager.dart';
import 'package:bayaa_pos/features/invoice/presentation/cubit/invoice_cubit.dart';
import '../../settings/presentation/cubit/settings_cubit.dart';

class SalesScreen extends StatefulWidget {
  final SalesRepository? repository;

  const SalesScreen({super.key, this.repository});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  final TextEditingController _barcodeController = TextEditingController();
  final FocusNode _barcodeFocusNode = FocusNode();

  final StringBuffer _hidBuffer = StringBuffer();
  Timer? _hidTimer;

  late final SalesRepository _repository;

  final List<Map<String, dynamic>> _cartItems = [];
  List<Map<String, dynamic>> _recentSales = [];
  List<Product> _filteredProducts = [];
  bool _isRecentSalesCollapsed = false;

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
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _fadeController.forward();

    RawKeyboard.instance.addListener(_onRawKey);
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

      final productCubit = getIt<ProductCubit>();
      final allProducts = productCubit.allProducts;

      final query = q.toLowerCase();
      final parsedNumber = double.tryParse(q.replaceAll(',', '.'));

      final List<Map<String, dynamic>> scored = [];
      for (final p in allProducts) {
        var score = 0;
        final name = p.name.toLowerCase();
        final barcode = p.barcode.toLowerCase();
        final category = (p.category).toLowerCase();
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

      setState(() => _filteredProducts =
          scored.map((s) => s['product'] as Product).toList());
    });
  }

  Future<void> _commitBarcode(String code) async {
    if (code.isEmpty) return;

    final result = await _repository.findProductByBarcode(code);

    result.fold((failure) {
      MotionSnackBarError(context,
          AppLocalizations.of(context).searchErrorMsg(failure.message));
    }, (product) {
      if (product == null) {
        MotionSnackBarError(
            context, AppLocalizations.of(context).productNotFound(code));
        _barcodeController.clear();
        setState(() {});
        _barcodeFocusNode.requestFocus();
        return;
      }

      if (product.quantity <= 0) {
        MotionSnackBarError(context, AppLocalizations.of(context).outOfStock);
        _barcodeController.clear();
        setState(() {});
        _barcodeFocusNode.requestFocus();
        return;
      }

      final idx = _cartItems.indexWhere((e) => e['id'] == product.barcode);
      if (idx != -1) {
        final currentQty = _cartItems[idx]['qty'] as int;
        if (currentQty >= product.quantity) {
          MotionSnackBarWarning(context,
              AppLocalizations.of(context).maxQtyReached(product.quantity));
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
    });
  }

  Future<void> _onCheckout() async {
    if (_cartItems.isEmpty) {
      MotionSnackBarError(context, AppLocalizations.of(context).cartEmpty);
      return;
    }

    final total = _totalAmount;
    final itemCount = _cartItems.length;
    final itemNames = _cartItems.map((e) => e['name'] as String).toList();
    final userName = getIt<UserCubit>().currentUser.name;

    // Show payment method selection dialog
    final paymentMethod = await _showPaymentMethodDialog();
    if (paymentMethod == null) return; // User cancelled

    for (final item in _cartItems) {
      final productBarcode = item['id'] as String;
      final qtySold = item['qty'] as int;
      final stockQuantity = item['quantity'] as int;

      final newQuant = stockQuantity - qtySold;

      await _repository.updateProductQuantity(
          productBarcode, newQuant < 0 ? 0 : newQuant);
    }

    getIt<ProductCubit>().getAllProducts();

    String? sessionId;
    try {
      sessionId = await getIt<SessionManager>().ensureSessionId(
        userName: userName,
      );
    } catch (e) {
      print('DEBUG_CHECKOUT: Failed to get session: $e');
    }

    final sale = Sale(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      cashierName: userName,
      total: total,
      items: itemCount,
      date: DateTime.now(),
      sessionId: sessionId,
      paymentMethod: paymentMethod,
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
        MotionSnackBarError(context,
            AppLocalizations.of(context).saveSaleFailed(failure.message));
        setState(() {});
      },
      (_) async {
        MotionSnackBarSuccess(
          context,
          AppLocalizations.of(context).saleCompleted(total.toStringAsFixed(2),
              AppLocalizations.of(context).currencyEg),
        );

        if (sessionId != null) {
          try {
            await getIt<ActivityLogger>().logActivity(
              type: ActivityType.sale,
              description: AppLocalizations.of(context).saleActivityDesc(
                  total.toStringAsFixed(2),
                  AppLocalizations.of(context).currencyEg),
              userName: userName,
              sessionId: sessionId,
              details: {
                'total': total,
                'itemCount': itemCount,
                'items': itemNames,
              },
              eventKey: 'saleCompleted',
              parameters: {'user': userName, 'total': total.toStringAsFixed(2)},
            );
            print('DEBUG_CHECKOUT: Sale activity logged ✓');
          } catch (e) {
            print('DEBUG_CHECKOUT: Failed to log activity: $e');
          }
        }

        _recentSales = [
          {
            'total': total,
            'items': itemCount,
            'date': DateTime.now(),
            'isRefund': false,
          },
          ..._recentSales,
        ];

        _cartItems.clear();
        setState(() {});

        getIt<InvoiceCubit>().loadSales();

        _openInvoice(sale);
      },
    );
  }

  Future<void> _openInvoice(Sale sale) async {
    final subtotal = sale.saleItems.fold<double>(0, (s, it) => s + it.total);
    final cashierName = sale.cashierName ?? 'Cashier';

    final data = InvoiceData(
      invoiceId: sale.id,
      date: sale.date,
      storeName: getIt<SettingsCubit>().currentStoreInfo?.name ?? 'Bayaa',
      storeAddress:
          getIt<SettingsCubit>().currentStoreInfo?.address ?? 'AlKhanaka',
      storePhone:
          getIt<SettingsCubit>().currentStoreInfo?.phone ?? '0100000000',
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
      paymentMethod: sale.paymentMethod,
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

  Future<String?> _showPaymentMethodDialog() {
    final l10n = AppLocalizations.of(context);
    return showDialog<String>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 380,
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.payments_outlined,
                  color: AppColors.primaryColor,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.paymentMethodTitle,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.saleCompleted(
                    _totalAmount.toStringAsFixed(2), l10n.currencyEg),
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _PaymentOption(
                      icon: Icons.money,
                      label: l10n.paymentCash,
                      color: Colors.green,
                      onTap: () => Navigator.of(context).pop('cash'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PaymentOption(
                      icon: Icons.account_balance_wallet,
                      label: l10n.paymentWallet,
                      color: AppColors.primaryColor,
                      onTap: () => Navigator.of(context).pop('wallet'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  l10n.cancelPayment,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
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
            final isDesktop = constraints.maxWidth > 1100;
            final isTablet =
                constraints.maxWidth >= 768 && constraints.maxWidth <= 1100;
            return Padding(
              padding: EdgeInsets.fromLTRB(
                isDesktop ? 24 : (isTablet ? 16 : 12),
                8,
                isDesktop ? 24 : (isTablet ? 16 : 12),
                isDesktop ? 24 : (isTablet ? 16 : 12),
              ),
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
    final l10n = AppLocalizations.of(context);
    return Directionality(
      textDirection:
          l10n.localeName == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column (POS Scanner + Cart Table)
          Expanded(
            flex: isDesktop ? 7 : 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ScreenHeader(
                  title: AppLocalizations.of(context).salesScreenTitle,
                  subtitle: AppLocalizations.of(context).salesScreenSubtitle,
                  fontSize: 30,
                  icon: Icons.point_of_sale,
                  iconColor: AppColors.primaryColor,
                  titleColor: AppColors.textPrimary,
                ),
                const ScreenHeaderGap(height: 16),
                Expanded(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Visibility(
                            maintainSize: true,
                            maintainAnimation: true,
                            maintainState: true,
                            visible: false,
                            child: const BarcodeScanCard(),
                          ),
                          const SizedBox(height: 16),
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
                                  MotionSnackBarWarning(
                                      context,
                                      AppLocalizations.of(context)
                                          .cantAddMoreStock(stockQuantity));
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
          SizedBox(width: isDesktop ? 24 : 16),
          // Right Column (Checkout totals + Recent sales)
          Expanded(
            flex: isDesktop ? 3 : 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const ScreenHeaderGap(height: 86),
                TotalSectionCard(
                  totalAmount: _totalAmount,
                  itemCount: _cartItems.length,
                  onCheckout: _onCheckout,
                  onClearCart: () {
                    _cartItems.clear();
                    setState(() {});
                  },
                ),
                const SizedBox(height: 16),
                if (!_isRecentSalesCollapsed)
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: RecentSalesSection(
                        recentSales: _recentSales,
                        onToggleCollapse: () {
                          setState(() {
                            _isRecentSalesCollapsed = !_isRecentSalesCollapsed;
                          });
                        },
                      ),
                    ),
                  ),
                if (_isRecentSalesCollapsed)
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isRecentSalesCollapsed = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.kCardBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderColor),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.01),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chevron_left,
                              color: AppColors.primaryColor, size: 20),
                          SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(context).showRecentSales,
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ScreenHeader(
          title: AppLocalizations.of(context).salesScreenTitle,
          subtitle: AppLocalizations.of(context).salesScreenSubtitle,
          fontSize: 26,
          icon: Icons.point_of_sale,
          iconColor: AppColors.primaryColor,
          titleColor: AppColors.textPrimary,
        ),
        const ScreenHeaderGap(height: 12),
        Expanded(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                        final stockQuantity = _cartItems[i]['quantity'] as int;

                        if (currentQty < stockQuantity) {
                          _cartItems[i]['qty'] = currentQty + 1;
                          setState(() {});
                        } else {
                          MotionSnackBarWarning(
                              context,
                              AppLocalizations.of(context)
                                  .cantAddMoreStock(stockQuantity));
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
        InkWell(
          onTap: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              builder: (context) => Container(
                decoration: const BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                padding: const EdgeInsets.all(16),
                child: RecentSalesSection(
                  recentSales: _recentSales,
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: AppColors.primaryColor.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.history,
                    color: AppColors.primaryColor, size: 18),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context).recentSalesLabel,
                  style: const TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _onRawKey(RawKeyEvent event) {
    if (event is! RawKeyDownEvent) return;
    if (_barcodeFocusNode.hasFocus) return;

    final primary = FocusManager.instance.primaryFocus;
    if (primary != null && primary != _barcodeFocusNode) return;

    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.numpadEnter) {
      _hidTimer?.cancel();
      final code = _hidBuffer.toString().trim();
      _hidBuffer.clear();
      _commitBarcode(code);
      return;
    }

    String? ch = event.character;
    if ((ch == null || ch.isEmpty) && event.logicalKey.keyLabel.length == 1) {
      ch = event.logicalKey.keyLabel;
    }

    if (ch != null && ch.isNotEmpty && ch.codeUnitAt(0) >= 32) {
      _hidBuffer.write(ch);
      _barcodeController.text = _hidBuffer.toString();
    }

    _hidTimer?.cancel();
    _hidTimer = Timer(const Duration(milliseconds: 120), () {
      final code = _hidBuffer.toString().trim();
      _hidBuffer.clear();
      _commitBarcode(code);
    });
  }

  void _addProductFromSearch(Product product) {
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
    super.dispose();
  }
}

class _PaymentOption extends StatelessWidget {
  const _PaymentOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.06),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
