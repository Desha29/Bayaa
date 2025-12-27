class ProductSalesDetail {
  final String productName;
  final String barcode;
  final int soldQuantity;
  final int refundedQuantity;
  final int netSoldQuantity;

  ProductSalesDetail({
    required this.productName,
    required this.barcode,
    required this.soldQuantity,
    required this.refundedQuantity,
  }) : netSoldQuantity = soldQuantity - refundedQuantity;
}
