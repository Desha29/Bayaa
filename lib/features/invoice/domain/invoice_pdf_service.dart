import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:barcode/barcode.dart';
import '../data/invoice_models.dart';
import '../../settings/data/models/store_info_model.dart';
import 'package:bayaa_pos/core/di/dependency_injection.dart';
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
    
    // Fallback logo
    try {
      final bytes = await rootBundle.load('assets/images/logo.png');
      _cachedLogo = pw.MemoryImage(bytes.buffer.asUint8List());
      return _cachedLogo;
    } catch (e) {
      return null;
    }
  }

  static Future<Uint8List> buildReceipt80mm(InvoiceData data) async {
    final doc = pw.Document();
    
    // 80mm thermal paper page format
    final pageFormat = const PdfPageFormat(
      80 * PdfPageFormat.mm,
      double.infinity,
      marginAll: 4 * PdfPageFormat.mm,
    );

    final arabicFont = await _loadArabicFont();
    final boldFont = await _loadBoldFont();

    // Brand Colors
    final brandBlue = PdfColor.fromInt(0xFF1E3A8A);
    final brandOrange = PdfColor.fromInt(0xFFF97316);
    final textDark = PdfColor.fromInt(0xFF0F172A);
    final borderLight = PdfColor.fromInt(0xFFE2E8F0);

    // Get store info
    final storeRepo = getIt<StoreInfoRepository>();
    final storeInfoResult = await storeRepo.getStoreInfo();
    final storeInfo = storeInfoResult.getOrElse(() => StoreInfo(
          name: 'بياع POS',
          address: 'القاهرة، مصر',
          phone: '0100000000',
          vat: '', email: '',
        ));
    
    final logoProvider = await _loadLogo(storeInfo.logoPath); 

    doc.addPage(
      pw.Page(
        pageFormat: pageFormat,
        build: (context) => pw.Directionality(
          textDirection: pw.TextDirection.rtl,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // Receipt Logo
              if (logoProvider != null) 
                pw.Container(
                  width: 44,
                  height: 44,
                  margin: const pw.EdgeInsets.only(bottom: 6),
                  child: pw.Image(logoProvider),
                ),
              
              // Store Header
              pw.Text(
                storeInfo.name, 
                style: pw.TextStyle(font: boldFont, fontSize: 13, color: brandBlue),
                textAlign: pw.TextAlign.center,
              ),
              if (storeInfo.address.isNotEmpty)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 2),
                  child: pw.Text(
                    storeInfo.address, 
                    style: pw.TextStyle(font: arabicFont, fontSize: 8, color: PdfColors.grey700), 
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              if (storeInfo.phone.isNotEmpty)
                pw.Text(
                  'هاتف: ${storeInfo.phone}', 
                  style: pw.TextStyle(font: arabicFont, fontSize: 8, color: PdfColors.grey700),
                ),
              if (storeInfo.vat.isNotEmpty)
                pw.Text(
                  'الرقم الضريبي: ${storeInfo.vat}', 
                  style: pw.TextStyle(font: arabicFont, fontSize: 7.5, color: PdfColors.grey600),
                ),
              
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 6),
                child: pw.Divider(color: brandOrange, thickness: 1.2),
              ),

              // Invoice Type Title
              pw.Text(
                'إيصال مبيعات ضريبي', 
                style: pw.TextStyle(font: boldFont, fontSize: 10, color: brandBlue),
              ),
              pw.SizedBox(height: 6),

              // Metadata Row
              _receiptMetaRow('رقم الفاتورة:', data.invoiceId, arabicFont, boldFont),
              _receiptMetaRow('التاريخ والوقت:', _fmt(data.date), arabicFont, boldFont),
              _receiptMetaRow('الكاشير المسؤول:', data.cashierName, arabicFont, boldFont),
              
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 6),
                child: pw.Divider(color: borderLight, thickness: 0.8),
              ),

              // Items Table
              pw.TableHelper.fromTextArray(
                context: null,
                headers: ['المنتج', 'ك', 'سعر', 'إجمالي'],
                data: data.lines.map((l) => [
                  l.name,
                  l.qty.toString(),
                  l.price.toStringAsFixed(0),
                  l.total.toStringAsFixed(0),
                ]).toList(),
                headerStyle: pw.TextStyle(font: boldFont, fontSize: 8, color: PdfColors.white),
                cellStyle: pw.TextStyle(font: arabicFont, fontSize: 8.5, color: textDark),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(0.8),
                  2: const pw.FlexColumnWidth(1.2),
                  3: const pw.FlexColumnWidth(1.4),
                },
                headerDecoration: pw.BoxDecoration(color: brandBlue),
                border: null,
                cellAlignment: pw.Alignment.centerRight,
              ),

              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 6),
                child: pw.Divider(color: borderLight, thickness: 0.8),
              ),

              // Totals
              _receiptMetaRow('إجمالي السلع:', '${data.subtotal.toStringAsFixed(2)} ج.م', arabicFont, boldFont, fontSize: 8.5),
              if (data.discount > 0)
                _receiptMetaRow('الخصم المطبق:', '- ${data.discount.toStringAsFixed(2)} ج.م', arabicFont, boldFont, fontSize: 8.5, color: brandOrange),
              if (data.tax > 0)
                _receiptMetaRow('ضريبة القيمة المضافة:', '${data.tax.toStringAsFixed(2)} ج.م', arabicFont, boldFont, fontSize: 8.5),
              
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 4),
                child: pw.Divider(color: PdfColor.fromInt(0x4D1E3A8A), thickness: 0.5),
              ),

              _receiptMetaRow(
                'الصافي الكلي:', 
                '${data.grandTotal.toStringAsFixed(2)} ج.م', 
                boldFont, 
                boldFont, 
                fontSize: 11, 
                color: brandBlue,
              ),
              
              pw.SizedBox(height: 12),
              pw.Text('شكراً لتسوقكم معنا!', style: pw.TextStyle(font: boldFont, fontSize: 8.5, color: textDark), textAlign: pw.TextAlign.center),
              pw.Text('نظام بياع لإدارة المبيعات POS', style: pw.TextStyle(font: arabicFont, fontSize: 6.5, color: PdfColors.grey600)), 
              
              pw.SizedBox(height: 8),
              pw.BarcodeWidget(
                barcode: Barcode.code128(),
                data: data.invoiceId,
                width: 90,
                height: 25,
                drawText: false,
              ),
            ],
          ),
        ),
      ),
    );

    return doc.save();
  }

  static pw.Widget _receiptMetaRow(String label, String value, pw.Font font, pw.Font bold, {double fontSize = 8, PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(font: font, fontSize: fontSize, color: color ?? PdfColors.grey800)),
          pw.Text(value, style: pw.TextStyle(font: bold, fontSize: fontSize, color: color ?? PdfColor.fromInt(0xFF0F172A))),
        ],
      ),
    );
  }

  static Future<Uint8List> buildA4(InvoiceData data, {PdfPageFormat? format}) async {
    final doc = pw.Document();
    
    final arabicFont = await _loadArabicFont();
    final boldFont = await _loadBoldFont();
    
    // Premium Corporate Colors
    final brandBlue = PdfColor.fromInt(0xFF1E3A8A); // Deep Navy Blue
    final brandOrange = PdfColor.fromInt(0xFFF97316); // Accent Orange
    final bgLight = PdfColor.fromInt(0xFFF8FAFC); // Very light slate
    final borderLight = PdfColor.fromInt(0xFFE2E8F0); // Border slate
    final textDark = PdfColor.fromInt(0xFF0F172A); // Dark slate text
    final textMuted = PdfColor.fromInt(0xFF64748B); // Muted slate text

    final storeRepo = getIt<StoreInfoRepository>();
    final storeInfoResult = await storeRepo.getStoreInfo();
    final storeInfo = storeInfoResult.getOrElse(() => StoreInfo(
          name: 'بياع POS',
          address: 'القاهرة، جمهورية مصر العربية',
          phone: '0100000000',
          vat: '', email: '',
        ));
    final logoProvider = await _loadLogo(storeInfo.logoPath);

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(1.5 * PdfPageFormat.cm),
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(base: arabicFont, bold: boldFont),
        build: (context) => [
          // 1. Header Banner
          _buildA4Header(storeInfo, logoProvider, boldFont, arabicFont, brandBlue, brandOrange, textMuted),
          
          pw.SizedBox(height: 18),
          
          // 2. Invoice Details Box
          _buildA4InvoiceInfoBox(data, boldFont, arabicFont, bgLight, borderLight, brandBlue),
          
          pw.SizedBox(height: 20),
          
          // 3. Products Table
          _buildA4ItemsTable(data, boldFont, arabicFont, brandBlue, borderLight, bgLight, textDark),
          
          pw.SizedBox(height: 20),
          
          // 4. Totals and Summary Box
          _buildA4SummaryRow(data, boldFont, arabicFont, brandBlue, brandOrange, bgLight, borderLight, textDark),
          
          pw.Spacer(),
          
          // 5. Barcode & Footer
          _buildA4Footer(data, arabicFont, boldFont, textMuted),
        ],
      ),
    );

    return doc.save();
  }

  static pw.Widget _buildA4Header(
    StoreInfo store, 
    pw.ImageProvider? logo, 
    pw.Font bold, 
    pw.Font regular, 
    PdfColor brandColor, 
    PdfColor accentColor,
    PdfColor textMuted,
  ) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Store info
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            if (logo != null)
              pw.Container(
                width: 64,
                height: 64,
                margin: const pw.EdgeInsets.only(bottom: 8),
                child: pw.Image(logo),
              ),
            pw.Text(store.name, style: pw.TextStyle(font: bold, fontSize: 20, color: brandColor)),
            pw.SizedBox(height: 4),
            if (store.address.isNotEmpty) 
              pw.Text(store.address, style: pw.TextStyle(font: regular, fontSize: 9.5, color: textMuted)),
            if (store.phone.isNotEmpty) 
              pw.Text('هاتف: ${store.phone}', style: pw.TextStyle(font: regular, fontSize: 9.5, color: textMuted)),
            if (store.vat.isNotEmpty) 
              pw.Text('الرقم الضريبي للمنشأة: ${store.vat}', style: pw.TextStyle(font: regular, fontSize: 9.5, color: textMuted)),
          ],
        ),
        
        // Document Title
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('فاتورة مبيعات ضريبية', style: pw.TextStyle(font: bold, fontSize: 22, color: brandColor)),
            pw.Text('TAX INVOICE', style: pw.TextStyle(font: bold, fontSize: 13, color: accentColor)),
            pw.SizedBox(height: 12),
            pw.Container(
              width: 140,
              height: 3,
              color: accentColor,
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildA4InvoiceInfoBox(
    InvoiceData data, 
    pw.Font bold, 
    pw.Font regular, 
    PdfColor bgLight, 
    PdfColor borderLight,
    PdfColor brandColor,
  ) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        color: bgLight,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
        border: pw.Border.all(color: borderLight, width: 1),
      ),
      padding: const pw.EdgeInsets.all(16),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                children: [
                  pw.Text('رقم الفاتورة: ', style: pw.TextStyle(font: bold, fontSize: 11, color: brandColor)),
                  pw.Text(data.invoiceId, style: pw.TextStyle(font: bold, fontSize: 11)),
                ],
              ),
              pw.SizedBox(height: 6),
              pw.Row(
                children: [
                  pw.Text('تاريخ الإصدار: ', style: pw.TextStyle(font: regular, fontSize: 10, color: brandColor)),
                  pw.Text(_fmt(data.date), style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Row(
                children: [
                  pw.Text('الكاشير المسؤول: ', style: pw.TextStyle(font: regular, fontSize: 10, color: brandColor)),
                  pw.Text(data.cashierName, style: pw.TextStyle(font: bold, fontSize: 10)),
                ],
              ),
              pw.SizedBox(height: 6),
              pw.Row(
                children: [
                  pw.Text('حالة الفاتورة: ', style: pw.TextStyle(font: regular, fontSize: 10, color: brandColor)),
                  pw.Text('مدفوعة بالكامل', style: pw.TextStyle(font: bold, fontSize: 10, color: PdfColor.fromInt(0xFF22C55E))),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildA4ItemsTable(
    InvoiceData data, 
    pw.Font bold, 
    pw.Font regular, 
    PdfColor brandColor, 
    PdfColor borderLight,
    PdfColor bgLight,
    PdfColor textDark,
  ) {
    return pw.Table(
      border: pw.TableBorder(
        horizontalInside: pw.BorderSide(color: borderLight, width: 0.8),
        bottom: pw.BorderSide(color: brandColor, width: 1.5),
      ),
      columnWidths: {
        0: const pw.FlexColumnWidth(4), // Product name
        1: const pw.FlexColumnWidth(1), // Quantity
        2: const pw.FlexColumnWidth(1.5), // Price
        3: const pw.FlexColumnWidth(1.8), // Total
      },
      defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
      children: [
        // Table Header
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: brandColor,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
          ),
          children: [
            _tableHeaderCell('المنتج / السلعة', bold),
            _tableHeaderCell('الكمية', bold),
            _tableHeaderCell('سعر الوحدة', bold),
            _tableHeaderCell('الإجمالي الكلي', bold),
          ],
        ),
        
        // Table Rows
        ...List.generate(data.lines.length, (index) {
          final line = data.lines[index];
          final isEven = index % 2 == 0;
          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: isEven ? bgLight : PdfColors.white,
            ),
            children: [
              _tableCell(line.name, regular, align: pw.TextAlign.right, textDark: textDark),
              _tableCell(line.qty.toString(), regular, textDark: textDark),
              _tableCell('${line.price.toStringAsFixed(2)} ج.م', regular, textDark: textDark),
              _tableCell('${line.total.toStringAsFixed(2)} ج.م', bold, textDark: textDark),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _tableHeaderCell(String text, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: pw.Text(
        text,
        style: pw.TextStyle(font: font, color: PdfColors.white, fontSize: 10),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static pw.Widget _tableCell(String text, pw.Font font, {pw.TextAlign align = pw.TextAlign.center, PdfColor? textDark}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: pw.Text(
        text,
        style: pw.TextStyle(font: font, fontSize: 9.5, color: textDark),
        textAlign: align,
      ),
    );
  }

  static pw.Widget _buildA4SummaryRow(
    InvoiceData data, 
    pw.Font bold, 
    pw.Font regular, 
    PdfColor brandColor, 
    PdfColor accentColor,
    PdfColor bgLight, 
    PdfColor borderLight,
    PdfColor textDark,
  ) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Terms & signature
        pw.Expanded(
          flex: 1,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('الشروط والأحكام:', style: pw.TextStyle(font: bold, fontSize: 9.5, color: brandColor)),
              pw.SizedBox(height: 4),
              pw.Text('1. البضاعة المباعة لا ترد ولا تستبدل بعد 14 يوماً من تاريخ الفاتورة.', style: pw.TextStyle(font: regular, fontSize: 8, color: PdfColors.grey700)),
              pw.Text('2. يجب إحضار الفاتورة الأصلية عند طلب الاسترجاع أو الصيانة.', style: pw.TextStyle(font: regular, fontSize: 8, color: PdfColors.grey700)),
            ],
          ),
        ),
        pw.SizedBox(width: 40),
        
        // Totals Box
        pw.Container(
          width: 240,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: borderLight, width: 1),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
          ),
          child: pw.Column(
            children: [
              _summaryRow('الإجمالي الفرعي:', '${data.subtotal.toStringAsFixed(2)} ج.م', regular, regular, textDark),
              if (data.discount > 0)
                _summaryRow('خصومات الفاتورة:', '- ${data.discount.toStringAsFixed(2)} ج.م', regular, regular, accentColor),
              if (data.tax > 0)
                _summaryRow('ضريبة القيمة المضافة:', '${data.tax.toStringAsFixed(2)} ج.م', regular, regular, textDark),
              
              pw.Container(
                decoration: pw.BoxDecoration(
                  color: brandColor,
                  borderRadius: const pw.BorderRadius.vertical(bottom: pw.Radius.circular(9)),
                ),
                padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'الإجمالي النهائي:', 
                      style: pw.TextStyle(font: bold, fontSize: 11, color: PdfColors.white),
                    ),
                    pw.Text(
                      '${data.grandTotal.toStringAsFixed(2)} ج.م', 
                      style: pw.TextStyle(font: bold, fontSize: 12, color: PdfColors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _summaryRow(String label, String value, pw.Font labelFont, pw.Font valueFont, PdfColor? color) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(font: labelFont, fontSize: 9.5, color: PdfColors.grey700)),
          pw.Text(value, style: pw.TextStyle(font: valueFont, fontSize: 9.5, color: color)),
        ],
      ),
    );
  }

  static pw.Widget _buildA4Footer(InvoiceData data, pw.Font regular, pw.Font bold, PdfColor textMuted) {
    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey300, thickness: 0.5),
        pw.SizedBox(height: 6),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'شكراً لتعاملكم معنا ودمتم سالمين!', 
              style: pw.TextStyle(font: bold, fontSize: 9.5, color: PdfColor.fromInt(0xFF1E3A8A)),
            ),
            pw.BarcodeWidget(
              barcode: Barcode.code128(),
              data: data.invoiceId,
              width: 110,
              height: 25,
              drawText: false,
            ),
          ],
        ),
      ],
    );
  }

  static String _fmt(DateTime d) =>
      '${d.year}/${_2(d.month)}/${_2(d.day)} ${_2(d.hour)}:${_2(d.minute)}';
  static String _2(int x) => x.toString().padLeft(2, '0');
}
