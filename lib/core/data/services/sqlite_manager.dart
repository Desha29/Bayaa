// lib/core/data/services/sqlite_manager.dart

// ignore_for_file: avoid_print

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../logging/file_logger.dart';

/// SQLite database manager with WAL mode and optimizations.
class SQLiteManager {
  final String databasePath;
  Database? _database;

  SQLiteManager({required this.databasePath});

  Future<void> initialize() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    FileLogger.info('Initializing SQLite database at: $databasePath',
        source: 'SQLite');

    _database = await openDatabase(
      databasePath,
      version: 5,
      onCreate: _onCreate,
      onConfigure: _onConfigure,
      onUpgrade: _onUpgrade,
      onOpen: _onOpen,
    );

    FileLogger.info('SQLite database initialized successfully',
        source: 'SQLite');
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onOpen(Database db) async {
    await db.execute('PRAGMA journal_mode = WAL');
    await db.execute('PRAGMA synchronous = NORMAL');
    await db.execute('PRAGMA cache_size = -64000');
    await db.execute('PRAGMA temp_store = MEMORY');
    await db.execute('PRAGMA mmap_size = 30000000000');
    await db.execute('PRAGMA wal_autocheckpoint = 1000');

    FileLogger.debug('SQLite PRAGMAs configured: WAL mode, synchronous=NORMAL',
        source: 'SQLite');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('🔄 Migrating database from version $oldVersion to $newVersion');

    if (oldVersion < 2) {
      print('  ➕ Adding missing columns to sales table...');

      // Add items_count column to sales table
      try {
        await db.execute(
            'ALTER TABLE sales ADD COLUMN items_count INTEGER DEFAULT 0');
        print('    ✅ Added items_count column');
      } catch (e) {
        if (!e.toString().contains('duplicate column name')) {
          print('    ⚠️ Error adding items_count: $e');
        }
      }

      // Add cashier_name column to sales table
      try {
        await db.execute('ALTER TABLE sales ADD COLUMN cashier_name TEXT');
        print('    ✅ Added cashier_name column');
      } catch (e) {
        if (!e.toString().contains('duplicate column name')) {
          print('    ⚠️ Error adding cashier_name: $e');
        }
      }

      print('  ➕ Adding missing columns to shifts table...');

      // Add close_time column to shifts table
      try {
        await db.execute('ALTER TABLE shifts ADD COLUMN close_time TEXT');
        print('    ✅ Added close_time column');
      } catch (e) {
        if (!e.toString().contains('duplicate column name')) {
          print('    ⚠️ Error adding close_time: $e');
        }
      }

      // Add closed_by column to shifts table
      try {
        await db.execute('ALTER TABLE shifts ADD COLUMN closed_by TEXT');
        print('    ✅ Added closed_by column');
      } catch (e) {
        if (!e.toString().contains('duplicate column name')) {
          print('    ⚠️ Error adding closed_by: $e');
        }
      }

      print('  ✅ Migration complete');
    }

    if (oldVersion < 3) {
      print('  ➕ Adding missing columns to store_settings table...');

      // List of new columns to ensure exist in store_settings
      // store_address, store_phone, store_email, logo_path, tax_number, tax_rate, currency, invoice_prefix
      final newColumns = {
        'store_address': 'TEXT',
        'store_phone': 'TEXT',
        'store_email': 'TEXT',
        'logo_path': 'TEXT',
        'tax_number': 'TEXT',
        'tax_rate': 'REAL DEFAULT 0.0',
        'currency': "TEXT DEFAULT 'EGP'",
        'invoice_prefix': "TEXT DEFAULT 'INV'",
      };

      for (final entry in newColumns.entries) {
        try {
          await db.execute(
              'ALTER TABLE store_settings ADD COLUMN ${entry.key} ${entry.value}');
          print('    ✅ Added ${entry.key} column');
        } catch (e) {
          if (!e.toString().contains('duplicate column name')) {
            print('    ⚠️ Error adding ${entry.key}: $e');
          }
        }
      }

      print('  ✅ Migration to v3 complete');
    }

    if (oldVersion < 4) {
      print('  ➕ Adding activity_logs table...');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS activity_logs (
          id TEXT PRIMARY KEY NOT NULL,
          timestamp TEXT NOT NULL,
          type TEXT NOT NULL,
          description TEXT NOT NULL,
          user_name TEXT NOT NULL,
          details TEXT
        )
      ''');
      await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_activity_logs_timestamp ON activity_logs(timestamp DESC)');
      print('  ✅ Migration to v4 complete');
    }

    if (oldVersion < 5) {
      print('  ➕ Adding session_id to activity_logs...');
      try {
        await db
            .execute('ALTER TABLE activity_logs ADD COLUMN session_id TEXT');
        print('    ✅ Added session_id column');
      } catch (e) {
        if (!e.toString().contains('duplicate column name')) {
          print('    ⚠️ Error adding session_id: $e');
        }
      }
      await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_activity_logs_session ON activity_logs(session_id)');
      await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_activity_logs_type ON activity_logs(type)');
      print('  ✅ Migration to v5 complete');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // Store settings table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS store_settings (
        id TEXT PRIMARY KEY NOT NULL,
        store_name TEXT NOT NULL,
        store_address TEXT,
        store_phone TEXT,
        store_email TEXT,
        logo_path TEXT,
        tax_number TEXT,
        tax_rate REAL DEFAULT 0.0,
        currency TEXT DEFAULT 'EGP',
        invoice_prefix TEXT DEFAULT 'INV',
        last_invoice_number INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        CHECK (tax_rate >= 0 AND tax_rate <= 100)
      )
    ''');

    // Activity Logs table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS activity_logs (
        id TEXT PRIMARY KEY NOT NULL,
        session_id TEXT,
        timestamp TEXT NOT NULL,
        type TEXT NOT NULL,
        description TEXT NOT NULL,
        user_name TEXT NOT NULL,
        details TEXT
      )
    ''');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_activity_logs_timestamp ON activity_logs(timestamp DESC)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_activity_logs_session ON activity_logs(session_id)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_activity_logs_type ON activity_logs(type)');

    // Categories table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS categories (
        id TEXT PRIMARY KEY NOT NULL,
        name TEXT NOT NULL UNIQUE,
        color TEXT,
        sort_order INTEGER DEFAULT 0
      )
    ''');

    // Products table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS products (
        id TEXT PRIMARY KEY NOT NULL,
        barcode TEXT UNIQUE,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        min_price REAL DEFAULT 0.0,
        wholesale_price REAL DEFAULT 0.0,
        cost REAL DEFAULT 0.0,
        stock REAL DEFAULT 0.0,
        min_stock REAL DEFAULT 0.0,
        category_id TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories(id)
      )
    ''');

    // Users table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id TEXT PRIMARY KEY NOT NULL,
        username TEXT NOT NULL UNIQUE,
        display_name TEXT NOT NULL,
        password_hash TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'cashier',
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        created_by TEXT,
        last_login TEXT,
        CHECK (role IN ('admin', 'manager', 'cashier')),
        FOREIGN KEY (created_by) REFERENCES users(id)
      )
    ''');

    // Shifts table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS shifts (
        id TEXT PRIMARY KEY NOT NULL,
        user_id TEXT NOT NULL,
        open_time TEXT NOT NULL,
        close_time TEXT,
        closed_by TEXT,
        opening_cash REAL DEFAULT 0.0,
        closing_cash REAL DEFAULT 0.0,
        is_open INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // Sales table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS sales (
        id TEXT PRIMARY KEY NOT NULL,
        total REAL NOT NULL DEFAULT 0.0,
        created_at TEXT NOT NULL,
        user_id TEXT,
        cashier_name TEXT,
        items_count INTEGER DEFAULT 0,
        is_refund INTEGER NOT NULL DEFAULT 0,
        original_sale_id TEXT,
        shift_id TEXT,
        discount REAL DEFAULT 0.0,
        tax REAL DEFAULT 0.0,
        payment_method TEXT DEFAULT 'cash',
        notes TEXT,
        FOREIGN KEY (user_id) REFERENCES users(id),
        FOREIGN KEY (original_sale_id) REFERENCES sales(id),
        FOREIGN KEY (shift_id) REFERENCES shifts(id)
      )
    ''');

    // Sale items table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS sale_items (
        id TEXT PRIMARY KEY NOT NULL,
        sale_id TEXT NOT NULL,
        product_id TEXT NOT NULL,
        product_barcode TEXT,
        product_name TEXT NOT NULL,
        quantity REAL NOT NULL,
        price REAL NOT NULL,
        wholesale_price REAL DEFAULT 0.0,
        subtotal REAL NOT NULL,
        refunded_quantity REAL DEFAULT 0.0,
        FOREIGN KEY (sale_id) REFERENCES sales(id) ON DELETE CASCADE,
        CHECK (quantity > 0),
        CHECK (price >= 0),
        CHECK (refunded_quantity >= 0),
        CHECK (refunded_quantity <= quantity)
      )
    ''');

    // Create indexes
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_products_barcode ON products(barcode)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_products_category_id ON products(category_id)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_sales_created_at ON sales(created_at DESC)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_sales_user_id ON sales(user_id)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_sale_items_sale_id ON sale_items(sale_id)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_users_username ON users(username)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_shifts_user_id ON shifts(user_id)');

    // Additional performance indexes
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_sales_shift_date ON sales(shift_id, created_at DESC)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_sales_is_refund ON sales(is_refund, created_at DESC)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_sale_items_product ON sale_items(product_id)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_products_active ON products(is_active, category_id)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_products_low_stock ON products(stock, min_stock) WHERE stock < min_stock');

    FileLogger.info('Database indexes created', source: 'SQLite');

    // Insert default settings
    await db.execute('''
      INSERT INTO store_settings (
        id, store_name, store_address, store_phone,
        currency, invoice_prefix, last_invoice_number,
        created_at, updated_at
      ) VALUES (
        'store_settings_singleton', 'Bayaa Store', '', '',
        'EGP', 'INV', 0,
        '${DateTime.now().toIso8601String()}',
        '${DateTime.now().toIso8601String()}'
      )
    ''');
  }

  Database get database {
    if (_database == null) {
      throw StateError('Database not initialized');
    }
    return _database!;
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final stopwatch = Stopwatch()..start();
    final results = await database.query(
      table,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
    print(
        '🔍 SQL SELECT from $table | Count: ${results.length} | Time: ${stopwatch.elapsedMilliseconds}ms');
    // Optional: verbose log for small results?
    // if (results.length < 5) print('   Results: $results');
    return results;
  }

  Future<int> insert(
    String table,
    Map<String, dynamic> values, {
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    print('📝 SQL INSERT into $table | Data: $values');
    return database.insert(
      table,
      values,
      conflictAlgorithm: conflictAlgorithm,
    );
  }

  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    print(
        '📝 SQL UPDATE $table | Where: $where | Args: $whereArgs | Data: $values');
    return database.update(
      table,
      values,
      where: where,
      whereArgs: whereArgs,
    );
  }

  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    print('🗑️ SQL DELETE from $table | Where: $where | Args: $whereArgs');
    return database.delete(
      table,
      where: where,
      whereArgs: whereArgs,
    );
  }

  Future<void> execute(String sql, [List<Object?>? arguments]) async {
    print('⚙️ SQL EXECUTE: $sql | Args: $arguments');
    await database.execute(sql, arguments);
  }

  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    print('🔄 SQL TRANSACTION START');
    try {
      final result = await database.transaction(action);
      print('✅ SQL TRANSACTION COMMIT');
      return result;
    } catch (e) {
      print('❌ SQL TRANSACTION ROLLBACK: $e');
      rethrow;
    }
  }

  Future<bool> checkIntegrity() async {
    final result = await database.rawQuery('PRAGMA integrity_check');
    return result.isNotEmpty && result.first.values.first == 'ok';
  }

  Future<void> checkpoint() async {
    await database.execute('PRAGMA wal_checkpoint(FULL)');
  }

  Future<void> close() async {
    await checkpoint();
    await _database?.close();
    _database = null;
  }
}
