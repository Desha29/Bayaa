import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:barcode/barcode.dart';
import '../data/invoice_models.dart';
import '../../settings/data/models/store_info_model.dart';
import 'package:crazy_phone_pos/core/di/dependency_injection.dart';
import '../../settings/data/repository/settings_repository_imp.dart';

class InvoicePdfService {
  static pw.Font? _cachedArabicFont;
  static pw.Font? _cachedBoldFont;
  static pw.ImageProvider? _cachedLogo; 

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

  static Future<pw.ImageProvider?> _loadLogo(String? logoPath) async {
    if (_cachedLogo != null) return _cachedLogo;

    if (logoPath != null && logoPath.isNotEmpty) {
      try {
        final bytes = await rootBundle.load(logoPath);
        _cachedLogo = pw.MemoryImage(bytes.buffer.asUint8List());
        return _cachedLogo;
      } catch (e) {
        print('❌ Error loading logo from $logoPath: $e');
      }
    }
    
 
    // Fallback
    try {
      final bytes = await rootBundle.load('assets/images/logo.png'); // Updated asset
      _cachedLogo = pw.MemoryImage(bytes.buffer.asUint8List());
      return _cachedLogo;
    } catch (e) {
       return null;
    }
  }

  static Future<Uint8List> buildReceipt80mm(InvoiceData data) async {
    final doc = pw.Document();
    
    // 80mm thermal paper is usually around 72mm printable width
    final pageFormat = const PdfPageFormat(
      80 * PdfPageFormat.mm,
      double.infinity,
      marginAll: 5 * PdfPageFormat.mm,
    );

    final arabicFont = await _loadArabicFont();
    final boldFont = await _loadBoldFont();

    // Brand Colors
    final brandBlue = PdfColor.fromInt(0xFF1E3A8A);
    final brandOrange = PdfColor.fromInt(0xFFF97316);

    // Get dynamic store info
    final storeRepo = getIt<StoreInfoRepository>();
    final storeInfoResult = await storeRepo.getStoreInfo();
    final storeInfo = storeInfoResult.getOrElse(() => StoreInfo(
          name: 'Bayaa', // Updated Default Name
          address: '',
          phone: '',
          vat: '', email: '',
        ));
    
    final logoProvider = await _loadLogo(storeInfo.logoPath); 

    // Styles...
    final dividerColor = PdfColors.grey400;

    doc.addPage(
      pw.Page(
        pageFormat: pageFormat,
        build: (context) => pw.Directionality(
          textDirection: pw.TextDirection.rtl,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              if (logoProvider != null) 
                pw.Container(
                  width: 50,
                  height: 50,
                  child: pw.Image(logoProvider),
                ),
              pw.Text(storeInfo.name, 
                  style: pw.TextStyle(font: boldFont, fontSize: 16, fontWeight: pw.FontWeight.bold, color: brandBlue)),
              if (storeInfo.address.isNotEmpty)
                pw.Text(storeInfo.address, 
                    style: pw.TextStyle(font: arabicFont, fontSize: 8), textAlign: pw.TextAlign.center),
              if (storeInfo.phone.isNotEmpty)
                pw.Text('هاتف: ${storeInfo.phone}', 
                    style: pw.TextStyle(font: arabicFont, fontSize: 8)),
              if (storeInfo.vat.isNotEmpty)
                pw.Text('الرقم الضريبي: ${storeInfo.vat}', 
                    style: pw.TextStyle(font: arabicFont, fontSize: 7)),
              
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 4),
                child: pw.Divider(color: brandOrange, thickness: 1), // Orange Divider
              ),

              pw.Text('فاتورة مبيعات', style: pw.TextStyle(font: boldFont, fontSize: 12, color: brandBlue)),
              pw.SizedBox(height: 4),
              _row('رقم الفاتورة:', data.invoiceId, arabicFont, boldFont),
              _row('التاريخ:', _fmt(data.date), arabicFont, boldFont),
              _row('الكاشير:', data.cashierName, arabicFont, boldFont),
              
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 4),
                child: pw.Divider(color: dividerColor, thickness: 0.5),
              ),

