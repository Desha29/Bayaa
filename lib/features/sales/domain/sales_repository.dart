import 'package:dartz/dartz.dart';

import '../../../core/error/failure.dart';
import '../../products/data/models/product_model.dart';
import '../data/models/sale_model.dart';


abstract class SalesRepository {
  Future<Either<Failure, Product?>> findProductByBarcode(String barcode);
  Future<Either<Failure, List<Product>>> getAllProducts();
  Future<Either<Failure, Unit>> saveSale(Sale sale);
  Future<Either<Failure, List<Sale>>> getRecentSales({int limit = 10});
  Future<Either<Failure, Unit>> updateProductQuantity(String barcode, int newQuantity);
  Future<Either<Failure, bool>> validateMinPrice(String barcode, double salePrice);
}
