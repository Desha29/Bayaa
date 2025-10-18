import 'package:hive_flutter/adapters.dart';

part 'sale_model.g.dart';

@HiveType(typeId: 5)
class Sale extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double total;

  @HiveField(2)
  final int items;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final List<SaleItem> saleItems;

  Sale({
    required this.id,
    required this.total,
    required this.items,
    required this.date,
    required this.saleItems,
  });
}

@HiveType(typeId: 6)
class SaleItem {
  @HiveField(0)
  final String productId;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double price;

  @HiveField(3)
  final int quantity;

  @HiveField(4)
  final double total;

  SaleItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.total,
  });
}
