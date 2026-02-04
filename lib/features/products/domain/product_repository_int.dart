import 'package:crazy_phone_pos/features/products/data/models/product_model.dart';
import 'package:either_dart/either.dart';

import '../../../core/error/failure.dart';

abstract class ProductRepositoryInt {
  Future<Either<Failure, List<Product>>> getAllProduct();
  Future<Either<Failure, List<Product>>> getProductsPaginated({
    required int page,
    required int pageSize,
    String? category,
    String? availability,
    String? searchQuery,
  });
  Future<Either<Failure, void>> saveProduct(Product product);
  Future<Either<Failure, void>> deleteProduct(String barcode);
  Future<Either<Failure, List<String>>> getAllCategory();
  Future<Either<Failure, void>> saveCategory(String category);
  Future<Either<Failure, void>> deleteCategory(
      {required String category,
      bool forceDelete = false,
      String? newCategory});
  Future<Either<Failure, bool>> productExists(String barcode);
}
