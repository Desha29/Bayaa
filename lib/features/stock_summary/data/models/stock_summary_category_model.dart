import 'product_sales_detail.dart';

class StockSummaryCategoryModel {
  final String categoryName;
  final int productCount;
  final int totalQuantity;
  final int totalSoldQuantity; 
  final double totalHistoricValue;
  final double totalCurrentWholesaleValue;
  final double totalMinSellValue;
  final double totalDefaultSellValue;
  final bool isDeletedCategory;
  final List<ProductSalesDetail> productDetails; 

  StockSummaryCategoryModel({
    required this.categoryName,
    required this.productCount,
    required this.totalQuantity,
    required this.totalSoldQuantity,
    required this.totalHistoricValue,
    required this.totalCurrentWholesaleValue,
    required this.totalMinSellValue,
    required this.totalDefaultSellValue,
    this.isDeletedCategory = false,
    this.productDetails = const [],
  });

  double get expectedProfit => totalDefaultSellValue - totalCurrentWholesaleValue;
  double get minPossibleProfit => totalMinSellValue - totalCurrentWholesaleValue;
  double get profitMarginPercent => totalCurrentWholesaleValue == 0
      ? 0
      : (expectedProfit / totalCurrentWholesaleValue) * 100;
}
