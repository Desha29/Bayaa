import 'package:crazy_phone_pos/features/products/data/models/product_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ProductDataSource {
  final Box _productBox = Hive.box<Product>('productsBox');
  void saveUser(Product product) {
    try {
      _productBox.put(product.barcode, product);
    } on Exception {
      rethrow;
    }
  }

  List<Product> getAllUsers() {
    try {
      return _productBox.values.cast<Product>().toList();
    } on Exception {
      rethrow;
    }
  }

  void deleteUser(String barcode) {
    try {
      _productBox.delete(barcode);
    } on Exception {
      rethrow;
    }
  }
}
