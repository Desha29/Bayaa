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
          sessionId: (row['session_id'] ?? '') as String,
          timestamp: DateTime.parse(row['timestamp'] as String),
          type: ActivityType.values.firstWhere(
            (e) => e.toString() == 'ActivityType.${row['type']}',
            orElse: () => ActivityType.sale,
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

  Future<void> logActivity({
    required ActivityType type,
    required String description,
    required String userName,
    String sessionId = '',
    Map<String, dynamic>? details,
  }) async {
    final activity = ActivityLog(
      id: _uuid.v4(),
      sessionId: sessionId,
      timestamp: DateTime.now(),
      type: type,
      description: description,
      userName: userName,
      details: details,
    );

    // Persist to DB FIRST
    try {
      final db = PersistenceInitializer.persistenceManager!.sqliteManager;
      await db.insert('activity_logs', {
        'id': activity.id,
        'session_id': activity.sessionId,
        'timestamp': activity.timestamp.toIso8601String(),
        'type': activity.type.toString().split('.').last,
        'description': activity.description,
        'user_name': activity.userName,
        'details': activity.details != null ? jsonEncode(activity.details) : null,
      });
    } catch (e) {
      print('Failed to persist activity log: $e');
      // Should we continue to update UI if DB failed? 
      // Yes, generally better to show optimization even if persist failed, 
      // but here the issue was race condition where UI tried to read from DB too early.
      // So ensuring DB write happens first solves it.
    }

    // Update in-memory and notify listeners
    _activities.insert(0, activity);
    if (_activities.length > 100) {
      _activities.removeLast();
    }
    _controller.add(_activities);
  }

  /// Get activities for a specific session.
  Future<List<ActivityLog>> getActivitiesForSession(String sessionId) async {
    try {
      final db = PersistenceInitializer.persistenceManager!.sqliteManager;
      final results = await db.query(
        'activity_logs',
        where: 'session_id = ?',
        whereArgs: [sessionId],
        orderBy: 'timestamp DESC',
      );

      return results.map((row) => ActivityLog(
        id: row['id'] as String,
        sessionId: (row['session_id'] ?? '') as String,
        timestamp: DateTime.parse(row['timestamp'] as String),
        type: ActivityType.values.firstWhere(
          (e) => e.toString() == 'ActivityType.${row['type']}',
          orElse: () => ActivityType.sale,
        ),
        description: row['description'] as String,
        userName: row['user_name'] as String,
        details: row['details'] != null 
            ? jsonDecode(row['details'] as String) 
            : null,
      )).toList();
    } catch (e) {
      print('Failed to load session activities: $e');
      return [];
    }
  }

  /// Get activities filtered by type.
  Future<List<ActivityLog>> getActivitiesByType(ActivityType type, {int limit = 50}) async {
    try {
      final db = PersistenceInitializer.persistenceManager!.sqliteManager;
      final results = await db.query(
        'activity_logs',
        where: 'type = ?',
        whereArgs: [type.toString().split('.').last],
        orderBy: 'timestamp DESC',
        limit: limit,
      );

      return results.map((row) => ActivityLog(
        id: row['id'] as String,
        sessionId: (row['session_id'] ?? '') as String,
        timestamp: DateTime.parse(row['timestamp'] as String),
        type: ActivityType.values.firstWhere(
          (e) => e.toString() == 'ActivityType.${row['type']}',
          orElse: () => ActivityType.sale,
        ),
        description: row['description'] as String,
        userName: row['user_name'] as String,
        details: row['details'] != null 
            ? jsonDecode(row['details'] as String) 
            : null,
      )).toList();
    } catch (e) {
      print('Failed to load activities by type: $e');
      return [];
    }
  }

  List<ActivityLog> getRecentActivities({int limit = 20}) {
    return _activities.take(limit).toList();
  }

  /// Get activities grouped by session, ordered so that within each session:
  /// - sessionOpen comes first (top)
  /// - operations in chronological order
  /// - sessionClose comes last (bottom)
  Future<List<SessionActivityGroup>> getActivitiesGroupedBySession({int sessionLimit = 5}) async {
    try {
      final db = PersistenceInitializer.persistenceManager!.sqliteManager;
      
      // Get distinct session IDs from recent activities (most recent sessions first)
      final sessionRows = await db.query(
        'activity_logs',
        columns: ['DISTINCT session_id'],
        where: "session_id IS NOT NULL AND session_id != ''",
        orderBy: 'timestamp DESC',
        limit: sessionLimit * 10, // Oversample to get enough unique sessions
      );

      // Deduplicate and take the requested limit
      final sessionIds = <String>[];
      for (final row in sessionRows) {
        final sid = row['session_id'] as String?;
        if (sid != null && sid.isNotEmpty && !sessionIds.contains(sid)) {
          sessionIds.add(sid);
          if (sessionIds.length >= sessionLimit) break;
        }
      }

      final groups = <SessionActivityGroup>[];

      for (final sessionId in sessionIds) {
        // Get all activities for this session, chronological order (ASC)
        final activityRows = await db.query(
          'activity_logs',
          where: 'session_id = ?',
          whereArgs: [sessionId],
          orderBy: 'timestamp ASC',
        );

        final activities = activityRows.map((row) => ActivityLog(
          id: row['id'] as String,
          sessionId: (row['session_id'] ?? '') as String,
          timestamp: DateTime.parse(row['timestamp'] as String),
          type: ActivityType.values.firstWhere(
            (e) => e.toString() == 'ActivityType.${row['type']}',
            orElse: () => ActivityType.sale,
          ),
          description: row['description'] as String,
          userName: row['user_name'] as String,
          details: row['details'] != null
              ? jsonDecode(row['details'] as String)
              : null,
        )).toList();

        if (activities.isEmpty) continue;

        // Sort: sessionOpen first, sessionClose last, rest by timestamp
        activities.sort((a, b) {
          if (a.type == ActivityType.sessionOpen) return -1;
          if (b.type == ActivityType.sessionOpen) return 1;
          if (a.type == ActivityType.sessionClose) return 1;
          if (b.type == ActivityType.sessionClose) return -1;
          return a.timestamp.compareTo(b.timestamp);
        });

        // Get session info from shifts table
        DateTime? openTime;
        DateTime? closeTime;
        String? openedBy;
        bool isOpen = true;
        try {
          final shiftRows = await db.query(
            'shifts',
            where: 'id = ?',
            whereArgs: [sessionId],
          );
          if (shiftRows.isNotEmpty) {
            final shift = shiftRows.first;
            openTime = DateTime.parse(shift['open_time'] as String);
            closeTime = shift['close_time'] != null
                ? DateTime.parse(shift['close_time'] as String)
                : null;
            openedBy = shift['user_id'] as String?;
            isOpen = (shift['is_open'] as int) == 1;
          }
        } catch (_) {}

        groups.add(SessionActivityGroup(
          sessionId: sessionId,
          activities: activities,
          openTime: openTime ?? activities.first.timestamp,
          closeTime: closeTime,
          openedBy: openedBy ?? activities.first.userName,
          isOpen: isOpen,
        ));
      }

      // Sort groups so the most recent (or currently open) session is first
      groups.sort((a, b) {
        if (a.isOpen && !b.isOpen) return -1;
        if (!a.isOpen && b.isOpen) return 1;
        return b.openTime.compareTo(a.openTime);
      });

      return groups;
    } catch (e) {
      print('Failed to get grouped activities: $e');
      return [];
    }
  }

  /// Formats activity details into a human-readable Arabic string.
  static String formatDetailsArabic(ActivityType type, Map<String, dynamic>? details) {
    if (details == null || details.isEmpty) return '';

    try {
      final parts = <String>[];

      switch (type) {
        case ActivityType.sale:
        case ActivityType.refund:
          if (details['items'] != null && details['items'] is List) {
            parts.add('الأصناف: ${(details['items'] as List).join('، ')}');
          } else if (details['refundedItems'] != null && details['refundedItems'] is List) {
            parts.add('الأصناف: ${(details['refundedItems'] as List).join('، ')}');
          }
          if (details['total'] != null) {
            parts.add('الإجمالي: ${details['total']} ج.م');
          }
          break;

        case ActivityType.productUpdate:
        case ActivityType.productQuantityUpdate:
          if (details['name'] != null) parts.add('المنتج: ${details['name']}');
          if (details['oldQty'] != null && details['newQty'] != null) {
            parts.add('الكمية: ${details['oldQty']} ← ${details['newQty']}');
          }
          if (details['oldPrice'] != null && details['newPrice'] != null) {
            parts.add('السعر: ${details['oldPrice']} ← ${details['newPrice']}');
          }
          break;

        case ActivityType.restock:
          if (details['productName'] != null) parts.add('المنتج: ${details['productName']}');
          if (details['addedQty'] != null) parts.add('الكمية المضافة: ${details['addedQty']}');
          break;

        case ActivityType.expense:
          if (details['category'] != null) parts.add('الفئة: ${details['category']}');
          if (details['amount'] != null) parts.add('المبلغ: ${details['amount']} ج.م');
          break;

        case ActivityType.userAdd:
        case ActivityType.userUpdate:
        case ActivityType.userDelete:
          if (details['targetUser'] != null) parts.add('المستخدم: ${details['targetUser']}');
          if (details['role'] != null) parts.add('الصلاحية: ${details['role']}');
          break;

        default:
          // Fallback: join all keys and values
          details.forEach((key, value) {
            if (value != null && value.toString().isNotEmpty) {
              parts.add('$key: $value');
            }
          });
      }

      return parts.join(' • ');
    } catch (e) {
      return details.toString();
    }
  }

  void dispose() {
    _controller.close();
  }
}

/// A group of activity logs belonging to a single session.
class SessionActivityGroup {
  final String sessionId;
  final List<ActivityLog> activities;
  final DateTime openTime;
  final DateTime? closeTime;
  final String openedBy;
  final bool isOpen;

  SessionActivityGroup({
    required this.sessionId,
    required this.activities,
    required this.openTime,
    this.closeTime,
    required this.openedBy,
    required this.isOpen,
  });
}
