import 'package:crazy_phone_pos/core/data/services/persistence_initializer.dart';
import 'package:crazy_phone_pos/core/data/services/repository_persistence_mixin.dart';
import 'package:crazy_phone_pos/features/arp/data/models/daily_report_model.dart';
import 'package:crazy_phone_pos/features/arp/data/models/session_model.dart';
import 'package:crazy_phone_pos/features/auth/data/models/user_model.dart';
import 'package:crazy_phone_pos/features/sales/data/models/sale_model.dart';
import '../models/product_performance_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class SessionRepositoryImpl with RepositoryPersistenceMixin {
  // Removed Hive boxes

  /// Returns the currently active session, or null if none exists.
  /// Modified to logic: query SQLite asynchronously? 
  /// The interface implies synchronous return (Session?), but SQLite is async.
  /// However, this method signature `Session? getCurrentSession()` is synchronous.
  /// This is a problem if relying on async SQLite.
  /// 
  /// OPTIONS:
  /// 1. Change signature to Future<Session?> (Breaking change, affects call sites).
  /// 2. Cache current session in memory (singleton).
  /// 
  /// Given "without change structure", I should potentially cache the session in memory 
  /// after load, or if I can't change signature, I MUST block (bad) or cache.
  /// 
  /// Let's assume we can change signature OR use a cached value.
  /// But `getCurrentSession` is likely called by Cubit initialization.
  /// 
  /// Let's look at `SessionModel`. It's a simple Dart object.
  /// 
  /// PROPOSED: Add an async `init()` or `loadCurrentSession()`?
  /// OR checks call sites.
  /// 
  /// If I cannot change signature, I have to rely on an in-memory variable `_currentSession`
  /// that is populated during app initialization.
  /// 
  /// For now, I will change the signature to Future<Session?> if checking call sites is hard.
  /// actually `RepositoryPersistenceMixin` functions are async.
  /// The original code used `_sessionBox.values.firstWhere`, which is sync because Hive loads all in memory.
  /// 
  /// To purely rely on SQLite, I MUST make this async.
  /// "without change structure" might just refer to business logic, but strict typing...
  /// 
  /// I will try to cache the session in `_currentSession` variable.
  Session? _cachedSession;

  Future<void> loadCurrentSession() async {
    try {
      final db = PersistenceInitializer.persistenceManager!.sqliteManager;
      final results = await db.query('shifts', where: 'is_open = 1');
      if (results.isNotEmpty) {
        final row = results.first;
        _cachedSession = Session(
          id: row['id'] as String,
          openTime: DateTime.parse(row['open_time'] as String),
          openedByUserId: row['user_id'] as String,
          isOpen: (row['is_open'] as int) == 1,
          closeTime: row['close_time'] != null ? DateTime.parse(row['close_time'] as String) : null,
          closedByUserId: row['closed_by'] as String?,
        );
      } else {
        _cachedSession = null;
      }
    } catch (e) {
      print('Failed to load session: $e');
    }
  }

  Session? getCurrentSession() {
    return _cachedSession;
  }

  /// Opens a new session if one doesn't exist.
  Future<Session> openSession(User user) async {
    // Refresh cache first? Or trust memory?
    
    if (_cachedSession != null && _cachedSession!.isOpen) {
      return _cachedSession!;
    }

    // Double check DB
    await loadCurrentSession();
    if (_cachedSession != null && _cachedSession!.isOpen) {
      return _cachedSession!;
    }

    final newSession = Session(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      openTime: DateTime.now(),
      openedByUserId: user.username, 
      isOpen: true,
    );

    await writeCritical(
      entity: 'session',
      id: newSession.id,
      data: newSession.toMap(),
      sqliteWrite: () async {
        final db = PersistenceInitializer.persistenceManager!.sqliteManager;
        await db.insert('shifts', {
          'id': newSession.id,
          'user_id': newSession.openedByUserId,
          'open_time': newSession.openTime.toIso8601String(),
          'is_open': 1,
        });
      },
    );
    
    _cachedSession = newSession;
    return newSession;
  }

  /// Closes the current session and generates a DailyReport snapshot.
  Future<DailyReport> closeSession(User user, {
    required double totalSales,
    required double totalRefunds,
    required double netRevenue,
    required int totalTransactions,
    required List<ProductPerformanceModel> topProducts,
    List<ProductPerformanceModel> refundedProducts = const [],
    List<Sale> transactions = const [],
  }) async {
    // Ensure we have current session
    if (_cachedSession == null) {
      await loadCurrentSession();
    }
    
    final session = _cachedSession;
    if (session == null) {
      throw Exception("No open session found to close.");
    }

    final now = DateTime.now();
    final reportId = "${session.id}_REPORT";

    final report = DailyReport(
      id: reportId,
      sessionId: session.id,
      date: now,
      totalSales: totalSales,
      totalRefunds: totalRefunds,
      netRevenue: netRevenue,
      totalTransactions: totalTransactions,
      closedByUserName: user.name,
      topProducts: topProducts,
      refundedProducts: refundedProducts,
      transactions: transactions,
    );

    // Update session object
    session.isOpen = false;
    session.closeTime = now;
    session.closedByUserId = user.username;
    session.dailyReportId = report.id;

    await writeCritical(
      entity: 'report',
      id: report.id,
      data: report.toMap(),
      sqliteWrite: () async {
        final db = PersistenceInitializer.persistenceManager!.sqliteManager;
        
        // Update shift in SQLite
        await db.update('shifts', {
          'close_time': session.closeTime?.toIso8601String(),
          'closed_by': session.closedByUserId,
          'is_open': 0,
        }, where: 'id = ?', whereArgs: [session.id]);
        
        // We don't have a 'daily_reports' table to store the snapshot.
        // The data exists in sales/shifts tables implicitly for history.
      },
    );

    _cachedSession = null; // Clear cache as it's closed
    return report;
  }
  
  /// Get all closed sessions (for history)
  /// Changed to async because pure SQLite is async
  Future<List<Session>> getClosedSessions() async {
    try {
      final db = PersistenceInitializer.persistenceManager!.sqliteManager;
      print('DEBUG: Querying shifts table for closed sessions...');
      
      final results = await db.query('shifts', 
        where: 'is_open = ?',  // Use proper parameter binding
        whereArgs: [0],         // Pass as argument
        orderBy: 'open_time DESC', // Newest first
      );
      
      print('DEBUG: Found ${results.length} closed sessions');
      
      return results.map((row) => Session(
        id: row['id'] as String,
        openTime: DateTime.parse(row['open_time'] as String),
        openedByUserId: row['user_id'] as String,
        isOpen: (row['is_open'] as int) == 1,
        closeTime: row['close_time'] != null ? DateTime.parse(row['close_time'] as String) : null,
        closedByUserId: row['closed_by'] as String?,
      )).toList();
    } catch(e) {
      print('ERROR getting closed sessions: $e');
      return [];
    }
  }

  /// Delete a closed session
  Future<void> deleteSession(Session session) async {
    if (session.isOpen) {
      throw Exception('لا يمكن حذف جلسة ما زالت مفتوحة.');
    }

    await deleteCritical(
      entity: 'session',
      id: session.id,
      sqliteWrite: () async {
        final db = PersistenceInitializer.persistenceManager!.sqliteManager;
        await db.transaction((txn) async {
           // 1. Delete items linked to sales in this session
           await txn.rawDelete(
             'DELETE FROM sale_items WHERE sale_id IN (SELECT id FROM sales WHERE shift_id = ?)', 
             [session.id]
           );
           
           // 2. Delete sales in this session
           await txn.delete('sales', where: 'shift_id = ?', whereArgs: [session.id]);
           
           // 3. Delete the session itself
           await txn.delete('shifts', where: 'id = ?', whereArgs: [session.id]);
        });
      },
    );
  }

  /// Delete all closed sessions whose closeTime is between [start] and [end]
  Future<int> deleteSessionsInRange(DateTime start, DateTime end) async {
    // Fetch IDs first to return count, then delete
    final db = PersistenceInitializer.persistenceManager!.sqliteManager;
    final results = await db.query('shifts',
      columns: ['id'],
      where: 'is_open = 0 AND close_time >= ? AND close_time <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()]
    );
    
    final count = results.length;
    if (count > 0) {
      final ids = results.map((r) => r['id']).toList();
       await deleteCritical(
        entity: 'sessions_range',
        id: 'range_delete',
        sqliteWrite: () async {
           final db = PersistenceInitializer.persistenceManager!.sqliteManager;
           await db.transaction((txn) async {
             final startIso = start.toIso8601String();
             final endIso = end.toIso8601String();
             
             // 1. Delete items linked to sales in these sessions
             await txn.rawDelete('''
                DELETE FROM sale_items 
                WHERE sale_id IN (
                  SELECT id FROM sales 
                  WHERE shift_id IN (
                    SELECT id FROM shifts 
                    WHERE is_open = 0 AND close_time >= ? AND close_time <= ?
                  )
                )
             ''', [startIso, endIso]);
             
             // 2. Delete sales in these sessions
             await txn.rawDelete('''
                DELETE FROM sales 
                WHERE shift_id IN (
                  SELECT id FROM shifts 
                  WHERE is_open = 0 AND close_time >= ? AND close_time <= ?
                )
             ''', [startIso, endIso]);

             // 3. Delete the sessions
             await txn.delete('shifts', 
               where: 'is_open = 0 AND close_time >= ? AND close_time <= ?', 
               whereArgs: [startIso, endIso]
             );
           });
        }
      );
    }
    
    return count;
  }
  /// Get all closed sessions whose closeTime is between [start] and [end]
  Future<List<Session>> getSessionsInRange(DateTime start, DateTime end) async {
    try {
      final db = PersistenceInitializer.persistenceManager!.sqliteManager;
      final results = await db.query('shifts', 
        where: 'is_open = 0 AND close_time >= ? AND close_time <= ?',
        whereArgs: [start.toIso8601String(), end.toIso8601String()],
        orderBy: 'close_time DESC',
      );
      
      return results.map((row) => Session(
        id: row['id'] as String,
        openTime: DateTime.parse(row['open_time'] as String),
        openedByUserId: row['user_id'] as String,
        isOpen: (row['is_open'] as int) == 1,
        closeTime: row['close_time'] != null ? DateTime.parse(row['close_time'] as String) : null,
        closedByUserId: row['closed_by'] as String?,
      )).toList();
    } catch(e) {
      print('Failed to get sessions in range: $e');
      return [];
    }
  }
}

