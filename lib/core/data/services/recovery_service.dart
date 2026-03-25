// lib/core/data/services/recovery_service.dart

import 'dart:io';
import '../../logging/file_logger.dart';
import 'persistence_initializer.dart';
import 'checkpoint_service.dart';

/// Recovery service that detects corruption and auto-restores from checkpoints.
///
/// Checks on startup:
/// - Database file exists
/// - Database integrity (PRAGMA integrity_check)
/// - Required folders exist
/// - Config file valid
class RecoveryService {
  static final RecoveryService _instance = RecoveryService._internal();
  factory RecoveryService() => _instance;
  RecoveryService._internal();

  /// Run all recovery checks. Returns true if system is healthy or was recovered.
  Future<bool> check() async {
    if (!PersistenceInitializer.isEnabled) {
      print('⚠️ Recovery check skipped: persistence not enabled');
      return true;
    }

    print('🔍 Running recovery checks...');
    FileLogger.info('Running recovery checks', source: 'Recovery');

    final issues = <String>[];

    // 1. Check database file exists
    final dbPath = PersistenceInitializer.persistenceManager!.pathResolver.mainDatabaseFile;
    if (!File(dbPath).existsSync()) {
      issues.add('Database file missing: $dbPath');
      FileLogger.error('Database file missing', source: 'Recovery');
    }

    // 2. Check folder structure
    final pathResolver = PersistenceInitializer.persistenceManager!.pathResolver;
    final requiredDirs = [
      pathResolver.databasePath,
      pathResolver.backupsPath,
      pathResolver.checkpointsPath,
      pathResolver.configPath,
      pathResolver.logsPath,
      pathResolver.ledgerPath,
    ];

    for (final dirPath in requiredDirs) {
      final dir = Directory(dirPath);
      if (!dir.existsSync()) {
        print('  📁 Recreating missing directory: $dirPath');
        await dir.create(recursive: true);
        FileLogger.warning('Recreated missing directory: $dirPath', source: 'Recovery');
      }
    }

    // 3. Check database integrity
    if (File(dbPath).existsSync()) {
      try {
        final isOk = await PersistenceInitializer.persistenceManager!.sqliteManager.checkIntegrity();
        if (!isOk) {
          issues.add('Database integrity check failed');
          FileLogger.error('Database integrity check failed', source: 'Recovery');
        } else {
          print('  ✅ Database integrity OK');
        }
      } catch (e) {
        issues.add('Database integrity check error: $e');
        FileLogger.error('Database integrity check error', error: e, source: 'Recovery');
      }
    }

    // 4. Check config file
    final configPath = pathResolver.configFile;
    if (!File(configPath).existsSync()) {
      print('  ⚠️ Config file missing, will be recreated on next save');
      FileLogger.warning('Config file missing', source: 'Recovery');
      // Not critical — ConfigurationStorage creates defaults
    }

    // 5. If critical issues found, attempt restore
    if (issues.isNotEmpty) {
      print('  ⚠️ Found ${issues.length} issue(s):');
      for (final issue in issues) {
        print('    - $issue');
      }

      FileLogger.warning('Recovery: ${issues.length} issues found, attempting restore', source: 'Recovery');

      final restored = await CheckpointService().restoreFromLatestCheckpoint();
      if (restored) {
        print('  ✅ Successfully restored from latest checkpoint');
        FileLogger.info('Recovery: restored from checkpoint', source: 'Recovery');
        return true;
      } else {
        // Try backup manager
        final backupRestored = await PersistenceInitializer.persistenceManager!.backupManager.restoreFromLatestBackup();
        if (backupRestored) {
          print('  ✅ Successfully restored from latest backup');
          FileLogger.info('Recovery: restored from backup', source: 'Recovery');
          return true;
        }

        print('  ❌ No checkpoint or backup available for recovery');
        FileLogger.error('Recovery: no restore source available', source: 'Recovery');
        return false;
      }
    }

    print('  ✅ All recovery checks passed');
    FileLogger.info('All recovery checks passed', source: 'Recovery');
    return true;
  }
}
