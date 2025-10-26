import 'package:crazy_phone_pos/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../data/models/dialy_report_model.dart';
import '../../domain/daily_report_pdf_service.dart';

class DailyReportPreviewScreen extends StatelessWidget {
  final DailyReportModel report;

  const DailyReportPreviewScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    final isMobile = screenWidth < 600;

    final maxPageWidth = isMobile ? 350.0 : isTablet ? 500.0 : 650.0;

    final titleText = 'تقرير المبيعات اليومية';
    final printText = 'طباعة';
    final shareText = 'مشاركة';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          centerTitle: true,
          title: Text(titleText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            Tooltip(
              message: printText,
              child: IconButton(icon: const Icon(Icons.print), onPressed: _handlePrint),
            ),
            Tooltip(
              message: shareText,
              child: IconButton(icon: const Icon(Icons.share), onPressed: _handleShare),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: maxPageWidth + (isDesktop ? 100 : 40)),
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 8 : isTablet ? 16 : 24,
                  vertical: isMobile ? 12 : isTablet ? 16 : 24,
                ),
                child: Card(
                  elevation: isDesktop ? 8 : 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isDesktop ? 16 : 12)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
                    child: PdfPreview(
                      build: (format) => DailyReportPdfService.generateDailyReportPDF(report),
                      allowPrinting: true,
                      allowSharing: true,
                      canChangeOrientation: false,
                      canChangePageFormat: false,
                      canDebug: false,
                      pdfFileName: 'daily_report_${_formatDate(report.date)}.pdf',
                      maxPageWidth: maxPageWidth,
                      dpi: isDesktop ? 200 : 150,
                      useActions: false,
                      scrollViewDecoration: BoxDecoration(color: Colors.grey.shade50),
                      previewPageMargin: EdgeInsets.all(isMobile ? 4 : isTablet ? 8 : 12),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _handlePrint() async {
    await Printing.layoutPdf(onLayout: (format) => DailyReportPdfService.generateDailyReportPDF(report));
  }

  Future<void> _handleShare() async {
    final bytes = await DailyReportPdfService.generateDailyReportPDF(report);
    await Printing.sharePdf(bytes: bytes, filename: 'daily_report_${_formatDate(report.date)}.pdf');
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
