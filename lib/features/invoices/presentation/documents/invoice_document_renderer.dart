import 'package:flutter/foundation.dart';
import 'dart:ui';
import 'package:bayaa_pos/preview/branch_preview_controller.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:barcode/barcode.dart';
import 'package:bayaa_pos/shared/theme/app_colors.dart';
import 'package:bayaa_pos/l10n/app_localizations.dart';
import 'package:bayaa_pos/features/invoices/presentation/models/invoice_document_view_data.dart';
import 'package:bayaa_pos/features/settings/presentation/models/store_view_data.dart';
import 'package:bayaa_pos/app/bootstrap/service_locator.dart';
import 'package:bayaa_pos/preview/sources/sample_store_source.dart';

class InvoiceDocumentRenderer {
  static String _paymentLabel(String method, AppLocalizations l) {
    final ar = l.localeName == 'ar';
    return switch (method) {
      'card' => ar ? 'بطاقة' : 'Card',
      'bank' => ar ? 'تحويل بنكي' : 'Bank transfer',
      'vodafone' => ar ? 'فودافون كاش' : 'Vodafone Cash',
      'orange' => ar ? 'أورنج كاش' : 'Orange Cash',
      'etisalat' => ar ? 'اتصالات كاش' : 'Etisalat Cash',
      'wallet' => l.paymentWallet,
      _ => l.paymentCash,
    };
  }

  static pw.TextDirection _contentDirection(String value) =>
      RegExp(r'[\u0600-\u06FF]').hasMatch(value)
          ? pw.TextDirection.rtl
          : pw.TextDirection.ltr;

  static pw.Font? _cachedArabicFont;
  static pw.Font? _cachedBoldFont;
  static final Map<String, pw.ImageProvider?> _logoCache = {};

  static Future<pw.ImageProvider> _previewLogo(Uint8List bytes) async {
    // The source logos are up to 1600px; the document displays them at 64pt.
    // Resize with the platform codec before PDF encoding to avoid UI-thread
    // decoding/compression of several million pixels on every format change.
    final codec = await instantiateImageCodec(bytes,
        targetWidth: 256, allowUpscaling: false);
    try {
      final frame = await codec.getNextFrame();
      try {
        final png = await frame.image.toByteData(format: ImageByteFormat.png);
        return pw.MemoryImage(png!.buffer.asUint8List());
      } finally {
        frame.image.dispose();
      }
    } finally {
      codec.dispose();
    }
  }

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

  static Future<pw.ImageProvider?> _loadLogo(String? logoPath,
      {required Locale locale}) async {
    final cacheKey = '${logoPath ?? ''}_${locale.languageCode}';
    if (_logoCache.containsKey(cacheKey)) return _logoCache[cacheKey];

    if (logoPath != null && logoPath.isNotEmpty) {
      try {
        final bytes = await rootBundle.load(logoPath);
        final image = await _previewLogo(bytes.buffer.asUint8List());
        _logoCache[cacheKey] = image;
        return image;
      } catch (e) {
        debugPrint('❌ Error loading logo from $logoPath: $e');
      }
    }

    // Fallback logo
    try {
      final fallbackPath = locale.languageCode == 'en'
          ? 'assets/images/logo_en.png'
          : 'assets/images/logo.png';
      final bytes = await rootBundle.load(fallbackPath);
      final image = await _previewLogo(bytes.buffer.asUint8List());
      _logoCache[cacheKey] = image;
      return image;
    } catch (e) {
      _logoCache[cacheKey] = null;
      return null;
    }
  }

