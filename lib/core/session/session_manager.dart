import 'dart:async';
import 'package:uuid/uuid.dart';
import '../../features/sessions/data/models/session_model.dart';
import '../../features/sessions/data/models/daily_report_model.dart';
import '../../features/sessions/data/repositories/session_repository_impl.dart';
import '../../features/auth/data/models/user_model.dart';
import '../services/activity_logger.dart';
import '../data/models/activity_log.dart';
import '../di/dependency_injection.dart';

/// Production-grade session manager with automatic session creation.
///
/// Guarantees that every operation in the system has an active session.
/// If no session is open, one is created automatically before the operation proceeds.
class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  final _uuid = const Uuid();

  SessionRepositoryImpl? _sessionRepo;
  Completer<Session>? _pendingCreate;

  /// Initialize with the session repository (called from DI setup).
  void initialize(SessionRepositoryImpl repo) {
    _sessionRepo = repo;
  }

  SessionRepositoryImpl get _repo {
    if (_sessionRepo == null) {
      throw StateError('SessionManager not initialized. Call initialize() first.');
    }
    return _sessionRepo!;
  }

  /// Returns the current open session ID, or null if no session is open.
  String? get currentSessionId => _repo.getCurrentSession()?.id;

  /// Returns the current open session, or null if no session is open.
  Session? get currentSession => _repo.getCurrentSession();

  /// Core method: ensures an open session exists before any operation.
  ///
  /// - If an open session exists → returns it.
  /// - If no open session exists → creates one automatically.
  /// - Thread-safe: concurrent calls will wait for the same session creation.
  Future<Session> getOrCreateSession({String? userName}) async {
    print('DEBUG_SESSION: SessionManager.getOrCreateSession called');
    // Fast path: session already open in cache
    final existing = _repo.getCurrentSession();
    if (existing != null && existing.isOpen) {
      return existing;
    }

    // Prevent concurrent session creation
    if (_pendingCreate != null && !_pendingCreate!.isCompleted) {
      return _pendingCreate!.future;
    }

    _pendingCreate = Completer<Session>();

    try {
      // Double-check from DB
      await _repo.loadCurrentSession();
      final dbSession = _repo.getCurrentSession();
      if (dbSession != null && dbSession.isOpen) {
        _pendingCreate!.complete(dbSession);
        return dbSession;
      }

      // Auto-create a new session
      final autoUser = User(
        username: userName ?? 'system',
        password: '',
        name: userName ?? 'النظام',
        userType: UserType.cashier,
        phone: '',
      );

      final newSession = await _repo.openSession(autoUser);

      // Log the session open activity
      try {
        final logger = getIt<ActivityLogger>();
        await logger.logActivity(
          type: ActivityType.sessionOpen,
          description: 'فتح يوم جديد — ${autoUser.name}',
          userName: autoUser.name,
          sessionId: newSession.id,
        );
      } catch (e) {
        print('Warning: Failed to log auto-session creation: $e');
      }

      _pendingCreate!.complete(newSession);
      return newSession;
    } catch (e) {
      _pendingCreate!.completeError(e);
      _pendingCreate = null;
      rethrow;
    }
  }

  /// Returns a valid session ID, auto-creating a session if none is open.
  /// Use this instead of `currentSessionId ?? ''` to guarantee session tracking.
  Future<String> ensureSessionId({String? userName}) async {
    final session = await getOrCreateSession(userName: userName);
    return session.id;
  }

  /// Opens a session for a specific user (e.g., on login).
  Future<Session> openSession(User user) async {
    final session = await _repo.openSession(user);
    return session;
  }

  /// Closes the current session.
  ///
  /// After closing:
  /// - session status becomes closed
  /// - cached session is cleared
  /// - next operation will auto-create a new session via [getOrCreateSession]
  Future<DailyReport> closeCurrentSession(User user, {
    required double totalSales,
    required double totalRefunds,
    required double netRevenue,
    required int totalTransactions,
    required List topProducts,
    List refundedProducts = const [],
    List transactions = const [],
  }) async {
    final report = await _repo.closeSession(
      user,
      totalSales: totalSales,
      totalRefunds: totalRefunds,
      netRevenue: netRevenue,
      totalTransactions: totalTransactions,
      topProducts: topProducts.cast(),
      refundedProducts: refundedProducts.cast(),
      transactions: transactions.cast(),
    );
    
    // Reset pending completer so next getOrCreateSession creates fresh
    _pendingCreate = null;
    
    return report;
  }

  /// Returns true if the current session has been open for more than 24 hours.
  bool get isSessionStale {
    final session = currentSession;
    if (session == null || !session.isOpen) return false;
    return DateTime.now().difference(session.openTime).inHours >= 24;
  }

  /// Returns how long the current session has been open, or null if no session.
  Duration? get sessionAge {
    final session = currentSession;
    if (session == null || !session.isOpen) return null;
    return DateTime.now().difference(session.openTime);
  }

  /// Ensures session is loaded from DB on app startup.
  Future<void> loadSession() async {
    await _repo.loadCurrentSession();
  }
}
