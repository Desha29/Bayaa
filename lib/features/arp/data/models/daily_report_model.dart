import 'package:hive/hive.dart';
import '../../../../features/sales/data/models/sale_model.dart';
import 'product_performance_model.dart';

part 'daily_report_model.g.dart';

@HiveType(typeId: 8)
class DailyReport extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String sessionId;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final double totalSales;

  @HiveField(4)
  final double totalRefunds;

  @HiveField(5)
  final double netRevenue;

  @HiveField(6)
  final int totalTransactions;

  @HiveField(7)
  final String closedByUserName;

  @HiveField(8)
  final List<ProductPerformanceModel> topProducts;

  @HiveField(9)
  final List<ProductPerformanceModel> refundedProducts;

  @HiveField(10)
  final List<Sale> transactions;

  DailyReport({
    required this.id,
    required this.sessionId,
    required this.date,
    required this.totalSales,
    required this.totalRefunds,
    required this.netRevenue,
    required this.totalTransactions,
    required this.closedByUserName,
    required this.topProducts,
    this.refundedProducts = const [],
    this.transactions = const [],
  });
}
