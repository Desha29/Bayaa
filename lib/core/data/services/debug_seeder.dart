// lib/core/data/services/debug_seeder.dart

import 'package:bayaa_pos/core/data/services/persistence_initializer.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DebugSeeder {
  static Future<void> seedIfNeeded() async {
    final db = PersistenceInitializer.persistenceManager?.sqliteManager;
    if (db == null) return;

    try {
      // Check if products are already seeded
      final productsCount = await db.query('products', columns: ['COUNT(*) as count']);
      final count = productsCount.isNotEmpty ? (productsCount.first['count'] as int? ?? 0) : 0;
      if (count > 0) {
        print('ℹ️ Products already seeded. Skipping auto-seeding.');
        return;
      }

      print('🌱 Empty database in debug mode. Seeding mock data...');
      await seedAll();
    } catch (e) {
      print('❌ Error checking / seeding database: $e');
    }
  }

  static Future<void> seedAll() async {
    final db = PersistenceInitializer.persistenceManager?.sqliteManager;
    if (db == null) return;

    await db.transaction((txn) async {
      final now = DateTime.now().toIso8601String();

      // 1. Seed Users
      await txn.insert('users', {
        'id': 'admin',
        'username': 'admin',
        'display_name': 'مدير النظام',
        'password_hash': 'admin',
        'role': 'manager',
        'is_active': 1,
        'created_at': now,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      await txn.insert('users', {
        'id': 'cashier',
        'username': 'cashier',
        'display_name': 'كاشير تجريبي',
        'password_hash': 'cashier',
        'role': 'cashier',
        'is_active': 1,
        'created_at': now,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      // 2. Seed Categories
      final categories = [
        {'id': 'هواتف', 'name': 'هواتف', 'sort_order': 1},
        {'id': 'إكسسوارات', 'name': 'إكسسوارات', 'sort_order': 2},
        {'id': 'شواحن', 'name': 'شواحن', 'sort_order': 3},
        {'id': 'صيانة', 'name': 'صيانة', 'sort_order': 4},
        {'id': 'سماعات', 'name': 'سماعات', 'sort_order': 5},
      ];

      for (var cat in categories) {
        await txn.insert('categories', cat, conflictAlgorithm: ConflictAlgorithm.replace);
      }

      // 3. Seed Products
      final products = [
        {
          'id': '111111',
          'barcode': '111111',
          'name': 'iPhone 13 Pro Max',
          'price': 35000.0,
          'min_price': 34000.0,
          'wholesale_price': 32000.0,
          'cost': 32000.0,
          'stock': 15.0,
          'min_stock': 3.0,
          'category_id': 'هواتف',
          'is_active': 1,
          'created_at': now,
          'updated_at': now,
        },
        {
          'id': '222222',
          'barcode': '222222',
          'name': 'Samsung Galaxy S22 Ultra',
          'price': 28000.0,
          'min_price': 27000.0,
          'wholesale_price': 25000.0,
          'cost': 25000.0,
          'stock': 8.0,
          'min_stock': 2.0,
          'category_id': 'هواتف',
          'is_active': 1,
          'created_at': now,
          'updated_at': now,
        },
        {
          'id': '333333',
          'barcode': '333333',
          'name': 'Apple AirPods Pro 2',
          'price': 7500.0,
          'min_price': 7000.0,
          'wholesale_price': 6500.0,
          'cost': 6500.0,
          'stock': 25.0,
          'min_stock': 5.0,
          'category_id': 'سماعات',
          'is_active': 1,
          'created_at': now,
          'updated_at': now,
        },
        {
          'id': '444444',
          'barcode': '444444',
          'name': 'Anker PowerCore 20k',
          'price': 1800.0,
          'min_price': 1600.0,
          'wholesale_price': 1400.0,
          'cost': 1400.0,
          'stock': 3.0,
          'min_stock': 5.0,
          'category_id': 'شواحن',
          'is_active': 1,
          'created_at': now,
          'updated_at': now,
        },
        {
          'id': '555555',
          'barcode': '555555',
          'name': 'iPhone 14 Silicon Case',
          'price': 450.0,
          'min_price': 400.0,
          'wholesale_price': 300.0,
          'cost': 300.0,
          'stock': 50.0,
          'min_stock': 10.0,
          'category_id': 'إكسسوارات',
          'is_active': 1,
          'created_at': now,
          'updated_at': now,
        },
        {
          'id': '666666',
          'barcode': '666666',
          'name': 'Type-C to Lightning Cable',
          'price': 350.0,
          'min_price': 300.0,
          'wholesale_price': 200.0,
          'cost': 200.0,
          'stock': 0.0,
          'min_stock': 5.0,
          'category_id': 'شواحن',
          'is_active': 1,
          'created_at': now,
          'updated_at': now,
        },
        {
          'id': '777777',
          'barcode': '777777',
          'name': 'شاشة iPhone 12 Pro',
          'price': 4200.0,
          'min_price': 4000.0,
          'wholesale_price': 3500.0,
          'cost': 3500.0,
          'stock': 12.0,
          'min_stock': 2.0,
          'category_id': 'صيانة',
          'is_active': 1,
          'created_at': now,
          'updated_at': now,
        },
      ];

      for (var p in products) {
        await txn.insert('products', p, conflictAlgorithm: ConflictAlgorithm.replace);
      }

      // 4. Seed past Shifts & Sales (Last 7 days)
      final baseDate = DateTime.now().subtract(const Duration(days: 7));
      
      final randSalesTotals = [
        [35450.0, 7500.0, 1800.0], // Day 1
        [28450.0, 4200.0],         // Day 2
        [35000.0, 7500.0, 1800.0, 450.0], // Day 3
        [28000.0, 7500.0, 4200.0], // Day 4
        [35450.0, 1800.0],         // Day 5
        [28000.0, 7500.0, 1800.0, 450.0], // Day 6
        [35450.0, 7500.0, 4200.0, 1800.0, 450.0], // Day 7
      ];

      final itemsMap = {
        35450.0: [
          {'product_id': '111111', 'product_name': 'iPhone 13 Pro Max', 'quantity': 1.0, 'price': 35000.0, 'wholesale_price': 32000.0, 'subtotal': 35000.0},
          {'product_id': '555555', 'product_name': 'iPhone 14 Silicon Case', 'quantity': 1.0, 'price': 450.0, 'wholesale_price': 300.0, 'subtotal': 450.0},
        ],
        28450.0: [
          {'product_id': '222222', 'product_name': 'Samsung Galaxy S22 Ultra', 'quantity': 1.0, 'price': 28000.0, 'wholesale_price': 25000.0, 'subtotal': 28000.0},
          {'product_id': '555555', 'product_name': 'iPhone 14 Silicon Case', 'quantity': 1.0, 'price': 450.0, 'wholesale_price': 300.0, 'subtotal': 450.0},
        ],
        35000.0: [
          {'product_id': '111111', 'product_name': 'iPhone 13 Pro Max', 'quantity': 1.0, 'price': 35000.0, 'wholesale_price': 32000.0, 'subtotal': 35000.0},
        ],
        28000.0: [
          {'product_id': '222222', 'product_name': 'Samsung Galaxy S22 Ultra', 'quantity': 1.0, 'price': 28000.0, 'wholesale_price': 25000.0, 'subtotal': 28000.0},
        ],
        7500.0: [
          {'product_id': '333333', 'product_name': 'Apple AirPods Pro 2', 'quantity': 1.0, 'price': 7500.0, 'wholesale_price': 6500.0, 'subtotal': 7500.0},
        ],
        4200.0: [
          {'product_id': '777777', 'product_name': 'شاشة iPhone 12 Pro', 'quantity': 1.0, 'price': 4200.0, 'wholesale_price': 3500.0, 'subtotal': 4200.0},
        ],
        1800.0: [
          {'product_id': '444444', 'product_name': 'Anker PowerCore 20k', 'quantity': 1.0, 'price': 1800.0, 'wholesale_price': 1400.0, 'subtotal': 1800.0},
        ],
        450.0: [
          {'product_id': '555555', 'product_name': 'iPhone 14 Silicon Case', 'quantity': 1.0, 'price': 450.0, 'wholesale_price': 300.0, 'subtotal': 450.0},
        ],
      };

      for (int i = 0; i < 7; i++) {
        final dayDate = baseDate.add(Duration(days: i + 1));
        final shiftId = 'shift_day_${i + 1}';
        final openTime = DateTime(dayDate.year, dayDate.month, dayDate.day, 9, 0);
        final closeTime = DateTime(dayDate.year, dayDate.month, dayDate.day, 21, 0);

        final totals = randSalesTotals[i];
        double totalSales = 0.0;
        for (var t in totals) {
          totalSales += t;
        }

        // Insert closed Shift
        await txn.insert('shifts', {
          'id': shiftId,
          'user_id': 'admin',
          'open_time': openTime.toIso8601String(),
          'close_time': closeTime.toIso8601String(),
          'closed_by': 'admin',
          'opening_cash': 1000.0,
          'closing_cash': 1000.0 + totalSales,
          'is_open': 0,
        });

        // Insert Sales
        for (int j = 0; j < totals.length; j++) {
          final saleTotal = totals[j];
          final saleId = 'INV_${shiftId}_$j';
          final saleDate = openTime.add(Duration(hours: j * 2 + 1));

          final saleItems = itemsMap[saleTotal] ?? [];

          await txn.insert('sales', {
            'id': saleId,
            'total': saleTotal,
            'items_count': saleItems.length,
            'created_at': saleDate.toIso8601String(),
            'cashier_name': 'مدير النظام',
            'user_id': 'admin',
            'shift_id': shiftId,
            'is_refund': 0,
          });

          for (var item in saleItems) {
            await txn.insert('sale_items', {
              'id': '${saleId}_${item['product_id']}_${j}_${item['price']}',
              'sale_id': saleId,
              'product_id': item['product_id'],
              'product_barcode': item['product_id'],
              'product_name': item['product_name'],
              'quantity': item['quantity'],
              'price': item['price'],
              'wholesale_price': item['wholesale_price'],
              'subtotal': item['subtotal'],
              'refunded_quantity': 0.0,
            });
          }
        }
      }
    });

    print('🌱 Seeding complete successfully!');
  }

  static Future<void> clearAndReSeed() async {
    final db = PersistenceInitializer.persistenceManager?.sqliteManager;
    if (db == null) return;

    print('🗑️ Clearing database tables...');
    await db.transaction((txn) async {
      await txn.delete('sale_items');
      await txn.delete('sales');
      await txn.delete('shifts');
      await txn.delete('products');
      await txn.delete('categories');
      await txn.delete('users');
      await txn.delete('activity_logs');
    });

    print('🌱 Re-seeding database...');
    await seedAll();
  }
}
