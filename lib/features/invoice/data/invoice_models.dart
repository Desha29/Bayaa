// lib/features/invoice/data/invoice_models.dart
import 'package:flutter/foundation.dart';

class InvoiceLine {
  final String name;
  final String barcode;
  final double price;
  final int qty;
  final double total;

  const InvoiceLine({
    required this.name,
    required this.barcode,
    required this.price,
    required this.qty,
  }) : total = price * qty;
}

class InvoiceData {
  final String invoiceId;
  final DateTime date;
  final String storeName;
  final String storeAddress;
  final String storePhone;
  final String cashierName;
  final List<InvoiceLine> lines;
  final double subtotal;
  final double discount;
  final double tax;
  final double grandTotal;
  final String? footerNote;
  final String? logoAsset; 
  final Uint8List? logoBytes; 

  const InvoiceData({
    required this.invoiceId,
    required this.date,
    required this.storeName,
    required this.storeAddress,
    required this.storePhone,
    required this.cashierName,
    required this.lines,
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.grandTotal,
    this.footerNote,
    this.logoAsset,
    this.logoBytes,
  });
}
