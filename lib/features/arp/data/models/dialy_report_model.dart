
import 'product_performance_model.dart';

class DailyReportModel {
  final DateTime date;
  final double totalRevenue;
  final double totalCost;
  final double totalProfit;
  final double profitMargin;
  final List<ProductPerformanceModel> topProducts;

  DailyReportModel({
    required this.date,
    required this.totalRevenue,
    required this.totalCost,
    required this.totalProfit,
    required this.profitMargin,
    required this.topProducts,
  });
}
