// lib/core/data/services/checkpoint_service.dart

import 'dart:io';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import '../../logging/file_logger.dart';
import 'persistence_initializer.dart';

/// Automatic checkpoint service for crash recovery.
///
/// Creates named checkpoints of the database at key moments:
/// - On login
/// - On logout / session close
/// - Before reset
/// - Before restore
/// - Before update
class CheckpointService {
  static final CheckpointService _instance = CheckpointService._internal();
  factory CheckpointService() => _instance;
  CheckpointService._internal();

  static const int _maxCheckpoints = 10;

  String get _checkpointsPath {
    return PersistenceInitializer.persistenceManager!.pathResolver.checkpointsPath;
  }

  String get _databasePath {
    return PersistenceInitializer.persistenceManager!.pathResolver.mainDatabaseFile;
  }

  /// Create a checkpoint with a reason tag.
  Future<bool> createCheckpoint({
    required String reason,
    String userName = 'system',
  }) async {
    try {
      if (!PersistenceInitializer.isEnabled) {
        print('⚠️ Checkpoint skipped: persistence not enabled');
        return false;
      }

      FileLogger.info('Creating checkpoint: $reason (user: $userName)', source: 'Checkpoint');

      // Ensure checkpoints directory exists
      final dir = Directory(_checkpointsPath);
      if (!dir.existsSync()) {
        await dir.create(recursive: true);
      }

      // WAL checkpoint first to flush pending writes
      try {
        await PersistenceInitializer.persistenceManager!.sqliteManager.checkpoint();
      } catch (e) {
        print('⚠️ WAL checkpoint warning: $e');
      }

      // Create timestamped checkpoint folder
      final timestamp = DateFormat('yyyy_MM_dd_HH_mm_ss').format(DateTime.now());
      final chkName = 'chk_${timestamp}_${reason.replaceAll(' ', '_')}';
      final chkPath = path.join(_checkpointsPath, chkName);
      await Directory(chkPath).create();

      // Copy database files
      final dbFile = File(_databasePath);
      if (await dbFile.exists()) {
        await dbFile.copy(path.join(chkPath, path.basename(_databasePath)));
      }

      // Copy WAL file if exists
      final walFile = File('$_databasePath-wal');
      if (await walFile.exists()) {
        await walFile.copy(path.join(chkPath, '${path.basename(_databasePath)}-wal'));
      }

      // Copy SHM file if exists
      final shmFile = File('$_databasePath-shm');
      if (await shmFile.exists()) {
        await shmFile.copy(path.join(chkPath, '${path.basename(_databasePath)}-shm'));
      }

      // Write metadata
      final metadata = {
        'user': userName,
        'timestamp': DateTime.now().toIso8601String(),
        'reason': reason,
        'dbSize': await dbFile.exists() ? await dbFile.length() : 0,
        'version': '2.0',
      };
      await File(path.join(chkPath, 'metadata.json'))
          .writeAsString(const JsonEncoder.withIndent('  ').convert(metadata));

      // Update config
      try {
        final config = PersistenceInitializer.persistenceManager!.config;
        config.set('lastCheckpoint', DateTime.now().toIso8601String());
        config.set('lastCheckpointReason', reason);
        await config.save();
      } catch (_) {}

      FileLogger.info('Checkpoint created: $chkName', source: 'Checkpoint');
      print('✅ Checkpoint created: $chkName');

      // Clean old checkpoints
      await _cleanOldCheckpoints();

      return true;
    } catch (e, stack) {
      FileLogger.error('Checkpoint creation failed', error: e, stackTrace: stack, source: 'Checkpoint');
      print('❌ Checkpoint failed: $e');
      return false;
    }
  }

  /// Restore from the latest checkpoint.
  Future<bool> restoreFromLatestCheckpoint() async {
    try {
      final latest = await getLatestCheckpoint();
      if (latest == null) {
        FileLogger.warning('No checkpoints available for restore', source: 'Checkpoint');
        return false;
      }
      return await restoreFromCheckpoint(latest.path);
    } catch (e, stack) {
      FileLogger.error('Restore from checkpoint failed', error: e, stackTrace: stack, source: 'Checkpoint');
      return false;
    }
  }

