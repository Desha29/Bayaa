import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../products/data/models/product_model.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/models/sale_model.dart';
import '../../domain/sales_repository.dart';
import 'sales_state.dart';

class SalesCubit extends Cubit<SalesState> {
  final SalesRepository repository;
  List<CartItemModel> _cartItems = [];
  List<Sale> _recentSales = [];

  SalesCubit({required this.repository}) : super(SalesInitial());

  Future<void> loadInitialData() async {
    emit(SalesLoading());
    
    final recentSalesResult = await repository.getRecentSales(limit: 10);
    
    recentSalesResult.fold(
      (failure) => emit(SalesError(message: failure.message)),
      (sales) {
        _recentSales = sales;
        emit(SalesLoaded(
          cartItems: _cartItems,
          recentSales: _recentSales,
          totalAmount: _calculateTotal(),
        ));
      },
    );
  }

  Future<void> scanBarcode(String barcode) async {
    if (barcode.isEmpty) return;

    final productResult = await repository.findProductByBarcode(barcode);

    productResult.fold(
      (failure) => emit(SalesError(message: failure.message)),
      (product) {
        if (product == null) {
          emit(const SalesError(message: 'المنتج غير موجود'));
          _reloadState();
        } else if (product.quantity <= 0) {
          emit(const SalesError(message: 'المنتج غير متوفر في المخزون'));
          _reloadState();
        } else {
          _addProductToCart(product);
        }
      },
    );
  }

  void _addProductToCart(Product product) {
    final existingIndex = _cartItems.indexWhere((item) => item.id == product.barcode);

    if (existingIndex != -1) {
      _cartItems[existingIndex].qty++;
    } else {
      _cartItems.add(CartItemModel(
        id: product.barcode,
        name: product.name,
        originalPrice: product.price,
        salePrice: product.price,
        qty: 1,
        date: DateTime.now(),
        minPrice: product.minPrice,
      ));
    }

    emit(SalesLoaded(
      cartItems: _cartItems,
      recentSales: _recentSales,
      totalAmount: _calculateTotal(),
      scannerMessage: 'تم إضافة ${product.name}',
    ));
  }

  Future<void> editItemPrice(int index, double newPrice) async {
    if (index >= _cartItems.length) return;

    final item = _cartItems[index];
    
    if (newPrice < item.minPrice) {
      emit(PriceValidationError(
        message: 'السعر أقل من الحد الأدنى المسموح (${item.minPrice.toStringAsFixed(2)} ج.م)',
        minPrice: item.minPrice,
        attemptedPrice: newPrice,
      ));
      _reloadState();
      return;
    }

    _cartItems[index].salePrice = newPrice;
    emit(SalesLoaded(
      cartItems: _cartItems,
      recentSales: _recentSales,
      totalAmount: _calculateTotal(),
    ));
  }

  void increaseQuantity(int index) {
    if (index >= _cartItems.length) return;
    _cartItems[index].qty++;
    _reloadState();
  }

  void decreaseQuantity(int index) {
    if (index >= _cartItems.length) return;
    if (_cartItems[index].qty > 1) {
      _cartItems[index].qty--;
    } else {
      _cartItems.removeAt(index);
    }
    _reloadState();
  }

  void removeItem(int index) {
    if (index >= _cartItems.length) return;
    _cartItems.removeAt(index);
    _reloadState();
  }

  void clearCart() {
    _cartItems.clear();
    _reloadState();
  }

  Future<void> checkout() async {
    if (_cartItems.isEmpty) {
      emit(const SalesError(message: 'السلة فارغة'));
      _reloadState();
      return;
    }

    emit(SalesLoading());

    // Update product quantities
    for (var cartItem in _cartItems) {
      final productResult = await repository.findProductByBarcode(cartItem.id);
      
      await productResult.fold(
        (failure) async => null,
        (product) async {
          if (product != null) {
            final newQuantity = product.quantity - cartItem.qty;
            await repository.updateProductQuantity(cartItem.id, newQuantity);
          }
        },
      );
    }

    // Create sale record
    final sale = Sale(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      total: _calculateTotal(),
      items: _cartItems.length,
      date: DateTime.now(),
      saleItems: _cartItems.map((item) => SaleItem(
        productId: item.id,
        name: item.name,
        price: item.salePrice,
        quantity: item.qty,
        total: item.total,
      )).toList(),
    );

    final saveResult = await repository.saveSale(sale);

    saveResult.fold(
      (failure) {
        emit(SalesError(message: failure.message));
        _reloadState();
      },
      (_) {
        final total = _calculateTotal();
        _cartItems.clear();
        emit(CheckoutSuccess(
          message: 'تمت عملية البيع بنجاح',
          total: total,
        ));
        loadInitialData();
      },
    );
  }

  double _calculateTotal() {
    return _cartItems.fold(0.0, (sum, item) => sum + item.total);
  }

  void _reloadState() {
    emit(SalesLoaded(
      cartItems: _cartItems,
      recentSales: _recentSales,
      totalAmount: _calculateTotal(),
    ));
  }
}
