// lib/features/invoice/domain/invoice_pdf_service.dart
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:barcode/barcode.dart';
import '../data/invoice_models.dart';

class InvoicePdfService {
  static pw.Font? _cachedArabicFont;
  static pw.Font? _cachedBoldFont;

  // Load fonts
  static Future<pw.Font> _loadArabicFont() async {
    if (_cachedArabicFont != null) return _cachedArabicFont!;
    final fontData = await rootBundle.load('assets/fonts/Amiri-Regular.ttf');
    _cachedArabicFont = pw.Font.ttf(fontData);
    return _cachedArabicFont!;
  }

  static Future<pw.Font> _loadBoldFont() async {
    if (_cachedBoldFont != null) return _cachedBoldFont!;
    // Try to load bold, fallback to regular
    try {
      final fontData = await rootBundle.load('assets/fonts/Amiri-Bold.ttf');
      _cachedBoldFont = pw.Font.ttf(fontData);
    } catch (_) {
      _cachedBoldFont = await _loadArabicFont();
    }
    return _cachedBoldFont!;
  }

  // Fawry-style thermal receipt (57mm width - standard payment device size)
  static Future<Uint8List> buildReceipt80mm(InvoiceData data) async {
    final doc = pw.Document();
    // 57mm thermal paper (standard for Fawry/payment devices)
    final pageFormat = const PdfPageFormat(57 * PdfPageFormat.mm, double.infinity, marginAll: 2);
    final arabicFont = await _loadArabicFont();
    final boldFont = await _loadBoldFont();

    pw.ImageProvider? logoProvider;
    if (data.logoBytes != null) {
      logoProvider = pw.MemoryImage(data.logoBytes!);
    } else if (data.logoAsset != null) {
      try {
        final bytes = await rootBundle.load(data.logoAsset!);
        logoProvider = pw.MemoryImage(bytes.buffer.asUint8List());
      } catch (_) {}
    }

    // Professional thermal receipt styles
    final storeTitleStyle = pw.TextStyle(
      fontSize: 10,
      fontWeight: pw.FontWeight.bold,
      font: boldFont,
    );
    final headerStyle = pw.TextStyle(
      fontSize: 7,
      font: arabicFont,
    );
    final titleStyle = pw.TextStyle(
      fontSize: 9,
      fontWeight: pw.FontWeight.bold,
      font: boldFont,
    );
    final bodyStyle = pw.TextStyle(
      fontSize: 6.5,
      font: arabicFont,
    );
    final itemNameStyle = pw.TextStyle(
      fontSize: 7,
      fontWeight: pw.FontWeight.bold,
      font: boldFont,
    );
    final totalStyle = pw.TextStyle(
      fontSize: 9,
      fontWeight: pw.FontWeight.bold,
      font: boldFont,
    );
    final smallStyle = pw.TextStyle(
      fontSize: 6,
      font: arabicFont,
    );

    doc.addPage(
      pw.Page(
        pageFormat: pageFormat,
        build: (context) => pw.Directionality(
          textDirection: pw.TextDirection.rtl,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // Logo
              if (logoProvider != null) ...[
                pw.Container(
                  width: 30,
                  height: 30,
                  child: pw.Image(logoProvider, fit: pw.BoxFit.contain),
                ),
                pw.SizedBox(height: 2),
              ],

              // Store name
              pw.Text(data.storeName, style: storeTitleStyle, textAlign: pw.TextAlign.center),
              pw.SizedBox(height: 1),
              pw.Text(data.storeAddress, style: headerStyle, textAlign: pw.TextAlign.center),
              pw.Text('هاتف: ${data.storePhone}', style: headerStyle, textAlign: pw.TextAlign.center),
              pw.SizedBox(height: 3),

              // Divider
              pw.Container(
                width: double.infinity,
                height: 0.5,
                color: PdfColors.grey700,
              ),
              pw.SizedBox(height: 3),

              // Invoice title
              pw.Text('فاتورة بيع', style: titleStyle),
              pw.SizedBox(height: 2),

              // Invoice details
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(_fmt(data.date), style: bodyStyle),
                  pw.Text('رقم: ${data.invoiceId}', style: bodyStyle),
                ],
              ),
              pw.Text('الكاشير: ${data.cashierName}', style: bodyStyle),
              pw.SizedBox(height: 3),

              // Divider
              pw.Container(
                width: double.infinity,
                height: 0.5,
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    top: pw.BorderSide(color: PdfColors.grey700, width: 0.5, style: pw.BorderStyle.dashed),
                  ),
                ),
              ),
              pw.SizedBox(height: 3),

