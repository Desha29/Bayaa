// lib/features/sales/domain/sales_repository.dart
import 'package:dartz/dartz.dart';
import '../../../core/error/failure.dart';
import '../../products/data/models/product_model.dart';
import '../data/models/cart_item_model.dart';
import '../data/models/sale_model.dart';

abstract class SalesRepository {
  Future<Either<Failure, Product?>> findProductByBarcode(String barcode);
  Future<Either<Failure, List<Product>>> getAllProducts();
  Future<Either<Failure, List<Sale>>> getAllSales();
  Future<Either<Failure, Unit>> saveSale(Sale sale);
  Future<Either<Failure, Unit>> deleteSale(String saleId);
  Future<Either<Failure, Unit>> deleteSalesInRange(
      DateTime start, DateTime end);
  Future<Either<Failure, Unit>> deleteSalesByQuery(String query);
  Future<Either<Failure, List<Sale>>> getRecentSales({
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<Either<Failure, Unit>> updateProductQuantity(
      String barcode, int newQuantity);
  Future<Either<Failure, bool>> validateMinPrice(
      String barcode, double salePrice);

  // NEW: Method to create sale with cashier info
  Future<Either<Failure, Unit>> createSaleWithCashier({
    required List<CartItemModel> items,
    required double total,
    required String cashierName,
    required String cashierUsername,
  });
}
