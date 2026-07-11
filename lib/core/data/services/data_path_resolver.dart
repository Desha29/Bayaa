// lib/core/data/services/data_path_resolver.dart

import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../logging/file_logger.dart';

/// Resolves and manages the user-selected data storage root directory.
class DataPathResolver {
  static const String _systemConfigFileName = 'system_config.json';
  static const String _dataRootKey = 'data_root_path';
  
  String? _dataRootPath;
  File? _systemConfigFile;

  /// Initialize and resolve the data root path.
  Future<bool> initialize() async {
    // Determine system config path: %APPDATA%\Bayaa\system_config.json
    String? appData = Platform.environment['APPDATA'];
    if (appData == null) {
      // Fallback to path_provider if APPDATA env var is missing (unlikely on Windows)
      final appSupport = await getApplicationSupportDirectory();
      appData = appSupport.path;
    }
    
    final systemConfigDir = Directory(path.join(appData, 'Bayaa'));
    if (!await systemConfigDir.exists()) {
      await systemConfigDir.create(recursive: true);
    }
    
    _systemConfigFile = File(path.join(systemConfigDir.path, _systemConfigFileName));
    
    if (await _systemConfigFile!.exists()) {
      final configJson = await _systemConfigFile!.readAsString();
      final config = jsonDecode(configJson) as Map<String, dynamic>;
      _dataRootPath = config[_dataRootKey] as String?;
      
      if (_dataRootPath != null && await Directory(_dataRootPath!).exists()) {
        return true;
      }
    }
    
    return false;
  }

  /// Check if a directory contains existing BayaaData
  static bool hasExistingData(String directoryPath) {
    final bayaaDataDir = Directory(path.join(directoryPath, 'BayaaData'));
    if (!bayaaDataDir.existsSync()) return false;
    
    // Check for key indicators of valid data
    final dbDir = Directory(path.join(bayaaDataDir.path, 'db'));
    final configDir = Directory(path.join(bayaaDataDir.path, 'config'));
    
    return dbDir.existsSync() || configDir.existsSync();
  }

  /// Check if path itself IS a BayaaData folder (user selected 'BayaaData' directly)
  static bool isBayaaDataFolder(String directoryPath) {
    final dirName = path.basename(directoryPath);
    if (dirName != 'BayaaData') return false;
    
    final dbDir = Directory(path.join(directoryPath, 'db'));
    final configDir = Directory(path.join(directoryPath, 'config'));
    
    return dbDir.existsSync() || configDir.existsSync();
  }

  /// Prompt user to select data storage directory.
  Future<bool> promptUserForDataPath({bool allowCancel = true}) async {
    // Determine if we are in Program Files
    final executablePath = Platform.resolvedExecutable;
    final inProgramFiles = executablePath.contains('Program Files');
    
    final executableDir = File(executablePath).parent.path;
    String? defaultDataPath;
    if (!inProgramFiles) {
      defaultDataPath = path.join(executableDir, 'BayaaData');
    }
    
    print('  🔍 Default data path suggested: $defaultDataPath');
    
    // Show dialog
    String? result;
    try {
      result = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'اختر مكان حفظ البيانات - Select Data Storage Location${defaultDataPath != null ? '\n\nالافتراضي: $defaultDataPath' : ''}',
        lockParentWindow: false,
      );
    } catch (e) {
      print('  ❌ FilePicker error: $e');
      result = null;
    }
    
    print('  📥 FilePicker result: $result');
    String? selectedDirectory;
    
    if (result == null) {
      // User cancelled - use exe directory as default location
      print('  ℹ️ User cancelled folder selection. Using exe directory as default.');
      selectedDirectory = inProgramFiles 
          ? path.join(Platform.environment['USERPROFILE'] ?? 'C:\\', 'BayaaData')
          : executableDir;
    } else {
      selectedDirectory = result;
    }

    // Case 1: User selected a folder that IS the BayaaData folder itself
    if (isBayaaDataFolder(selectedDirectory)) {
      print('  📂 User selected the BayaaData folder directly - using it as-is');
      _dataRootPath = selectedDirectory;
      await _saveDataRootPath(selectedDirectory);
      // Ensure any missing subdirectories are created
      await _createDirectoryStructure();
      return true;
    }

    // Case 2: User selected a parent folder that already contains BayaaData
    if (hasExistingData(selectedDirectory)) {
      final existingPath = path.join(selectedDirectory, 'BayaaData');
      print('  📂 Found existing BayaaData in selected folder: $existingPath');
      _dataRootPath = existingPath;
      await _saveDataRootPath(existingPath);
      // Ensure any missing subdirectories are created
      await _createDirectoryStructure();
      return true;
    }

    // Case 3: Fresh folder - create BayaaData inside it
    final dataRoot = path.join(selectedDirectory, 'BayaaData');
    final dataRootDir = Directory(dataRoot);
    await dataRootDir.create(recursive: true);
    
    await _saveDataRootPath(dataRoot);
    _dataRootPath = dataRoot;
    
    await _createDirectoryStructure();
    
