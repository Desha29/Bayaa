
import '../../invoice/data/invoice_models.dart';

class InvoiceMapper {
  static InvoiceData fromCart({
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
  }) {
    final lines = cartMaps.map((m) {
      return InvoiceLine(
        name: (m['name'] ?? '').toString(),
        barcode: (m['id'] ?? '').toString(),
        price: (m['price'] as num).toDouble(),
        qty: (m['qty'] as num).toInt(),
      );
    }).toList();

    final subtotal = lines.fold<double>(0.0, (s, e) => s + e.total);
    final grand = subtotal - discount + tax;

    return InvoiceData(
      invoiceId: invoiceId,
      date: date,
      storeName: storeName,
      storeAddress: storeAddress,
      storePhone: storePhone,
      cashierName: cashierName,
      lines: lines,
      subtotal: subtotal,
      discount: discount,
      tax: tax,
      grandTotal: grand,
      footerNote: footerNote,
      logoAsset: logoAsset,
    );
  }
}
