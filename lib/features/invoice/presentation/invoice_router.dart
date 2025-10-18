// lib/features/invoice/presentation/invoice_router.dart
// Helper to navigate to invoice preview after checkout.
import 'package:flutter/material.dart';
import '../data/invoice_models.dart';
import '../domain/invoice_mapper.dart';
import 'invoice_preview_screen.dart';

class InvoiceRouter {
  static Future<void> pushFromCart({
    required BuildContext context,
    required String invoiceId,
    required DateTime date,
    required String storeName,
    required String storeAddress,
    required String storePhone,
    required String cashierName,
    required List<Map<String, dynamic>> cartMaps,
    double discount = 0.0,
    double tax = 0.0,
    String? footerNote,
    String? logoAsset,
    bool receiptMode = false,
  }) async {
    final dto = InvoiceMapper.fromCart(
      invoiceId: invoiceId,
      date: date,
      storeName: storeName,
      storeAddress: storeAddress,
      storePhone: storePhone,
      cashierName: cashierName,
      cartMaps: cartMaps,
      discount: discount,
      tax: tax,
      footerNote: footerNote,
      logoAsset: logoAsset,
    );
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => InvoicePreviewScreen(data: dto, receiptMode: receiptMode)),
    );
  }
}
