import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../data/models/dialy_report_model.dart';

import 'package:crazy_phone_pos/core/constants/app_colors.dart';

// PDF Color helpers based on AppColors
class PdfAppColors {
  static const mutedColor = PdfColors.grey600;
  static const mutedColor200 = PdfColor.fromInt(0xFFE5E7EB);
  static const mutedColor600 = PdfColors.grey600;
  static const mutedColor700 = PdfColors.grey700;
  static const mutedColor800 = PdfColors.grey800;
}

class DailyReportPdfService {
  static Future<Uint8List> generateDailyReportPDF(
    DailyReportModel report, {
    bool landscape = false,
  }) async {
    final pdf = pw.Document();

    // تحميل الخطوط العربية (Regular + Bold)
    final arabicRegularFontData =
        await rootBundle.load('assets/fonts/Amiri-Regular.ttf');
    final arabicBoldFontData =
        await rootBundle.load('assets/fonts/Amiri-Bold.ttf');

    final arabicRegularFont = pw.Font.ttf(arabicRegularFontData);
    final arabicBoldFont = pw.Font.ttf(arabicBoldFontData);

    // تحميل اللوجو
    final logoData = await rootBundle.load('assets/images/logo.jpg');
    final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());

    // إعداد الصفحة (A4 عمودي أو أفقي)
    final pageFormat =
        landscape ? PdfPageFormat.a4.landscape : PdfPageFormat.a4;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        margin: const pw.EdgeInsets.all(28),
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(
          base: arabicRegularFont,
          bold: arabicBoldFont,
        ),
        build: (context) => [
          _buildHeader(logoImage, arabicBoldFont),
          pw.SizedBox(height: 15),
          _buildReportInfo(report, arabicBoldFont),
          pw.SizedBox(height: 20),
          _buildSummarySection(report, arabicBoldFont),
          pw.SizedBox(height: 20),
          _buildProductTable(report, arabicRegularFont, arabicBoldFont),
          pw.SizedBox(height: 25),
          _buildFooter(arabicRegularFont),
        ],
      ),
    );

    return pdf.save();
  }

  /// ------------------------- HEADER -------------------------
  static pw.Widget _buildHeader(pw.MemoryImage logo, pw.Font boldFont) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'تقرير المبيعات اليومية',
              style: pw.TextStyle(
                font: boldFont,
                fontWeight: pw.FontWeight.bold,
                fontSize: 22,
                color: PdfColors.black,
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              'نظام نقاط البيع المتطور - Amr Store',
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
  static pw.Widget _buildReportInfo(DailyReportModel report, pw.Font boldFont) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfAppColors.mutedColor600, width: 0.8),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          _infoItem('تاريخ التقرير:', _formatDate(report.date), boldFont),
          _infoItem('عدد المنتجات:', '${report.topProducts.length}', boldFont),
          _infoItem('إجمالي الإيرادات:',
              '${report.totalRevenue.toStringAsFixed(2)} ج.م', boldFont),
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
  static pw.Widget _buildSummarySection(DailyReportModel report, pw.Font boldFont) {
    final totalSold =
        report.topProducts.fold<int>(0, (prev, e) => prev + e.quantitySold);
    final avgValue = report.topProducts.isEmpty
        ? 0.0
        : report.totalRevenue / report.topProducts.length;

    final summaries = [
      _summaryBox('إجمالي الإيرادات',
          '${report.totalRevenue.toStringAsFixed(2)} ج.م', boldFont),
      _summaryBox('إجمالي الأرباح',
          '${report.totalProfit.toStringAsFixed(2)} ج.م', boldFont),
      _summaryBox('إجمالي التكاليف',
          '${report.totalCost.toStringAsFixed(2)} ج.م', boldFont),
      _summaryBox('إجمالي المنتجات المباعة', '$totalSold وحدة', boldFont),
      _summaryBox('عدد المنتجات المختلفة', '${report.topProducts.length}', boldFont),
      _summaryBox('متوسط قيمة المنتج',
          '${avgValue.toStringAsFixed(2)} ج.م', boldFont),
    ];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'ملخص الأداء اليومي',
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
  static pw.Widget _buildProductTable(
      DailyReportModel report, pw.Font font, pw.Font boldFont) {
    final headers = [
      'المنتج',
      'الكمية',
      'سعر الوحدة',
      'الإيرادات',
      'التكلفة',
      'الأرباح',
      'هامش الربح'
    ];

    final data = report.topProducts.map((p) {
      final qty = p.quantitySold;
      final revenue = p.revenue;
      final cost = p.cost;
      final profit = p.profit;
      final margin = p.profitMargin;
      final unitPrice = qty > 0 ? revenue / qty : 0.0;
      return [
        p.productName,
        qty.toString(),
        '${unitPrice.toStringAsFixed(2)}',
        '${revenue.toStringAsFixed(2)}',
        '${cost.toStringAsFixed(2)}',
        '${profit.toStringAsFixed(2)}',
        '${margin.toStringAsFixed(1)}%',
      ];
    }).toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'تفاصيل المنتجات المباعة',
          style: pw.TextStyle(
            font: boldFont,
            fontSize: 17,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        // Using TableHelper instead of deprecated Table.fromTextArray
        pw.TableHelper.fromTextArray(
          headers: headers,
          data: data,
          headerStyle: pw.TextStyle(
            font: boldFont,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.black,
          ),
          headerDecoration: const pw.BoxDecoration(color: PdfAppColors.mutedColor200),
          cellStyle: pw.TextStyle(
            font: boldFont,
            fontSize: 11,
            color: PdfColors.black,
            fontWeight: pw.FontWeight.bold,
          ),
          border: pw.TableBorder.all(color: PdfAppColors.mutedColor700, width: 0.5),
          cellAlignment: pw.Alignment.center,
          headerAlignment: pw.Alignment.center,
          cellHeight: 26,
        ),
      ],
    );
  }

  /// ------------------------- FOOTER -------------------------
  static pw.Widget _buildFooter(pw.Font font) {
    return pw.Container(
      alignment: pw.Alignment.center,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfAppColors.mutedColor600, width: 0.5)),
      ),
      child: pw.Column(children: [
        pw.Text(
          'تم إنشاء التقرير في: ${_formatDateTime(DateTime.now())}',
          style: pw.TextStyle(font: font, fontSize: 10, color: PdfAppColors.mutedColor700),
        ),
        pw.SizedBox(height: 3),
        pw.Text(
          '© 2025 Amr Store POS - جميع الحقوق محفوظة',
          style: pw.TextStyle(font: font, fontSize: 10, color: PdfAppColors.mutedColor700),
        ),
      ]),
    );
  }

  /// ------------------------- HELPERS -------------------------
  static String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  static String _formatDateTime(DateTime dateTime) =>
      '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} - ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
}
