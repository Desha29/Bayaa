import 'package:hive/hive.dart';

part 'product_performance_model.g.dart';

@HiveType(typeId: 9)
class ProductPerformanceModel extends HiveObject {
  @HiveField(0)
  final String productId;
  @HiveField(1)
  final String productName;
  @HiveField(2)
  final int quantitySold;
  @HiveField(3)
  final double revenue;
  @HiveField(4)
  final double cost;
  @HiveField(5)
  final double profit;
  @HiveField(6)
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

