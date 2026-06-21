// ignore_for_file: deprecated_member_use

import 'package:crazy_phone_pos/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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

    final titleText = receiptMode ? 'إيصال دفع حراري (80mm)' : 'فاتورة مبيعات (A4)';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowRight, color: AppColors.textPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                titleText,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.5,
                ),
              ),
              Text(
                'رقم الفاتورة: #${data.invoiceId}',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.mutedColor,
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          centerTitle: false,
          actions: [
            _buildHeaderAction(
              icon: LucideIcons.printer,
              tooltip: 'طباعة فورية',
              color: AppColors.primaryColor,
              onPressed: () => _handlePrint(context),
            ),
            const SizedBox(width: 8),
            _buildHeaderAction(
              icon: LucideIcons.share2,
              tooltip: 'مشاركة PDF',
              color: AppColors.secondaryColor,
              onPressed: () => _handleShare(context),
            ),
            const SizedBox(width: 16),
          ],
        ),
        body: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: maxPageWidth + (isDesktop ? 120 : 40),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : isTablet ? 20 : 32,
              vertical: isMobile ? 16 : isTablet ? 24 : 32,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderColor.withOpacity(0.8)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.015),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
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
                  dpi: isDesktop ? 220 : 160,
                  useActions: false,
                  scrollViewDecoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  previewPageMargin: EdgeInsets.all(
                    isMobile ? 8 : isTablet ? 12 : 16,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderAction({
    required IconData icon,
    required String tooltip,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      textStyle: const TextStyle(fontFamily: 'Cairo', color: Colors.white, fontSize: 11),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withOpacity(0.15)),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
        ),
      ),
    );
  }

  Future<void> _handlePrint(BuildContext context) async {
    await Printing.layoutPdf(
      onLayout: (format) => receiptMode
          ? InvoicePdfService.buildReceipt80mm(data)
          : InvoicePdfService.buildA4(data, format: format),
    );
  }

  Future<void> _handleShare(BuildContext context) async {
    final bytes = await (receiptMode
        ? InvoicePdfService.buildReceipt80mm(data)
        : InvoicePdfService.buildA4(data, format: PdfPageFormat.a4));
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'invoice_${data.invoiceId}.pdf',
    );
  }
}
