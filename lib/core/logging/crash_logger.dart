// lib/core/logging/crash_logger.dart

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'file_logger.dart';

/// Crash logger that captures unhandled errors and creates crash dumps
class CrashLogger {
  static CrashLogger? _instance;
  static CrashLogger get instance => _instance ??= CrashLogger._();
  
  CrashLogger._();

  String? _crashDumpDirectory;
  bool _isInitialized = false;

  /// Initialize crash logger
  Future<void> initialize(String crashDumpDirectoryPath) async {
    if (_isInitialized) return;
    
    _crashDumpDirectory = crashDumpDirectoryPath;
    
    try {
      // Ensure crash dump directory exists
      final dir = Directory(_crashDumpDirectory!);
      if (!dir.existsSync()) {
        await dir.create(recursive: true);
      }
      
      // Set up Flutter error handlers
      _setupFlutterErrorHandlers();
      
      // Set up Dart error handlers
      _setupDartErrorHandlers();
      
      _isInitialized = true;
      FileLogger.info('CrashLogger initialized', source: 'CrashLogger');
    } catch (e) {
      print('⚠️ Failed to initialize CrashLogger: $e');
    }
  }

  /// Set up Flutter framework error handlers
  void _setupFlutterErrorHandlers() {
    FlutterError.onError = (FlutterErrorDetails details) {
      // Log to file
      FileLogger.critical(
        'Flutter framework error: ${details.exception}',
        error: details.exception,
        stackTrace: details.stack,
        source: 'Flutter',
      );
      
      // Create crash dump
      _createCrashDump(
        error: details.exception,
        stackTrace: details.stack,
        context: details.context?.toString(),
        library: details.library,
      );
      
      // Also print to console for debugging
      FlutterError.presentError(details);
    };
  }

  /// Set up Dart zone error handlers
  void _setupDartErrorHandlers() {
    // This will be called by runZonedGuarded in main.dart
  }

  /// Create a crash dump file
  Future<void> _createCrashDump({
    required Object error,
    StackTrace? stackTrace,
    String? context,
    String? library,
  }) async {
    if (_crashDumpDirectory == null) return;

    try {
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final crashFileName = 'crash_$timestamp.txt';
      final crashFilePath = path.join(_crashDumpDirectory!, crashFileName);
      
      final crashFile = File(crashFilePath);
      final sink = crashFile.openWrite();
      
      // Write crash report
      sink.writeln('=' * 80);
      sink.writeln('BAYAA POS - CRASH REPORT');
      sink.writeln('=' * 80);
      sink.writeln('Timestamp: ${DateTime.now().toIso8601String()}');
      sink.writeln('Platform: ${Platform.operatingSystem} ${Platform.operatingSystemVersion}');
      sink.writeln('Dart Version: ${Platform.version}');
      if (library != null) {
        sink.writeln('Library: $library');
      }
      sink.writeln('');
      
      sink.writeln('ERROR:');
      sink.writeln('-' * 80);
      sink.writeln(error.toString());
      sink.writeln('');
      
      if (context != null) {
        sink.writeln('CONTEXT:');
        sink.writeln('-' * 80);
        sink.writeln(context);
        sink.writeln('');
      }
      
      if (stackTrace != null) {
        sink.writeln('STACK TRACE:');
        sink.writeln('-' * 80);
        sink.writeln(stackTrace.toString());
        sink.writeln('');
      }
      
      sink.writeln('=' * 80);
      
      await sink.flush();
      await sink.close();
      
      print('💥 Crash dump created: $crashFileName');
    } catch (e) {
      print('⚠️ Failed to create crash dump: $e');
    }
  }

  /// Manually log a caught exception
  static void logException(
    Object error, {
    StackTrace? stackTrace,
    String? context,
    bool isFatal = false,
  }) {
    FileLogger.error(
      context ?? 'Exception caught',
      error: error,
      stackTrace: stackTrace,
      source: 'Exception',
    );
    
    if (isFatal) {
      instance._createCrashDump(
        error: error,
        stackTrace: stackTrace,
        context: context,
      );
    }
  }

  /// Clean old crash dumps (keep last 30 days)
  static Future<void> cleanOldCrashDumps() async {
    final crashDir = instance._crashDumpDirectory;
    if (crashDir == null) return;

    try {
      final dir = Directory(crashDir);
      if (!dir.existsSync()) return;

      final cutoffDate = DateTime.now().subtract(const Duration(days: 30));

      await for (final entity in dir.list()) {
        if (entity is File && entity.path.endsWith('.txt')) {
          final stat = await entity.stat();
          if (stat.modified.isBefore(cutoffDate)) {
            await entity.delete();
            FileLogger.debug('Deleted old crash dump: ${path.basename(entity.path)}', source: 'CrashLogger');
          }
        }
      }
    } catch (e) {
      FileLogger.warning('Failed to clean old crash dumps', error: e, source: 'CrashLogger');
    }
  }

  /// Get list of crash dump files
  static Future<List<File>> getCrashDumps() async {
    final crashDir = instance._crashDumpDirectory;
    if (crashDir == null) return [];

    try {
      final dir = Directory(crashDir);
      if (!dir.existsSync()) return [];

      final dumps = <File>[];
      await for (final entity in dir.list()) {
        if (entity is File && entity.path.endsWith('.txt')) {
          dumps.add(entity);
        }
      }
      
      // Sort by modification time (newest first)
      dumps.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
      
      return dumps;
    } catch (e) {
      FileLogger.warning('Failed to get crash dumps', error: e, source: 'CrashLogger');
      return [];
    }
  }
}
