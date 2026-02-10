import 'dart:async';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../data/models/activity_log.dart';
import '../data/services/persistence_initializer.dart';

class ActivityLogger {
  static final ActivityLogger _instance = ActivityLogger._internal();
  factory ActivityLogger() => _instance;
  ActivityLogger._internal();

  final List<ActivityLog> _activities = [];
  final _controller = StreamController<List<ActivityLog>>.broadcast();
  final _uuid = const Uuid();

  Stream<List<ActivityLog>> get activitiesStream => _controller.stream;

  Future<void> loadRecentActivities() async {
    try {
      final db = PersistenceInitializer.persistenceManager!.sqliteManager;
      final results = await db.query(
        'activity_logs',
        orderBy: 'timestamp DESC',
        limit: 100,
      );

      _activities.clear();
      for (final row in results) {
        _activities.add(ActivityLog(
          id: row['id'] as String,
          timestamp: DateTime.parse(row['timestamp'] as String),
          type: ActivityType.values.firstWhere(
            (e) => e.toString() == 'ActivityType.${row['type']}',
          ),
          description: row['description'] as String,
          userName: row['user_name'] as String,
          details: row['details'] != null 
              ? jsonDecode(row['details'] as String) 
              : null,
        ));
      }
      _controller.add(_activities);
    } catch (e) {
      print('Failed to load recent activities: $e');
    }
  }

  void logActivity({
    required ActivityType type,
    required String description,
    required String userName,
    Map<String, dynamic>? details,
  }) async {
    final activity = ActivityLog(
      id: _uuid.v4(),
      timestamp: DateTime.now(),
      type: type,
      description: description,
      userName: userName,
      details: details,
    );

    // Update in-memory
    _activities.insert(0, activity); // Most recent first
    if (_activities.length > 100) {
      _activities.removeLast();
    }
    _controller.add(_activities);

    // Persist to DB
    try {
      final db = PersistenceInitializer.persistenceManager!.sqliteManager;
      await db.insert('activity_logs', {
        'id': activity.id,
        'timestamp': activity.timestamp.toIso8601String(),
        'type': activity.type.toString().split('.').last,
        'description': activity.description,
        'user_name': activity.userName,
        'details': activity.details != null ? jsonEncode(activity.details) : null,
      });
    } catch (e) {
      print('Failed to persist activity log: $e');
    }
  }

  List<ActivityLog> getRecentActivities({int limit = 20}) {
    return _activities.take(limit).toList();
  }

  void dispose() {
    _controller.close();
  }
}
