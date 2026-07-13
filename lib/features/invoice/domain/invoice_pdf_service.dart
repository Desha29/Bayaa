import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:barcode/barcode.dart';
import '../data/invoice_models.dart';
import '../../settings/data/models/store_info_model.dart';
import 'package:bayaa_pos/core/di/dependency_injection.dart';
import '../../settings/data/repository/settings_repository_imp.dart';
import 'package:bayaa_pos/l10n/app_localizations.dart';

class InvoicePdfService {
  static pw.Font? _cachedArabicFont;
  static pw.Font? _cachedBoldFont;
  static final Map<String, pw.ImageProvider?> _logoCache = {}; 

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

  static Future<pw.ImageProvider?> _loadLogo(String? logoPath, {required Locale locale}) async {
    final cacheKey = '${logoPath ?? ''}_${locale.languageCode}';
    if (_logoCache.containsKey(cacheKey)) return _logoCache[cacheKey];

    if (logoPath != null && logoPath.isNotEmpty) {
      try {
        final bytes = await rootBundle.load(logoPath);
        final image = pw.MemoryImage(bytes.buffer.asUint8List());
        _logoCache[cacheKey] = image;
        return image;
      } catch (e) {
        print('❌ Error loading logo from $logoPath: $e');
      }
    }
    
    // Fallback logo
    try {
      final fallbackPath = locale.languageCode == 'en'
          ? 'assets/images/logo_en.png'
          : 'assets/images/logo.png';
      final bytes = await rootBundle.load(fallbackPath);
      final image = pw.MemoryImage(bytes.buffer.asUint8List());
      _logoCache[cacheKey] = image;
      return image;
    } catch (e) {
      _logoCache[cacheKey] = null;
      return null;
    }
  }

