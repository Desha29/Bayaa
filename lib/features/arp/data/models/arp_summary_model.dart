

class ArpSummaryModel {
  final double totalRevenue;
  final double totalCost;
  final double totalProfit;
  final double profitMargin;
  final int totalSales;
  final DateTime startDate;
  final DateTime endDate;

  ArpSummaryModel({
    required this.totalRevenue,
    required this.totalCost,
    required this.totalProfit,
    required this.profitMargin,
    required this.totalSales,
    required this.startDate,
    required this.endDate,
    this.grossRevenue = 0.0,
    this.refundedAmount = 0.0,
  });
  
  final double? grossRevenue;
  final double? refundedAmount;

  double get loss => totalProfit < 0 ? totalProfit.abs() : 0;
  bool get isProfitable => totalProfit >= 0;
  double get averageSaleValue => totalSales > 0 ? totalRevenue / totalSales : 0;
}
