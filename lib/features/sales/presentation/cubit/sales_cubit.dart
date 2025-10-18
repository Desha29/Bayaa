import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../products/data/models/product_model.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/models/sale_model.dart';
import '../../domain/sales_repository.dart';
import 'sales_state.dart';

class SalesCubit extends Cubit<SalesState> {
  final SalesRepository repository;

  // HID buffer for keyboard-wedge scanners
  final StringBuffer _hidBuffer = StringBuffer();
  Timer? _hidTimer;

  // In-memory data exposed via state
  final List<CartItemModel> _cartItems = [];
  List<Sale> _recentSales = [];
  Sale? _lastCompletedSale; // cache for invoice generation

  SalesCubit({required this.repository}) : super(SalesInitial());

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
      ));
    }
    _emitLoaded();
  }

  void increase(int index) {
    if (index < 0 || index >= _cartItems.length) return;
    _cartItems[index] = _cartItems[index].copyWith(qty: _cartItems[index].qty + 1);
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
        message: 'السعر أقل من الحد الأدنى (${item.minPrice.toStringAsFixed(2)} ج.م)',
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

    // Update stock
    for (final it in _cartItems) {
      final prod = await repository.findProductByBarcode(it.id);
      await prod.fold((_) async {}, (p) async {
        if (p != null) {
          await repository.updateProductQuantity(p.barcode, p.quantity - it.qty);
        }
      });
    }

    // Create sale record
    final sale = Sale(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      total: _total(),
      items: _cartItems.length,
      date: DateTime.now(),
      saleItems: _cartItems
          .map((x) => SaleItem(
                productId: x.id,
                name: x.name,
                price: x.salePrice,
                quantity: x.qty,
                total: x.total,
              ))
          .toList(),
    );

    final saved = await repository.saveSale(sale);
    saved.fold(
      (f) {
        emit(SalesError(message: f.message));
        _emitLoaded();
      },
      (_) async {
        _lastCompletedSale = sale; // cache for invoice
        final total = _total();
        _cartItems.clear();
        
        // NEW: emit with sale data so listener can open invoice immediately
        emit(CheckoutSuccessWithSale(
          message: 'تمت عملية البيع بنجاح',
          total: total,
          sale: sale,
        ));
        
        await load(); // reload recent sales
      },
    );
  }

  // Helpers
  double _total() => _cartItems.fold(0.0, (s, x) => s + x.total);

  void _emitLoaded() {
    emit(SalesLoaded(
      cartItems: List.unmodifiable(_cartItems),
      recentSales: _recentSales,
      totalAmount: _total(),
    ));
  }

  // Expose last sale for invoice generation
  Sale? get lastCompletedSale => _lastCompletedSale;
}

// Backwards-compatible copyWith for CartItemModel (defined in data models).
// Adds a convenient way to create modified copies without editing the model file.
extension CartItemModelCopyWith on CartItemModel {
  CartItemModel copyWith({
    String? id,
    String? name,
    double? originalPrice,
    double? salePrice,
    int? qty,
    DateTime? date,
    double? minPrice,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      originalPrice: originalPrice ?? this.originalPrice,
      salePrice: salePrice ?? this.salePrice,
      qty: qty ?? this.qty,
      date: date ?? this.date,
      minPrice: minPrice ?? this.minPrice,
    );
  }
}
