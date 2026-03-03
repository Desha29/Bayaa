import '../../../../core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:printing/printing.dart';

import '../../data/models/daily_report_model.dart';
import '../../data/models/session_model.dart';
import '../../domain/daily_report_pdf_service.dart';

class DailyReportPreviewScreen extends StatelessWidget {
  final DailyReport report;
  final Session? session;
  final bool isEmbedded;

  const DailyReportPreviewScreen({
    super.key,
    required this.report,
    this.session,
    this.isEmbedded = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    final isMobile = screenWidth < 600;

    final maxPageWidth = isMobile
        ? 350.0
        : isTablet
            ? 500.0
            : 650.0;

    final body = LayoutBuilder(
      builder: (context, constraints) {
        if (isEmbedded) {
          return PdfPreview(
            build: (format) =>
                DailyReportPdfService.generateDailyReportPDF(report),
            allowPrinting: true,
            allowSharing: true,
            canChangeOrientation: false,
            canChangePageFormat: false,
            canDebug: false,
            pdfFileName: 'daily_report_${_formatDate(report.date)}.pdf',
            maxPageWidth: null,
            dpi: isDesktop ? 200 : 150,
            useActions: true,
            scrollViewDecoration: BoxDecoration(
              color: AppColors.backgroundColor,
            ),
            previewPageMargin: const EdgeInsets.all(8),
          );
        }

        return Center(
          child: Container(
            constraints: BoxConstraints(
                maxWidth: maxPageWidth + (isDesktop ? 100 : 40)),
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 8 : isTablet ? 16 : 24,
              vertical: isMobile ? 12 : isTablet ? 16 : 24,
            ),
            child: Column(
              children: [
                // Session Details Header Card
                if (session != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: _buildSessionDetailsCard(context),
                  ),

                // PDF Preview Card
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryColor.withOpacity(0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                          spreadRadius: 0,
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: PdfPreview(
                        build: (format) =>
                            DailyReportPdfService.generateDailyReportPDF(report),
                        allowPrinting: true,
                        allowSharing: true,
                        canChangeOrientation: false,
                        canChangePageFormat: false,
                        canDebug: false,
                        pdfFileName:
                            'daily_report_${_formatDate(report.date)}.pdf',
                        maxPageWidth: maxPageWidth,
                        dpi: isDesktop ? 200 : 150,
                        useActions: isEmbedded,
                        scrollViewDecoration: BoxDecoration(
                          color: AppColors.backgroundColor,
                        ),
                        previewPageMargin: EdgeInsets.all(isMobile ? 4 : isTablet ? 8 : 12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (isEmbedded) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: body,
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: _buildGradientAppBar(context),
        body: body,
      ),
    );
  }

  PreferredSizeWidget _buildGradientAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryColor, AppColors.secondaryColor],
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x1A1E3A8A),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'معاينة التقرير',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('EEEE, d MMMM yyyy', 'ar').format(report.date),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildAppBarAction(
                  icon: Icons.print_rounded,
                  label: 'طباعة',
                  onPressed: _handlePrint,
                ),
                const SizedBox(width: 4),
                _buildAppBarAction(
                  icon: Icons.share_rounded,
                  label: 'مشاركة',
                  onPressed: _handleShare,
                ),
                const SizedBox(width: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarAction({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSessionDetailsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            AppColors.primaryColor.withOpacity(0.02),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryColor.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildDetailChip(
            icon: Icons.login_rounded,
            label: 'وقت الفتح',
            value: DateFormat('hh:mm a').format(session!.openTime),
            color: AppColors.successColor,
          ),
          _buildDetailDivider(),
          _buildDetailChip(
            icon: Icons.logout_rounded,
            label: 'وقت الإغلاق',
            value: session!.closeTime != null
                ? DateFormat('hh:mm a').format(session!.closeTime!)
                : 'مفتوح',
            color: AppColors.warningColor,
          ),
          _buildDetailDivider(),
          _buildDetailChip(
            icon: Icons.person_rounded,
            label: 'بواسطة',
            value: report.closedByUserName,
            color: AppColors.secondaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              color: AppColors.mutedColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailDivider() {
    return Container(
      height: 50,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.borderColor.withOpacity(0),
            AppColors.borderColor,
            AppColors.borderColor.withOpacity(0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Future<void> _handlePrint() async {
    await Printing.layoutPdf(
        onLayout: (format) =>
            DailyReportPdfService.generateDailyReportPDF(report));
  }

  Future<void> _handleShare() async {
    final bytes = await DailyReportPdfService.generateDailyReportPDF(report);
    await Printing.sharePdf(
        bytes: bytes,
        filename: 'daily_report_${_formatDate(report.date)}.pdf');
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'unknown';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
