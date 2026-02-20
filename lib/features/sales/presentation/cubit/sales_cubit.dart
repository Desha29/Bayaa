import 'dart:async';
import 'package:crazy_phone_pos/core/di/dependency_injection.dart';
import 'package:crazy_phone_pos/features/auth/presentation/cubit/user_cubit.dart';
import 'package:crazy_phone_pos/features/sessions/data/repositories/session_repository_impl.dart';
import 'package:crazy_phone_pos/features/sessions/data/models/session_model.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crazy_phone_pos/features/notifications/presentation/cubit/notifications_cubit.dart';
import '../../../invoice/presentation/cubit/invoice_cubit.dart';
import '../../../../core/services/activity_logger.dart';
import '../../../../core/data/models/activity_log.dart';
import '../../../auth/presentation/cubit/user_cubit.dart';
import '../../../../core/session/session_manager.dart';

import '../../../products/data/models/product_model.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/models/sale_model.dart';
import '../../domain/sales_repository.dart';

import 'sales_state.dart';

class SalesCubit extends Cubit<SalesState> {
  final SalesRepository repository;
  // Use dependency injection for session repository if possible, or getIt inside
  // But strictly constructor injection is better. I will add it to DI later.
  // For now, to minimize diffs and since getIt is used elsewhere, allow lookup or optional Param?
  // Let's rely on DI update.
  // But wait, the previous code update for DI (Step 173) did NOT inject SessionRepository into SalesCubit yet.
  // I will assume I will update DI in next step.
  // So I add the field here.

  // Note: DI update is NEEDED after this file change.

  SalesCubit({required this.repository}) : super(SalesInitial());

  // HID buffer for keyboard-wedge scanners
  final StringBuffer _hidBuffer = StringBuffer();
  Timer? _hidTimer;

  // In-memory data exposed via state
  final List<CartItemModel> _cartItems = [];
  List<Sale> _recentSales = [];
  Sale? _lastCompletedSale; // cache for invoice generation

  // Attach/detach global HID listener (call from screen init/dispose)
  void attachHidListener() {
    RawKeyboard.instance.addListener(_onRawKey);
  }

  void detachHidListener() {
    RawKeyboard.instance.removeListener(_onRawKey);
    _hidTimer?.cancel();
  }

  // Initialize: load recent sales
  Future<void> load() async {
    emit(SalesLoading());
    final recent = await repository.getRecentSales(limit: 10);
    recent.fold(
      (f) => emit(SalesError(message: f.message)),
      (list) {
        _recentSales = list;
        _emitLoaded();
      },
    );
  }

  // Screen TextField Add button or manual commit calls this
  Future<void> commitBarcode(String code) async {
    final trimmed = code.trim();
    if (trimmed.isEmpty) return;
    await _addByBarcode(trimmed);
  }

  // HID key handler moved to Cubit
  void _onRawKey(RawKeyEvent e) {
    if (e is! RawKeyDownEvent) return;

    if (e.logicalKey == LogicalKeyboardKey.enter ||
        e.logicalKey == LogicalKeyboardKey.numpadEnter) {
      _hidTimer?.cancel();
      final code = _hidBuffer.toString().trim();
      _hidBuffer.clear();
      commitBarcode(code);
      return;
    }

    String? ch = e.character;
    if ((ch == null || ch.isEmpty) && e.logicalKey.keyLabel.length == 1) {
      ch = e.logicalKey.keyLabel;
    }
    if (ch != null && ch.isNotEmpty && ch.codeUnitAt(0) >= 32) {
      _hidBuffer.write(ch);
    }

    _hidTimer?.cancel();
    _hidTimer = Timer(const Duration(milliseconds: 120), () {
      final code = _hidBuffer.toString().trim();
      _hidBuffer.clear();
      commitBarcode(code);
    });
  }

  // Repository lookup and add to cart
  Future<void> _addByBarcode(String barcode) async {
    final res = await repository.findProductByBarcode(barcode);
    await res.fold(
      (f) async {
        emit(SalesError(message: f.message));
        _emitLoaded(); // restore UI
      },
      (product) async {
        if (product == null) {
          emit(const SalesError(message: 'المنتج غير موجود'));
          _emitLoaded();
          return;
        }
        if (product.quantity <= 0) {
          emit(const SalesError(message: 'المنتج غير متوفر في المخزون'));
          _emitLoaded();
          return;
        }
        _addProductToCart(product);
      },
    );
  }

  void _addProductToCart(Product p) {
    final i = _cartItems.indexWhere((x) => x.id == p.barcode);
    if (i != -1) {
      _cartItems[i] = _cartItems[i].copyWith(qty: _cartItems[i].qty + 1);
    } else {
      _cartItems.add(CartItemModel(
        id: p.barcode,
        name: p.name,
        originalPrice: p.price,
        salePrice: p.price,
        qty: 1,
        date: DateTime.now(),
        minPrice: p.minPrice,
        wholesalePrice: p.wholesalePrice, // important addition here
      ));
    }
    _emitLoaded();
  }

  // Public API so other features (e.g., Products screen) can add items
  // directly to the sales cart.
  void addProduct(Product p) {
    _addProductToCart(p);
  }

  void increase(int index) {
    if (index < 0 || index >= _cartItems.length) return;
    _cartItems[index] =
        _cartItems[index].copyWith(qty: _cartItems[index].qty + 1);
    _emitLoaded();
  }

