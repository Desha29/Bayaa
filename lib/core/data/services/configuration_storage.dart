// lib/core/data/services/configuration_storage.dart

import 'dart:io';
import 'dart:convert';

/// Manages the application configuration file (config/bayaa.json).
class ConfigurationStorage {
  final String configFilePath;
  File? _configFile;
  Map<String, dynamic> _config = {};

  ConfigurationStorage(this.configFilePath);

  Future<void> load() async {
    _configFile = File(configFilePath);
    
    if (await _configFile!.exists()) {
      final content = await _configFile!.readAsString();
      _config = jsonDecode(content) as Map<String, dynamic>;
    } else {
      _config = _createDefaultConfig();
      await save();
    }
  }

  Future<void> save() async {
    if (_configFile == null) {
      throw StateError('Configuration not loaded');
    }
    
    final tempFile = File('${_configFile!.path}.tmp');
    final jsonContent = const JsonEncoder.withIndent('  ').convert(_config);
    await tempFile.writeAsString(jsonContent);
    await tempFile.rename(_configFile!.path);
  }

  Map<String, dynamic> _createDefaultConfig() {
    return {
      'version': '2.0',
      'checkpoint_interval_minutes': 15,
      'checkpoint_after_sales': 50,
      'ledger_max_size_mb': 10,
      'backup_schedule': 'daily',
      'backup_retention_days': 30,
      'auto_backup_enabled': true,
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  int get checkpointIntervalMinutes => 
      _config['checkpoint_interval_minutes'] as int? ?? 15;
  
  int get checkpointAfterSales => 
      _config['checkpoint_after_sales'] as int? ?? 50;
  
  int get ledgerMaxSizeMB => 
      _config['ledger_max_size_mb'] as int? ?? 10;
  
  bool get autoBackupEnabled => 
      _config['auto_backup_enabled'] as bool? ?? true;

  String? get dataPath => _config['dataPath'] as String?;
  set dataPath(String? v) => _config['dataPath'] = v;

  String? get lastBackup => _config['lastBackup'] as String?;
  set lastBackup(String? v) => _config['lastBackup'] = v;

  String? get lastCheckpoint => _config['lastCheckpoint'] as String?;
  set lastCheckpoint(String? v) => _config['lastCheckpoint'] = v;

  String get version => _config['version'] as String? ?? '2.0';
  set version(String v) => _config['version'] = v;

  dynamic get(String key) => _config[key];
  
  void set(String key, dynamic value) {
    _config[key] = value;
  }
  
  Map<String, dynamic> get all => Map.unmodifiable(_config);
}
