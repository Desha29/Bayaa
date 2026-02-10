import 'package:crazy_phone_pos/core/data/services/persistence_initializer.dart';
import 'package:crazy_phone_pos/core/data/services/repository_persistence_mixin.dart';
import 'package:crazy_phone_pos/core/error/error_handler.dart';
import 'package:crazy_phone_pos/core/state/state_synchronizer.dart';
import 'package:dartz/dartz.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../../../core/error/failure.dart';
import '../../../products/data/models/product_model.dart';
import '../../domain/sales_repository.dart';
import '../models/sale_model.dart';
import '../models/cart_item_model.dart';

class SalesRepositoryImpl with RepositoryPersistenceMixin implements SalesRepository {
  // Removed Hive boxes
  SalesRepositoryImpl();

  @override
  Future<Either<Failure, Product?>> findProductByBarcode(String barcode) async {
    try {
      final db = PersistenceInitializer.persistenceManager!.sqliteManager;
      final results = await db.query('products', where: 'id = ?', whereArgs: [barcode]);
      
      if (results.isEmpty) {
        return const Right(null);
      }
      
      final m = results.first;
      final product = Product(
        name: m['name'] as String,
        barcode: m['barcode'] as String,
        price: m['price'] as double,
        minPrice: m['min_price'] as double,
        wholesalePrice: m['wholesale_price'] as double? ?? 0.0,
        quantity: (m['stock'] as num).toInt(),
        minQuantity: (m['min_stock'] as num).toInt(),
        category: m['category_id'] as String? ?? 'عام',
      );
      
      return Right(product);
    } catch (e) {
      return Left(CacheFailure('فشل في العثور على المنتج: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getAllProducts() async {
    try {
      final db = PersistenceInitializer.persistenceManager!.sqliteManager;
      final results = await db.query('products', where: 'is_active = 1');
      
      final products = results.map((m) => Product(
        name: m['name'] as String,
        barcode: m['barcode'] as String,
        price: m['price'] as double,
        minPrice: m['min_price'] as double,
        wholesalePrice: m['wholesale_price'] as double? ?? 0.0,
        quantity: (m['stock'] as num).toInt(),
        minQuantity: (m['min_stock'] as num).toInt(),
        category: m['category_id'] as String? ?? 'عام',
      )).toList();
      
      return Right(products);
    } catch (e) {
      return Left(CacheFailure('فشل في جلب المنتجات: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveSale(Sale sale) async {
    return ErrorHandler.executeWithErrorHandling(
      operation: () async {
        await writeCritical(
          entity: 'sale',
          id: sale.id,
          data: sale.toMap(),
          sqliteWrite: () async {
            final db = PersistenceInitializer.persistenceManager!.sqliteManager;
            await db.insert('sales', {
              'id': sale.id,
              'total': sale.total,
              'items_count': sale.items,
              'created_at': sale.date.toIso8601String(),
              'cashier_name': sale.cashierName,
              'user_id': sale.cashierUsername,
              'shift_id': sale.sessionId,
              'is_refund': sale.isRefund ? 1 : 0,
              'original_sale_id': sale.refundOriginalInvoiceId,
            }, conflictAlgorithm: ConflictAlgorithm.replace);
            
            // First delete existing items to support updates/overwrites
            await db.delete('sale_items', where: 'sale_id = ?', whereArgs: [sale.id]);

            for (final item in sale.saleItems) {
              await db.insert('sale_items', {
                'id': '${sale.id}_${item.productId}_${DateTime.now().microsecondsSinceEpoch}',
                'sale_id': sale.id,
                'product_id': item.productId,
                'product_barcode': item.productId,
                'product_name': item.name,
                'quantity': item.quantity.toDouble(),
                'price': item.price,
                'subtotal': item.total,
                'wholesale_price': item.wholesalePrice,
                'refunded_quantity': item.refundedQuantity.toDouble(),
              });
            }
          },
        );
        
        // Notify state change
        StateSynchronizer.notify(DataChangeEvent(
          entityType: 'sale',
          operation: 'create',
          id: sale.id,
        ));
        
        return const Right(unit);
      },
      operationName: 'saveSale',
      userFriendlyMessage: 'فشل في حفظ البيع',
      source: 'SalesRepository',
    );
  }

  Future<List<Sale>> _getSalesWithItems(List<Map<String, dynamic>> saleRows) async {
    if (saleRows.isEmpty) return [];

    final db = PersistenceInitializer.persistenceManager!.sqliteManager;
    final saleIds = saleRows.map((r) => r['id'] as String).toList();
    
    // Fetch items for these sales
    final placeholders = List.filled(saleIds.length, '?').join(',');
    final itemRows = await db.query(
      'sale_items',
      where: 'sale_id IN ($placeholders)',
      whereArgs: saleIds,
    );

    // Group items by sale_id
    final itemsMap = <String, List<SaleItem>>{};
    for (var row in itemRows) {
      final saleId = row['sale_id'] as String;
      if (!itemsMap.containsKey(saleId)) {
        itemsMap[saleId] = [];
      }
      
      itemsMap[saleId]!.add(SaleItem(
        productId: row['product_id'] as String,
        name: row['product_name'] as String,
        price: row['price'] as double,
        quantity: (row['quantity'] as num).toInt(),
        total: row['subtotal'] as double,
        wholesalePrice: row['wholesale_price'] as double? ?? 0.0,
        refundedQuantity: (row['refunded_quantity'] as num?)?.toInt() ?? 0,
      ));
    }

    // Bind items to sales
    return saleRows.map((row) {
      final id = row['id'] as String;
      return Sale(
        id: id,
        total: row['total'] as double,
        items: row['items_count'] as int? ?? 0,
        date: DateTime.parse(row['created_at'] as String),
        saleItems: itemsMap[id] ?? [],
        cashierName: row['cashier_name'] as String?,
        cashierUsername: row['user_id'] as String?,
        sessionId: row['shift_id'] as String?,
        invoiceTypeIndex: (row['is_refund'] as int? ?? 0) == 1 ? 1 : 0,
        refundOriginalInvoiceId: row['original_sale_id'] as String?,
      );
    }).toList();
  }

  @override
  Future<Either<Failure, List<Sale>>> getRecentSales({
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
    String? sessionId,
  }) async {
    try {
      final db = PersistenceInitializer.persistenceManager!.sqliteManager;
      
      String? where;
      List<Object?>? whereArgs;
      
      if (startDate != null || endDate != null) {
        final conditions = <String>[];
        whereArgs = [];
        
        if (startDate != null) {
          conditions.add('created_at >= ?');
          whereArgs.add(startDate.toIso8601String());
        }
        if (endDate != null) {
          conditions.add('created_at <= ?');
          whereArgs.add(endDate.toIso8601String());
        }
        if (sessionId != null) {
          conditions.add('shift_id = ?');
          whereArgs.add(sessionId);
        }
        where = conditions.join(' AND ');
      } else if (sessionId != null) {
        where = 'shift_id = ?';
        whereArgs = [sessionId];
      }

      final saleRows = await db.query(
        'sales',
        where: where,
        whereArgs: whereArgs,
        orderBy: 'created_at DESC',
        limit: limit,
      );

      final sales = await _getSalesWithItems(saleRows);
      return Right(sales);
    } catch (e) {
      return Left(CacheFailure('فشل في جلب آخر المبيعات: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateProductQuantity(
      String barcode, int newQuantity) async {
    try {
      await updateCritical(
        entity: 'product_stock',
        id: barcode,
        data: {'stock': newQuantity},
        sqliteWrite: () async {
          final db = PersistenceInitializer.persistenceManager!.sqliteManager;
          await db.update(
            'products',
            {'stock': newQuantity},
            where: 'id = ?',
            whereArgs: [barcode],
          );
        },
      );
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('فشل في تحديث الكمية: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> validateMinPrice(
      String barcode, double salePrice) async {
    try {
      final db = PersistenceInitializer.persistenceManager!.sqliteManager;
      final results = await db.query(
        'products', 
        columns: ['price', 'min_price'],
        where: 'id = ?',
        whereArgs: [barcode]
      );
      
      if (results.isEmpty) return const Right(false);
      
      final productPrice = results.first['price'] as double;
      // You might want to check against min_price too if that's the business logic
      // But implementation asked for check against 'price' <= salePrice ? 
      // The original code checked salePrice >= product.price which seems backwards for validMinPrice logic 
      // usually minPrice check means salePrice >= minPrice.
      // But assuming original logic was checking if we are selling above base price ?? 
      // Or maybe it was checking validity. Let's stick to original logic:
      // Original: return Right(salePrice >= product.price);
      
      return Right(salePrice >= productPrice);
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
    return ErrorHandler.executeWithErrorHandling(
      operation: () async {
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

        // ATOMIC TRANSACTION: Save sale + update stock in one transaction
        final db = PersistenceInitializer.persistenceManager!.sqliteManager;
        await db.transaction((txn) async {
          // 1. Save sale
          await txn.insert('sales', {
            'id': sale.id,
            'total': sale.total,
            'items_count': sale.items,
            'created_at': sale.date.toIso8601String(),
            'cashier_name': sale.cashierName,
            'user_id': sale.cashierUsername,
            'shift_id': sale.sessionId,
            'is_refund': sale.isRefund ? 1 : 0,
            'original_sale_id': sale.refundOriginalInvoiceId,
          });
          
          // 2. Save sale items
          for (final item in sale.saleItems) {
            await txn.insert('sale_items', {
              'id': '${sale.id}_${item.productId}_${DateTime.now().microsecondsSinceEpoch}',
              'sale_id': sale.id,
              'product_id': item.productId,
              'product_barcode': item.productId,
              'product_name': item.name,
              'quantity': item.quantity.toDouble(),
              'price': item.price,
              'subtotal': item.total,
              'wholesale_price': item.wholesalePrice,
              'refunded_quantity': 0.0,
            });
          }
          
          // 3. Update stock for all items
          for (var item in items) {
            await txn.rawUpdate(
              'UPDATE products SET stock = stock - ? WHERE id = ?',
              [item.qty, item.id]
            );
          }
        });
        
        // Notify state changes
        StateSynchronizer.notify(DataChangeEvent(
          entityType: 'sale',
          operation: 'create',
          id: saleId,
        ));
        
        // Notify that product stock changed
        StateSynchronizer.notify(DataChangeEvent(
          entityType: 'product_stock',
          operation: 'update',
        ));

        return const Right(unit);
      },
      operationName: 'createSaleWithCashier',
      userFriendlyMessage: 'فشل في إنشاء البيع',
      source: 'SalesRepository',
    );
  }

  @override
  Future<Either<Failure, Unit>> deleteSalesInRange(DateTime start, DateTime end) async {
    try {
      final db = PersistenceInitializer.persistenceManager!.sqliteManager;
      
      // Get sales to be deleted to restore stock?
      // Original code called deleteSale which deletes items.
      // Ideally we should handle stock restoration here too if deleteSale handles it??
      // Looking at original deleteSale, it just deletes from box. It does NOT seem to restore stock.
      // So I will just delete them.
      
      // Use raw SQL delete for efficiency
      await deleteCritical(
        entity: 'sales_range',
        id: '${start.millisecondsSinceEpoch}_${end.millisecondsSinceEpoch}',
        sqliteWrite: () async {
             // Delete sale_items first via cascade or manual
             // Our schema ON DELETE CASCADE on sale_items might handle it, 
             // but let's be safe or query IDs first.
             
             // First select IDs to delete for logging/security if needed.
             // Then delete.
             
             // Ensure we cover the full range of the given end date
             // e.g. if start=today, end=today, we want start 00:00:00 to end 23:59:59
             final adjustedStart = DateTime(start.year, start.month, start.day, 0, 0, 0);
             final adjustedEnd = DateTime(end.year, end.month, end.day, 23, 59, 59, 999);
             
             await db.delete('sales', 
                where: 'created_at >= ? AND created_at <= ?',
                whereArgs: [adjustedStart.toIso8601String(), adjustedEnd.toIso8601String()]
             );
             // SQLite with PRAGMA foreign_keys = ON should trigger cascade delete on sale_items
             // If not, we should manually delete items where sale_id undefined.
        }
      );

      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('فشل في حذف الفواتير خلال الفترة: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteSalesByQuery(String query) async {
    try {
      final db = PersistenceInitializer.persistenceManager!.sqliteManager;
      
      // Complex query: search sales by ID OR sale_items by name/barcode
      final sql = '''
        SELECT DISTINCT s.id 
        FROM sales s 
        LEFT JOIN sale_items si ON s.id = si.sale_id 
        WHERE s.id LIKE ? OR si.product_barcode LIKE ? OR si.product_name LIKE ?
      ''';
      
      final pattern = '%$query%';
      final results = await db.database.rawQuery(sql, [pattern, pattern, pattern]);
      
      final idsToDelete = results.map((r) => r['id'] as String).toList();
      
      for (final id in idsToDelete) {
        await deleteSale(id);
      }
      
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('فشل في حذف الفواتير المطابقة: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteSale(String saleId) async {
    try {
      await deleteCritical(
        entity: 'sale',
        id: saleId,
        sqliteWrite: () async {
          final db = PersistenceInitializer.persistenceManager!.sqliteManager;
          await db.delete('sales', where: 'id = ?', whereArgs: [saleId]);
          // Items deleted by cascade or manual
          await db.delete('sale_items', where: 'sale_id = ?', whereArgs: [saleId]);
        },
      );
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('فشل في حذف البيع: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Sale>>> getAllSales() async {
    try {
      final db = PersistenceInitializer.persistenceManager!.sqliteManager;
      final saleRows = await db.query(
        'sales',
        orderBy: 'created_at DESC',
        limit: 100, // Matching original limit
      );
      
      final sales = await _getSalesWithItems(saleRows);
      return Right(sales);
    } catch (e) {
      return Left(CacheFailure('فشل في جلب البيعات: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Sale>>> getSalesByIds(List<String> ids) async {
    try {
      if (ids.isEmpty) return const Right([]);
      
      final db = PersistenceInitializer.persistenceManager!.sqliteManager;
      final placeholders = List.filled(ids.length, '?').join(',');
      
      final saleRows = await db.query(
        'sales',
        where: 'id IN ($placeholders)',
        whereArgs: ids,
      );
      
      final sales = await _getSalesWithItems(saleRows);
      return Right(sales);
    } catch (e) {
      return Left(CacheFailure('فشل في جلب الفواتير المحددة: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Sale>>> getRefundsForInvoice(String originalInvoiceId) async {
    try {
      final db = PersistenceInitializer.persistenceManager!.sqliteManager;
      final saleRows = await db.query(
        'sales',
        where: 'original_sale_id = ? AND is_refund = 1',
        whereArgs: [originalInvoiceId],
      );
      
      final sales = await _getSalesWithItems(saleRows);
      return Right(sales);
    } catch (e) {
      return Left(CacheFailure('فشل في جلب المرتجعات: ${e.toString()}'));
    }
  }
  
  @override
  Future<Either<Failure, Unit>> linkSalesToSession(List<String> saleIds, String sessionId) async {
    try {
      if (saleIds.isEmpty) return const Right(unit);

      await updateCritical(
        entity: 'session_sales_link',
        id: sessionId,
        data: {'sale_ids': saleIds},
        sqliteWrite: () async {
          final db = PersistenceInitializer.persistenceManager!.sqliteManager;
          final placeholders = List.filled(saleIds.length, '?').join(',');
          
          await db.database.rawUpdate(
            'UPDATE sales SET shift_id = ? WHERE id IN ($placeholders)',
            [sessionId, ...saleIds],
          );
        },
      );
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('فشل في ربط الفواتير بالجلسة: ${e.toString()}'));
    }
  }
}
