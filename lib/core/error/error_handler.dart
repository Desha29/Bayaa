// lib/core/error/error_handler.dart

import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:either_dart/either.dart' as either_dart;
import '../logging/file_logger.dart';
import 'failure.dart';

/// Centralized error handler for all repository operations
class ErrorHandler {
  /// Execute a repository operation with comprehensive error handling
  /// 
  /// This wrapper ensures:
  /// - All exceptions are caught
  /// - Errors are logged to file
  /// - User-friendly messages are returned
  /// - No unhandled exceptions escape
  static Future<Either<Failure, T>> executeWithErrorHandling<T>({
    required Future<Either<Failure, T>> Function() operation,
    required String operationName,
    String? userFriendlyMessage,
    String? source,
  }) async {
    try {
      FileLogger.debug('Executing operation: $operationName', source: source ?? 'ErrorHandler');
      
      final result = await operation();
      
      return result.fold(
        (failure) {
          // Operation returned a Failure (business logic error)
          FileLogger.warning(
            'Operation failed: $operationName - ${failure.message}',
            source: source ?? 'ErrorHandler',
          );
          return Left(failure);
        },
        (success) {
          // Operation succeeded
          FileLogger.debug('Operation succeeded: $operationName', source: source ?? 'ErrorHandler');
          return Right(success);
        },
      );
    } on DatabaseException catch (e, stack) {
      // SQLite/Database specific errors
      final message = userFriendlyMessage ?? 'حدث خطأ في قاعدة البيانات';
      FileLogger.error(
        'Database error in $operationName',
        error: e,
        stackTrace: stack,
        source: source ?? 'ErrorHandler',
      );
      return Left(CacheFailure(message));
    } on FileSystemException catch (e, stack) {
      // File system errors (e.g., permissions, disk full)
      final message = userFriendlyMessage ?? 'حدث خطأ في نظام الملفات';
      FileLogger.error(
        'FileSystem error in $operationName',
        error: e,
        stackTrace: stack,
        source: source ?? 'ErrorHandler',
      );
      return Left(CacheFailure(message));
    } catch (e, stack) {
      // Catch-all for any other unexpected errors
      final message = userFriendlyMessage ?? 'حدث خطأ غير متوقع';
      FileLogger.critical(
        'Unexpected error in $operationName',
        error: e,
        stackTrace: stack,
        source: source ?? 'ErrorHandler',
      );
      return Left(CacheFailure(message));
    }
  }

  /// Execute operation with either_dart package (for repositories using either_dart)
  static Future<either_dart.Either<Failure, T>> executeWithErrorHandlingEitherDart<T>({
    required Future<either_dart.Either<Failure, T>> Function() operation,
    required String operationName,
    String? userFriendlyMessage,
    String? source,
  }) async {
    try {
      FileLogger.debug('Executing operation: $operationName', source: source ?? 'ErrorHandler');
      
      final result = await operation();
      
      if (result.isLeft) {
        final failure = result.left;
        FileLogger.warning(
          'Operation failed: $operationName - ${failure.message}',
          source: source ?? 'ErrorHandler',
        );
      } else {
        FileLogger.debug('Operation succeeded: $operationName', source: source ?? 'ErrorHandler');
      }
      
      return result;
    } on DatabaseException catch (e, stack) {
      final message = userFriendlyMessage ?? 'حدث خطأ في قاعدة البيانات';
      FileLogger.error(
        'Database error in $operationName',
        error: e,
        stackTrace: stack,
        source: source ?? 'ErrorHandler',
      );
      return either_dart.Left(CacheFailure(message));
    } on FileSystemException catch (e, stack) {
      final message = userFriendlyMessage ?? 'حدث خطأ في نظام الملفات';
      FileLogger.error(
        'FileSystem error in $operationName',
        error: e,
        stackTrace: stack,
        source: source ?? 'ErrorHandler',
      );
      return either_dart.Left(CacheFailure(message));
    } catch (e, stack) {
      final message = userFriendlyMessage ?? 'حدث خطأ غير متوقع';
      FileLogger.critical(
        'Unexpected error in $operationName',
        error: e,
        stackTrace: stack,
        source: source ?? 'ErrorHandler',
      );
      return either_dart.Left(CacheFailure(message));
    }
  }
}

/// Common database exception placeholder
class DatabaseException implements Exception {
  final String message;
  DatabaseException(this.message);
  
  @override
  String toString() => message;
}
