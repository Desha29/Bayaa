import 'package:dartz/dartz.dart';
import 'package:hive_flutter/adapters.dart';
import '../../../../core/error/failure.dart';
import '../../../products/data/models/product_model.dart';
import '../../domain/sales_repository.dart';
import '../models/sale_model.dart';
import '../models/cart_item_model.dart';

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
      final product = productsBox.get(barcode);
      if (product == null) {
        return const Right(null);
      }
      return Right(product);
    } catch (e) {
      return Left(CacheFailure('فشل في العثور على المنتج: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getAllProducts() async {
    try {
      return Right(productsBox.values.toList());
    } catch (e) {
      return Left(CacheFailure('فشل في جلب المنتجات: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveSale(Sale sale) async {
    try {
      await salesBox.put(sale.id, sale);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('فشل في حفظ البيع: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Sale>>> getRecentSales({
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var sales = salesBox.values.toList();

      // Filter by date range if provided
      if (startDate != null) {
        sales = sales.where((sale) => !sale.date.isBefore(startDate)).toList();
      }
      if (endDate != null) {
        sales = sales.where((sale) => !sale.date.isAfter(endDate)).toList();
      }

      // Sort by descending date
      sales.sort((a, b) => b.date.compareTo(a.date));

      return Right(sales.take(limit).toList());
    } catch (e) {
      return Left(CacheFailure('فشل في جلب آخر المبيعات: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateProductQuantity(
      String barcode, int newQuantity) async {
    try {
      final products = productsBox.values.where((p) => p.barcode == barcode);
      if (products.isEmpty) {
        return Left(CacheFailure('المنتج غير موجود'));
      }
      final product = products.first;
      product.quantity = newQuantity;
      await productsBox.put(product.barcode, product);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('فشل في تحديث الكمية: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> validateMinPrice(
      String barcode, double salePrice) async {
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
      return Left(CacheFailure('فشل في التحقق من السعر: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> createSaleWithCashier({
    required List<CartItemModel> items,
    required double total,
    required String cashierName,
    required String cashierUsername,
  }) async {
    try {
      final saleId = DateTime.now().millisecondsSinceEpoch.toString();

      final sale = Sale(
        id: saleId,
        total: total,
        items: items.length,
        date: DateTime.now(),
        cashierName: cashierName,
        cashierUsername: cashierUsername,
        saleItems: items
            .map((item) => SaleItem(
                  productId: item.id,
                  name: item.name,
                  price: item.salePrice,
                  quantity: item.qty,
                  total: item.total,
                  wholesalePrice: item.wholesalePrice,
                ))
            .toList(),
      );

      await salesBox.put(sale.id, sale);

      // Update product quantities
      for (var item in items) {
        final productResult = await findProductByBarcode(item.id);
        await productResult.fold(
          (failure) => Future.value(),
          (product) async {
            if (product != null) {
              product.quantity -= item.qty;
              await productsBox.put(product.barcode, product);
            }
          },
        );
      }

      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('فشل في إنشاء البيع: ${e.toString()}'));
    }
  }

@override
Future<Either<Failure, Unit>> deleteSalesInRange(DateTime start, DateTime end) async {
  try {
    final salesToDelete = salesBox.values.where(
      (sale) => !sale.date.isBefore(start) && !sale.date.isAfter(end)
    ).toList();

    for (var sale in salesToDelete) {
      await salesBox.delete(sale.id);
    }

    return const Right(unit);
  } catch (e) {
    return Left(CacheFailure('فشل في حذف الفواتير خلال الفترة: ${e.toString()}'));
  }
}
@override
Future<Either<Failure, Unit>> deleteSalesByQuery(String query) async {
  try {
    final matchingSales = salesBox.values.where((sale) {
      if (sale.id.contains(query)) return true;
      return sale.saleItems.any((item) =>
        item.productId.contains(query) || item.name.toLowerCase().contains(query.toLowerCase())
      );
    }).toList();

    for (var sale in matchingSales) {
      await salesBox.delete(sale.id);
    }

    return const Right(unit);
  } catch (e) {
    return Left(CacheFailure('فشل في حذف الفواتير المطابقة: ${e.toString()}'));
  }
}
@override
Future<Either<Failure, Unit>> deleteSale(String saleId) async {
  try {
    if (!salesBox.containsKey(saleId)) {
      return Left(CacheFailure('عملية الحذف فشلت: لم يتم العثور على هذا البيع.'));
    }
    await salesBox.delete(saleId);
    if (salesBox.containsKey(saleId)) {
      return Left(CacheFailure('حدث خطأ أثناء الحذف، لم يتم حذف البيع بشكل صحيح.'));
    }
    return const Right(unit);
  } catch (e) {
    return Left(CacheFailure('فشل في حذف البيع: ${e.toString()}'));
  }
}

 @override
Future<Either<Failure, List<Sale>>> getAllSales() async {
  try {
    final sales = salesBox.values.toList();
    return Right(sales);
  } catch (e) {
    return Left(CacheFailure('فشل في جلب البيعات: ${e.toString()}'));
  }
}



}
