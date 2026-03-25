

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

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'quantitySold': quantitySold,
      'revenue': revenue,
      'cost': cost,
      'profit': profit,
      'profitMargin': profitMargin,
    };
  }

  ProductPerformanceModel copyWith({
    String? productId,
    String? productName,
    int? quantitySold,
    double? revenue,
    double? cost,
    double? profit,
    double? profitMargin,
  }) {
    return ProductPerformanceModel(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantitySold: quantitySold ?? this.quantitySold,
      revenue: revenue ?? this.revenue,
      cost: cost ?? this.cost,
      profit: profit ?? this.profit,
      profitMargin: profitMargin ?? this.profitMargin,
    );
  }
}
