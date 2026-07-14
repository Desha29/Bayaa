// ignore_for_file: avoid_print

import 'package:bayaa_pos/core/data/services/persistence_initializer.dart';
import 'package:bayaa_pos/core/data/services/repository_persistence_mixin.dart';
import 'package:bayaa_pos/core/error/failure.dart';
import 'package:bayaa_pos/core/error/error_handler.dart';
import 'package:bayaa_pos/core/state/state_synchronizer.dart';
import 'package:bayaa_pos/features/products/data/models/product_model.dart';
import 'package:bayaa_pos/features/products/domain/product_repository_int.dart';
import 'package:either_dart/either.dart';

class ProductRepositoryImp extends ProductRepositoryInt with RepositoryPersistenceMixin {
  // Removed Hive data sources
  ProductRepositoryImp();

  @override
  Future<Either<Failure, void>> deleteProduct(String barcode) async {
    return ErrorHandler.executeWithErrorHandlingEitherDart(
      operation: () async {
        await deleteCritical(
          entity: 'product',
          id: barcode,
          sqliteWrite: () async {
            final db = PersistenceInitializer.persistenceManager!.sqliteManager;
            await db.delete('products', where: 'id = ?', whereArgs: [barcode]);
          },
        );
        
        // Notify state change
        StateSynchronizer.notify(DataChangeEvent(
          entityType: 'product',
          operation: 'delete',
          id: barcode,
        ));
        
        return const Right(null);
      },
      operationName: 'deleteProduct',
      userFriendlyMessage: 'Failed to delete product',
      source: 'ProductRepository',
    );
  }

