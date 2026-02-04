// sale_model.dart

// Removed Hive dependencies

class Sale {
  final String id;
  final double total;
  final int items;
  final DateTime date;
  final List<SaleItem> saleItems;
  final String? cashierName; // NEW: Who made the sale
  final String? cashierUsername; // NEW: Username for reference
  final String? sessionId;
  final int invoiceTypeIndex; // 0: Sale, 1: Refund
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'total': total,
      'items': items,
      'date': date.toIso8601String(),
      'cashierName': cashierName,
      'cashierUsername': cashierUsername,
      'sessionId': sessionId,
      'invoiceTypeIndex': invoiceTypeIndex,
      'refundOriginalInvoiceId': refundOriginalInvoiceId,
      'saleItems': saleItems.map((x) => x.toMap()).toList(),
    };
  }
}

class SaleItem {
  final String productId;
  final String name;
  final double price;
  final int quantity;
  final double total;
  final double wholesalePrice;
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

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'total': total,
      'wholesalePrice': wholesalePrice,
      'refundedQuantity': refundedQuantity,
    };
  }
}
