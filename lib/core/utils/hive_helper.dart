import 'dart:io';
import 'package:hive/hive.dart';

import 'package:crazy_phone_pos/features/auth/data/models/user_model.dart';
import 'package:crazy_phone_pos/features/products/data/models/product_model.dart';
import 'package:crazy_phone_pos/features/sales/data/models/sale_model.dart';
import 'package:crazy_phone_pos/features/settings/data/models/store_info_model.dart';
import 'package:crazy_phone_pos/features/arp/data/models/session_model.dart';
import 'package:crazy_phone_pos/features/arp/data/models/daily_report_model.dart';
import 'package:crazy_phone_pos/features/arp/data/models/product_performance_model.dart';

class HiveHelper {
  /// Initialize Hive and perform all setup operations
  static Future<void> initialize() async {
    // -------------------------------------------------
    // ✅ Store Hive data in a "data" folder next to exe
    // -------------------------------------------------
    final Directory exeDir = Directory.current;
    final Directory hiveDir = Directory('${exeDir.path}\\data');

    // Create folder if it doesn’t exist
    await hiveDir.create(recursive: true);

    // Initialize Hive in this custom path
    Hive.init(hiveDir.path);

    print('✅ Hive initialized at: ${hiveDir.path}');

    // Register all adapters
    _registerAdapters();

    // Open all boxes safely
    await _openBoxesSafely();

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
    Hive.registerAdapter(SessionAdapter());
    Hive.registerAdapter(DailyReportAdapter());
    Hive.registerAdapter(ProductPerformanceModelAdapter());
  }

  /// Open all required Hive boxes with error handling
  static Future<void> _openBoxesSafely() async {
    try {
      await Future.wait([
        Hive.openBox<User>('userBox'),
        Hive.openBox<Product>('productsBox'),
        Hive.openBox('categoryBox'),
        Hive.openBox<StoreInfo>('storeBox'),
        Hive.openLazyBox<Sale>('salesBox'),
        Hive.openBox<Session>('sessionBox'),
        Hive.openBox<DailyReport>('dailyReportBox'),
      ]);
    } catch (e) {
      print('Error opening boxes, attempting to recover: $e');

      await _deleteCorruptedBoxes();

      await Future.wait([
        Hive.openBox<User>('userBox'),
        Hive.openBox<Product>('productsBox'),
        Hive.openBox('categoryBox'),
        Hive.openBox<StoreInfo>('storeBox'),
        Hive.openLazyBox<Sale>('salesBox'),
        Hive.openBox<Session>('sessionBox'),
        Hive.openBox<DailyReport>('dailyReportBox'),
      ]);
    }
  }

  /// Delete corrupted boxes
  static Future<void> _deleteCorruptedBoxes() async {
    try {
      await Future.wait([
        Hive.deleteBoxFromDisk('userBox'),
        Hive.deleteBoxFromDisk('productsBox'),
        Hive.deleteBoxFromDisk('categoryBox'),
        Hive.deleteBoxFromDisk('storeBox'),
        Hive.deleteBoxFromDisk('salesBox'),
        Hive.deleteBoxFromDisk('sessionBox'),
        Hive.deleteBoxFromDisk('dailyReportBox'),
      ]);
      print('Corrupted boxes deleted successfully');
    } catch (e) {
      print('Error deleting corrupted boxes: $e');
    }
  }

  /// Initialize default data
  static Future<void> _initializeDefaultData() async {
    final userBox = Hive.box<User>('userBox');

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

  static Box<User> get userBox => Hive.box<User>('userBox');
  static Box<Product> get productsBox => Hive.box<Product>('productsBox');
  static Box get categoryBox => Hive.box('categoryBox');
  static Box<StoreInfo> get storeBox => Hive.box<StoreInfo>('storeBox');
  static LazyBox<Sale> get salesBox => Hive.lazyBox<Sale>('salesBox'); // Changed to LazyBox
  static Box<Session> get sessionBox => Hive.box<Session>('sessionBox');
  static Box<DailyReport> get dailyReportBox => Hive.box<DailyReport>('dailyReportBox');

  static Future<void> closeAllBoxes() async => Hive.close();

  static Future<void> deleteBox(String boxName) async {
    if (Hive.isBoxOpen(boxName)) {
      await Hive.box(boxName).close();
    }
    await Hive.deleteBoxFromDisk(boxName);
  }

  static Future<void> deleteAllBoxes() async {
    await closeAllBoxes();
    await Future.wait([
      Hive.deleteBoxFromDisk('salesBox'),
    ]);
  }

  static Future<void> clearAllData() async {
    await Future.wait([
      salesBox.clear(),
    ]);
  }

  static Future<void> resetToDefaults() async {
    await clearAllData();
    await _initializeDefaultData();
  }

  static Future<void> completeReset() async {
    await closeAllBoxes();
    await deleteAllBoxes();
    await initialize();
  }
}
