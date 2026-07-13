import 'dart:async';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../data/models/activity_log.dart';
import '../data/services/persistence_initializer.dart';

import '../localization/translation_helper.dart';

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
          eventKey: row['event_key'] as String?,
          parameters: row['parameters'] != null
              ? jsonDecode(row['parameters'] as String) as Map<String, dynamic>
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
    String? eventKey,
    Map<String, dynamic>? parameters,
  }) async {
    final activity = ActivityLog(
      id: _uuid.v4(),
      sessionId: sessionId,
      timestamp: DateTime.now(),
      type: type,
      description: description,
      userName: userName,
      details: details,
      eventKey: eventKey,
      parameters: parameters,
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
        'details':
            activity.details != null ? jsonEncode(activity.details) : null,
        'event_key': activity.eventKey,
        'parameters': activity.parameters != null
            ? jsonEncode(activity.parameters)
            : null,
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

      return results
          .map((row) => ActivityLog(
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
                eventKey: row['event_key'] as String?,
                parameters: row['parameters'] != null
                    ? jsonDecode(row['parameters'] as String)
                        as Map<String, dynamic>
                    : null,
              ))
          .toList();
    } catch (e) {
      print('Failed to load session activities: $e');
      return [];
    }
  }

  /// Get activities filtered by type.
  Future<List<ActivityLog>> getActivitiesByType(ActivityType type,
      {int limit = 50}) async {
    try {
      final db = PersistenceInitializer.persistenceManager!.sqliteManager;
      final results = await db.query(
        'activity_logs',
        where: 'type = ?',
        whereArgs: [type.toString().split('.').last],
        orderBy: 'timestamp DESC',
        limit: limit,
      );

      return results
          .map((row) => ActivityLog(
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
                eventKey: row['event_key'] as String?,
                parameters: row['parameters'] != null
                    ? jsonDecode(row['parameters'] as String)
                        as Map<String, dynamic>
                    : null,
              ))
          .toList();
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
  Future<List<SessionActivityGroup>> getActivitiesGroupedBySession(
      {int sessionLimit = 5}) async {
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

        final activities = activityRows
            .map((row) => ActivityLog(
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
                  eventKey: row['event_key'] as String?,
                  parameters: row['parameters'] != null
                      ? jsonDecode(row['parameters'] as String)
                          as Map<String, dynamic>
                      : null,
                ))
            .toList();

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

  /// Formats activity details into a human-readable localized string.
  static String formatDetails(
      BuildContext context, ActivityType type, Map<String, dynamic>? details) {
    if (details == null || details.isEmpty) return '';

    try {
      final l10n = AppLocalizations.of(context);
      final parts = <String>[];

      switch (type) {
        case ActivityType.sale:
        case ActivityType.refund:
          if (details['items'] != null && details['items'] is List) {
            parts.add(l10n.detailsItems((details['items'] as List).join('، ')));
          } else if (details['refundedItems'] != null &&
              details['refundedItems'] is List) {
            parts.add(l10n
                .detailsItems((details['refundedItems'] as List).join('، ')));
          }
          if (details['total'] != null) {
            parts.add(l10n.detailsTotal(
                details['total'].toString(), l10n.currencyEg));
          }
          break;

        case ActivityType.productUpdate:
        case ActivityType.productQuantityUpdate:
          if (details['name'] != null)
            parts.add(l10n.detailsProduct(details['name'].toString()));
          if (details['oldQty'] != null && details['newQty'] != null) {
            parts.add(l10n.detailsQty(
                details['oldQty'].toString(), details['newQty'].toString()));
          }
          if (details['oldPrice'] != null && details['newPrice'] != null) {
            parts.add(l10n.detailsPrice(details['oldPrice'].toString(),
                details['newPrice'].toString()));
          }
          break;

        case ActivityType.restock:
          if (details['productName'] != null)
            parts.add(l10n.detailsProduct(details['productName'].toString()));
          if (details['addedQty'] != null)
            parts.add(l10n.detailsAddedQty(details['addedQty'].toString()));
          break;

        case ActivityType.expense:
          if (details['category'] != null)
            parts.add(l10n.detailsCategory(details['category'].toString()));
          if (details['amount'] != null) {
            parts.add(l10n.detailsAmount(
                details['amount'].toString(), l10n.currencyEg));
          }
          break;

        case ActivityType.userAdd:
        case ActivityType.userUpdate:
        case ActivityType.userDelete:
          if (details['targetUser'] != null)
            parts.add(l10n.detailsUser(details['targetUser'].toString()));
          if (details['role'] != null)
            parts.add(l10n.detailsRole(details['role'].toString()));
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

  static String formatActivity(BuildContext context, ActivityLog activity) {
    if (activity.eventKey == null || activity.eventKey!.isEmpty) {
      return _translateLegacyDescription(context, activity);
    }

    final l10n = AppLocalizations.of(context);
    final params = activity.parameters ?? {};
    final rawUser = params['user']?.toString() ?? '';
    final user = TranslationHelper.translateUserName(context, rawUser);
    final product = params['product']?.toString() ?? '';
    final qty = params['qty']?.toString() ?? '';
    final total = params['total']?.toString() ?? '';
    final rawTargetUser = params['targetUser']?.toString() ?? '';
    final targetUser =
        TranslationHelper.translateUserName(context, rawTargetUser);
    final id = params['id']?.toString() ?? '';

    switch (activity.eventKey) {
      case 'sessionOpened':
        return l10n.activitySessionOpened(user);
      case 'sessionClosed':
        return l10n.activitySessionClosed(user);
      case 'login':
        return l10n.activityLogin(user);
      case 'productAdded':
        return l10n.activityProductAdded(user, product);
      case 'productUpdated':
        return l10n.activityProductUpdated(user, product);
      case 'productDeleted':
        return l10n.activityProductDeleted(user, product);
      case 'productQtyUpdated':
        return l10n.activityProductQtyUpdated(user, product, qty);
      case 'restock':
        return l10n.activityRestock(user, product, qty);
      case 'saleCompleted':
        return l10n.activitySaleCompleted(user, total);
      case 'refundCompleted':
        return l10n.activityRefundCompleted(user, total);
      case 'userAdded':
        return l10n.activityUserAdded(user, targetUser);
      case 'userUpdated':
        return l10n.activityUserUpdated(user, targetUser);
      case 'userDeleted':
        return l10n.activityUserDeleted(user, targetUser);
      case 'invoiceDeleted':
        return l10n.activityInvoiceDeleted(user, id);
      default:
        return activity.description;
    }
  }

  static String _translateLegacyDescription(
      BuildContext context, ActivityLog activity) {
    final l10n = AppLocalizations.of(context);
    final desc = activity.description;
    final user =
        TranslationHelper.translateUserName(context, activity.userName);

    if (desc.startsWith('فتح يوم')) return l10n.activitySessionOpened(user);
    if (desc.startsWith('إغلاق يوم') || desc.contains('إغلاق يوم'))
      return l10n.activitySessionClosed(user);
    if (desc == 'تسجيل دخول' || desc.startsWith('تسجيل دخول'))
      return l10n.activityLogin(user);
    if (desc.startsWith('إضافة منتج')) {
      final name = desc.replaceFirst('إضافة منتج: ', '');
      return l10n.activityProductAdded(user, name);
    }
    if (desc.startsWith('تحديث منتج')) {
      final name = desc.replaceFirst('تحديث منتج: ', '');
      return l10n.activityProductUpdated(user, name);
    }
    if (desc.startsWith('حذف منتج')) {
      final name = desc.replaceFirst('حذف منتج: ', '');
      return l10n.activityProductDeleted(user, name);
    }
    if (desc.startsWith('عملية بيع')) {
      final total = RegExp(r'[\d.]+').firstMatch(desc)?.group(0) ?? '';
      return l10n.activitySaleCompleted(user, total);
    }
    if (desc.startsWith('استرجاع')) {
      final total = RegExp(r'[\d.]+').firstMatch(desc)?.group(0) ?? '';
      return l10n.activityRefundCompleted(user, total);
    }
    if (desc.startsWith('إضافة مستخدم')) {
      final name = desc.replaceFirst('إضافة مستخدم: ', '');
      return l10n.activityUserAdded(user, name);
    }
    if (desc.startsWith('تحديث مستخدم')) {
      final name = desc.replaceFirst('تحديث مستخدم: ', '');
      return l10n.activityUserUpdated(user, name);
    }
    if (desc.startsWith('حذف مستخدم')) {
      final name = desc.replaceFirst('حذف مستخدم: ', '');
      return l10n.activityUserDeleted(user, name);
    }
    if (desc.startsWith('حذف فاتورة'))
      return l10n.activityInvoiceDeleted(user, '');
    if (desc.startsWith('تحديث مخزون')) {
      final name = desc.replaceFirst('تحديث مخزون: ', '').split(' ').first;
      return l10n.activityProductQtyUpdated(user, name, '');
    }
    if (desc.startsWith('تحديث معلومات المتجر'))
      return l10n.activityUserUpdated(user, 'store info');

    return desc;
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
