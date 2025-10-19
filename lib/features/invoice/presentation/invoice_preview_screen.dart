
import 'package:crazy_phone_pos/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

import '../data/invoice_models.dart';
import '../domain/invoice_pdf_service.dart';

class InvoicePreviewScreen extends StatelessWidget {
  final InvoiceData data;
  final bool receiptMode;

  const InvoicePreviewScreen({
    super.key,
    required this.data,
    this.receiptMode = true,
  });



  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    final isMobile = screenWidth < 600;

    // Responsive width
    final maxPageWidth = receiptMode
        ? (isMobile ? 200.0 : isTablet ? 240.0 : 280.0)
        : (isMobile ? 350.0 : isTablet ? 500.0 : 650.0);

    // Localized strings
    final titleText = receiptMode ? 'إيصال الدفع' : 'فاتورة';
    final printText = 'طباعة';
    final shareText = 'مشاركة';

    return Directionality(
      textDirection: TextDirection.rtl, // Default RTL for Arabic
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            titleText,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            // Print button in AppBar
            Tooltip(
              message: printText,
              child: IconButton(
                icon: const Icon(Icons.print),
                onPressed: _handlePrint,
              ),
            ),
            // Share button in AppBar
            Tooltip(
              message: shareText,
              child: IconButton(
                icon: const Icon(Icons.share),
                onPressed: _handleShare,
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: maxPageWidth + (isDesktop ? 100 : 40),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 8 : isTablet ? 16 : 24,
                  vertical: isMobile ? 12 : isTablet ? 16 : 24,
                ),
                child: Card(
                  elevation: isDesktop ? 8 : 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
                    child: PdfPreview(
                      build: (format) => receiptMode
                          ? InvoicePdfService.buildReceipt80mm(data)
                          : InvoicePdfService.buildA4(data, format: format),
                      allowPrinting: true,
                      allowSharing: true,
                      canChangeOrientation: false,
                      canChangePageFormat: false,
                      canDebug: false,
                      pdfFileName: 'invoice_${data.invoiceId}.pdf',
                      maxPageWidth: maxPageWidth,
                      dpi: isDesktop ? 200 : 150,
                      useActions: false,
                      scrollViewDecoration: BoxDecoration(
                        color: Colors.grey.shade50,
                      ),
                      previewPageMargin: EdgeInsets.all(
                        isMobile ? 4 : isTablet ? 8 : 12,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        // FAB only on mobile
        floatingActionButton: isMobile
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton(
                    heroTag: 'mobile_print',
                    backgroundColor: AppColors.primaryColor,
                    tooltip: printText,
                    child: const Icon(Icons.print, color: Colors.white),
                    onPressed: _handlePrint,
                  ),
                  const SizedBox(height: 12),
                  FloatingActionButton(
                    heroTag: 'mobile_share',
                    backgroundColor: const Color(0xFF10B981),
                    tooltip: shareText,
                    child: const Icon(Icons.share, color: Colors.white),
                    onPressed: _handleShare,
                  ),
                ],
              )
            : null,
      ),
    );
  }

  Future<void> _handlePrint() async {
    await Printing.layoutPdf(
      onLayout: (format) => receiptMode
          ? InvoicePdfService.buildReceipt80mm(data)
          : InvoicePdfService.buildA4(data, format: format),
    );
  }

  Future<void> _handleShare() async {
    final bytes = await (receiptMode
        ? InvoicePdfService.buildReceipt80mm(data)
        : InvoicePdfService.buildA4(data, format: PdfPageFormat.a4));
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'invoice_${data.invoiceId}.pdf',
    );
  }
}
