import 'package:hive/hive.dart';
import 'package:crazy_phone_pos/core/utils/hive_helper.dart';
import 'package:crazy_phone_pos/features/arp/data/models/daily_report_model.dart';
import 'package:crazy_phone_pos/features/arp/data/models/session_model.dart';
import 'package:crazy_phone_pos/features/auth/data/models/user_model.dart';

import 'package:crazy_phone_pos/features/sales/data/models/sale_model.dart';

import '../models/product_performance_model.dart';

class SessionRepositoryImpl {
  final Box<Session> _sessionBox = HiveHelper.sessionBox;
  final Box<DailyReport> _reportBox = HiveHelper.dailyReportBox;

  /// Returns the currently active session, or null if none exists.
  Session? getCurrentSession() {
    try {
      return _sessionBox.values.firstWhere((s) => s.isOpen);
    } catch (e) {
      return null;
    }
  }

  /// Opens a new session if one doesn't exist.
  Future<Session> openSession(User user) async {
    final current = getCurrentSession();
    if (current != null) {
      return current;
    }

    final newSession = Session(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      openTime: DateTime.now(),
      openedByUserId: user.username, // Using username as ID for now
      isOpen: true,
    );

    await _sessionBox.put(newSession.id, newSession);
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
    final session = getCurrentSession();
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

    // Save report
    await _reportBox.put(report.id, report);

    // Update session
    session.isOpen = false;
    session.closeTime = now;
    session.closedByUserId = user.username;
    session.dailyReportId = report.id;
    await session.save();

    return report;
  }
  
  /// Get all closed sessions (for history)
   List<Session> getClosedSessions() {
    return _sessionBox.values.where((s) => !s.isOpen).toList();
  }

  /// Delete a closed session and its linked daily report (if any)
  Future<void> deleteSession(Session session) async {
    // Only closed sessions should be deleted via history
    if (session.isOpen) {
      throw Exception('لا يمكن حذف جلسة ما زالت مفتوحة.');
    }

    if (session.dailyReportId != null) {
      await _reportBox.delete(session.dailyReportId);
    }

    await _sessionBox.delete(session.id);
  }

  /// Delete all closed sessions whose closeTime is between [start] and [end] (inclusive)
  Future<int> deleteSessionsInRange(DateTime start, DateTime end) async {
    int deleted = 0;
    for (final session in _sessionBox.values) {
      if (session.isOpen) continue;
      final close = session.closeTime;
      if (close == null) continue;
      if (close.isBefore(start) || close.isAfter(end)) continue;

      if (session.dailyReportId != null) {
        await _reportBox.delete(session.dailyReportId);
      }
      await _sessionBox.delete(session.id);
      deleted++;
    }
    return deleted;
  }
}
