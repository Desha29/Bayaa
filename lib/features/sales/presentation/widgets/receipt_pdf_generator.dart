import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:bayaa_pos/features/sales/data/models/sale_model.dart';
import 'package:bayaa_pos/features/settings/data/models/store_info_model.dart';
import 'package:bayaa_pos/l10n/app_localizations.dart';

class ReceiptPdfGenerator {
  static Future<Uint8List> generateReceipt({
    required Sale sale,
    required StoreInfo storeInfo,
    bool isThermal = true,
    required Locale locale,
  }) async {
    final pdf = pw.Document();
    final l10n = await AppLocalizations.delegate.load(locale);

    final arabicRegularData = await rootBundle.load('assets/fonts/Amiri-Regular.ttf');
    final arabicBoldData = await rootBundle.load('assets/fonts/Amiri-Bold.ttf');
    final regular = pw.Font.ttf(arabicRegularData);
    final bold = pw.Font.ttf(arabicBoldData);

    pw.MemoryImage? logoImage;
    if (storeInfo.logoPath != null && storeInfo.logoPath!.isNotEmpty) {
       try {
         final logoData = await rootBundle.load(storeInfo.logoPath!);
         logoImage = pw.MemoryImage(logoData.buffer.asUint8List());
       } catch (e) {
         // Fallback or ignore
       }
    }

    final format = isThermal 
        ? const PdfPageFormat(80 * PdfPageFormat.mm, double.infinity, marginAll: 5 * PdfPageFormat.mm)
        : PdfPageFormat.a4;

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        textDirection: locale.languageCode == 'ar' ? pw.TextDirection.rtl : pw.TextDirection.ltr,
        theme: pw.ThemeData.withFont(base: regular, bold: bold),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              if (logoImage != null) 
                pw.Container(
                  width: isThermal ? 40 : 80,
                  height: isThermal ? 40 : 80,
                  child: pw.Image(logoImage),
                ),
              pw.Text(storeInfo.name, style: pw.TextStyle(font: bold, fontSize: isThermal ? 16 : 24)),
              pw.Text(storeInfo.address, style: const pw.TextStyle(fontSize: 10)),
              pw.Text(l10n.receiptPhone(storeInfo.phone), style: const pw.TextStyle(fontSize: 10)),
              pw.Divider(),
              pw.Text(sale.isRefund ? l10n.refundInvoice : l10n.taxSalesInvoice, style: pw.TextStyle(font: bold, fontSize: 14)),
              pw.SizedBox(height: 5),
              _buildRow(l10n.invoiceNumberPdf, sale.id, regular),
              _buildRow(l10n.dateTimeLabel, _formatDate(sale.date), regular),
              _buildRow(l10n.responsibleCashier, sale.cashierName ?? 'Unknown', regular),
              pw.Divider(),
              _buildItemsTable(sale.saleItems, bold, regular, isThermal, l10n),
              pw.Divider(),
              _buildRow(l10n.grandTotalLabelPdf, '${sale.total.toStringAsFixed(2)} ${l10n.currencyEg}', bold, fontSize: 14),
              pw.SizedBox(height: 10),
              pw.Text(l10n.thankYouShopping, style: pw.TextStyle(font: regular, fontSize: 10)),
              if (storeInfo.vat.isNotEmpty)
                pw.Text(l10n.vatNumber(storeInfo.vat), style: const pw.TextStyle(fontSize: 8)),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildRow(String label, String value, pw.Font font, {double fontSize = 10}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: pw.TextStyle(font: font, fontSize: fontSize)),
        pw.Text(value, style: pw.TextStyle(font: font, fontSize: fontSize)),
      ],
    );
  }

  static pw.Widget _buildItemsTable(List<SaleItem> items, pw.Font bold, pw.Font regular, bool isThermal, AppLocalizations l10n) {
    return pw.TableHelper.fromTextArray(
      context: null,
      headers: [l10n.pdfProductHeader, l10n.pdfQtyHeader, l10n.pdfPriceHeader, l10n.pdfTotalHeader],
      data: items.map((i) => [
        i.name,
        i.quantity.toString(),
        i.price.toStringAsFixed(0),
        i.total.toStringAsFixed(0),
      ]).toList(),
      headerStyle: pw.TextStyle(font: bold, fontSize: 8),
      cellStyle: pw.TextStyle(font: regular, fontSize: 8),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(1.5),
      },
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
      border: null,
      cellAlignment: pw.Alignment.centerRight,
    );
  }

  static String _formatDate(DateTime date) => 
      '${date.year}/${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
}