              // Items Table
              pw.TableHelper.fromTextArray(
                context: null,
                headers: ['المنتج', 'ك', 'س', 'ج'],
                data: data.lines.map((l) => [
                  l.name,
                  l.qty.toString(),
                  l.price.toStringAsFixed(0),
                  l.total.toStringAsFixed(0),
                ]).toList(),
                headerStyle: pw.TextStyle(font: boldFont, fontSize: 9, color: PdfColors.white),
                cellStyle: pw.TextStyle(font: arabicFont, fontSize: 9),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(1),
                  2: const pw.FlexColumnWidth(1.5),
                  3: const pw.FlexColumnWidth(1.5),
                },
                headerDecoration: pw.BoxDecoration(color: brandBlue), // Blue Header
                border: null,
                cellAlignment: pw.Alignment.centerRight,
              ),

              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 4),
                child: pw.Divider(color: dividerColor, thickness: 0.5),
              ),

              _row('الإجمالي:', '${data.grandTotal.toStringAsFixed(2)}', arabicFont, boldFont, fontSize: 12, color: brandBlue),
              
              pw.SizedBox(height: 10),
              pw.Text('شكراً لزيارتكم!', style: pw.TextStyle(font: arabicFont, fontSize: 10)),
              pw.Text('Powered by Bayaa', style: pw.TextStyle(font: arabicFont, fontSize: 6, color: PdfColors.grey500)), 
              
              pw.SizedBox(height: 5),
              pw.BarcodeWidget(
                barcode: Barcode.code128(),
                data: data.invoiceId,
                width: 100,
                height: 30,
                drawText: false,
              ),
            ],
          ),
        ),
      ),
    );

    return doc.save();
  }

  static pw.Widget _row(String label, String value, pw.Font font, pw.Font bold, {double fontSize = 9, PdfColor? color}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: pw.TextStyle(font: font, fontSize: fontSize, color: color)),
        pw.Text(value, style: pw.TextStyle(font: bold, fontSize: fontSize, color: color)),
      ],
    );
  }

  static Future<Uint8List> buildA4(InvoiceData data, {PdfPageFormat? format}) async {
    // For A4 we can use a more elaborate layout
    final doc = pw.Document();
    
    final arabicFont = await _loadArabicFont();
    final boldFont = await _loadBoldFont();
    
    // Brand Colors
    final brandBlue = PdfColor.fromInt(0xFF1E3A8A);
    final brandOrange = PdfColor.fromInt(0xFFF97316);

    final storeRepo = getIt<StoreInfoRepository>();
    final storeInfoResult = await storeRepo.getStoreInfo();
    final storeInfo = storeInfoResult.getOrElse(() => StoreInfo(
          name: 'Bayaa',
          address: '',
          phone: '',
          vat: '', email: '',
        ));
    final logoProvider = await _loadLogo(storeInfo.logoPath);

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(1 * PdfPageFormat.cm),
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(base: arabicFont, bold: boldFont),
        build: (context) => [
          _buildA4Header(storeInfo, logoProvider, boldFont, brandBlue),
          pw.Divider(color: brandOrange, thickness: 2),
          _buildA4InvoiceInfo(data, boldFont),
          pw.SizedBox(height: 20),
          _buildA4ItemsTable(data, boldFont, arabicFont, brandBlue),
          pw.SizedBox(height: 20),
          _buildA4Summary(data, boldFont, brandBlue),
          pw.Spacer(),
          _buildA4Footer(arabicFont),
        ],
      ),
    );

    return doc.save();
  }

  static pw.Widget _buildA4Header(StoreInfo store, pw.ImageProvider? logo, pw.Font bold, PdfColor brandColor) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(store.name, style: pw.TextStyle(font: bold, fontSize: 24, color: brandColor)),
            if (store.address.isNotEmpty) pw.Text(store.address),
            if (store.phone.isNotEmpty) pw.Text('هاتف: ${store.phone}'),
            if (store.vat.isNotEmpty) pw.Text('الرقم الضريبي: ${store.vat}'),
          ],
        ),
        if (logo != null)
          pw.Container(width: 80, height: 80, child: pw.Image(logo)),
      ],
    );
  }

  static pw.Widget _buildA4InvoiceInfo(InvoiceData data, pw.Font bold) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('فاتورة رقم: ${data.invoiceId}', style: pw.TextStyle(font: bold)),
            pw.Text('التاريخ: ${_fmt(data.date)}'),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('الكاشير: ${data.cashierName}'),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildA4ItemsTable(InvoiceData data, pw.Font bold, pw.Font regular, PdfColor brandColor) {
     return pw.TableHelper.fromTextArray(
      headers: ['المنتج', 'الكمية', 'السعر', 'الإجمالي'],
      data: data.lines.map((l) => [
        l.name,
        l.qty.toString(),
        l.price.toStringAsFixed(2),
        l.total.toStringAsFixed(2),
      ]).toList(),
      headerStyle: pw.TextStyle(font: bold, color: PdfColors.white),
      cellStyle: pw.TextStyle(font: regular),
      headerDecoration: pw.BoxDecoration(color: brandColor), // Blue Header
      cellAlignment: pw.Alignment.center,
    );
    }

  static pw.Widget _buildA4Summary(InvoiceData data, pw.Font bold, PdfColor brandColor) {
    return pw.Align(
      alignment: pw.Alignment.centerLeft,
      child: pw.Container(
        width: 200,
        child: pw.Column(
          children: [
            _row('الإجمالي الفرعي:', data.subtotal.toStringAsFixed(2), bold, bold),
            pw.Divider(),
            _row('الإجمالي الكلي:', '${data.grandTotal.toStringAsFixed(2)} ج.م', bold, bold, fontSize: 14, color: brandColor),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildA4Footer(pw.Font regular) {
    return pw.Container(
      alignment: pw.Alignment.center,
      child: pw.Text('شكراً لتعاملكم معنا', style: pw.TextStyle(font: regular, fontSize: 10)),
    );
  }

  static String _fmt(DateTime d) =>
      '${d.year}/${_2(d.month)}/${_2(d.day)} ${_2(d.hour)}:${_2(d.minute)}';
  static String _2(int x) => x.toString().padLeft(2, '0');
}
