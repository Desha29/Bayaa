import 'package:dartz/dartz.dart';
import 'package:hive_flutter/adapters.dart';
import '../../../../core/error/failure.dart';
import '../../../products/data/models/product_model.dart';
import '../../domain/sales_repository.dart';
import '../models/sale_model.dart';
import '../models/cart_item_model.dart';

class SalesRepositoryImpl implements SalesRepository {
  final Box<Product> productsBox;
  final LazyBox<Sale> salesBox; // Changed to LazyBox

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
      // With LazyBox, we iterate keys. Assuming strict chronological key insertion if using timestamps,
      // but keys might not be ordered. However, simple iteration is okay for now.
      // Better: Get all keys, sort/filter might be needed but we can't sort without loading.
      // Optimization: Read last N keys if we assume append-only.
      
      final keys = salesBox.keys.toList();
      // Reverse to get newest first (assuming keys usually added in order or we just want latest entries)
      // This is a heuristic. For strict date sorting, we'd need an index or load metadata.
      // Given the constraints, loading last N keys is "Recent".
      
      final recentKeys = keys.reversed.take(limit * 2).toList(); // Take more to account for filtering
      
      final List<Sale> loadedSales = [];
      for (var key in recentKeys) {
        final sale = await salesBox.get(key);
        if (sale != null) {
          loadedSales.add(sale);
        }
      }

      var sales = loadedSales;

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
    String? sessionId, // Added sessionId
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
        sessionId: sessionId,
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
    final keys = salesBox.keys.toList();
    for (var key in keys) {
      if (key is String) { 
           final keyMillis = int.tryParse(key);
           if (keyMillis != null) {
               final date = DateTime.fromMillisecondsSinceEpoch(keyMillis);
               if (!date.isBefore(start) && !date.isAfter(end)) {
                    // Use deleteSale to ensure stock adjustment
                    await deleteSale(key);
               }
               continue;
           }
      }
      
      final sale = await salesBox.get(key);
      if (sale != null) {
           if (!sale.date.isBefore(start) && !sale.date.isAfter(end)) {
               // Use deleteSale to ensure stock adjustment
               await deleteSale(key.toString());
           }
      }
    }

    return const Right(unit);
  } catch (e) {
    return Left(CacheFailure('فشل في حذف الفواتير خلال الفترة: ${e.toString()}'));
  }
}
@override
Future<Either<Failure, Unit>> deleteSalesByQuery(String query) async {
  try {
    final keys = salesBox.keys.toList();
    for (var key in keys) {
       final sale = await salesBox.get(key);
       if (sale != null) {
          if (sale.id.contains(query) || sale.saleItems.any((item) =>
              item.productId.contains(query) || item.name.toLowerCase().contains(query.toLowerCase())
          )) {
              // Use deleteSale to ensure stock is adjusted correctly
              await deleteSale(key.toString());
          }
       }
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

      // User requested NO stock update on delete ("when delete no").
      // We strictly delete the record here without modifying product quantities.

      await salesBox.delete(saleId);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('فشل في حذف البيع: ${e.toString()}'));
    }
  }

 @override
Future<Either<Failure, List<Sale>>> getAllSales() async {
  try {
     final keys = salesBox.keys.toList(); 
     final recentKeys = keys.reversed.take(100).toList();
     final List<Sale> sales = [];
     for(var k in recentKeys) {
         final s = await salesBox.get(k);
         if(s!=null) sales.add(s);
     }
     return Right(sales);
  } catch (e) {
    return Left(CacheFailure('فشل في جلب البيعات: ${e.toString()}'));
  }
}




  @override
  Future<Either<Failure, List<Sale>>> getSalesByIds(List<String> ids) async {
    try {
      final List<Sale> sales = [];
      for (var id in ids) {
        final sale = await salesBox.get(id);
        if (sale != null) {
          sales.add(sale);
        }
      }
      return Right(sales);
    } catch (e) {
      return Left(CacheFailure('فشل في جلب الفواتير المحددة: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Sale>>> getRefundsForInvoice(String originalInvoiceId) async {
    try {
      final List<Sale> refunds = [];
      
      // Iterate through all keys in LazyBox
      for (var key in salesBox.keys) {
        final sale = await salesBox.get(key);
        if (sale != null &&
            sale.invoiceTypeIndex == 1 &&
            sale.refundOriginalInvoiceId == originalInvoiceId) {
          refunds.add(sale);
        }
      }
      
      return Right(refunds);
    } catch (e) {
      return Left(CacheFailure('فشل في جلب المرتجعات: ${e.toString()}'));
    }
  }

}