  /// Restore from a specific checkpoint folder.
  Future<bool> restoreFromCheckpoint(String checkpointPath) async {
    try {
      FileLogger.info('Restoring from checkpoint: ${path.basename(checkpointPath)}', source: 'Checkpoint');

      final dbFileName = path.basename(_databasePath);
      final backupDb = File(path.join(checkpointPath, dbFileName));

      if (!await backupDb.exists()) {
        FileLogger.error('Checkpoint DB file not found', source: 'Checkpoint');
        return false;
      }

      // Close current DB connection
      try {
        await PersistenceInitializer.persistenceManager!.sqliteManager.close();
      } catch (_) {}

      // Restore files
      await backupDb.copy(_databasePath);

      final dbDir = File(_databasePath).parent.path;
      final dbBase = path.basenameWithoutExtension(_databasePath);

      final walBackup = File(path.join(checkpointPath, '$dbBase.db-wal'));
      if (await walBackup.exists()) {
        await walBackup.copy(path.join(dbDir, '$dbBase.db-wal'));
      }

      final shmBackup = File(path.join(checkpointPath, '$dbBase.db-shm'));
      if (await shmBackup.exists()) {
        await shmBackup.copy(path.join(dbDir, '$dbBase.db-shm'));
      }

      FileLogger.info('Checkpoint restored successfully', source: 'Checkpoint');
      return true;
    } catch (e, stack) {
      FileLogger.error('Checkpoint restore failed', error: e, stackTrace: stack, source: 'Checkpoint');
      return false;
    }
  }

  /// Get the latest checkpoint directory.
  Future<Directory?> getLatestCheckpoint() async {
    final dir = Directory(_checkpointsPath);
    if (!dir.existsSync()) return null;

    final checkpoints = <Directory>[];
    await for (final entity in dir.list()) {
      if (entity is Directory && path.basename(entity.path).startsWith('chk_')) {
        checkpoints.add(entity);
      }
    }

    if (checkpoints.isEmpty) return null;
    checkpoints.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
    return checkpoints.first;
  }

  /// Get all checkpoints with metadata.
  Future<List<Map<String, dynamic>>> getAllCheckpoints() async {
    final dir = Directory(_checkpointsPath);
    if (!dir.existsSync()) return [];

    final results = <Map<String, dynamic>>[];
    await for (final entity in dir.list()) {
      if (entity is Directory && path.basename(entity.path).startsWith('chk_')) {
        final metaFile = File(path.join(entity.path, 'metadata.json'));
        Map<String, dynamic> meta = {'path': entity.path, 'name': path.basename(entity.path)};
        if (await metaFile.exists()) {
          try {
            final content = await metaFile.readAsString();
            meta.addAll(jsonDecode(content) as Map<String, dynamic>);
          } catch (_) {}
        }
        results.add(meta);
      }
    }

    results.sort((a, b) => (b['timestamp'] ?? '').compareTo(a['timestamp'] ?? ''));
    return results;
  }

  /// Remove old checkpoints beyond max limit.
  Future<void> _cleanOldCheckpoints() async {
    try {
      final dir = Directory(_checkpointsPath);
      if (!dir.existsSync()) return;

      final checkpoints = <Directory>[];
      await for (final entity in dir.list()) {
        if (entity is Directory && path.basename(entity.path).startsWith('chk_')) {
          checkpoints.add(entity);
        }
      }

      if (checkpoints.length <= _maxCheckpoints) return;

      checkpoints.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));

      // Delete oldest beyond limit
      for (var i = _maxCheckpoints; i < checkpoints.length; i++) {
        await checkpoints[i].delete(recursive: true);
        FileLogger.debug('Deleted old checkpoint: ${path.basename(checkpoints[i].path)}', source: 'Checkpoint');
      }
    } catch (e) {
      FileLogger.warning('Failed to clean old checkpoints', error: e, source: 'Checkpoint');
    }
  }
}
