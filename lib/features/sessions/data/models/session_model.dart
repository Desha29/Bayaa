

enum SessionStatus { open, closed }

class Session {
  final String id;
  final DateTime openTime;
  DateTime? closeTime;
  SessionStatus status;
  final String openedByUserId;
  String? closedByUserId;
  final List<String> invoiceIds; 
  String? dailyReportId; 

  Session({
    required this.id,
    required this.openTime,
    this.closeTime,
    bool isOpen = true,
    SessionStatus? status,
    required this.openedByUserId,
    this.closedByUserId,
    List<String>? invoiceIds,
    this.dailyReportId,
  }) : status = status ?? (isOpen ? SessionStatus.open : SessionStatus.closed),
       invoiceIds = invoiceIds ?? [];

  /// Backward-compatible getter.
  bool get isOpen => status == SessionStatus.open;

  /// Backward-compatible setter.
  set isOpen(bool value) {
    status = value ? SessionStatus.open : SessionStatus.closed;
  }

  factory Session.fromMap(Map<String, dynamic> row) {
    return Session(
      id: row['id'] as String,
      openTime: DateTime.parse(row['open_time'] as String),
      openedByUserId: row['user_id'] as String,
      isOpen: (row['is_open'] as int) == 1,
      closeTime: row['close_time'] != null ? DateTime.parse(row['close_time'] as String) : null,
      closedByUserId: row['closed_by'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'openTime': openTime.toIso8601String(),
      'closeTime': closeTime?.toIso8601String(),
      'isOpen': isOpen,
      'status': status.name,
      'openedByUserId': openedByUserId,
      'closedByUserId': closedByUserId,
      'invoiceIds': invoiceIds,
      'dailyReportId': dailyReportId,
    };
  }
}
