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

  @HiveField(7)
  final String? sessionId;

  @HiveField(8)
  final int invoiceTypeIndex; // 0: Sale, 1: Refund

  @HiveField(9)
  final String? refundOriginalInvoiceId;

  Sale({
    required this.id,
    required this.total,
    required this.items,
    required this.date,
    required this.saleItems,
    required this.cashierName,
    this.cashierUsername,
    this.sessionId,
    this.invoiceTypeIndex = 0,
    this.refundOriginalInvoiceId,
  });

  bool get isRefund => invoiceTypeIndex == 1;
  bool get canBeRefunded => !isRefund;
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
  final double wholesalePrice;

  @HiveField(6)
  int refundedQuantity = 0; // NEW: Track refunded quantity permanently

  SaleItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.total,
    required this.wholesalePrice,
    this.refundedQuantity = 0, // Default to 0
  });
}
