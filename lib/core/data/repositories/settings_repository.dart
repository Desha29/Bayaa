// lib/core/data/repositories/settings_repository.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as path;
import '../models/store_settings_model.dart';
import '../services/data_persistence_manager.dart';

class SettingsRepository {
  final DataPersistenceManager persistence;

  SettingsRepository(this.persistence);

  /// Get store settings
  Future<StoreSettingsModel> getStoreSettings() async {
    if (!persistence.isEnabled) {
      return StoreSettingsModel.defaultSettings();
    }

    final results = await persistence.sqliteManager.query(
      'store_settings',
      limit: 1,
    );

    if (results.isEmpty) {
      final defaultSettings = StoreSettingsModel.defaultSettings();
      await _saveSettings(defaultSettings);
      return defaultSettings;
    }

    return StoreSettingsModel.fromSQLite(results.first);
  }

  /// Update store settings
  Future<void> updateStoreSettings({
    String? storeName,
    String? storeAddress,
    String? storePhone,
    String? storeEmail,
    double? taxRate,
    String? currency,
    String? invoicePrefix,
  }) async {
    final current = await getStoreSettings();
    final updated = current.copyWith(
      storeName: storeName,
      storeAddress: storeAddress,
      storePhone: storePhone,
      storeEmail: storeEmail,
      taxRate: taxRate,
      currency: currency,
      invoicePrefix: invoicePrefix,
    );

    await _saveSettings(updated);
  }

  /// Update store logo
  Future<void> updateStoreLogo(File logoFile) async {
    final current = await getStoreSettings();
    
    final logoDir = Directory(
      path.join(persistence.pathResolver.assetsPath)
    );
    await logoDir.create(recursive: true);
    
    final extension = path.extension(logoFile.path);
    final logoPath = path.join(logoDir.path, 'store_logo$extension');
    
    await logoFile.copy(logoPath);
    
    final updated = current.copyWith(logoPath: logoPath);
    await _saveSettings(updated);
  }

  /// Update logo from bytes
  Future<void> updateStoreLogoFromBytes(
    Uint8List logoBytes,
    String extension,
  ) async {
    final current = await getStoreSettings();
    
    final logoDir = Directory(
      path.join(persistence.pathResolver.assetsPath)
    );
    await logoDir.create(recursive: true);
    
    final logoPath = path.join(logoDir.path, 'store_logo$extension');
    final logoFile = File(logoPath);
    await logoFile.writeAsBytes(logoBytes);
    
    final updated = current.copyWith(logoPath: logoPath);
    await _saveSettings(updated);
  }

  /// Remove store logo
  Future<void> removeStoreLogo() async {
    final current = await getStoreSettings();
    
    if (current.logoPath != null) {
      final logoFile = File(current.logoPath!);
      if (await logoFile.exists()) {
        await logoFile.delete();
      }
    }
    
    final updated = current.copyWith(logoPath: '');
    await _saveSettings(updated);
  }

  Future<void> _saveSettings(StoreSettingsModel settings) async {
    if (!persistence.isEnabled) return;

    await persistence.writeImmediate(
      operation: 'UPDATE',
      entity: 'store_settings',
      id: settings.id,
      data: settings.toJson(),
      sqliteWrite: () async {
        final existing = await persistence.sqliteManager.query(
          'store_settings',
          where: 'id = ?',
          whereArgs: [settings.id],
        );

        if (existing.isEmpty) {
          await persistence.sqliteManager.insert(
            'store_settings',
            settings.toSQLite(),
          );
        } else {
          await persistence.sqliteManager.update(
            'store_settings',
            settings.toSQLite(),
            where: 'id = ?',
            whereArgs: [settings.id],
          );
        }
      },
    );
  }

  /// Get next invoice number
  Future<String> getNextInvoiceNumber() async {
    final current = await getStoreSettings();
    final nextNumber = current.lastInvoiceNumber + 1;
    final invoiceNumber = current.generateNextInvoiceNumber();
    
    if (persistence.isEnabled) {
      final updated = current.copyWith(lastInvoiceNumber: nextNumber);
      await _saveSettings(updated);
    }
    
    return invoiceNumber;
  }
}
