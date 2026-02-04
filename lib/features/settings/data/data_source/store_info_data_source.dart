import 'package:crazy_phone_pos/core/data/services/persistence_initializer.dart';
import '../models/store_info_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class StoreInfoDataSource {
  static const String _table = 'store_settings';
  static const String _id = 'store_settings_singleton';

  Future<void> saveStoreInfo(StoreInfo storeInfo) async {
    try {
      final db = PersistenceInitializer.persistenceManager!.sqliteManager;
      
      final count = await db.update(_table, {
        'store_name': storeInfo.name,
        'store_address': storeInfo.address,
        'store_phone': storeInfo.phone,
        'store_email': storeInfo.email,
        'tax_number': storeInfo.vat,
        'logo_path': storeInfo.logoPath ?? '',
        'updated_at': DateTime.now().toIso8601String(),
      }, where: 'id = ?', whereArgs: [_id]);

      if (count == 0) {
        // Fallback insert if not exists (should be rare)
        await db.insert(_table, {
          'id': _id,
          'store_name': storeInfo.name,
          'store_address': storeInfo.address,
          'store_phone': storeInfo.phone,
          'store_email': storeInfo.email,
          'tax_number': storeInfo.vat,
          'logo_path': storeInfo.logoPath ?? '',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
          // Defaults for others will be used
        });
      }

    } catch (e) {
      throw Exception('Failed to save store info: $e');
    }
  }

  Future<StoreInfo?> getStoreInfo() async {
    try {
      final db = PersistenceInitializer.persistenceManager!.sqliteManager;
      final results = await db.query(_table, where: 'id = ?', whereArgs: [_id]);
      
      if (results.isNotEmpty) {
        final row = results.first;
        return StoreInfo(
          name: row['store_name'] as String ,
          address: (row['store_address'] as String?) ?? 'Alkhanka',
          phone: (row['store_phone'] as String?) ?? '01000000000',
          email: (row['store_email'] as String?) ?? 'bayaa@bayaa',
         
          vat: (row['tax_number'] as String?) ?? '0000000000000',
          logoPath: row['logo_path'] as String?,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get store info: $e');
    }
  }

  Future<void> deleteStoreInfo() async {
    // We typically don't delete the singleton settings, just reset or ignore.
    // implementation kept for interface compatibility
  }

  Future<bool> hasStoreInfo() async {
    final info = await getStoreInfo();
    return info != null;
  }

  StoreInfo getDefaultStoreInfo() {
    return StoreInfo(
      name: 'Bayaa',
      phone: '',
      email: '',
      address: "",
      vat: '',
      logoPath: '',
    );
  }
}
