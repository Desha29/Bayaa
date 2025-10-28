import 'package:crazy_phone_pos/features/products/data/models/product_model.dart';
import 'package:either_dart/either.dart';

import '../../../core/error/failure.dart';

abstract class ProductRepositoryInt {
  Either<Failure, List<Product>> getAllProduct();
  Either<Failure, void> saveProduct(Product product);
  Either<Failure, void> deleteProduct(String barcode);
  Either<Failure, List<String>> getAllCategory();
  Either<Failure, void> saveCategory(String category);
  Either<Failure, void> deleteCategory(
      {required String category,
      bool forceDelete = false,
      String? newCategory});
}