    return true;
  }

  /// Migrate data to a new location.
  /// Returns true if migration was successful.
  Future<bool> migrateData(String newParentPath) async {
    if (_dataRootPath == null) {
      print('  ❌ Cannot migrate: no current data root path');
      return false;
    }

    final oldDataRoot = _dataRootPath!;
    final newDataRoot = path.join(newParentPath, 'BayaaData');

    // Don't migrate to the same location
    if (path.normalize(oldDataRoot) == path.normalize(newDataRoot)) {
      print('  ℹ️ Source and destination are the same. No migration needed.');
      return true;
    }

    // Check if destination already has data
    if (await Directory(newDataRoot).exists()) {
      final dbFile = File(path.join(newDataRoot, 'db', 'sales.db'));
      if (await dbFile.exists()) {
        print('  ⚠️ Destination already contains data. Migration cancelled.');
        return false;
      }
    }

    try {
      print('  📦 Starting data migration...');
      print('  📂 From: $oldDataRoot');
      print('  📂 To: $newDataRoot');
      FileLogger.info('Starting data migration from $oldDataRoot to $newDataRoot', source: 'DataPathResolver');

      // Create destination
      await Directory(newDataRoot).create(recursive: true);

      // Copy all files recursively
      await _copyDirectory(Directory(oldDataRoot), Directory(newDataRoot));
      
      // Also move backup folder
      final oldBackupPath = path.join(File(oldDataRoot).parent.path, 'BayaaBackup');
      final newBackupPath = path.join(newParentPath, 'BayaaBackup');
      if (await Directory(oldBackupPath).exists()) {
        await Directory(newBackupPath).create(recursive: true);
        await _copyDirectory(Directory(oldBackupPath), Directory(newBackupPath));
        print('  ✅ Backup folder migrated');
      }

      // Update config to new path
      await _saveDataRootPath(newDataRoot);
      _dataRootPath = newDataRoot;

      // Clean up old data (after successful migration)
      try {
        await Directory(oldDataRoot).delete(recursive: true);
        if (await Directory(oldBackupPath).exists()) {
          await Directory(oldBackupPath).delete(recursive: true);
        }
        print('  🗑️ Old data cleaned up');
      } catch (e) {
        print('  ⚠️ Could not delete old data (not critical): $e');
        FileLogger.warning('Could not delete old data after migration', error: e, source: 'DataPathResolver');
      }

      print('  ✅ Data migration completed successfully');
      FileLogger.info('Data migration completed successfully to $newDataRoot', source: 'DataPathResolver');
      return true;
    } catch (e, stack) {
      print('  ❌ Data migration failed: $e');
      FileLogger.error('Data migration failed', error: e, stackTrace: stack, source: 'DataPathResolver');
      return false;
    }
  }

  /// Copy directory recursively
  Future<void> _copyDirectory(Directory source, Directory destination) async {
    await for (final entity in source.list(recursive: false)) {
      final newPath = path.join(destination.path, path.basename(entity.path));
      
      if (entity is File) {
        await entity.copy(newPath);
      } else if (entity is Directory) {
        final newDir = Directory(newPath);
        await newDir.create(recursive: true);
        await _copyDirectory(entity, newDir);
      }
    }
  }

  Future<void> _saveDataRootPath(String rootPath) async {
    final config = {_dataRootKey: rootPath};
    
    final tempFile = File('${_systemConfigFile!.path}.tmp');
    await tempFile.writeAsString(jsonEncode(config));
    await tempFile.rename(_systemConfigFile!.path);
  }

  Future<void> _createDirectoryStructure() async {
    if (_dataRootPath == null) {
      throw StateError('Data root path not set');
    }
    
    final directories = [
      'config',
      'ledger',
      'ledger/archived',
      'db',
      'checkpoints',
      'logs',
      'assets',
    ];
    
    for (final dir in directories) {
      final fullPath = path.join(_dataRootPath!, dir);
      await Directory(fullPath).create(recursive: true);
    }
    
    // Create backup directory outside data root
    await Directory(backupsPath).create(recursive: true);
  }

  String get dataRootPath {
    if (_dataRootPath == null) {
      throw StateError('Data root path not initialized');
    }
    return _dataRootPath!;
  }
  
  String get configPath => path.join(dataRootPath, 'config');
  String get ledgerPath => path.join(dataRootPath, 'ledger');
  String get ledgerArchivedPath => path.join(dataRootPath, 'ledger', 'archived');
  String get databasePath => path.join(dataRootPath, 'db');
  String get checkpointsPath => path.join(dataRootPath, 'checkpoints');
  
  String get backupsPath {
    final parentDir = File(dataRootPath).parent.path;
    return path.join(parentDir, 'BayaaBackup');
  }
  
  String get logsPath => path.join(dataRootPath, 'logs');
  String get assetsPath => path.join(dataRootPath, 'assets');
  
  String get mainDatabaseFile => path.join(databasePath, 'sales.db');
  String get configFile => path.join(configPath, 'bayaa.json');
}
