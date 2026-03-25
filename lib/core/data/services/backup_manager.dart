// lib/core/data/services/backup_manager.dart

import 'dart:async';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import '../../logging/file_logger.dart';
import 'persistence_initializer.dart';

/// Backup manager for automatic database backups
class BackupManager {
  final String databasePath;
  final String backupsPath;
  final int retentionDays;
  Timer? _periodicBackupTimer;

  BackupManager({
    required this.databasePath,
    required this.backupsPath,
    this.retentionDays = 30,
  });

  /// Start periodic auto-backup (default: every 30 minutes)
  void startPeriodicBackup({Duration interval = const Duration(minutes: 30)}) {
    stopPeriodicBackup();
    FileLogger.info('Starting periodic backup every ${interval.inMinutes} minutes', source: 'BackupManager');
    _periodicBackupTimer = Timer.periodic(interval, (_) async {
      FileLogger.info('Running periodic auto-backup...', source: 'BackupManager');
      await createBackup();
    });
  }

  /// Stop periodic auto-backup
  void stopPeriodicBackup() {
    _periodicBackupTimer?.cancel();
    _periodicBackupTimer = null;
  }

  /// Create a backup of the database
  /// 
  /// Backs up:
  /// - SQLite database file (.db)
  /// - WAL file (.db-wal) if exists
  /// - SHM file (.db-shm) if exists
  Future<bool> createBackup() async {
    try {
      FileLogger.info('Starting database backup', source: 'BackupManager');
      
      // Ensure backups directory exists
      final backupsDir = Directory(backupsPath);
      if (!backupsDir.existsSync()) {
        await backupsDir.create(recursive: true);
      }

      // Create timestamped backup folder
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final backupFolderName = 'backup_$timestamp';
      final backupFolderPath = path.join(backupsPath, backupFolderName);
      final backupFolder = Directory(backupFolderPath);
      await backupFolder.create();

      // Get database directory
      final dbFile = File(databasePath);
      final dbDir = dbFile.parent.path;
      final dbBaseName = path.basenameWithoutExtension(databasePath);

      var filesBackedUp = 0;

      // 1. Backup main database file
      if (await dbFile.exists()) {
        final backupDbPath = path.join(backupFolderPath, path.basename(databasePath));
        await dbFile.copy(backupDbPath);
        filesBackedUp++;
        FileLogger.debug('Backed up database file', source: 'BackupManager');
      }

      // 2. Backup WAL file if exists
      final walFile = File(path.join(dbDir, '$dbBaseName.db-wal'));
      if (await walFile.exists()) {
        final backupWalPath = path.join(backupFolderPath, path.basename(walFile.path));
        await walFile.copy(backupWalPath);
        filesBackedUp++;
        FileLogger.debug('Backed up WAL file', source: 'BackupManager');
      }

      // 3. Backup SHM file if exists
      final shmFile = File(path.join(dbDir, '$dbBaseName.db-shm'));
      if (await shmFile.exists()) {
        final backupShmPath = path.join(backupFolderPath, path.basename(shmFile.path));
        await shmFile.copy(backupShmPath);
        filesBackedUp++;
        FileLogger.debug('Backed up SHM file', source: 'BackupManager');
      }

      // 4. Validate backup
      final isValid = await _validateBackup(backupFolderPath);
      if (!isValid) {
        FileLogger.error('Backup validation failed', source: 'BackupManager');
        // Delete invalid backup
        await backupFolder.delete(recursive: true);
        return false;
      }

      FileLogger.info('Backup created successfully: $backupFolderName ($filesBackedUp files)', source: 'BackupManager');
      
      // Clean old backups
      await _cleanOldBackups();
      
      return true;
    } catch (e, stack) {
      FileLogger.error('Backup creation failed', error: e, stackTrace: stack, source: 'BackupManager');
      return false;
    }
  }

  /// Validate backup integrity
  Future<bool> _validateBackup(String backupFolderPath) async {
    try {
      // Check that at least the main database file exists
      final files = await Directory(backupFolderPath).list().toList();
      final dbFileName = path.basename(databasePath);
      
      final hasDbFile = files.any((f) => f is File && path.basename(f.path) == dbFileName);
      
      if (!hasDbFile) {
        FileLogger.warning('Backup validation failed: missing database file', source: 'BackupManager');
        return false;
      }

      // Check file size is > 0
      final dbBackupFile = File(path.join(backupFolderPath, dbFileName));
      final size = await dbBackupFile.length();
      
      if (size == 0) {
        FileLogger.warning('Backup validation failed: database file is empty', source: 'BackupManager');
        return false;
      }

      return true;
    } catch (e) {
      FileLogger.error('Backup validation error', error: e, source: 'BackupManager');
      return false;
    }
  }

