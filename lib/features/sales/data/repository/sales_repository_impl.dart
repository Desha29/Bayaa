import 'package:dartz/dartz.dart';
import 'package:hive_flutter/adapters.dart';

import '../../../../core/error/failure.dart';

import '../../../products/data/models/product_model.dart';
import '../../domain/sales_repository.dart';
import '../models/sale_model.dart';


class SalesRepositoryImpl implements SalesRepository {
  final Box<Product> productsBox;
  final Box<Sale> salesBox;

  SalesRepositoryImpl({
    required this.productsBox,
    required this.salesBox,
  });

  @override
  Future<Either<Failure, Product?>> findProductByBarcode(String barcode) async {
    try {
      final products = productsBox.values.where((p) => p.barcode == barcode);
      if (products.isEmpty) {
        return Right(null);
      }
      return Right(products.first);
    } catch (e) {
      return Left(CacheFailure( 'Failed to find product: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getAllProducts() async {
    try {
      return Right(productsBox.values.toList());
    } catch (e) {
      return Left(CacheFailure('Failed to get products: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveSale(Sale sale) async {
    try {
      await salesBox.put(sale.id, sale);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure( 'Failed to save sale: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Sale>>> getRecentSales({int limit = 10}) async {
    try {
      final sales = salesBox.values.toList();
      sales.sort((a, b) => b.date.compareTo(a.date));
      return Right(sales.take(limit).toList());
    } catch (e) {
      return Left(CacheFailure( 'Failed to get recent sales: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateProductQuantity(String barcode, int newQuantity) async {
    try {
      final products = productsBox.values.where((p) => p.barcode == barcode);
      if (products.isEmpty) {
        return Left(CacheFailure( 'Product not found'));
      }
      
      final product = products.first;
      product.quantity = newQuantity;
      await productsBox.put(product.barcode, product);
      
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure( 'Failed to update quantity: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> validateMinPrice(String barcode, double salePrice) async {
    try {
      final productResult = await findProductByBarcode(barcode);
      return productResult.fold(
        (failure) => Left(failure),
        (product) {
          if (product == null) return const Right(false);
          return Right(salePrice >= product.price);
        },
      );
    } catch (e) {
      return Left(CacheFailure('Failed to validate price: ${e.toString()}'));
    }
  }
}