  void decrease(int index) {
    if (index < 0 || index >= _cartItems.length) return;
    final q = _cartItems[index].qty;
    if (q > 1) {
      _cartItems[index] = _cartItems[index].copyWith(qty: q - 1);
    } else {
      _cartItems.removeAt(index);
    }
    _emitLoaded();
  }

  void remove(int index) {
    if (index < 0 || index >= _cartItems.length) return;
    _cartItems.removeAt(index);
    _emitLoaded();
  }

  void clearCart() {
    _cartItems.clear();
    _emitLoaded();
  }

  Future<void> editPrice(int index, double newPrice) async {
    if (index < 0 || index >= _cartItems.length) return;
    final item = _cartItems[index];
    if (newPrice < item.minPrice) {
      emit(PriceValidationError(
        message:
            'السعر أقل من الحد الأدنى (${item.minPrice.toStringAsFixed(2)} ج.م)',
        minPrice: item.minPrice,
        attemptedPrice: newPrice,
      ));
      _emitLoaded();
      return;
    }
    _cartItems[index] = item.copyWith(salePrice: newPrice);
    _emitLoaded();
  }

  Future<void> checkout() async {
    if (_cartItems.isEmpty) {
      emit(const SalesError(message: 'السلة فارغة'));
      _emitLoaded();
      return;
    }
    emit(SalesLoading());

    // Capture total NOW before any async operations
    final total = _total();
    final itemNames = _cartItems.map((e) => e.name).toList();
    final itemCount = _cartItems.length;
    final userName = getIt<UserCubit>().currentUser.name;
    
    print('DEBUG_CHECKOUT: Starting checkout total=$total items=$itemCount user=$userName');

    // Get or auto-create session via SessionManager
    String sessionId;
    try {
      sessionId = await getIt<SessionManager>().ensureSessionId(
        userName: userName,
      );
    } catch (e) {
      print('DEBUG_CHECKOUT: Failed to get session: $e');
      emit(SalesError(message: 'فشل فتح يوم جديد: $e'));
      _emitLoaded();
      return;
    }
    print('DEBUG_CHECKOUT: Using session $sessionId');

    // Update stock — fixed: no unawaited fold
    for (final it in _cartItems) {
      final prod = await repository.findProductByBarcode(it.id);
      prod.fold((_) {}, (p) async {
        if (p != null) {
          final newQty = p.quantity - it.qty;
          await repository.updateProductQuantity(p.barcode, newQty);
          getIt<NotificationsCubit>().addItem(p.copyWith(quantity: newQty));
        }
      });
    }

    // Create sale record
    final sale = Sale(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      total: total,
      items: itemCount,
      cashierName: userName,
      cashierUsername: getIt<UserCubit>().currentUser.username,
      sessionId: sessionId,
      date: DateTime.now(),
      saleItems: _cartItems
          .map((x) => SaleItem(
                productId: x.id,
                name: x.name,
                price: x.salePrice,
                quantity: x.qty,
                total: x.total,
                wholesalePrice: x.wholesalePrice,
              ))
          .toList(),
    );

    print('DEBUG_CHECKOUT: Saving sale id=${sale.id} isRefund=${sale.isRefund}');
    final saved = await repository.saveSale(sale);
    if (saved.isLeft()) {
      saved.fold(
        (f) {
          print('DEBUG_CHECKOUT: Save FAILED: ${f.message}');
          emit(SalesError(message: f.message));
          _emitLoaded();
        },
        (_) {},
      );
      return;
    }
    print('DEBUG_CHECKOUT: Sale saved successfully');

    // Sale saved — log activity immediately
    _lastCompletedSale = sale;
    
    try {
      print('DEBUG_CHECKOUT: Logging activity type=sale total=$total');
      await getIt<ActivityLogger>().logActivity(
        type: ActivityType.sale,
        description: 'عملية بيع: ${total.toStringAsFixed(2)} ج.م',
        userName: userName,
        sessionId: sessionId,
        details: {
          'total': total,
          'itemCount': itemCount,
          'items': itemNames,
        },
      );
      print('DEBUG_CHECKOUT: Activity logged successfully ✓');
    } catch (e) {
      print('DEBUG_CHECKOUT: FAILED to log activity: $e');
    }

    _cartItems.clear();

    // Emit with sale data to open invoice immediately
    emit(CheckoutSuccessWithSale(
      message: 'تمت عملية البيع بنجاح',
      total: total,
      sale: sale,
    ));

    await load(); // reload recent sales
    
    // Refresh InvoiceCubit to update Dashboard stats immediately
    getIt<InvoiceCubit>().loadSales();
  }

  double _total() => _cartItems.fold(0.0, (s, x) => s + x.total);

  void _emitLoaded() {
    emit(SalesLoaded(
      cartItems: List.unmodifiable(_cartItems),
      recentSales: _recentSales,
      totalAmount: _total(),
    ));
  }

  Sale? get lastCompletedSale => _lastCompletedSale;
}

// Extension for convenient copyWith
extension CartItemModelCopyWith on CartItemModel {
  CartItemModel copyWith({
    String? id,
    String? name,
    double? originalPrice,
    double? salePrice,
    int? qty,
    DateTime? date,
    double? minPrice,
    double? wholesalePrice,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      originalPrice: originalPrice ?? this.originalPrice,
      salePrice: salePrice ?? this.salePrice,
      qty: qty ?? this.qty,
      date: date ?? this.date,
      minPrice: minPrice ?? this.minPrice,
      wholesalePrice: wholesalePrice ?? this.wholesalePrice,
    );
  }
}
