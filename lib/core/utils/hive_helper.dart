import 'package:hive_flutter/hive_flutter.dart';
import 'package:crazy_phone_pos/features/auth/data/models/user_model.dart';
import 'package:crazy_phone_pos/features/products/data/models/product_model.dart';
import 'package:crazy_phone_pos/features/sales/data/models/sale_model.dart';
import 'package:crazy_phone_pos/features/settings/data/models/store_info_model.dart';

class HiveHelper {
  /// Initialize Hive and perform all setup operations
  static Future<void> initialize() async {
    // Initialize Hive Flutter
    await Hive.initFlutter();

    // Register all adapters
    _registerAdapters();

    // Open all boxes with error handling
    await _openBoxesSafely();
    //await clearAllData();
    // Initialize default data
    await _initializeDefaultData();
  }

  /// Register all Hive adapters
  static void _registerAdapters() {
    Hive.registerAdapter(UserTypeAdapter());
    Hive.registerAdapter(UserAdapter());
    Hive.registerAdapter(StoreInfoAdapter());
    Hive.registerAdapter(ProductAdapter());
    Hive.registerAdapter(SaleAdapter());
    Hive.registerAdapter(SaleItemAdapter());
  }

  /// Open all required Hive boxes with error handling
  static Future<void> _openBoxesSafely() async {
    try {
      await Future.wait([
        Hive.openBox<User>('userBox'),
        Hive.openBox<Product>('productsBox'),
        Hive.openBox('categoryBox'),
        Hive.openBox<StoreInfo>('storeBox'),
        Hive.openBox<Sale>('salesBox'),
      ]);
    } catch (e) {
      print('Error opening boxes, attempting to recover: $e');

      // If there's a schema mismatch, delete corrupted boxes
      await _deleteCorruptedBoxes();

      // Try opening again with fresh boxes
      await Future.wait([
        Hive.openBox<User>('userBox'),
        Hive.openBox<Product>('productsBox'),
        Hive.openBox('categoryBox'),
        Hive.openBox<StoreInfo>('storeBox'),
        Hive.openBox<Sale>('salesBox'),
      ]);
    }
  }

  /// Delete corrupted boxes from disk
  static Future<void> _deleteCorruptedBoxes() async {
    try {
      await Future.wait([
        Hive.deleteBoxFromDisk('userBox'),
        Hive.deleteBoxFromDisk('productsBox'),
        Hive.deleteBoxFromDisk('categoryBox'),
        Hive.deleteBoxFromDisk('storeBox'),
        Hive.deleteBoxFromDisk('salesBox'),
      ]);
      print('Corrupted boxes deleted successfully');
    } catch (e) {
      print('Error deleting corrupted boxes: $e');
    }
  }

  /// Initialize default data (admin user, sample products, etc.)
  static Future<void> _initializeDefaultData() async {
    final userBox = Hive.box<User>('userBox');

    // Create default admin user if not exists
    if (!userBox.containsKey('admin')) {
      await userBox.put(
        'admin',
        User(
          name: "Mostafa",
          phone: "01000000000",
          username: 'admin',
          password: 'admin',
          userType: UserType.manager,
        ),
      );
    }
  }

  /// Get user box
  static Box<User> get userBox => Hive.box<User>('userBox');

  /// Get products box
  static Box<Product> get productsBox => Hive.box<Product>('productsBox');

  /// Get category box
  static Box get categoryBox => Hive.box('categoryBox');

  /// Get store box
  static Box<StoreInfo> get storeBox => Hive.box<StoreInfo>('storeBox');

  /// Get sales box
  static Box<Sale> get salesBox => Hive.box<Sale>('salesBox');

  /// Close all boxes
  static Future<void> closeAllBoxes() async {
    await Hive.close();
  }

  /// Delete a specific box from disk (must be called AFTER close)
  static Future<void> deleteBox(String boxName) async {
    if (Hive.isBoxOpen(boxName)) {
      await Hive.box(boxName).close();
    }
    await Hive.deleteBoxFromDisk(boxName);
  }

  /// Delete all boxes from disk (use with caution!)
  static Future<void> deleteAllBoxes() async {
    await closeAllBoxes();

    await Future.wait([
      // Hive.deleteBoxFromDisk('userBox'),
      // Hive.deleteBoxFromDisk('productsBox'),
      // Hive.deleteBoxFromDisk('categoryBox'),
      // Hive.deleteBoxFromDisk('storeBox'),
      Hive.deleteBoxFromDisk('salesBox'),
    ]);
  }

  /// Clear all data from all boxes (keeps boxes open)
  static Future<void> clearAllData() async {
    await Future.wait([
      // userBox.clear(),
      // productsBox.clear(),
      // categoryBox.clear(),
      // storeBox.clear(),
      salesBox.clear(),
    ]);
  }

  /// Reset to default state (clear all data and reinitialize defaults)
  static Future<void> resetToDefaults() async {
    await clearAllData();
    await _initializeDefaultData();
  }

  /// Complete app data reset (closes, deletes, reinitializes)
  static Future<void> completeReset() async {
    await closeAllBoxes();
    await deleteAllBoxes();
    await initialize();
  }
}
