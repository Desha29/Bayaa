import '../../../../features/sales/data/models/sale_model.dart';
import 'product_performance_model.dart';


class DailyReport {
  final String id;
  final String sessionId;
  final DateTime date;
  final double totalSales;
  final double totalRefunds;
  final double netRevenue;
  final int totalTransactions;
  final String closedByUserName;
  final List<ProductPerformanceModel> topProducts;
  final List<ProductPerformanceModel> refundedProducts;
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sessionId': sessionId,
      'date': date.toIso8601String(),
      'totalSales': totalSales,
      'totalRefunds': totalRefunds,
      'netRevenue': netRevenue,
      'totalTransactions': totalTransactions,
      'closedByUserName': closedByUserName,
      'topProducts': topProducts.map((p) => p.toMap()).toList(),
      'refundedProducts': refundedProducts.map((p) => p.toMap()).toList(),
      'transactionIds': transactions.map((t) => t.id).toList(),
    };
  }
}
