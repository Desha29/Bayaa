// lib/features/arp/data/models/arp_summary_model.dart
import 'package:hive/hive.dart';

part 'arp_summary_model.g.dart';

@HiveType(typeId: 4)
class ArpSummaryModel {
  @HiveField(0)
  final double totalRevenue;

  @HiveField(1)
  final double totalCost;

  @HiveField(2)
  final double totalProfit;

  @HiveField(3)
  final double profitMargin;

  @HiveField(4)
  final int totalSales;

  @HiveField(5)
  final DateTime startDate;

  @HiveField(6)
  final DateTime endDate;

  ArpSummaryModel({
    required this.totalRevenue,
    required this.totalCost,
    required this.totalProfit,
    required this.profitMargin,
    required this.totalSales,
    required this.startDate,
    required this.endDate,
  });

  double get loss => totalProfit < 0 ? totalProfit.abs() : 0;
  bool get isProfitable => totalProfit >= 0;
  double get averageSaleValue => totalSales > 0 ? totalRevenue / totalSales : 0;
}

// lib/features/arp/data/models/product_performance_model.dart
class ProductPerformanceModel {
  final String productId;
  final String productName;
  final int quantitySold;
  final double revenue;
  final double cost;
  final double profit;
  final double profitMargin;

  ProductPerformanceModel({
    required this.productId,
    required this.productName,
    required this.quantitySold,
    required this.revenue,
    required this.cost,
    required this.profit,
    required this.profitMargin,
  });
}
