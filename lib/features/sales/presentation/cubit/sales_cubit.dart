import 'dart:async';
import 'package:crazy_phone_pos/core/di/dependency_injection.dart';
import 'package:crazy_phone_pos/features/auth/presentation/cubit/user_cubit.dart';
import 'package:crazy_phone_pos/features/arp/data/repositories/session_repository_impl.dart';
import 'package:crazy_phone_pos/features/arp/data/models/session_model.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

    // Get Session ID using DI since we didn't inject repository yet in Setup for this specific cubit (to be safe)
    // Or better, update DI for SalesCubit.
    // I will use getIt to access SessionRepositoryImpl.
    // This is safer as I don't need to change Constructor if I don't want to break other tests immediately, but constructor injection is best practice.
    // However, since I am rewriting this file, I might as well rely on getIt global or update constructor.
    // Given the constraints and context, using getIt inside method is lower risk for now.

    final sessionRepo = getIt<SessionRepositoryImpl>();
    var currentSession = sessionRepo.getCurrentSession();
    Session session;

    // Auto-Open Session if not exists (for Admin flow who stays logged in)
    if (currentSession == null || !currentSession.isOpen) {
      final currentUser = getIt<UserCubit>().currentUser;
      try {
        session = await sessionRepo.openSession(currentUser);
      } catch (e) {
        emit(SalesError(message: 'فشل فتح جلسة جديدة: $e'));
        _emitLoaded();
        return;
      }
    } else {
      session = currentSession;
    }

    // Update stock
    for (final it in _cartItems) {
      final prod = await repository.findProductByBarcode(it.id);
      await prod.fold((_) async {}, (p) async {
        if (p != null) {
          await repository.updateProductQuantity(
              p.barcode, p.quantity - it.qty);
        }
      });
    }

    // Create sale record
    final sale = Sale(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      total: _total(),
      items: _cartItems.length,
      cashierName: getIt<UserCubit>().currentUser.name,
      cashierUsername:
          getIt<UserCubit>().currentUser.username, // Added username
      sessionId: session.id, // Linked Session ID
      date: DateTime.now(),
      saleItems: _cartItems
          .map((x) => SaleItem(
                productId: x.id,
                name: x.name,
                price: x.salePrice,
                quantity: x.qty,
                total: x.total,
                wholesalePrice: x.wholesalePrice, // add wholesalePrice here
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
        // Also add invoice ID to session?
        // Session definition says: "List<String> validInvoiceIds".
        // session.invoiceIds.add(sale.id); session.save();
        // I should do this.

        // Optimistic update of session
        session.invoiceIds.add(sale.id);
        await session.save(); // Hive save

        final total = _total();
        _cartItems.clear();

        // Emit with sale data to open invoice immediately
        emit(CheckoutSuccessWithSale(
          message: 'تمت عملية البيع بنجاح',
          total: total,
          sale: sale,
        ));

        await load(); // reload recent sales
      },
    );
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
