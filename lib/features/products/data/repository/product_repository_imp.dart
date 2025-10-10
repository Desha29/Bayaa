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
  Either<Failure, void> deleteCategory(String category) {
    List<Product> productsList = [];
    try {
      getAllProduct().fold(
          (failure) => Left(CacheFailure("خطأ في جلب المنتجات")),
          (products) => productsList = products);
      if (productsList
          .where((element) => element.category == category)
          .isNotEmpty) {
        return Left(
            CacheFailure("لا يمكن حذف هذه الفئة لوجود منتجات مرتبطة بها"));
      }
      categoryDataSource.deleteCategory(category);
      return const Right(null);
    } on Exception catch (e) {
      return Left(CacheFailure("خطأ في حذف الفئة"));
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
