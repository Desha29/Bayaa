import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:barcode/barcode.dart';
import '../data/invoice_models.dart';

class InvoicePdfService {
  static pw.Font? _cachedArabicFont;
  static pw.Font? _cachedBoldFont;
  static pw.ImageProvider? _cachedLogo; // ✅ Cache logo

  // Load fonts
  static Future<pw.Font> _loadArabicFont() async {
    if (_cachedArabicFont != null) return _cachedArabicFont!;
    final fontData = await rootBundle.load('assets/fonts/Amiri-Regular.ttf');
    _cachedArabicFont = pw.Font.ttf(fontData);
    return _cachedArabicFont!;
  }

  static Future<pw.Font> _loadBoldFont() async {
    if (_cachedBoldFont != null) return _cachedBoldFont!;
    try {
      final fontData = await rootBundle.load('assets/fonts/Amiri-Bold.ttf');
      _cachedBoldFont = pw.Font.ttf(fontData);
    } catch (_) {
      _cachedBoldFont = await _loadArabicFont();
    }
    return _cachedBoldFont!;
  }

  // ✅ Load and cache logo
  static Future<pw.ImageProvider?> _loadLogo(InvoiceData data) async {
    // Return cached logo if available
    if (_cachedLogo != null) return _cachedLogo;

    // Priority 1: Use provided logo bytes
    if (data.logoBytes != null) {
      _cachedLogo = pw.MemoryImage(data.logoBytes!);
      return _cachedLogo;
    }

    // Priority 2: Load from asset path
    if (data.logoAsset != null && data.logoAsset!.isNotEmpty) {
      try {
        final bytes = await rootBundle.load(data.logoAsset!);
        _cachedLogo = pw.MemoryImage(bytes.buffer.asUint8List());
        return _cachedLogo;
      } catch (e) {
        print('❌ Error loading logo from ${data.logoAsset}: $e');
        // Try default path
        try {
          final bytes = await rootBundle.load('assets/images/logo1.png');
          _cachedLogo = pw.MemoryImage(bytes.buffer.asUint8List());
          return _cachedLogo;
        } catch (e2) {
          print('❌ Error loading default logo: $e2');
        }
      }
    }

    return null;
  }

