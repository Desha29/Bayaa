import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../features/arp/data/models/daily_report_model.dart';

class PdfReportGenerator {
  static Future<File> generateDailyReportPDF(
      DailyReport report, String filePath,
      {PdfPageFormat format = PdfPageFormat.a4}) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Daily Sales Report',
                    style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900)),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Date: ${report.date.day}/${report.date.month}/${report.date.year}',
                  style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
                ),
                pw.SizedBox(height: 20),
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.lightBlue100,
                    borderRadius: pw.BorderRadius.circular(10),
                  ),
                  child: pw.Column(
                    children: [
                      _buildSummaryRow('Total Sales', report.totalSales),
                      _buildSummaryRow('Total Refunds', report.totalRefunds),
                      _buildSummaryRow('Net Revenue', report.netRevenue),
                    ],
                  ),
                ),
                pw.SizedBox(height: 30),
                pw.Text('Top Products',
                    style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900)),
                pw.SizedBox(height: 10),
                pw.TableHelper.fromTextArray(
                  headers: ['Product Name', 'Qty Sold', 'Revenue', 'Profit'],
                  data: report.topProducts
                      .map((p) => [
                            p.productName,
                            p.quantitySold.toString(),
                            p.revenue.toStringAsFixed(2),
                            p.profit.toStringAsFixed(2)
                          ])
                      .toList(),
                  cellAlignment: pw.Alignment.centerLeft,
                  headerDecoration:
                      const pw.BoxDecoration(color: PdfColors.lightBlue300),
                  headerStyle: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                  cellHeight: 25,
                  cellAlignments: {
                    0: pw.Alignment.centerLeft,
                    1: pw.Alignment.center,
                    2: pw.Alignment.centerRight,
                    3: pw.Alignment.centerRight,
                  },
                )
              ],
            ),
          );
        },
      ),
    );

    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static pw.Widget _buildSummaryRow(String label, double value) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 6),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label,
              style:
                   pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.Text(value.toStringAsFixed(2)),
        ],
      ),
    );
  }
}
