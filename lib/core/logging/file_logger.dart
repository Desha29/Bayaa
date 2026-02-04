// lib/core/logging/file_logger.dart

import 'dart:io';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

/// Log levels for categorizing messages
enum LogLevel {
  debug,
  info,
  warning,
  error,
  critical,
}

/// Production-grade file logger with rotation and thread-safe writes
class FileLogger {
  static FileLogger? _instance;
  static FileLogger get instance => _instance ??= FileLogger._();
  
  FileLogger._();

  String? _logDirectory;
  File? _currentLogFile;
  IOSink? _logSink;
  final _writeQueue = <String>[];
  bool _isWriting = false;
  Timer? _rotationTimer;
  
  static const int maxLogSizeBytes = 10 * 1024 * 1024; // 10MB
  static const int maxLogAgeDays = 30;
  
  /// Initialize the logger with the logs directory path
  Future<void> initialize(String logDirectoryPath) async {
    _logDirectory = logDirectoryPath;
    
    try {
      // Ensure log directory exists
      final dir = Directory(_logDirectory!);
      if (!dir.existsSync()) {
        await dir.create(recursive: true);
      }
      
      // Create or open today's log file
      await _openLogFile();
      
      // Clean old logs
      await _cleanOldLogs();
      
      // Set up daily rotation check
      _rotationTimer = Timer.periodic(const Duration(hours: 1), (_) {
        _checkRotation();
      });
      
      info('FileLogger initialized successfully');
    } catch (e) {
      print('⚠️ Failed to initialize FileLogger: $e');
    }
  }

  /// Open or create today's log file
  Future<void> _openLogFile() async {
    if (_logDirectory == null) return;
    
    final today = DateFormat('yyyyMMdd').format(DateTime.now());
    final logFileName = 'bayaa_$today.log';
    final logFilePath = path.join(_logDirectory!, logFileName);
    
    _currentLogFile = File(logFilePath);
    
    // Open in append mode
    _logSink = _currentLogFile!.openWrite(mode: FileMode.append);
    
    // Write session start marker
    _logSink!.writeln('\n${'=' * 80}');
    _logSink!.writeln('Session started: ${DateTime.now().toIso8601String()}');
    _logSink!.writeln('=' * 80);
    await _logSink!.flush();
  }

  /// Check if log rotation is needed
  Future<void> _checkRotation() async {
    if (_currentLogFile == null) return;
    
    try {
      // Check if file size exceeds limit
      final fileSize = await _currentLogFile!.length();
      if (fileSize > maxLogSizeBytes) {
        await _rotateLog();
        return;
      }
      
      // Check if it's a new day
      final today = DateFormat('yyyyMMdd').format(DateTime.now());
      final currentFileName = path.basename(_currentLogFile!.path);
      if (!currentFileName.contains(today)) {
        await _rotateLog();
      }
    } catch (e) {
      print('⚠️ Log rotation check failed: $e');
    }
  }

  /// Rotate log file
  Future<void> _rotateLog() async {
    try {
      // Close current log
      await _logSink?.flush();
      await _logSink?.close();
      
      // Open new log file
      await _openLogFile();
      
      info('Log file rotated');
    } catch (e) {
      print('⚠️ Log rotation failed: $e');
    }
  }

  /// Clean logs older than maxLogAgeDays
  Future<void> _cleanOldLogs() async {
    if (_logDirectory == null) return;
    
    try {
      final dir = Directory(_logDirectory!);
      final cutoffDate = DateTime.now().subtract(Duration(days: maxLogAgeDays));
      
      await for (final entity in dir.list()) {
        if (entity is File && entity.path.endsWith('.log')) {
          final stat = await entity.stat();
          if (stat.modified.isBefore(cutoffDate)) {
            await entity.delete();
            print('🗑️ Deleted old log: ${path.basename(entity.path)}');
          }
        }
      }
    } catch (e) {
      print('⚠️ Failed to clean old logs: $e');
    }
  }

  /// Write log message
  Future<void> _writeLog(LogLevel level, String message, {Object? error, StackTrace? stackTrace, String? source}) async {
    if (_logSink == null) {
      // Fallback to console if logger not initialized
      print('[${level.name.toUpperCase()}] $message');
      return;
    }

    final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(DateTime.now());
    final levelStr = level.name.toUpperCase().padRight(8);
    final sourceStr = source != null ? '[$source] ' : '';
    
    final logLine = '[$timestamp] [$levelStr] $sourceStr$message';
    
    _writeQueue.add(logLine);
    
    // Add error details if present
    if (error != null) {
      _writeQueue.add('  Error: $error');
    }
    if (stackTrace != null) {
      _writeQueue.add('  Stack trace:\n${stackTrace.toString().split('\n').map((line) => '    $line').join('\n')}');
    }
    
    await _processQueue();
  }

  /// Process write queue
  Future<void> _processQueue() async {
    if (_isWriting || _writeQueue.isEmpty || _logSink == null) return;
    
    _isWriting = true;
    
    try {
      while (_writeQueue.isNotEmpty) {
        final line = _writeQueue.removeAt(0);
        _logSink!.writeln(line);
      }
      await _logSink!.flush();
    } catch (e) {
      print('⚠️ Failed to write to log: $e');
    } finally {
      _isWriting = false;
    }
  }

  /// Debug level log
  static void debug(String message, {String? source}) {
    instance._writeLog(LogLevel.debug, message, source: source);
  }

  /// Info level log
  static void info(String message, {String? source}) {
    instance._writeLog(LogLevel.info, message, source: source);
  }

  /// Warning level log
  static void warning(String message, {Object? error, String? source}) {
    instance._writeLog(LogLevel.warning, message, error: error, source: source);
  }

  /// Error level log
  static void error(String message, {Object? error, StackTrace? stackTrace, String? source}) {
    instance._writeLog(LogLevel.error, message, error: error, stackTrace: stackTrace, source: source);
  }

  /// Critical level log
  static void critical(String message, {Object? error, StackTrace? stackTrace, String? source}) {
    instance._writeLog(LogLevel.critical, message, error: error, stackTrace: stackTrace, source: source);
  }

  /// Shutdown logger
  Future<void> shutdown() async {
    _rotationTimer?.cancel();
    
    try {
      info('FileLogger shutting down');
      await _logSink?.flush();
      await _logSink?.close();
      _logSink = null;
    } catch (e) {
      print('⚠️ Error during logger shutdown: $e');
    }
  }
}
