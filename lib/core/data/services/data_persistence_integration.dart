// lib/core/data/services/data_persistence_integration.dart

/// Integration wrapper that allows existing code to work with or without the new persistence system
/// 
/// This class provides backward compatibility - your existing Hive-based code continues to work,
/// and the new persistence system runs alongside it.

import 'persistence_initializer.dart';

class DataPersistenceIntegration {
  /// Check if the new persistence system is available and enabled
  static bool get isAvailable => PersistenceInitializer.isEnabled;

  /// Try to initialize persistence system (non-blocking, silent failure)
  static Future<void> tryInitialize() async {
    try {
      await PersistenceInitializer.initialize();
    } catch (e) {
      print('Persistence system not available: $e');
      // System continues with Hive only
    }
  }

  /// Execute a write operation with optional persistence
  /// If persistence is enabled, writes to both ledger+SQLite and Hive
  /// If persistence is disabled, writes only to Hive (existing behavior)
  static Future<void> persistentWrite({
    required String entity,
    required String id,
    required Map<String, dynamic> data,
    required Future<void> Function() hiveWrite,
    Future<void> Function()? sqliteWrite,
    bool immediate = false,
  }) async {
    if (isAvailable && PersistenceInitializer.persistenceManager != null) {
      final persistence = PersistenceInitializer.persistenceManager!;
      
      if (immediate) {
        await persistence.writeImmediate(
          operation: 'INSERT',
          entity: entity,
          id: id,
          data: data,
          sqliteWrite: sqliteWrite ?? () async {},
        );
      } else {
        await persistence.writeAsync(
          operation: 'INSERT',
          entity: entity,
          id: id,
          data: data,
          sqliteWrite: sqliteWrite ?? () async {},
        );
      }
    }
    
    // Always execute Hive write (existing behavior)
    await hiveWrite();
  }

  /// Execute a query with optional SQLite fallback
  /// If persistence is enabled and SQLite has data, use SQLite
  /// Otherwise, use Hive (existing behavior)
  static Future<T> persistentQuery<T>({
    required Future<T> Function() hiveQuery,
    Future<T> Function()? sqliteQuery,
  }) async {
    if (isAvailable && 
        sqliteQuery != null &&
        PersistenceInitializer.persistenceManager != null) {
      try {
        return await sqliteQuery();
      } catch (e) {
        print('SQLite query failed, falling back to Hive: $e');
      }
    }
    
    // Default to Hive
    return hiveQuery();
  }
}
