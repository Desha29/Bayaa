import 'package:bayaa_pos/features/products/presentation/models/product_view_data.dart';
import 'package:bayaa_pos/features/products/presentation/sources/product_catalog_source.dart';
import 'package:bayaa_pos/features/inventory/presentation/controllers/stock_alerts_state.dart'
    show StockErrorState, StockLoadingState, StockAlertsState, StockLoadedState;
import 'package:flutter_bloc/flutter_bloc.dart';

class StockAlertsCubit extends Cubit<StockAlertsState> {
  StockAlertsCubit({required this.productRepository})
      : super(StockLoadingState());

  ProductCatalogSource productRepository;
  List<ProductViewData> products = [];

  String filter = 'all';
  int lowStockCount = 0;
  int outOfStockCount = 0;
  int totalCount = 0;
  List<ProductViewData> sendData() {
    return products.where((p) => p.quantity == 0 || _isLow(p)).toList();
  }

  bool _isLow(ProductViewData product) =>
      product.quantity > 0 && product.quantity <= product.minQuantity;

  void loadData() async {
    final result = await productRepository.getAllProduct();
    result.fold((error) => emit(StockErrorState(error.message)), (data) {
      products = data;
      _calculateCounts();
      filterProducts();
    });
  }

  void _calculateCounts() {
    outOfStockCount = products.where((p) => p.quantity == 0).length;
    lowStockCount = products.where(_isLow).length;
    totalCount = lowStockCount + outOfStockCount;
  }

  void filterProducts() {
    final filtered = switch (filter) {
      'low' => products.where(_isLow).toList(),
      'out' => products.where((p) => p.quantity == 0).toList(),
      _ => sendData(),
    };
    emit(StockLoadedState(products: filtered));
  }
}
