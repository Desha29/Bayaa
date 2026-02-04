// lib/core/state/state_synchronizer.dart

import 'dart:async';
import '../logging/file_logger.dart';

/// Event representing a data change in the system
class DataChangeEvent {
  final String entityType; // 'product', 'sale', 'category', 'stock', etc.
  final String operation; // 'create', 'update', 'delete'
  final String? id;
  final Map<String, dynamic>? metadata;

  DataChangeEvent({
    required this.entityType,
    required this.operation,
    this.id,
    this.metadata,
  });

  @override
  String toString() => 'DataChangeEvent($entityType:$operation${id != null ? ":$id" : ""})';
}

/// State synchronizer for real-time cross-feature updates
/// 
/// This event bus ensures that when data changes in one feature,
/// all other relevant features are immediately notified and can
/// refresh their state automatically.
class StateSynchronizer {
  static final StateSynchronizer _instance = StateSynchronizer._();
  static StateSynchronizer get instance => _instance;

  StateSynchronizer._();

  final _controller = StreamController<DataChangeEvent>.broadcast();

  /// Stream of all data change events
  static Stream<DataChangeEvent> get events => instance._controller.stream;

  /// Notify all listeners of a data change
  /// 
  /// Call this after ANY successful write operation (create, update, delete)
  /// 
  /// Example:
  /// ```dart
  /// await saveProduct(product);
  /// StateSynchronizer.notify(DataChangeEvent(
  ///   entityType: 'product',
  ///   operation: 'update',
  ///   id: product.barcode,
  /// ));
  /// ```
  static void notify(DataChangeEvent event) {
    FileLogger.debug('State change: ${event.toString()}', source: 'StateSynchronizer');
    instance._controller.add(event);
  }

  /// Dispose the synchronizer (call on app shutdown)
  static Future<void> dispose() async {
    await instance._controller.close();
  }
}