  /// Display-only 80mm roll document; height follows the wrapped content.
  static Future<Uint8List> buildReceipt80mm(InvoiceData data,
      {required Locale locale}) async {
    final l10n = await AppLocalizations.delegate.load(locale);
    final regular = await _loadArabicFont();
    final bold = await _loadBoldFont();
    final storeResult = await getIt<SampleStoreSource>().getStoreInfo();
    final store = storeResult.getOrElse(() => StoreViewData(
        name: 'Bayaa POS', address: '', phone: '', vat: '', email: ''));
    final logo = data.logoBytes != null
        ? await _previewLogo(data.logoBytes!)
        : await _loadLogo(data.logoAsset ?? store.logoPath, locale: locale);
    final brand = PdfColor.fromInt(AppColors.primaryColor.toARGB32());
    final accent = PdfColor.fromInt(AppColors.accentColor.toARGB32());
    final onBrand = PdfColor.fromInt(AppColors.primaryForeground.toARGB32());
    final ink = PdfColor.fromInt(0xFF0F172A);
    final muted = PdfColor.fromInt(0xFF64748B);
    final border = PdfColor.fromInt(0xFFE2E8F0);
    final arabic = locale.languageCode == 'ar';
    final name = data.storeName.isNotEmpty ? data.storeName : store.name;
    final address =
        data.storeAddress.isNotEmpty ? data.storeAddress : store.address;
    final phone = data.storePhone.isNotEmpty ? data.storePhone : store.phone;
    final document =
        pw.Document(theme: pw.ThemeData.withFont(base: regular, bold: bold));
    document.addPage(pw.Page(
      pageFormat: const PdfPageFormat(80 * PdfPageFormat.mm, double.infinity,
          marginAll: 4 * PdfPageFormat.mm),
      textDirection: arabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
      build: (context) => pw
          .Column(crossAxisAlignment: pw.CrossAxisAlignment.stretch, children: [
        if (logo != null)
          pw.Center(
              child: pw.Container(
                  width: 120,
                  height: 40,
                  margin: const pw.EdgeInsets.only(bottom: 7),
                  child: pw.Image(logo, fit: pw.BoxFit.contain))),
        pw.Text(name.isEmpty || name == 'Bayaa POS' ? l10n.appName : name,
            textDirection: _contentDirection(name),
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(font: bold, fontSize: 14, color: brand)),
        if (address.isNotEmpty)
          pw.Padding(
              padding: const pw.EdgeInsets.only(top: 3),
              child: pw.Text(address,
                  textDirection: _contentDirection(address),
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(fontSize: 8, color: muted))),
        if (phone.isNotEmpty)
          pw.Text(l10n.receiptPhone(phone),
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(fontSize: 8, color: muted)),
        if (store.vat.isNotEmpty)
          pw.Text(l10n.vatNumber(store.vat),
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(fontSize: 7.5, color: muted)),
        pw.SizedBox(height: 8),
        pw.Container(height: 2, color: accent),
        pw.SizedBox(height: 8),
        pw.Text(l10n.taxSalesReceipt,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(font: bold, fontSize: 11, color: brand)),
        pw.SizedBox(height: 7),
        _receiptMetaRow(l10n.invoiceNumberPdf, data.invoiceId, regular, bold),
        if (data.branchId case final branch?)
          _receiptMetaRow(arabic ? 'الفرع' : 'Branch',
              BranchPreviewController.labelFor(branch, arabic), regular, bold),
        _receiptMetaRow(l10n.dateTimeLabel, _fmt(data.date), regular, bold),
        _receiptMetaRow(
            l10n.responsibleCashier, data.cashierName, regular, bold),
        _receiptMetaRow(l10n.paymentMethodLabel,
            _paymentLabel(data.paymentMethod, l10n), regular, bold),
        pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 8),
            child: pw.Divider(color: border, thickness: .7)),
        pw.Table(columnWidths: {
          0: const pw.FlexColumnWidth(3.2),
          1: const pw.FlexColumnWidth(.8),
          2: const pw.FlexColumnWidth(1.45),
          3: const pw.FlexColumnWidth(1.55)
        }, children: [
          pw.TableRow(decoration: pw.BoxDecoration(color: brand), children: [
            for (final label in [
              l10n.pdfProductHeader,
              l10n.pdfQtyHeader,
              l10n.pdfPriceHeader,
              l10n.pdfTotalHeader
            ])
              pw.Padding(
                  padding:
                      const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 5),
                  child: pw.Text(label,
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                          font: bold, fontSize: 7.5, color: onBrand))),
          ]),
          for (var i = 0; i < data.lines.length; i++)
            pw.TableRow(
                decoration: pw.BoxDecoration(
                    color: i.isOdd
                        ? PdfColor.fromInt(0xFFF8FAFC)
                        : PdfColors.white,
                    border: pw.Border(
                        bottom: pw.BorderSide(color: border, width: .4))),
                children: [
                  pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 3, vertical: 6),
                      child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(data.lines[i].name,
                                textDirection:
                                    _contentDirection(data.lines[i].name),
                                style: pw.TextStyle(
                                    font: bold, fontSize: 8, color: ink)),
                            if (data.lines[i].barcode?.isNotEmpty ?? false)
                              pw.Text(data.lines[i].barcode!,
                                  textDirection: pw.TextDirection.ltr,
                                  style: pw.TextStyle(
                                      fontSize: 6.5, color: muted)),
                          ])),
                  for (final value in [
                    data.lines[i].qty.toString(),
                    data.lines[i].price.toStringAsFixed(2),
                    data.lines[i].total.toStringAsFixed(2)
                  ])
                    pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(
                            horizontal: 2, vertical: 6),
                        child: pw.Text(value,
                            textDirection: _contentDirection(value),
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(fontSize: 7.5, color: ink))),
                ]),
        ]),
        pw.SizedBox(height: 8),
        _receiptMetaRow(
            l10n.itemsTotalLabel,
            '${data.subtotal.toStringAsFixed(2)} ${l10n.currencyEg}',
            regular,
            bold,
            fontSize: 8.5),
        if (data.discount > 0)
          _receiptMetaRow(
              l10n.appliedDiscount,
              '- ${data.discount.toStringAsFixed(2)} ${l10n.currencyEg}',
              regular,
              bold,
              fontSize: 8.5,
              color: accent),
        if (data.tax > 0)
          _receiptMetaRow(
              l10n.valueAddedTax,
              '${data.tax.toStringAsFixed(2)} ${l10n.currencyEg}',
              regular,
              bold,
              fontSize: 8.5),
        pw.SizedBox(height: 6),
        pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 7),
            decoration: pw.BoxDecoration(
                color: brand,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5))),
            child: _receiptMetaRow(
                l10n.grandTotalLabelPdf,
                '${data.grandTotal.toStringAsFixed(2)} ${l10n.currencyEg}',
                bold,
                bold,
                fontSize: 10,
                color: onBrand)),
        pw.SizedBox(height: 12),
        pw.Text(l10n.thankYouShopping,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(font: bold, fontSize: 9, color: ink)),
        if (data.footerNote?.isNotEmpty ?? false)
          pw.Padding(
              padding: const pw.EdgeInsets.only(top: 4),
              child: pw.Text(data.footerNote!,
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(fontSize: 7.5, color: muted))),
        pw.SizedBox(height: 9),
        if (data.invoiceId.isNotEmpty &&
            data.invoiceId.codeUnits.every((c) => c >= 32 && c <= 126))
          pw.Center(
              child: pw.BarcodeWidget(
                  barcode: Barcode.code128(),
                  data: data.invoiceId,
                  width: 120,
                  height: 26,
                  drawText: false)),
        pw.SizedBox(height: 4),
        pw.Text(data.invoiceId,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(fontSize: 7, color: ink)),
        pw.SizedBox(height: 7),
        pw.Text(l10n.posSystemName,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(fontSize: 7, color: brand)),
        pw.Text(
            arabic
                ? 'نسخة معاينة • بدون طباعة أو حفظ'
                : 'Preview copy • no printing or saving',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(fontSize: 6.5, color: muted)),
      ]),
    ));
    return document.save();
  }

  static pw.Widget _receiptMetaRow(
          String label, String value, pw.Font font, pw.Font bold,
          {double fontSize = 8, PdfColor? color}) =>
      pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 2),
          child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                    flex: 4,
                    child: pw.Text(label,
                        style: pw.TextStyle(
                            font: font,
                            fontSize: fontSize,
                            color: color ?? PdfColors.grey700))),
                pw.SizedBox(width: 6),
                pw.Expanded(
                    flex: 6,
                    child: pw.Text(value,
                        textDirection: _contentDirection(value),
                        textAlign: pw.TextAlign.end,
                        style: pw.TextStyle(
                            font: bold,
                            fontSize: fontSize,
                            color: color ?? PdfColor.fromInt(0xFF0F172A)))),
              ]));
  static Future<Uint8List> buildA4(InvoiceData data,
      {PdfPageFormat? format, required Locale locale}) async {
    final doc = pw.Document();
    final l10n = await AppLocalizations.delegate.load(locale);

    final arabicFont = await _loadArabicFont();
    final boldFont = await _loadBoldFont();

    // Premium Corporate Colors
    final brandBlue = PdfColor.fromInt(AppColors.primaryColor.toARGB32());
    final brandOrange = PdfColor.fromInt(AppColors.accentColor.toARGB32());
    final bgLight = PdfColor.fromInt(0xFFF8FAFC); // Very light slate
    final borderLight = PdfColor.fromInt(0xFFE2E8F0); // Border slate
    final textDark = PdfColor.fromInt(0xFF0F172A); // Dark slate text
    final textMuted = PdfColor.fromInt(0xFF64748B); // Muted slate text

    final storeRepo = getIt<SampleStoreSource>();
    final storeInfoResult = await storeRepo.getStoreInfo();
    final storeInfo = storeInfoResult.getOrElse(() => StoreViewData(
          name: 'Bayaa POS',
          address: 'Cairo, Arab Republic of Egypt',
          phone: '0100000000',
          vat: '',
          email: '',
        ));
    final logoProvider = await _loadLogo(storeInfo.logoPath, locale: locale);

    doc.addPage(
      pw.MultiPage(
        pageFormat: format ?? PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(1.5 * PdfPageFormat.cm),
        textDirection: locale.languageCode == 'ar'
            ? pw.TextDirection.rtl
            : pw.TextDirection.ltr,
        theme: pw.ThemeData.withFont(base: arabicFont, bold: boldFont),
        build: (context) => [
          // 1. Header Banner
          _buildA4Header(storeInfo, logoProvider, boldFont, arabicFont,
              brandBlue, brandOrange, textMuted, l10n),

          pw.SizedBox(height: 18),

          // 2. Invoice Details Box
          _buildA4InvoiceInfoBox(data, boldFont, arabicFont, bgLight,
              borderLight, brandBlue, l10n),

          pw.SizedBox(height: 20),

          // 3. Products Table
          _buildA4ItemsTable(data, boldFont, arabicFont, brandBlue, borderLight,
              bgLight, textDark, l10n),

          pw.SizedBox(height: 20),

          // 4. Totals and Summary Box
          _buildA4SummaryRow(data, boldFont, arabicFont, brandBlue, brandOrange,
              bgLight, borderLight, textDark, l10n),

          pw.Spacer(),

          // 5. Barcode & Footer
          _buildA4Footer(data, arabicFont, boldFont, textMuted, l10n),
        ],
      ),
    );

    return doc.save();
  }

  static pw.Widget _buildA4Header(
    StoreViewData store,
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
                textDirection: _contentDirection(store.name),
                style:
                    pw.TextStyle(font: bold, fontSize: 20, color: brandColor)),
            pw.SizedBox(height: 4),
            if (store.address.isNotEmpty)
              pw.Text(store.address,
                  textDirection: _contentDirection(store.address),
                  style: pw.TextStyle(
                      font: regular, fontSize: 9.5, color: textMuted)),
            if (store.phone.isNotEmpty)
              pw.Text(l10n.receiptPhone(store.phone),
                  style: pw.TextStyle(
                      font: regular, fontSize: 9.5, color: textMuted)),
            if (store.vat.isNotEmpty)
              pw.Text('${l10n.enterpriseTaxNumber} ${store.vat}',
                  style: pw.TextStyle(
                      font: regular, fontSize: 9.5, color: textMuted)),
          ],
        ),

        // Document Title
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(l10n.taxSalesInvoice,
                style:
                    pw.TextStyle(font: bold, fontSize: 22, color: brandColor)),
            pw.Text('TAX INVOICE',
                style:
                    pw.TextStyle(font: bold, fontSize: 13, color: accentColor)),
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
                  pw.Text(l10n.invoiceNumberPdf,
                      style: pw.TextStyle(
                          font: bold, fontSize: 11, color: brandColor)),
                  pw.Text(data.invoiceId,
                      style: pw.TextStyle(font: bold, fontSize: 11)),
                ],
              ),
              pw.SizedBox(height: 6),
              pw.Row(
                children: [
                  pw.Text('${l10n.dateTimeLabel} ',
                      style: pw.TextStyle(
                          font: regular, fontSize: 10, color: brandColor)),
                  pw.Text(_fmt(data.date),
                      style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
              if (data.branchId case final branch?) ...[
                pw.SizedBox(height: 6),
                pw.Text(
                    BranchPreviewController.labelFor(
                        branch, l10n.localeName == 'ar'),
                    textDirection: l10n.localeName == 'ar'
                        ? pw.TextDirection.rtl
                        : pw.TextDirection.ltr,
                    style: pw.TextStyle(
                        font: bold, fontSize: 10, color: brandColor)),
              ],
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Row(
                children: [
                  pw.Text(l10n.responsibleCashier,
                      style: pw.TextStyle(
                          font: regular, fontSize: 10, color: brandColor)),
                  pw.Text(
                    (data.cashierName == 'System Administrator' ||
                            data.cashierName == 'مدير النظام')
                        ? l10n.roleManager
                        : (data.cashierName == 'Trial Cashier' ||
                                data.cashierName == 'كاشير تجريبي')
                            ? l10n.trialCashier
                            : data.cashierName,
                    textDirection: _contentDirection(data.cashierName),
                    style: pw.TextStyle(font: bold, fontSize: 10),
                  ),
                ],
              ),
              pw.SizedBox(height: 6),
              pw.Row(
                children: [
                  pw.Text(l10n.invoiceStatusLabel,
                      style: pw.TextStyle(
                          font: regular, fontSize: 10, color: brandColor)),
                  pw.Text(
                      data.isDraftPreview
                          ? (l10n.localeName == 'ar' ? 'معاينة' : 'Preview')
                          : l10n.fullyPaid,
                      style: pw.TextStyle(
                          font: bold,
                          fontSize: 10,
                          color: data.isDraftPreview
                              ? brandColor
                              : PdfColor.fromInt(0xFF22C55E))),
                ],
              ),
              pw.SizedBox(height: 6),
              pw.Row(
                children: [
                  pw.Text('${l10n.paymentMethodLabel}: ',
                      style: pw.TextStyle(
                          font: regular, fontSize: 10, color: brandColor)),
                  pw.Text(_paymentLabel(data.paymentMethod, l10n),
                      style: pw.TextStyle(font: bold, fontSize: 10)),
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
        0: const pw.FlexColumnWidth(4), // ProductViewData name
        1: const pw.FlexColumnWidth(1.2), // Quantity
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
              _tableCell(line.name, regular,
                  align: pw.TextAlign.right, textDark: textDark),
              _tableCell(line.qty.toString(), regular, textDark: textDark),
              _tableCell('${line.price.toStringAsFixed(2)} ${l10n.currencyEg}',
                  regular,
                  textDark: textDark),
              _tableCell(
                  '${line.total.toStringAsFixed(2)} ${l10n.currencyEg}', bold,
                  textDark: textDark),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _tableHeaderCell(String text, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      child: pw.Text(
        text,
        style: pw.TextStyle(font: font, color: PdfColors.white, fontSize: 10),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static pw.Widget _tableCell(String text, pw.Font font,
      {pw.TextAlign align = pw.TextAlign.center, PdfColor? textDark}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: pw.Text(
        text,
        textDirection: _contentDirection(text),
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
              pw.Text(l10n.termsAndConditions,
                  style: pw.TextStyle(
                      font: bold, fontSize: 9.5, color: brandColor)),
              pw.SizedBox(height: 4),
              pw.Text(l10n.termsLine1,
                  style: pw.TextStyle(
                      font: regular, fontSize: 8, color: PdfColors.grey700)),
              pw.Text(l10n.termsLine2,
                  style: pw.TextStyle(
                      font: regular, fontSize: 8, color: PdfColors.grey700)),
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
              _summaryRow(
                  l10n.subtotalLabel,
                  '${data.subtotal.toStringAsFixed(2)} ${l10n.currencyEg}',
                  regular,
                  regular,
                  textDark),
              if (data.discount > 0)
                _summaryRow(
                    l10n.invoiceDiscountsLabel,
                    '- ${data.discount.toStringAsFixed(2)} ${l10n.currencyEg}',
                    regular,
                    regular,
                    accentColor),
              if (data.tax > 0)
                _summaryRow(
                    l10n.valueAddedTax,
                    '${data.tax.toStringAsFixed(2)} ${l10n.currencyEg}',
                    regular,
                    regular,
                    textDark),
              pw.Container(
                decoration: pw.BoxDecoration(
                  color: brandColor,
                  borderRadius: const pw.BorderRadius.vertical(
                      bottom: pw.Radius.circular(9)),
                ),
                padding:
                    const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      l10n.finalTotal,
                      style: pw.TextStyle(
                          font: bold, fontSize: 11, color: PdfColors.white),
                    ),
                    pw.Text(
                      '${data.grandTotal.toStringAsFixed(2)} ${l10n.currencyEg}',
                      style: pw.TextStyle(
                          font: bold, fontSize: 12, color: PdfColors.white),
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

  static pw.Widget _summaryRow(String label, String value, pw.Font labelFont,
      pw.Font valueFont, PdfColor? color) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label,
              style: pw.TextStyle(
                  font: labelFont, fontSize: 9.5, color: PdfColors.grey700)),
          pw.Text(value,
              textDirection: _contentDirection(value),
              style:
                  pw.TextStyle(font: valueFont, fontSize: 9.5, color: color)),
        ],
      ),
    );
  }

  static pw.Widget _buildA4Footer(InvoiceData data, pw.Font regular,
      pw.Font bold, PdfColor textMuted, AppLocalizations l10n) {
    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey300, thickness: 0.5),
        pw.SizedBox(height: 6),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              l10n.thankYouDealing,
              style: pw.TextStyle(
                  font: bold,
                  fontSize: 9.5,
                  color: PdfColor.fromInt(0xFF1E3A8A)),
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
      '${d.year}/${_twoDigits(d.month)}/${_twoDigits(d.day)} ${_twoDigits(d.hour)}:${_twoDigits(d.minute)}';
  static String _twoDigits(int x) => x.toString().padLeft(2, '0');
}
