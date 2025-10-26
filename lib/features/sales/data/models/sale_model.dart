// sale_model.dart
import 'package:hive_flutter/hive_flutter.dart';

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

  @HiveField(5)
  final String? cashierName; // NEW: Who made the sale

  @HiveField(6)
  final String? cashierUsername; // NEW: Username for reference

  Sale({
    required this.id,
    required this.total,
    required this.items,
    required this.date,
    required this.saleItems,
    this.cashierName,
    this.cashierUsername,
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

  @HiveField(5)
  final double wholesalePrice; // Add this field with Hive annotation

  SaleItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.total,
    required this.wholesalePrice, // Add this to constructor
  });
}