              // Items header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(flex: 2, child: pw.Text('الإجمالي', style: bodyStyle, textAlign: pw.TextAlign.left)),
                  pw.Expanded(flex: 1, child: pw.Text('الكمية', style: bodyStyle, textAlign: pw.TextAlign.center)),
                  pw.Expanded(flex: 2, child: pw.Text('السعر', style: bodyStyle, textAlign: pw.TextAlign.center)),
                  pw.Expanded(flex: 3, child: pw.Text('الصنف', style: bodyStyle, textAlign: pw.TextAlign.right)),
                ],
              ),
              pw.SizedBox(height: 2),

              // Items list
              ...data.lines.map((item) => pw.Column(
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Expanded(
                            flex: 2,
                            child: pw.Text(
                              item.total.toStringAsFixed(2),
                              style: bodyStyle,
                              textAlign: pw.TextAlign.left,
                            ),
                          ),
                          pw.Expanded(
                            flex: 1,
                            child: pw.Text(
                              item.qty.toString(),
                              style: bodyStyle,
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                          pw.Expanded(
                            flex: 2,
                            child: pw.Text(
                              item.price.toStringAsFixed(2),
                              style: bodyStyle,
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                          pw.Expanded(
                            flex: 3,
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.end,
                              children: [
                                pw.Text(item.name, style: itemNameStyle, textAlign: pw.TextAlign.right),
                                pw.Text('(${item.barcode})', style: smallStyle, textAlign: pw.TextAlign.right),
                              ],
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 2),
                    ],
                  )),

              pw.SizedBox(height: 2),

              // Divider
              pw.Container(
                width: double.infinity,
                height: 0.5,
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    top: pw.BorderSide(color: PdfColors.grey700, width: 0.5, style: pw.BorderStyle.dashed),
                  ),
                ),
              ),
              pw.SizedBox(height: 3),

              // Subtotal, discount, tax
              _receiptRow('الإجمالي الفرعي', data.subtotal, bodyStyle),
              if (data.discount != 0) ...[
                pw.SizedBox(height: 1),
                _receiptRow('الخصم', -data.discount, bodyStyle),
              ],
              if (data.tax != 0) ...[
                pw.SizedBox(height: 1),
                _receiptRow('الضريبة', data.tax, bodyStyle),
              ],

              pw.SizedBox(height: 3),

              // Divider
              pw.Container(
                width: double.infinity,
                height: 1,
                color: PdfColors.grey800,
              ),
              pw.SizedBox(height: 3),

              // Total
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('${data.grandTotal.toStringAsFixed(2)} ج.م', style: totalStyle),
                  pw.Text('الإجمالي', style: totalStyle),
                ],
              ),

              pw.SizedBox(height: 3),

              // Divider
              pw.Container(
                width: double.infinity,
                height: 1,
                color: PdfColors.grey800,
              ),
              pw.SizedBox(height: 5),

              // Barcode
              pw.BarcodeWidget(
                barcode: Barcode.code128(),
                data: data.invoiceId,
                width: 110,
                height: 30,
                drawText: false,
              ),
              pw.SizedBox(height: 2),
              pw.Text(data.invoiceId, style: smallStyle, textAlign: pw.TextAlign.center),

              pw.SizedBox(height: 5),

              // Footer note
              if (data.footerNote != null) ...[
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.symmetric(vertical: 3, horizontal: 2),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
                    borderRadius: pw.BorderRadius.circular(2),
                  ),
                  child: pw.Text(
                    data.footerNote!,
                    style: smallStyle,
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.SizedBox(height: 3),
              ],

              // Thank you message
              pw.Text('شكراً لزيارتكم', style: headerStyle, textAlign: pw.TextAlign.center),
              pw.SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );

    return doc.save();
  }

  // Keep A4 for printing/viewing
  static Future<Uint8List> buildA4(InvoiceData data, {PdfPageFormat? format}) async {
    // Just call the receipt version with A4 size for preview
    return buildReceipt80mm(data);
  }

  static pw.Widget _receiptRow(String label, double value, pw.TextStyle style) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(value.toStringAsFixed(2), style: style),
        pw.Text(label, style: style),
      ],
    );
  }

  static String _fmt(DateTime d) => '${d.year}/${_2(d.month)}/${_2(d.day)}  ${_2(d.hour)}:${_2(d.minute)}';
  static String _2(int x) => x.toString().padLeft(2, '0');
}
