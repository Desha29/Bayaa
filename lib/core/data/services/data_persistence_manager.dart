// lib/core/data/services/data_persistence_manager.dart

// ignore_for_file: avoid_print

import 'data_path_resolver.dart';
import 'configuration_storage.dart';
import 'append_only_ledger.dart';
import 'sqlite_manager.dart';
import 'background_write_queue.dart';
import 'backup_manager.dart';
import '../../logging/file_logger.dart';
import '../../logging/crash_logger.dart';

/// Main orchestrator for the data persistence architecture.
class DataPersistenceManager {
  late DataPathResolver pathResolver;
  late ConfigurationStorage config;
  late SQLiteManager sqliteManager;
  late AppendOnlyLedger ledger;
  late BackgroundWriteQueue writeQueue;
  late BackupManager backupManager;
  
  bool _initialized = false;
  bool _enabled = false;

  /// Check if persistence system is enabled
  bool get isEnabled => _enabled;

  /// Initialize the entire data persistence system.
  Future<bool> initialize() async {
    if (_initialized) {
      print('  ℹ️ Already initialized');
      return true;
    }
    
    try {
      print('  📂 Initializing DataPathResolver...');
      // Step 1: Resolve data paths
      pathResolver = DataPathResolver();
      final pathConfigured = await pathResolver.initialize();
      
      if (!pathConfigured) {
        print('  ⚠️ Data path not configured');
        _enabled = false;
        return false;
      }
      print('  ✅ DataPathResolver ready');
      print('     Path: ${pathResolver.dataRootPath}');
      
      // Step 1.5: Initialize logging system
      print('  📝 Initializing logging system...');
      await FileLogger.instance.initialize(pathResolver.logsPath);
      await CrashLogger.instance.initialize(pathResolver.logsPath);
      FileLogger.info('Data persistence system initializing', source: 'PersistenceManager');
      print('  ✅ Logging system ready');
      
      print('  ⚙️ Loading configuration...');
      // Step 2: Load configuration
      config = ConfigurationStorage(pathResolver.configFile);
      await config.load();
      print('  ✅ Configuration loaded');
      print('     Checkpoint interval: ${config.checkpointIntervalMinutes} min');
      print('     Ledger max size: ${config.ledgerMaxSizeMB} MB');
      
      print('  🗄️ Initializing SQLite database...');
      // Step 3: Initialize SQLite
      sqliteManager = SQLiteManager(databasePath: pathResolver.mainDatabaseFile);
      await sqliteManager.initialize();
      print('  ✅ SQLite ready (WAL mode enabled)');
      
      print('  📝 Initializing append-only ledger...');
      // Step 4: Initialize ledger
      ledger = AppendOnlyLedger(
        ledgerDirectoryPath: pathResolver.ledgerPath,
        maxSizeMB: config.ledgerMaxSizeMB,
      );
      await ledger.initialize();
      final ledgerFiles = await ledger.getAllLedgerFiles();
      print('  ✅ Ledger ready (${ledgerFiles.length} file(s))');
      
      print('  ⚡ Starting background write queue...');
      // Step 5: Start background write queue
      writeQueue = BackgroundWriteQueue();
      writeQueue.start();
      print('  ✅ Background queue active');
      
      // Step 6: Initialize backup manager
      print('  💾 Initializing backup manager...');
      backupManager = BackupManager(
        databasePath: pathResolver.mainDatabaseFile,
        backupsPath: pathResolver.backupsPath,
        retentionDays: 30,
      );
      print('  ✅ Backup manager ready');
      
      _initialized = true;
      _enabled = true;
      
      print('  🎉 All systems initialized successfully!');
      FileLogger.info('All persistence systems initialized successfully', source: 'PersistenceManager');
      return true;
    } catch (e, stackTrace) {
      print('  ❌ Initialization failed: $e');
      print('     Stack: $stackTrace');
      FileLogger.critical('Persistence initialization failed', error: e, stackTrace: stackTrace, source: 'PersistenceManager');
      _enabled = false;
      return false;
    }
  }

  /// Prompt user to select data storage path.
  Future<bool> promptForDataPath({bool allowCancel = true}) async {
    return pathResolver.promptUserForDataPath(allowCancel: allowCancel);
  }

  /// Write data with full persistence guarantees (for critical operations).
  Future<void> writeImmediate({
    required String operation,
    required String entity,
    required String id,
    required Map<String, dynamic> data,
    required Future<void> Function() sqliteWrite,
  }) async {
    if (!_enabled) {
      // If persistence not enabled, just execute SQLite write
      await sqliteWrite();
      return;
    }

    try {
      print('  💾 Writing $entity:$id to ledger...');
      print('     📋 Data: $data');
      // Write to ledger first
      await ledger.write(
        operation: operation,
        entity: entity,
        id: id,
        data: data,
        immediate: true,
      );
      print('  ✅ Ledger write complete');
      
      print('  🗄️ Writing to SQLite...');
      // Then write to SQLite
      await sqliteWrite();
      print('  ✅ SQLite write complete');
    } catch (e) {
      print('  ❌ Write immediate failed: $e');
      rethrow;
    }
  }

  /// Write data using background queue (for non-critical operations).
  Future<void> writeAsync({
    required String operation,
    required String entity,
    required String id,
    required Map<String, dynamic> data,
    required Future<void> Function() sqliteWrite,
  }) async {
    if (!_enabled) {
      await sqliteWrite();
      return;
    }

    await writeQueue.enqueue(() async {
      await ledger.write(
        operation: operation,
        entity: entity,
        id: id,
        data: data,
      );
      
      await sqliteWrite();
    });
  }

  /// Graceful shutdown.
  Future<void> shutdown() async {
    if (!_enabled) return;
    
    try {
      FileLogger.info('Shutting down persistence system', source: 'PersistenceManager');
      
      // Create backup before shutdown
      print('💾 Creating backup before shutdown...');
      final backupSuccess = await backupManager.createBackup();
      if (backupSuccess) {
        print('✅ Backup created successfully');
      } else {
        print('⚠️ Backup creation failed');
      }
      
      await ledger.close();
      await sqliteManager.close();
      await writeQueue.dispose();
      
      // Shutdown logging last
      await FileLogger.instance.shutdown();
      
      _initialized = false;
      _enabled = false;
    } catch (e) {
      print('Shutdown error: $e');
      FileLogger.error('Shutdown error', error: e, source: 'PersistenceManager');
    }
  }
}