  /// Clean old backups, keeping only the most recent one
  Future<void> _cleanOldBackups() async {
    try {
      final backupsDir = Directory(backupsPath);
      if (!backupsDir.existsSync()) return;

      final backups = <Directory>[];
      await for (final entity in backupsDir.list()) {
        if (entity is Directory && path.basename(entity.path).startsWith('backup_')) {
          backups.add(entity);
        }
      }

      if (backups.length <= 1) return;

      // Sort by modification time (newest first)
      backups.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));

      // Skip the first (latest) and delete the rest
      final toDelete = backups.skip(1).toList();
      var deletedCount = 0;

      for (final dir in toDelete) {
        await dir.delete(recursive: true);
        deletedCount++;
        FileLogger.debug('Deleted old backup: ${path.basename(dir.path)}', source: 'BackupManager');
      }

      if (deletedCount > 0) {
        FileLogger.info('Cleaned $deletedCount old backups', source: 'BackupManager');
      }
    } catch (e) {
      FileLogger.warning('Failed to clean old backups', error: e, source: 'BackupManager');
    }
  }

  /// Restore from latest backup
  Future<bool> restoreFromLatestBackup() async {
    try {
      FileLogger.info('Starting database restore from latest backup', source: 'BackupManager');
      
      final latestBackup = await getLatestBackup();
      if (latestBackup == null) {
        FileLogger.error('No backups found for restore', source: 'BackupManager');
        return false;
      }

      return await restoreFromBackup(latestBackup.path);
    } catch (e, stack) {
      FileLogger.error('Restore failed', error: e, stackTrace: stack, source: 'BackupManager');
      return false;
    }
  }

  /// Restore from specific backup
  Future<bool> restoreFromBackup(String backupFolderPath) async {
    try {
      FileLogger.info('Restoring from backup: ${path.basename(backupFolderPath)}', source: 'BackupManager');
      
      final dbBaseName = path.basename(databasePath);
      final backupDbFile = File(path.join(backupFolderPath, dbBaseName));
      
      if (!await backupDbFile.exists()) {
        FileLogger.error('Backup database file not found', source: 'BackupManager');
        return false;
      }

      // Close current DB connection before overwriting files
      try {
        await PersistenceInitializer.persistenceManager!.sqliteManager.close();
      } catch (_) {}

      // Copy backup files to database location
      await backupDbFile.copy(databasePath);
      
      // Restore WAL and SHM if they exist
      final dbDir = File(databasePath).parent.path;
      final dbBaseNameNoExt = path.basenameWithoutExtension(databasePath);
      
      final backupWalFile = File(path.join(backupFolderPath, '$dbBaseNameNoExt.db-wal'));
      if (await backupWalFile.exists()) {
        await backupWalFile.copy(path.join(dbDir, '$dbBaseNameNoExt.db-wal'));
      }
      
      final backupShmFile = File(path.join(backupFolderPath, '$dbBaseNameNoExt.db-shm'));
      if (await backupShmFile.exists()) {
        await backupShmFile.copy(path.join(dbDir, '$dbBaseNameNoExt.db-shm'));
      }

      FileLogger.info('Database restored successfully', source: 'BackupManager');
      return true;
    } catch (e, stack) {
      FileLogger.error('Restore operation failed', error: e, stackTrace: stack, source: 'BackupManager');
      return false;
    }
  }

  /// Get latest backup directory
  Future<Directory?> getLatestBackup() async {
    try {
      final backupsDir = Directory(backupsPath);
      if (!backupsDir.existsSync()) return null;

      final backups = <Directory>[];
      await for (final entity in backupsDir.list()) {
        if (entity is Directory && path.basename(entity.path).startsWith('backup_')) {
          backups.add(entity);
        }
      }

      if (backups.isEmpty) return null;

      // Sort by modification time (newest first)
      backups.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
      
      return backups.first;
    } catch (e) {
      FileLogger.error('Failed to get latest backup', error: e, source: 'BackupManager');
      return null;
    }
  }

  /// Get all backups
  Future<List<Directory>> getAllBackups() async {
    try {
      final backupsDir = Directory(backupsPath);
      if (!backupsDir.existsSync()) return [];

      final backups = <Directory>[];
      await for (final entity in backupsDir.list()) {
        if (entity is Directory && path.basename(entity.path).startsWith('backup_')) {
          backups.add(entity);
        }
      }

      // Sort by modification time (newest first)
      backups.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
      
      return backups;
    } catch (e) {
      FileLogger.error('Failed to get backups list', error: e, source: 'BackupManager');
      return [];
    }
  }
}