  static Future<Uint8List> buildReceipt80mm(InvoiceData data) async {
    final doc = pw.Document();
    final pageFormat = const PdfPageFormat(
      57 * PdfPageFormat.mm,
      double.infinity,
      marginAll: 2,
    );

    final arabicFont = await _loadArabicFont();
    final boldFont = await _loadBoldFont();
    final logoProvider = await _loadLogo(data); // ✅ Load logo properly

    // Color theme suitable for thermal printing and clear display
    final primaryColor = PdfColors.black;
    final accentColor = PdfColor.fromHex('#1a73e8');
    final lightGray = PdfColor.fromHex('#757575');
    final dividerColor = PdfColor.fromHex('#cfcfcf');

    // Typography styles
    final storeTitleStyle = pw.TextStyle(
      fontSize: 11,
      fontWeight: pw.FontWeight.bold,
      font: boldFont,
      color: primaryColor,
      letterSpacing: 0.3,
    );

    final storeInfoStyle = pw.TextStyle(
      fontSize: 7,
      font: arabicFont,
      color: primaryColor,
      height: 1.4,
    );

    final invoiceTitleStyle = pw.TextStyle(
      fontSize: 10,
      fontWeight: pw.FontWeight.bold,
      font: boldFont,
      color: accentColor,
    );

    final labelStyle = pw.TextStyle(
      fontSize: 6.5,
      font: arabicFont,
      color: lightGray,
    );

    final valueStyle = pw.TextStyle(
      fontSize: 7,
      fontWeight: pw.FontWeight.bold,
      font: boldFont,
      color: primaryColor,
    );

    final tableHeaderStyle = pw.TextStyle(
      fontSize: 6.5,
      fontWeight: pw.FontWeight.bold,
      font: boldFont,
      color: primaryColor,
    );

    final itemNameStyle = pw.TextStyle(
      fontSize: 7.5,
      fontWeight: pw.FontWeight.bold,
      font: boldFont,
      color: primaryColor,
    );

    final itemDetailsStyle = pw.TextStyle(
      fontSize: 6.5,
      font: arabicFont,
      color: primaryColor,
    );

    final summaryLabelStyle = pw.TextStyle(
      fontSize: 7,
      font: arabicFont,
      color: primaryColor,
    );

    final summaryValueStyle = pw.TextStyle(
      fontSize: 7,
      fontWeight: pw.FontWeight.bold,
      font: boldFont,
      color: primaryColor,
    );

    final totalLabelStyle = pw.TextStyle(
      fontSize: 9,
      fontWeight: pw.FontWeight.bold,
      font: boldFont,
      color: PdfColors.black,
    );

    final totalValueStyle = pw.TextStyle(
      fontSize: 10,
      fontWeight: pw.FontWeight.bold,
      font: boldFont,
      color: PdfColors.black,
    );

    final footerStyle = pw.TextStyle(
      fontSize: 6,
      font: arabicFont,
      color: lightGray,
      height: 1.3,
    );

    doc.addPage(
      pw.Page(
        pageFormat: pageFormat,
        build: (context) => pw.Directionality(
          textDirection: pw.TextDirection.rtl,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // Header Section with logo and store info
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.symmetric(vertical: 4),
                child: pw.Column(
                  children: [
                    if (logoProvider != null) ...[ // ✅ Check if logo loaded
                      pw.Container(
                        width: 45,
                        height: 45,
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: dividerColor, width: 1.5),
                          borderRadius: pw.BorderRadius.circular(8),
                        ),
                        child: pw.ClipRRect(
                          horizontalRadius: 6,
                          verticalRadius: 6,
                          child: pw.Image(
                            logoProvider, 
                            fit: pw.BoxFit.contain,
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 3),
                    ],
                    pw.Text(
                      data.storeName,
                      style: storeTitleStyle,
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      data.storeAddress,
                      style: storeInfoStyle,
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.SizedBox(height: 1),
                    pw.Text(
                      'هاتف: ${data.storePhone}',
                      style: storeInfoStyle,
                      textAlign: pw.TextAlign.center,
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 4),

              // Dotted divider
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: List.generate(
                  20,
                  (index) => pw.Container(
                    width: 2,
                    height: 2,
                    margin: const pw.EdgeInsets.symmetric(horizontal: 1),
                    decoration: pw.BoxDecoration(
                      color: dividerColor,
                      shape: pw.BoxShape.circle,
                    ),
                  ),
                ),
              ),
              pw.SizedBox(height: 4),

              // Invoice information
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#f9fafb'),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Column(
                  children: [
                    pw.Text('فاتورة بيع', style: invoiceTitleStyle),
                    pw.SizedBox(height: 3),
                    _infoRow('رقم الفاتورة', data.invoiceId, labelStyle, valueStyle),
                    pw.SizedBox(height: 1.5),
                    _infoRow('التاريخ', _fmt(data.date), labelStyle, valueStyle),
                    pw.SizedBox(height: 1.5),
                    _infoRow('الكاشير', data.cashierName, labelStyle, valueStyle),
                  ],
                ),
              ),
              pw.SizedBox(height: 4),

              // Items header
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 1),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#f3f4f6'),
                  borderRadius: pw.BorderRadius.circular(3),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text('المجموع',
                          style: tableHeaderStyle, textAlign: pw.TextAlign.left),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Text('الكمية',
                          style: tableHeaderStyle, textAlign: pw.TextAlign.center),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text('السعر',
                          style: tableHeaderStyle, textAlign: pw.TextAlign.center),
                    ),
                    pw.Expanded(
                      flex: 3,
                      child: pw.Text('الصنف',
                          style: tableHeaderStyle, textAlign: pw.TextAlign.right),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 2),

              // Items list
              ...data.lines.map((item) => pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.symmetric(vertical: 3, horizontal: 1),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(item.total.toStringAsFixed(2),
                              style: valueStyle, textAlign: pw.TextAlign.left),
                        ),
                        pw.Expanded(
                          flex: 1,
                          child: pw.Center(
                            child: pw.Container(
                              padding: const pw.EdgeInsets.symmetric(
                                  horizontal: 3, vertical: 1.5),
                              decoration: pw.BoxDecoration(
                                color: PdfColor.fromHex('#e0e7ff'),
                                borderRadius: pw.BorderRadius.circular(3),
                              ),
                              child: pw.Text(item.qty.toString(),
                                  style: pw.TextStyle(
                                    fontSize: 7,
                                    fontWeight: pw.FontWeight.bold,
                                    font: boldFont,
                                    color: accentColor,
                                  ),
                                  textAlign: pw.TextAlign.center),
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(item.price.toStringAsFixed(2),
                              style: itemDetailsStyle, textAlign: pw.TextAlign.center),
                        ),
                        pw.Expanded(
                          flex: 3,
                          child: pw.Text(item.name,
                              style: itemNameStyle,
                              textAlign: pw.TextAlign.right,
                              maxLines: 2),
                        ),
                      ],
                    ),
                  )),
              pw.SizedBox(height: 4),