  @override
  Future<Either<Failure, List<Product>>> getAllProduct() async {
    try {
      print('📦 === LOADING PRODUCTS (SQLite) ===');
      
      final db = PersistenceInitializer.persistenceManager!.sqliteManager;
      final results = await db.query('products', where: 'is_active = 1');
      print('  📦 Products in SQL: ${results.length}');
      
      final products = results.map((m) => Product(
        name: m['name'] as String,
        barcode: m['barcode'] as String,
        price: m['price'] as double,
        minPrice: m['min_price'] as double,
        wholesalePrice: m['wholesale_price'] as double? ?? 0.0,
        quantity: (m['stock'] as num).toInt(),
        minQuantity: (m['min_stock'] as num).toInt(),
        category: m['category_id'] as String? ?? 'General',
        imagePath: m['image_path'] as String?,
      )).toList();
      
      return Right(products);
    } on Exception catch (e) {
      print('  ❌ Failed to load products: $e');
      return Left(CacheFailure("Error fetching products: ${e.toString()}"));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getProductsPaginated({
    required int page,
      required int pageSize,
    String? category,
    String? availability,
    String? searchQuery,
  }) async {
    try {
      print('📦 === LOADING PRODUCTS PAGE $page (SQLite) ===');
      
      final db = PersistenceInitializer.persistenceManager!.sqliteManager;
      final offset = page * pageSize;
      
      String whereClause = 'is_active = 1';
      List<Object?> whereArgs = [];
      
      if (category != null && category != '*') {
        whereClause += ' AND category_id = ?';
        whereArgs.add(category);
      }
      
      if (availability != null && availability != '*') {
        if (availability == 'outOfStock') {
          whereClause += ' AND stock = 0';
        } else if (availability == 'lowStock') {
          whereClause += ' AND stock > 0 AND stock <= min_stock';
        } else if (availability == 'available') {
          whereClause += ' AND stock > min_stock';
        }
      }
      
      if (searchQuery != null && searchQuery.isNotEmpty) {
        whereClause += ' AND (name LIKE ? OR barcode LIKE ?)';
        whereArgs.add('%$searchQuery%');
        whereArgs.add('%$searchQuery%');
      }
      
      final results = await db.query(
        'products',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'name COLLATE NOCASE ASC, id ASC',
        limit: pageSize,
        offset: offset,
      );
      
      print('  📦 Loaded ${results.length} products (page $page, offset $offset)');
      
      final products = results.map((m) => Product(
        name: m['name'] as String,
        barcode: m['barcode'] as String,
        price: m['price'] as double,
        minPrice: m['min_price'] as double,
        wholesalePrice: m['wholesale_price'] as double? ?? 0.0,
        quantity: (m['stock'] as num).toInt(),
        minQuantity: (m['min_stock'] as num).toInt(),
        category: m['category_id'] as String? ?? 'General',
        imagePath: m['image_path'] as String?,
      )).toList();
      
      return Right(products);
    } on Exception catch (e) {
      print('  ❌ Failed to load products page: $e');
      return Left(CacheFailure("Error fetching products: ${e.toString()}"));
    }
  }

  @override
  Future<Either<Failure, void>> saveProduct(Product product) async {
    return ErrorHandler.executeWithErrorHandlingEitherDart(
      operation: () async {
        final isUpdate = await _productExists(product.barcode);
        
        await writeCritical(
          entity: 'product',
          id: product.barcode,
          data: product.toMap(),
          sqliteWrite: () async {
            final db = PersistenceInitializer.persistenceManager!.sqliteManager;
            
            // Check if product exists to preserve created_at
            final existing = await db.query('products', where: 'id = ?', whereArgs: [product.barcode]);
            final now = DateTime.now().toIso8601String();
            final values = <String, Object?>{
              'barcode': product.barcode,
              'name': product.name,
              'price': product.price,
              'min_price': product.minPrice,
              'wholesale_price': product.wholesalePrice,
              'stock': product.quantity.toDouble(),
              'min_stock': product.minQuantity.toDouble(),
              'category_id': product.category,
              'image_path': product.imagePath,
              'is_active': 1,
              'updated_at': now,
            };
            if (existing.isNotEmpty) {
              await db.update(
                'products',
                values,
                where: 'id = ?',
                whereArgs: [product.barcode],
              );
            } else {
              await db.insert('products', {
                'id': product.barcode,
                ...values,
                'created_at': now,
              });
            }
          },
        );
        
        // Notify state change
        StateSynchronizer.notify(DataChangeEvent(
          entityType: 'product',
          operation: isUpdate ? 'update' : 'create',
          id: product.barcode,
        ));
        
        return const Right(null);
      },
      operationName: 'saveProduct',
      userFriendlyMessage: 'Failed to save product',
      source: 'ProductRepository',
    );
  }
  
  Future<bool> _productExists(String barcode) async {
    try {
      final db = PersistenceInitializer.persistenceManager!.sqliteManager;
      final result = await db.query('products', where: 'id = ?', whereArgs: [barcode]);
      return result.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(
      {required String category,
      bool forceDelete = false,
      String? newCategory}) async {
    List<Product> productsList = [];
    try {
      if (category == newCategory) {
        return Left(
            NetworkFailure("Cannot move products to the same category."));
      }
      
      final productsResult = await getAllProduct();
      productsResult.fold(
          (failure) => Left(NetworkFailure("Error fetching products")),
          (products) => productsList = products);
          
      var filteredProducts = productsList
          .where((product) => product.category == category)
          .toList();
          
      if (forceDelete) {
        for (var product in filteredProducts) {
          await deleteProduct(product.barcode);
        }
        
        await deleteCritical(
          entity: 'category',
          id: category,
          sqliteWrite: () async {
            final db = PersistenceInitializer.persistenceManager!.sqliteManager;
            await db.delete('categories', where: 'name = ?', whereArgs: [category]);
          },
        );
        return const Right(null);
      } else {
        if (filteredProducts.isNotEmpty) {
          if (newCategory == null || newCategory.isEmpty) {
            return Left(CacheFailure(
                "Cannot delete category because it contains products. Please choose a new category to move products to or use force delete."));
          }
          for (var product in filteredProducts) {
            var updatedProduct = Product(
              barcode: product.barcode,
              name: product.name,
              price: product.price,
              category: newCategory,
              quantity: product.quantity,
              minPrice: product.minPrice,
              minQuantity: product.minQuantity,
              wholesalePrice: product.wholesalePrice,
              imagePath: product.imagePath,
            );
            await saveProduct(updatedProduct);
          }
          await deleteCritical(
            entity: 'category',
            id: category,
            sqliteWrite: () async {
              final db = PersistenceInitializer.persistenceManager!.sqliteManager;
              await db.delete('categories', where: 'name = ?', whereArgs: [category]);
            },
          );
          return const Right(null);
        }
      }
      await deleteCritical(
        entity: 'category',
        id: category,
        sqliteWrite: () async {
          final db = PersistenceInitializer.persistenceManager!.sqliteManager;
          await db.delete('categories', where: 'name = ?', whereArgs: [category]);
        },
      );
      return const Right(null);
    } on Exception {
      return Left(NetworkFailure("Error deleting category"));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getAllCategory() async {
    try {
      print('📁 === LOADING CATEGORIES (SQLite) ===');
      
      final db = PersistenceInitializer.persistenceManager!.sqliteManager;
      final results = await db.query('categories', orderBy: 'sort_order ASC');
      print('  📁 Categories in SQL: ${results.length}');
      
      final categories = results.map((m) => m['name'] as String).toList();
      
      return Right(categories);
    } on Exception catch (e) {
      print('  ❌ Failed to load categories: $e');
      return Left(CacheFailure("Error fetching categories: ${e.toString()}"));
    }
  }

  @override
  Future<Either<Failure, void>> saveCategory(String category) async {
    return ErrorHandler.executeWithErrorHandlingEitherDart(
      operation: () async {
        await writeCritical(
          entity: 'category',
          id: category,
          data: {'name': category},
          sqliteWrite: () async {
            final db = PersistenceInitializer.persistenceManager!.sqliteManager;
            await db.insert('categories', {
              'id': category,
              'name': category,
            });
          },
        );
        
        // Notify state change
        StateSynchronizer.notify(DataChangeEvent(
          entityType: 'category',
          operation: 'create',
          id: category,
        ));
        
        return const Right(null);
      },
      operationName: 'saveCategory',
      userFriendlyMessage: 'Failed to save category',
      source: 'ProductRepository',
    );
  }

  @override
  Future<Either<Failure, bool>> productExists(String barcode) async {
    try {
      final exists = await _productExists(barcode);
      return Right(exists);
    } catch (e) {
      return Left(CacheFailure("Error checking product existence: ${e.toString()}"));
    }
  }
}
