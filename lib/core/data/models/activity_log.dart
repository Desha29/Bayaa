enum ActivityType {
  sale,
  refund,
  productAdd,
  productUpdate,
  productDelete,
  productQuantityUpdate,
  restock,
  userAdd,
  userUpdate,
  userDelete,
  sessionOpen,
  sessionClose,
  expense,
  invoiceDelete,
  printReport,
  login,
}

class ActivityLog {
  final String id;
  final String sessionId;
  final DateTime timestamp;
  final ActivityType type;
  final String description;
  final String userName;
  final Map<String, dynamic>? details;

  ActivityLog({
    required this.id,
    required this.sessionId,
    required this.timestamp,
    required this.type,
    required this.description,
    required this.userName,
    this.details,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      id: json['id'] as String,
      sessionId: (json['session_id'] ?? json['sessionId'] ?? '') as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: ActivityType.values.firstWhere(
        (e) => e.toString() == 'ActivityType.${json['type']}',
        orElse: () => ActivityType.sale,
      ),
      description: json['description'] as String,
      userName: (json['user_name'] ?? json['userName'] ?? '') as String,
      details: json['details'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session_id': sessionId,
      'timestamp': timestamp.toIso8601String(),
      'type': type.toString().split('.').last,
      'description': description,
      'userName': userName,
      'details': details,
    };
  }
}