  static Future<Uint8List> buildReceipt80mm(InvoiceData data, {required Locale locale}) async {
    final doc = pw.Document();
    final l10n = await AppLocalizations.delegate.load(locale);
    
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
          name: 'Bayaa POS',
          address: 'Cairo, Egypt',
          phone: '0100000000',
          vat: '', email: '',
        ));
    
    final logoProvider = await _loadLogo(storeInfo.logoPath, locale: locale); 

    doc.addPage(
      pw.Page(
        pageFormat: pageFormat,
        build: (context) => pw.Directionality(
          textDirection: locale.languageCode == 'ar' ? pw.TextDirection.rtl : pw.TextDirection.ltr,
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
                (storeInfo.name == 'Bayaa POS' || storeInfo.name.isEmpty)
                    ? l10n.appName
                    : storeInfo.name, 
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
                  l10n.receiptPhone(storeInfo.phone), 
                  style: pw.TextStyle(font: arabicFont, fontSize: 8, color: PdfColors.grey700),
                ),
              if (storeInfo.vat.isNotEmpty)
                pw.Text(
                  l10n.vatNumber(storeInfo.vat), 
                  style: pw.TextStyle(font: arabicFont, fontSize: 7.5, color: PdfColors.grey600),
                ),
              
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 6),
                child: pw.Divider(color: brandOrange, thickness: 1.2),
              ),

              // Invoice Type Title
              pw.Text(
                l10n.taxSalesReceipt, 
                style: pw.TextStyle(font: boldFont, fontSize: 10, color: brandBlue),
              ),
              pw.SizedBox(height: 6),

              // Metadata Row
              _receiptMetaRow(l10n.invoiceNumberPdf, data.invoiceId, arabicFont, boldFont),
              _receiptMetaRow(l10n.dateTimeLabel, _fmt(data.date), arabicFont, boldFont),
              _receiptMetaRow(
                l10n.responsibleCashier,
                (data.cashierName == 'System Administrator' || data.cashierName == 'مدير النظام')
                    ? l10n.roleManager
                    : (data.cashierName == 'Trial Cashier' || data.cashierName == 'كاشير تجريبي')
                        ? l10n.trialCashier
                        : data.cashierName,
                arabicFont,
                boldFont,
              ),
              _receiptMetaRow(l10n.paymentMethodLabel, data.paymentMethod == 'wallet' ? l10n.paymentWallet : l10n.paymentCash, arabicFont, boldFont),
              
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 6),
                child: pw.Divider(color: borderLight, thickness: 0.8),
              ),

              // Items Table
              pw.TableHelper.fromTextArray(
                context: null,
                headers: [l10n.pdfProductHeader, l10n.pdfQtyHeader, l10n.pdfPriceHeader, l10n.pdfTotalHeader],
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
              _receiptMetaRow(l10n.itemsTotalLabel, '${data.subtotal.toStringAsFixed(2)} ${l10n.currencyEg}', arabicFont, boldFont, fontSize: 8.5),
              if (data.discount > 0)
                _receiptMetaRow(l10n.appliedDiscount, '- ${data.discount.toStringAsFixed(2)} ${l10n.currencyEg}', arabicFont, boldFont, fontSize: 8.5, color: brandOrange),
              if (data.tax > 0)
                _receiptMetaRow(l10n.valueAddedTax, '${data.tax.toStringAsFixed(2)} ${l10n.currencyEg}', arabicFont, boldFont, fontSize: 8.5),
              
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 4),
                child: pw.Divider(color: PdfColor.fromInt(0x4D1E3A8A), thickness: 0.5),
              ),

              _receiptMetaRow(
                l10n.grandTotalLabelPdf, 
                '${data.grandTotal.toStringAsFixed(2)} ${l10n.currencyEg}', 
                boldFont, 
                boldFont, 
                fontSize: 11, 
                color: brandBlue,
              ),
              
              pw.SizedBox(height: 12),
              pw.Text(l10n.thankYouShopping, style: pw.TextStyle(font: boldFont, fontSize: 8.5, color: textDark), textAlign: pw.TextAlign.center),
              pw.Text(l10n.posSystemName, style: pw.TextStyle(font: arabicFont, fontSize: 6.5, color: PdfColors.grey600)), 
              
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

  static Future<Uint8List> buildA4(InvoiceData data, {PdfPageFormat? format, required Locale locale}) async {
    final doc = pw.Document();
    final l10n = await AppLocalizations.delegate.load(locale);
    
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
          name: 'Bayaa POS',
          address: 'Cairo, Arab Republic of Egypt',
          phone: '0100000000',
          vat: '', email: '',
        ));
    final logoProvider = await _loadLogo(storeInfo.logoPath, locale: locale);

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(1.5 * PdfPageFormat.cm),
        textDirection: locale.languageCode == 'ar' ? pw.TextDirection.rtl : pw.TextDirection.ltr,
        theme: pw.ThemeData.withFont(base: arabicFont, bold: boldFont),
        build: (context) => [
          // 1. Header Banner
          _buildA4Header(storeInfo, logoProvider, boldFont, arabicFont, brandBlue, brandOrange, textMuted, l10n),
          
          pw.SizedBox(height: 18),
          
          // 2. Invoice Details Box
          _buildA4InvoiceInfoBox(data, boldFont, arabicFont, bgLight, borderLight, brandBlue, l10n),
          
          pw.SizedBox(height: 20),
          
          // 3. Products Table
          _buildA4ItemsTable(data, boldFont, arabicFont, brandBlue, borderLight, bgLight, textDark, l10n),
          
          pw.SizedBox(height: 20),
          
          // 4. Totals and Summary Box
          _buildA4SummaryRow(data, boldFont, arabicFont, brandBlue, brandOrange, bgLight, borderLight, textDark, l10n),
          
          pw.Spacer(),
          
          // 5. Barcode & Footer
          _buildA4Footer(data, arabicFont, boldFont, textMuted, l10n),
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
    AppLocalizations l10n,
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
            pw.Text(
                (store.name == 'Bayaa POS' || store.name.isEmpty)
                    ? l10n.appName
                    : store.name,
                style: pw.TextStyle(font: bold, fontSize: 20, color: brandColor)),
            pw.SizedBox(height: 4),
            if (store.address.isNotEmpty) 
              pw.Text(store.address, style: pw.TextStyle(font: regular, fontSize: 9.5, color: textMuted)),
            if (store.phone.isNotEmpty) 
              pw.Text(l10n.receiptPhone(store.phone), style: pw.TextStyle(font: regular, fontSize: 9.5, color: textMuted)),
            if (store.vat.isNotEmpty) 
              pw.Text('${l10n.enterpriseTaxNumber} ${store.vat}', style: pw.TextStyle(font: regular, fontSize: 9.5, color: textMuted)),
          ],
        ),
        
        // Document Title
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(l10n.taxSalesInvoice, style: pw.TextStyle(font: bold, fontSize: 22, color: brandColor)),
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
    AppLocalizations l10n,
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
                  pw.Text(l10n.invoiceNumberPdf, style: pw.TextStyle(font: bold, fontSize: 11, color: brandColor)),
                  pw.Text(data.invoiceId, style: pw.TextStyle(font: bold, fontSize: 11)),
                ],
              ),
              pw.SizedBox(height: 6),
              pw.Row(
                children: [
                  pw.Text('${l10n.dateTimeLabel} ', style: pw.TextStyle(font: regular, fontSize: 10, color: brandColor)),
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
                  pw.Text(l10n.responsibleCashier, style: pw.TextStyle(font: regular, fontSize: 10, color: brandColor)),
                  pw.Text(
                    (data.cashierName == 'System Administrator' || data.cashierName == 'مدير النظام')
                        ? l10n.roleManager
                        : (data.cashierName == 'Trial Cashier' || data.cashierName == 'كاشير تجريبي')
                            ? l10n.trialCashier
                            : data.cashierName,
                    style: pw.TextStyle(font: bold, fontSize: 10),
                  ),
                ],
              ),
              pw.SizedBox(height: 6),
              pw.Row(
                children: [
                  pw.Text(l10n.invoiceStatusLabel, style: pw.TextStyle(font: regular, fontSize: 10, color: brandColor)),
                  pw.Text(l10n.fullyPaid, style: pw.TextStyle(font: bold, fontSize: 10, color: PdfColor.fromInt(0xFF22C55E))),
                ],
              ),
              pw.SizedBox(height: 6),
              pw.Row(
                children: [
                  pw.Text('${l10n.paymentMethodLabel}: ', style: pw.TextStyle(font: regular, fontSize: 10, color: brandColor)),
                  pw.Text(data.paymentMethod == 'wallet' ? l10n.paymentWallet : l10n.paymentCash, style: pw.TextStyle(font: bold, fontSize: 10)),
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
    AppLocalizations l10n,
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
            _tableHeaderCell(l10n.productHeaderA4, bold),
            _tableHeaderCell(l10n.quantity, bold),
            _tableHeaderCell(l10n.unitPrice, bold),
            _tableHeaderCell(l10n.grandTotalColumn, bold),
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
              _tableCell('${line.price.toStringAsFixed(2)} ${l10n.currencyEg}', regular, textDark: textDark),
              _tableCell('${line.total.toStringAsFixed(2)} ${l10n.currencyEg}', bold, textDark: textDark),
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
    AppLocalizations l10n,
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
              pw.Text(l10n.termsAndConditions, style: pw.TextStyle(font: bold, fontSize: 9.5, color: brandColor)),
              pw.SizedBox(height: 4),
              pw.Text(l10n.termsLine1, style: pw.TextStyle(font: regular, fontSize: 8, color: PdfColors.grey700)),
              pw.Text(l10n.termsLine2, style: pw.TextStyle(font: regular, fontSize: 8, color: PdfColors.grey700)),
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
              _summaryRow(l10n.subtotalLabel, '${data.subtotal.toStringAsFixed(2)} ${l10n.currencyEg}', regular, regular, textDark),
              if (data.discount > 0)
                _summaryRow(l10n.invoiceDiscountsLabel, '- ${data.discount.toStringAsFixed(2)} ${l10n.currencyEg}', regular, regular, accentColor),
              if (data.tax > 0)
                _summaryRow(l10n.valueAddedTax, '${data.tax.toStringAsFixed(2)} ${l10n.currencyEg}', regular, regular, textDark),
              
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
                      l10n.finalTotal, 
                      style: pw.TextStyle(font: bold, fontSize: 11, color: PdfColors.white),
                    ),
                    pw.Text(
                      '${data.grandTotal.toStringAsFixed(2)} ${l10n.currencyEg}', 
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

  static pw.Widget _buildA4Footer(InvoiceData data, pw.Font regular, pw.Font bold, PdfColor textMuted, AppLocalizations l10n) {
    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey300, thickness: 0.5),
        pw.SizedBox(height: 6),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              l10n.thankYouDealing, 
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
