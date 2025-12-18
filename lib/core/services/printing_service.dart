import 'dart:typed_data';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

class PrintingService {
  static Future<void> printPdf(Uint8List data, {String name = 'Document'}) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => data,
      name: name,
    );
  }

  static Future<void> sharePdf(Uint8List data, {String name = 'document.pdf'}) async {
    await Printing.sharePdf(bytes: data, filename: name);
  }

  // Handy for thermal printers where we might want to pick a specific printer or settings
  static Future<void> directPrint(Uint8List data, {String? printerName}) async {
    if (printerName != null) {
      final printers = await Printing.listPrinters();
      final printer = printers.firstWhere((p) => p.name == printerName, orElse: () => printers.first);
      await Printing.directPrintPdf(printer: printer, onLayout: (format) async => data);
    } else {
      await Printing.layoutPdf(onLayout: (format) async => data);
    }
  }
}
