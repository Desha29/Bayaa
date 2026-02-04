

class Session {
  final String id;
  final DateTime openTime;
  DateTime? closeTime;
  bool isOpen;
  final String openedByUserId;
  String? closedByUserId;
  final List<String> invoiceIds; 
  String? dailyReportId; 

  Session({
    required this.id,
    required this.openTime,
    this.closeTime,
    this.isOpen = true,
    required this.openedByUserId,
    this.closedByUserId,
    List<String>? invoiceIds,
    this.dailyReportId,
  }) : invoiceIds = invoiceIds ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'openTime': openTime.toIso8601String(),
      'closeTime': closeTime?.toIso8601String(),
      'isOpen': isOpen,
      'openedByUserId': openedByUserId,
      'closedByUserId': closedByUserId,
      'invoiceIds': invoiceIds,
      'dailyReportId': dailyReportId,
    };
  }
}
