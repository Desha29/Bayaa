import 'package:hive/hive.dart';

part 'session_model.g.dart';

@HiveType(typeId: 7)
class Session extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime openTime;

  @HiveField(2)
  DateTime? closeTime;

  @HiveField(3)
  bool isOpen;

  @HiveField(4)
  final String openedByUserId;

  @HiveField(5)
  String? closedByUserId;

  @HiveField(6)
  final List<String> invoiceIds; // Optimization: Link invoices to session

  @HiveField(7)
  String? dailyReportId; // Link to the snapshot report

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
}
