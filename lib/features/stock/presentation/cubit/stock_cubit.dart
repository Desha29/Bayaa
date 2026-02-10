import 'package:crazy_phone_pos/features/products/data/models/product_model.dart';
import 'package:crazy_phone_pos/features/products/data/repository/product_repository_imp.dart';
import 'package:crazy_phone_pos/features/products/domain/product_repository_int.dart';
import 'package:crazy_phone_pos/features/stock/presentation/cubit/stock_states.dart'
    show StockErrorState, StockLoadingState, StockStates, StockSucssesState;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/services/activity_logger.dart';
import '../../../../core/data/models/activity_log.dart';
import '../../../auth/presentation/cubit/user_cubit.dart';

class StockCubit extends Cubit<StockStates> {
  StockCubit({required this.productRepository}) : super(StockLoadingState());
  ProductRepositoryInt productRepository;
  List<Product> products = [];
  
  String filter = 'all';
  int lowStockCount = 0;
  int outOfStockCount = 0;
  int totalCount = 0;
  List<Product> sendData() {
    return products.where((p) => p.quantity <= p.minQuantity).toList();
  }

  void loadData() async {
    final result = await productRepository.getAllProduct();
    result.fold(
      (error) => emit(StockErrorState(error.message)), 
      (data) {
        products = data;
        _calculateCounts();
        filterProducts();
      }
    );
  }

  void _calculateCounts() {
    outOfStockCount = products.where((p) => p.quantity == 0).length;
    lowStockCount = products
        .where((p) => p.quantity > 0 && p.quantity < p.minQuantity)
        .length;
    totalCount = lowStockCount + outOfStockCount;
  }

  Future<void> restockProduct(Product product, int quantity) async {
    // Optimistic update
    product.quantity += quantity;
    
    // Recalculate and update UI immediately
    _calculateCounts();
    filterProducts(); // This will remove it from the list if it no longer matches 'out' or 'low'
    
    // Persist to DB
    await productRepository.saveProduct(product);
    
    // Log activity
    getIt<ActivityLogger>().logActivity(
      type: ActivityType.productQuantityUpdate,
      description: 'تحديث مخزون: ${product.name} (+$quantity)',
      userName: getIt<UserCubit>().currentUser.name,
      details: {'barcode': product.barcode, 'quantityAdded': quantity, 'newTotal': product.quantity},
    );
  }

  void filterProducts() {
    final List<Product> filtered = products.where((p) {
      if (filter == 'all' && totalCount > 0)
        return (p.quantity < p.minQuantity);
      if (filter == 'low' && lowStockCount > 0)
        return (p.quantity > 0 && p.quantity < p.minQuantity);
      if (filter == 'out' && outOfStockCount > 0) return p.quantity == 0;
      return false;
    }).toList();
    emit(StockSucssesState(products: filtered));
  }
}
