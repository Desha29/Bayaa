import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../l10n/app_localizations.dart';
import '../data/models/daily_report_model.dart';

class PdfAppColors {
  static const mutedColor = PdfColors.grey600;
  static const mutedColor200 = PdfColor.fromInt(0xFFE5E7EB);
  static const mutedColor600 = PdfColors.grey600;
  static const mutedColor700 = PdfColors.grey700;
  static const mutedColor800 = PdfColors.grey800;
}

class DailyReportPdfService {
  static Future<Uint8List> generateDailyReportPDF(
    DailyReport report, {
    bool landscape = false,
    required Locale locale,
  }) async {
    final pdf = pw.Document();
    final l10n = await AppLocalizations.delegate.load(locale);

    // تحميل الخطوط العربية (Regular + Bold)
    final arabicRegularFontData =
        await rootBundle.load('assets/fonts/Amiri-Regular.ttf');
    final arabicBoldFontData =
        await rootBundle.load('assets/fonts/Amiri-Bold.ttf');

    final arabicRegularFont = pw.Font.ttf(arabicRegularFontData);
    final arabicBoldFont = pw.Font.ttf(arabicBoldFontData);

    // تحميل اللوجو
    final logoData = await rootBundle.load('assets/images/logo.png');
    final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());

    // إعداد الصفحة (A4 عمودي أو أفقي)
    final pageFormat =
        landscape ? PdfPageFormat.a4.landscape : PdfPageFormat.a4;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        margin: const pw.EdgeInsets.all(28),
        textDirection: locale.languageCode == 'ar'
            ? pw.TextDirection.rtl
            : pw.TextDirection.ltr,
        theme: pw.ThemeData.withFont(
          base: arabicRegularFont,
          bold: arabicBoldFont,
        ),
        build: (context) => [
          _buildHeader(logoImage, arabicBoldFont, l10n),
          pw.SizedBox(height: 15),
          _buildReportInfo(report, arabicBoldFont, l10n),
          pw.SizedBox(height: 20),
          _buildSummarySection(report, arabicBoldFont, l10n),
          pw.SizedBox(height: 20),
          _buildProductTable(report, arabicRegularFont, arabicBoldFont, l10n),
          pw.SizedBox(height: 25),
          _buildFooter(arabicRegularFont, l10n),
        ],
      ),
    );

    return pdf.save();
  }

  /// ------------------------- HEADER -------------------------
  static pw.Widget _buildHeader(
      pw.MemoryImage logo, pw.Font boldFont, AppLocalizations l10n) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              l10n.dailySalesReport,
              style: pw.TextStyle(
                font: boldFont,
                fontWeight: pw.FontWeight.bold,
                fontSize: 22,
                color: PdfColor.fromInt(0xFF1E3A8A), // Bayaa Primary Blue
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              l10n.advancedPosSystem,
              style: pw.TextStyle(
                font: boldFont,
                fontSize: 13,
                color: PdfAppColors.mutedColor700,
              ),
            ),
          ],
        ),
        pw.Container(
          width: 70,
          height: 70,
          decoration: pw.BoxDecoration(
            shape: pw.BoxShape.circle,
            border: pw.Border.all(color: PdfAppColors.mutedColor600, width: 1),
          ),
          child: pw.ClipOval(child: pw.Image(logo)),
        ),
      ],
    );
  }

  /// ------------------------- REPORT INFO -------------------------
  static pw.Widget _buildReportInfo(
      DailyReport report, pw.Font boldFont, AppLocalizations l10n) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfAppColors.mutedColor600, width: 0.8),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          _infoItem(l10n.reportDateLabel, _formatDate(report.date), boldFont),
          _infoItem(l10n.transactionCountLabel, '${report.totalTransactions}',
              boldFont),
          _infoItem(
              l10n.netRevenueLabel,
              '${report.netRevenue.toStringAsFixed(2)} ${l10n.currencyEg}',
              boldFont),
        ],
      ),
    );
  }

  static pw.Widget _infoItem(String title, String value, pw.Font boldFont) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            font: boldFont,
            fontSize: 12,
            color: PdfAppColors.mutedColor800,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            font: boldFont,
            fontSize: 13,
            color: PdfColors.black,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// ------------------------- SUMMARY SECTION -------------------------
  static pw.Widget _buildSummarySection(
      DailyReport report, pw.Font boldFont, AppLocalizations l10n) {
    final summaries = [
      _summaryBox(
          l10n.totalSalesLabel,
          '${report.totalSales.toStringAsFixed(2)} ${l10n.currencyEg}',
          boldFont),
      _summaryBox(
          l10n.totalRefundsLabel,
          '${report.totalRefunds.toStringAsFixed(2)} ${l10n.currencyEg}',
          boldFont),
      _summaryBox(
          l10n.netProfitLabel,
          '${report.netRevenue.toStringAsFixed(2)} ${l10n.currencyEg}',
          boldFont),
      _summaryBox(
          l10n.transactionCountLabel, '${report.totalTransactions}', boldFont),
      _summaryBox(l10n.closedByLabel,
          _translateUserName(report.closedByUserName, l10n), boldFont),
    ];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          l10n.dailyPerformanceSummary,
          style: pw.TextStyle(
            font: boldFont,
            fontSize: 17,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Wrap(spacing: 10, runSpacing: 10, children: summaries),
      ],
    );
  }

  static pw.Widget _summaryBox(String title, String value, pw.Font boldFont) {
    return pw.Container(
      width: 160,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfAppColors.mutedColor700, width: 0.8),
        borderRadius: pw.BorderRadius.circular(8),
        color: PdfColors.white,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 12,
              color: PdfAppColors.mutedColor800,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            value,
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 13,
              color: PdfColors.black,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// ------------------------- PRODUCT TABLE -------------------------
  static pw.Widget _buildProductTable(DailyReport report, pw.Font font,
      pw.Font boldFont, AppLocalizations l10n) {
    final headers = [
      l10n.productColumn,
      l10n.quantity,
      l10n.netRevenueLabel,
      l10n.costLabel,
      l10n.profitLabel,
      l10n.profitMarginLabel
    ];

    final data = report.topProducts.map((p) {
      return [
        p.productName,
        p.quantitySold.toString(),
        '${p.revenue.toStringAsFixed(2)}',
        '${p.cost.toStringAsFixed(2)}',
        '${p.profit.toStringAsFixed(2)}',
        '${p.profitMargin.toStringAsFixed(1)}%',
      ];
    }).toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          l10n.topProductsPerformance,
          style: pw.TextStyle(
            font: boldFont,
            fontSize: 17,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.TableHelper.fromTextArray(
          headers: headers,
          data: data,
          headerStyle: pw.TextStyle(
            font: boldFont,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.black,
          ),
          headerDecoration:
              const pw.BoxDecoration(color: PdfAppColors.mutedColor200),
          cellStyle: pw.TextStyle(
            font: boldFont,
            fontSize: 11,
            color: PdfColors.black,
            fontWeight: pw.FontWeight.bold,
          ),
          border:
              pw.TableBorder.all(color: PdfAppColors.mutedColor700, width: 0.5),
          cellAlignment: pw.Alignment.center,
          headerAlignment: pw.Alignment.center,
          cellHeight: 26,
        ),
      ],
    );
  }

  /// ------------------------- FOOTER -------------------------
  static pw.Widget _buildFooter(pw.Font font, AppLocalizations l10n) {
    return pw.Container(
      alignment: pw.Alignment.center,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border(
            top: pw.BorderSide(color: PdfAppColors.mutedColor600, width: 0.5)),
      ),
      child: pw.Column(children: [
        pw.Text(
          l10n.reportCreatedAt(_formatDateTime(DateTime.now())),
          style: pw.TextStyle(
              font: font, fontSize: 10, color: PdfAppColors.mutedColor700),
        ),
        pw.SizedBox(height: 3),
        pw.Text(
          '© 2026 Bayaa POS - ${l10n.allRightsReserved}',
          style: pw.TextStyle(
              font: font, fontSize: 10, color: PdfAppColors.mutedColor700),
        ),
      ]),
    );
  }

  /// ------------------------- HELPERS -------------------------
  static String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  static String _formatDateTime(DateTime dateTime) =>
      '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} - ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';

  static String _translateUserName(String name, AppLocalizations l10n) {
    if (name == 'System Administrator' || name == 'مدير النظام')
      return l10n.roleManager;
    if (name == 'Trial Cashier' || name == 'كاشير تجريبي')
      return l10n.trialCashier;
    return name;
  }
}
