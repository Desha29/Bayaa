// lib/core/data/services/append_only_ledger.dart

import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:path/path.dart' as path;
import 'package:crypto/crypto.dart';

/// High-performance append-only ledger (write-ahead log).
class AppendOnlyLedger {
  final String ledgerDirectoryPath;
  final int maxSizeMB;
  
  IOSink? _currentSink;
  File? _currentFile;
  int _currentFileNumber = 1;
  Timer? _flushTimer;
  
  static const Duration _autoFlushInterval = Duration(seconds: 5);

  AppendOnlyLedger({
    required this.ledgerDirectoryPath,
    this.maxSizeMB = 10,
  });

  Future<void> initialize() async {
    await _findLatestLedgerFile();
    await _openLedgerFile();
    _startAutoFlush();
  }

  Future<void> _findLatestLedgerFile() async {
    final dir = Directory(ledgerDirectoryPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    
    final files = await dir.list().where((e) => e is File).toList();
    
    int maxNumber = 0;
    for (final file in files) {
      final fileName = path.basename(file.path);
      final match = RegExp(r'ledger_(\d+)\.log').firstMatch(fileName);
      if (match != null) {
        final num = int.parse(match.group(1)!);
        if (num > maxNumber) maxNumber = num;
      }
    }
    
    _currentFileNumber = maxNumber > 0 ? maxNumber : 1;
  }

  Future<void> _openLedgerFile() async {
    final fileName = 'ledger_${_currentFileNumber.toString().padLeft(3, '0')}.log';
    _currentFile = File(path.join(ledgerDirectoryPath, fileName));
    
    _currentSink = _currentFile!.openWrite(mode: FileMode.append);
  }

  void _startAutoFlush() {
    _flushTimer?.cancel();
    _flushTimer = Timer.periodic(_autoFlushInterval, (_) => flush());
  }

  Future<void> write({
    required String operation,
    required String entity,
    required String id,
    required Map<String, dynamic> data,
    bool immediate = false,
  }) async {
    if (_currentSink == null) {
      await initialize();
    }
    
    final entry = _createEntry(operation, entity, id, data);
    _currentSink!.writeln(jsonEncode(entry));
    
    if (immediate) {
      await flush();
    }
    
    await _checkRotation();
  }

  Future<void> writeBatch(List<Map<String, dynamic>> entries) async {
    if (_currentSink == null) {
      await initialize();
    }
    
    for (final entry in entries) {
      _currentSink!.writeln(jsonEncode(entry));
    }
    
    await flush();
    await _checkRotation();
  }

  Map<String, dynamic> _createEntry(
    String operation,
    String entity,
    String id,
    Map<String, dynamic> data,
  ) {
    final entry = {
      'ts': DateTime.now().toIso8601String(),
      'op': operation,
      'entity': entity,
      'id': id,
      'data': data,
    };
    
    final entryJson = jsonEncode(entry);
    final hash = sha256.convert(utf8.encode(entryJson));
    entry['hash'] = hash.toString();
    
    return entry;
  }

  Future<void> flush() async {
    await _currentSink?.flush();
  }

  Future<void> _checkRotation() async {
    if (_currentFile == null) return;
    
    final fileSize = await _currentFile!.length();
    final maxSizeBytes = maxSizeMB * 1024 * 1024;
    
    if (fileSize >= maxSizeBytes) {
      await rotate();
    }
  }

  Future<void> rotate() async {
    await flush();
    await _currentSink?.close();
    
    _currentFileNumber++;
    await _openLedgerFile();
  }

  Future<List<File>> getAllLedgerFiles() async {
    final dir = Directory(ledgerDirectoryPath);
    if (!await dir.exists()) return [];
    
    final files = await dir
        .list()
        .where((e) => e is File && e.path.contains('ledger_'))
        .cast<File>()
        .toList();
    
    files.sort((a, b) {
      final aNum = _extractFileNumber(a);
      final bNum = _extractFileNumber(b);
      return aNum.compareTo(bNum);
    });
    
    return files;
  }

  int _extractFileNumber(File file) {
    final fileName = path.basename(file.path);
    final match = RegExp(r'ledger_(\d+)\.log').firstMatch(fileName);
    return match != null ? int.parse(match.group(1)!) : 0;
  }

  Future<void> close() async {
    _flushTimer?.cancel();
    await flush();
    await _currentSink?.close();
  }
}
