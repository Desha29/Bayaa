// lib/core/data/services/repository_persistence_mixin.dart

import 'persistence_initializer.dart';

/// Mixin to add persistence capabilities to repositories
/// Automatically writes to Ledger + SQLite when enabled
mixin RepositoryPersistenceMixin {
  /// Write critical data (sales, invoices, money)
  /// Writes to Ledger FIRST, then SQLite
  Future<void> writeCritical({
    required String entity,
    required String id,
    required Map<String, dynamic> data,
    required Future<void> Function() sqliteWrite,
  }) async {
    if (PersistenceInitializer.isEnabled) {
      final persistence = PersistenceInitializer.persistenceManager!;
      
      await persistence.writeImmediate(
        operation: 'INSERT',
        entity: entity,
        id: id,
        data: data,
        sqliteWrite: sqliteWrite,
      );
    } else {
      // If persistence not enabled, just execute SQLite write
      await sqliteWrite();
    }
  }

  /// Update critical data
  Future<void> updateCritical({
    required String entity,
    required String id,
    required Map<String, dynamic> data,
    required Future<void> Function() sqliteWrite,
  }) async {
    if (PersistenceInitializer.isEnabled) {
      final persistence = PersistenceInitializer.persistenceManager!;
      
      await persistence.writeImmediate(
        operation: 'UPDATE',
        entity: entity,
        id: id,
        data: data,
        sqliteWrite: sqliteWrite,
      );
    } else {
      await sqliteWrite();
    }
  }

  /// Delete critical data
  Future<void> deleteCritical({
    required String entity,
    required String id,
    required Future<void> Function() sqliteWrite,
  }) async {
    if (PersistenceInitializer.isEnabled) {
      final persistence = PersistenceInitializer.persistenceManager!;
      
      await persistence.writeImmediate(
        operation: 'DELETE',
        entity: entity,
        id: id,
        data: {'id': id, 'deleted_at': DateTime.now().toIso8601String()},
        sqliteWrite: sqliteWrite,
      );
    } else {
      await sqliteWrite();
    }
  }

  /// Write non-critical data (background queue)
  Future<void> writeNonCritical({
    required String entity,
    required String id,
    required Map<String, dynamic> data,
    required Future<void> Function() sqliteWrite,
  }) async {
    if (PersistenceInitializer.isEnabled) {
      final persistence = PersistenceInitializer.persistenceManager!;
      
      await persistence.writeAsync(
        operation: 'INSERT',
        entity: entity,
        id: id,
        data: data,
        sqliteWrite: sqliteWrite,
      );
    } else {
      await sqliteWrite();
    }
  }
}
