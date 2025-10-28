import 'package:crazy_phone_pos/core/error/failure.dart';
import 'package:crazy_phone_pos/features/products/data/data_source/product_data_source.dart';
import 'package:crazy_phone_pos/features/products/data/models/product_model.dart';
import 'package:crazy_phone_pos/features/products/domain/product_repository_int.dart';
import 'package:either_dart/src/either.dart';
import 'package:flutter/foundation.dart';

import '../data_source/category_data_source.dart';

class ProductRepositoryImp extends ProductRepositoryInt {
  ProductDataSource productDataSource;
  CategoryDataSource categoryDataSource;
  ProductRepositoryImp(
      {required this.productDataSource, required this.categoryDataSource});

  @override
  Either<Failure, void> deleteProduct(String barcode) {
    try {
      productDataSource.deleteUser(barcode);
      return const Right(null);
    } on Exception catch (e) {
      return Left(CacheFailure("خطأ في حذف المنتج"));
    }
  }

  @override
  Either<Failure, List<Product>> getAllProduct() {
    try {
      final products = productDataSource.getAllUsers();
      return Right(products);
    } on Exception catch (e) {
      return Left(CacheFailure("خطأ في جلب المنتجات"));
    }
  }

  @override
  Either<Failure, void> saveProduct(Product product) {
    try {
      productDataSource.saveUser(product);
      return const Right(null);
    } on Exception catch (e) {
      return Left(CacheFailure("خطأ في حفظ المنتج"));
    }
  }

  @override
  Either<Failure, void> deleteCategory({
    required String category,
    bool forceDelete = false,
    String? newCategory,
  }) {
    try {
      return getAllProduct().fold(
        (failure) => Left(NetworkFailure("خطأ في جلب المنتجات")),
        (products) {
          final affectedProducts =
              products.where((p) => p.category == category).toList();

          if (affectedProducts.isEmpty) {
            categoryDataSource.deleteCategory(category);
            return const Right(null);
          }

          if (forceDelete) {
            for (final product in affectedProducts) {
              productDataSource.deleteUser(product.barcode);
            }
            categoryDataSource.deleteCategory(category);
            return const Right(null);
          }

          if (newCategory == null || newCategory.trim().isEmpty) {
            return Left(CacheFailure(
                "لا يمكنك حذف الفئة لأنها تحتوي على منتجات. الرجاء اختيار فئة جديدة لإعادة تعيين المنتجات أو استخدام الحذف القسري."));
          }

          for (final product in affectedProducts) {
            final updatedProduct = Product(
              barcode: product.barcode,
              name: product.name,
              price: product.price,
              category: newCategory,
              quantity: product.quantity,
              minPrice: product.minPrice,
              minQuantity: product.minQuantity,
              wholesalePrice: product.wholesalePrice,
            );
            productDataSource.saveUser(updatedProduct);
          }

          categoryDataSource.deleteCategory(category);
          return const Right(null);
        },
      );
    } on Exception catch (e) {
      return Left(NetworkFailure("خطأ في حذف الفئة"));
    }
  }

  @override
  Either<Failure, List<String>> getAllCategory() {
    try {
      final categories = categoryDataSource.getAllCategory();
      return Right(categories);
    } on Exception catch (e) {
      return Left(CacheFailure("خطأ في جلب الفئات"));
    }
  }

  @override
  Either<Failure, void> saveCategory(String category) {
    try {
      categoryDataSource.saveCategory(category);
      return const Right(null);
    } on Exception catch (e) {
      return Left(CacheFailure("خطأ في حفظ الفئة"));
    }
  }
}