              // Divider
              pw.Container(width: double.infinity, height: 1, color: dividerColor),
              pw.SizedBox(height: 3),

              // Summary section
              pw.Container(
                width: double.infinity,
                child: pw.Column(
                  children: [
                    _summaryRow('الإجمالي الفرعي', data.subtotal,
                        summaryLabelStyle, summaryValueStyle),
                    if (data.discount != 0) ...[
                      pw.SizedBox(height: 1.5),
                      _summaryRow('الخصم', -data.discount, summaryLabelStyle,
                          summaryValueStyle,
                          isDiscount: true),
                    ],
                    if (data.tax != 0) ...[
                      pw.SizedBox(height: 1.5),
                      _summaryRow(
                          'الضريبة', data.tax, summaryLabelStyle, summaryValueStyle),
                    ],
                  ],
                ),
              ),
              pw.SizedBox(height: 4),

              // Total section
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#f3f4f6'),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('${data.grandTotal.toStringAsFixed(2)} ج.م',
                        style: totalValueStyle),
                    pw.Text('الإجمالي النهائي', style: totalLabelStyle),
                  ],
                ),
              ),
              pw.SizedBox(height: 5),

              // Barcode section
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.symmetric(vertical: 6),
                alignment: pw.Alignment.center,
                child: pw.BarcodeWidget(
                  barcode: Barcode.code128(),
                  data: data.invoiceId,
                  width: 100,
                  height: 20,
                  drawText: true,
                  textStyle: pw.TextStyle(
                      fontSize: 7, fontWeight: pw.FontWeight.bold, font: boldFont),
                ),
              ),

              // Footer note if any
              if (data.footerNote != null) ...[
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(4),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#fffbeb'),
                    border: pw.Border.all(
                        color: PdfColor.fromHex('#fbbf24'), width: 0.5),
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Text(data.footerNote!,
                      style: footerStyle, textAlign: pw.TextAlign.center),
                ),
                pw.SizedBox(height: 4),
              ],

              // Thank you note
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.symmetric(vertical: 3),
                child: pw.Column(
                  children: [
                    pw.Text('شكراً لزيارتكم',
                        style: pw.TextStyle(
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold,
                          font: boldFont,
                          color: primaryColor,
                        ),
                        textAlign: pw.TextAlign.center),
                    pw.SizedBox(height: 1),
                    pw.Text('نتمنى رؤيتكم مرة أخرى',
                        style: footerStyle, textAlign: pw.TextAlign.center)
                  ],
                ),
              ),

              // Decorative bottom border
              pw.SizedBox(height: 3),
              pw.Container(
                width: 30,
                height: 2,
                decoration: pw.BoxDecoration(
                    color: accentColor, borderRadius: pw.BorderRadius.circular(1)),
              ),
              pw.SizedBox(height: 2),
            ],
          ),
        ),
      ),
    );

    return doc.save();
  }

  static Future<Uint8List> buildA4(InvoiceData data,
      {PdfPageFormat? format}) async {
    return buildReceipt80mm(data);
  }

  static pw.Widget _infoRow(String label, String value, pw.TextStyle labelStyle,
      pw.TextStyle valueStyle) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(value, style: valueStyle),
        pw.Text(label, style: labelStyle),
      ],
    );
  }

  static pw.Widget _summaryRow(String label, double value,
      pw.TextStyle labelStyle, pw.TextStyle valueStyle,
      {bool isDiscount = false}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text('${value.toStringAsFixed(2)}${isDiscount ? '-' : ''}',
            style: isDiscount
                ? valueStyle.copyWith(color: PdfColor.fromHex('#dc2626'))
                : valueStyle),
        pw.Text(label, style: labelStyle),
      ],
    );
  }

  static String _fmt(DateTime d) =>
      '${d.year}/${_2(d.month)}/${_2(d.day)} ${_2(d.hour)}:${_2(d.minute)}';
  static String _2(int x) => x.toString().padLeft(2, '0');
}
