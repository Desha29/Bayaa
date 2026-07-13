// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:printing/printing.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/components/screen_header.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/daily_report_model.dart';
import '../../data/models/product_performance_model.dart';
import '../../domain/daily_report_pdf_service.dart';
import 'daily_report_preview_screen.dart';
import 'daily_report_datasheet_screen.dart';
import '../../../../core/components/message_overlay.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../analytics/domain/analytics_repository.dart';
import '../../../../core/localization/translation_helper.dart';

class DailyReportScreen extends StatefulWidget {
  final DailyReport? initialReport;

  const DailyReportScreen({super.key, this.initialReport});

  @override
  State<DailyReportScreen> createState() => _DailyReportScreenState();
}

class _DailyReportScreenState extends State<DailyReportScreen>
    with SingleTickerProviderStateMixin {
  DateTime selectedDate = DateTime.now();
  DailyReport? report;
  bool loading = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    if (widget.initialReport != null) {
      report = widget.initialReport;
      selectedDate = report!.date;
    } else {
      fetchReport();
    }

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchReport() async {
    setState(() {
      loading = true;
    });

    final repo = getIt<AnalyticsRepository>();
    final result = await repo.getDailyReport(selectedDate);

    result.fold((failure) {
      GlobalMessage.showError(
          AppLocalizations.of(context).loadReportError(failure.toString()));
      setState(() => report = null);
    }, (loadedReport) {
      setState(() {
        report = loadedReport;
      });
      GlobalMessage.showSuccess(
          AppLocalizations.of(context).reportLoadedSuccess);
    });

    setState(() {
      loading = false;
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                textStyle: const TextStyle(
                    fontFamily: 'Cairo', fontWeight: FontWeight.bold),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      fetchReport();
    }
  }

  Future<void> _handlePreview() async {
    if (report == null) return;
    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            DailyReportPreviewScreen(report: report!),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.08),
                end: Offset.zero,
              ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut)),
              child: child,
            ),
          );
        },
      ),
    );
  }

  Future<void> _handlePrint() async {
    if (report == null) return;
    GlobalMessage.showLoading(AppLocalizations.of(context).loadingReport);
    try {
      final pdfBytes = await DailyReportPdfService.generateDailyReportPDF(
          report!,
          locale: Localizations.localeOf(context));
      await Printing.layoutPdf(
        onLayout: (format) => pdfBytes,
      );
      GlobalMessage.showSuccess(
          AppLocalizations.of(context).printReportSuccess);
    } catch (e) {
      GlobalMessage.showError(
          AppLocalizations.of(context).printReportError(e.toString()));
    }
  }

  Future<void> _handleShare() async {
    if (report == null) return;
    GlobalMessage.showLoading(AppLocalizations.of(context).loadingShare);
    try {
      final bytes = await DailyReportPdfService.generateDailyReportPDF(report!,
          locale: Localizations.localeOf(context));
      await Printing.sharePdf(
        bytes: bytes,
        filename:
            'daily_report_${DateFormat('yyyy-MM-dd').format(selectedDate)}.pdf',
      );
      GlobalMessage.showSuccess(
          AppLocalizations.of(context).shareReportSuccess);
    } catch (e) {
      GlobalMessage.showError(
          AppLocalizations.of(context).shareReportError(e.toString()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    return Directionality(
      textDirection:
          l10n.localeName == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowRight,
                color: AppColors.textPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            l10n.dailyReports,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: false,
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 32 : 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeTransition(
                      opacity: _animationController,
                      child: ScreenHeader(
                        title: l10n.todayRevenue,
                        icon: LucideIcons.trendingUp,
                        subtitle: l10n.dailyReportDesc,
                        subtitleColor: AppColors.mutedColor,
                        iconColor: AppColors.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (widget.initialReport == null)
                      FadeTransition(
                        opacity: _animationController,
                        child: _buildDateSelectionSection(),
                      )
                    else
                      FadeTransition(
                        opacity: _animationController,
                        child: _buildReadOnlyDateSection(),
                      ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: loading
                          ? const Center(
                              child: CircularProgressIndicator(
                                  color: AppColors.primaryColor))
                          : report == null
                              ? FadeTransition(
                                  opacity: _animationController,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(24),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryColor
                                                .withOpacity(0.04),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(LucideIcons.barChart2,
                                              size: 60,
                                              color: AppColors.mutedColor
                                                  .withOpacity(0.4)),
                                        ),
                                        const SizedBox(height: 20),
                                        Text(
                                          l10n.noDataForDate,
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: AppColors.textPrimary,
                                              fontFamily: 'Cairo',
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          l10n.ensureValidDate,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.mutedColor,
                                              fontFamily: 'Cairo'),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : _buildReportContent(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelectionSection() {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.calendar,
                  color: AppColors.primaryColor, size: 20),
              const SizedBox(width: 10),
              Text(
                l10n.filterReportByDate,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                    color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: _selectDate,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderColor),
                borderRadius: BorderRadius.circular(12),
                color: AppColors.backgroundColor.withOpacity(0.5),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.calendarDays,
                      color: AppColors.secondaryColor, size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.currentSelectedDay,
                            style: TextStyle(
                                fontSize: 10,
                                color: AppColors.mutedColor,
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(
                            DateFormat('dd MMMM yyyy', 'ar')
                                .format(selectedDate),
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Cairo',
                                color: AppColors.textPrimary)),
                      ],
                    ),
                  ),
                  const Icon(LucideIcons.chevronDown,
                      color: AppColors.mutedColor, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyDateSection() {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(LucideIcons.calendar,
                color: AppColors.primaryColor, size: 22),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.reportGeneratedDate,
                style: TextStyle(
                    fontSize: 11,
                    color: AppColors.mutedColor,
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('dd/MM/yyyy   hh:mm a')
                    .format(report?.date ?? DateTime.now()),
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                    color: AppColors.textPrimary),
              ),
            ],
          ),
          if (report?.closedByUserName != null) ...[
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.secondaryColor.withOpacity(0.06),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppColors.secondaryColor.withOpacity(0.12)),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.user,
                      size: 13, color: AppColors.secondaryColor),
                  const SizedBox(width: 8),
                  Text(
                    l10n.closedByUser(TranslationHelper.translateUserName(
                        context, report!.closedByUserName)),
                    style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondaryColor),
                  ),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildReportContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        children: [
          FadeTransition(
            opacity: _animationController,
            child: _buildSummaryCards(),
          ),
          const SizedBox(height: 20),
          FadeTransition(
            opacity: _animationController,
            child: _buildActionButtons(),
          ),
          const SizedBox(height: 20),
          if (report?.refundedProducts.isNotEmpty == true) ...[
            FadeTransition(
              opacity: _animationController,
              child: _buildRefundedProductsList(),
            ),
            const SizedBox(height: 20),
          ],
          if (report?.transactions.isNotEmpty == true) ...[
            FadeTransition(
              opacity: _animationController,
              child: _buildTransactionsLog(),
            ),
            const SizedBox(height: 20),
          ],
          FadeTransition(
            opacity: _animationController,
            child: _buildTopProductsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final l10n = AppLocalizations.of(context);
        final isMobile = constraints.maxWidth < 600;
        if (isMobile) {
          return Column(
            children: [
              _buildSummaryCard(
                  l10n.todayTotalSales,
                  '${report!.totalSales.toStringAsFixed(2)} ${l10n.currencyEg}',
                  LucideIcons.banknote,
                  AppColors.successColor),
              const SizedBox(height: 12),
              _buildSummaryCard(
                  l10n.dailyNetProfit,
                  '${report!.netRevenue.toStringAsFixed(2)} ${l10n.currencyEg}',
                  LucideIcons.trendingUp,
                  const Color(0xFF059669)),
            ],
          );
        }
        return Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                  l10n.todayTotalSales,
                  '${report!.totalSales.toStringAsFixed(2)} ${l10n.currencyEg}',
                  LucideIcons.banknote,
                  AppColors.successColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSummaryCard(
                  l10n.dailyNetProfit,
                  '${report!.netRevenue.toStringAsFixed(2)} ${l10n.currencyEg}',
                  LucideIcons.trendingUp,
                  const Color(0xFF059669)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.015),
              blurRadius: 10,
              offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'Cairo',
                      color: AppColors.mutedColor,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                fontFamily: 'Cairo',
                color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return LayoutBuilder(builder: (context, constraints) {
      final l10n = AppLocalizations.of(context);
      final isMobile = constraints.maxWidth < 600;

      if (isMobile) {
        return Column(
          children: [
            _buildActionButton(
              onPressed: _handlePreview,
              icon: LucideIcons.eye,
              label: l10n.salesReportPreview,
              color: AppColors.primaryColor,
            ),
            const SizedBox(height: 10),
            _buildActionButton(
              onPressed: () {
                if (report == null) return;
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      DailyReportDatasheetScreen(report: report!),
                ));
              },
              icon: LucideIcons.table,
              label: l10n.viewDetailedTable,
              color: AppColors.secondaryColor,
            ),
            const SizedBox(height: 10),
            _buildActionButton(
              onPressed: _handlePrint,
              icon: LucideIcons.printer,
              label: l10n.instantPrintReport,
              color: const Color(0xFF059669),
            ),
            const SizedBox(height: 10),
            _buildActionButton(
              onPressed: _handleShare,
              icon: LucideIcons.share2,
              label: l10n.sharePdfReport,
              color: AppColors.mutedColor,
              isOutlined: true,
            ),
          ],
        );
      }

      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  onPressed: _handlePreview,
                  icon: LucideIcons.eye,
                  label: l10n.previewReportTitle,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  onPressed: () {
                    if (report == null) return;
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          DailyReportDatasheetScreen(report: report!),
                    ));
                  },
                  icon: LucideIcons.table,
                  label: l10n.viewTableBtn,
                  color: AppColors.secondaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  onPressed: _handlePrint,
                  icon: LucideIcons.printer,
                  label: l10n.instantPrint,
                  color: const Color(0xFF059669),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: _buildActionButton(
              onPressed: _handleShare,
              icon: LucideIcons.share2,
              label: l10n.sharePdfReport,
              color: AppColors.textSecondary,
              isOutlined: true,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
    bool isOutlined = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isOutlined ? Colors.transparent : color,
            border: Border.all(color: color, width: isOutlined ? 1.5 : 1),
            borderRadius: BorderRadius.circular(12),
            boxShadow: isOutlined
                ? null
                : [
                    BoxShadow(
                      color: color.withOpacity(0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: isOutlined ? color : Colors.white),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isOutlined ? color : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopProductsList() {
    final l10n = AppLocalizations.of(context);
    if (report?.topProducts.isEmpty ?? true) {
      return Center(
          child: Text(l10n.noProductsSoldDate,
              style: TextStyle(
                  color: AppColors.mutedColor.withOpacity(0.5),
                  fontSize: 14,
                  fontFamily: 'Cairo')));
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.015),
              blurRadius: 10,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(LucideIcons.barChart2,
                    color: AppColors.primaryColor, size: 20),
                const SizedBox(width: 10),
                Text(
                  l10n.dailyProductsPerformance(report!.topProducts.length),
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                      color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: report!.topProducts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) =>
                _buildProductCard(report!.topProducts[index], index),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProductCard(ProductPerformanceModel product, int index) {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.008),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppColors.primaryColor.withOpacity(0.1)),
                ),
                child: const Icon(LucideIcons.package,
                    color: AppColors.primaryColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.productName,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(LucideIcons.shoppingBag,
                            size: 12, color: AppColors.mutedColor),
                        const SizedBox(width: 4),
                        Text(
                          l10n.salesUnits(product.quantitySold),
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11,
                            color: AppColors.mutedColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${product.revenue.toStringAsFixed(2)} ${l10n.currencyEg}',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.profitAmount(product.profit.toStringAsFixed(2)),
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.successColor,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '(${product.profitMargin.toStringAsFixed(1)}%)',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 10.5,
                          color: AppColors.mutedColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (10.0 - index.clamp(0, 9)) / 10.0,
              backgroundColor: AppColors.borderColor.withOpacity(0.5),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.secondaryColor),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRefundedProductsList() {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.015),
              blurRadius: 10,
              offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              children: [
                const Icon(LucideIcons.packageX,
                    color: AppColors.errorColor, size: 20),
                const SizedBox(width: 10),
                Text(
                  l10n.returnedProductsDetails,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                      color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              constraints: const BoxConstraints(minWidth: 600),
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: AppColors.borderColor.withOpacity(0.5),
                ),
                child: DataTable(
                  horizontalMargin: 20,
                  headingTextStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                    color: AppColors.mutedColor,
                    fontSize: 12,
                  ),
                  dataTextStyle: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Cairo',
                    fontSize: 12,
                  ),
                  columnSpacing: 24,
                  columns: [
                    DataColumn(label: Text(l10n.productNameColumn)),
                    DataColumn(label: Text(l10n.returnedQty), numeric: true),
                    DataColumn(label: Text(l10n.returnedValue), numeric: true),
                  ],
                  rows: report!.refundedProducts.map((product) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: AppColors.errorColor.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(LucideIcons.package,
                                    size: 14, color: AppColors.errorColor),
                              ),
                              const SizedBox(width: 8),
                              Text(product.productName),
                            ],
                          ),
                        ),
                        DataCell(Text('${product.quantitySold}')),
                        DataCell(
                          Text(
                            '${product.revenue.toStringAsFixed(2)} ${l10n.currencyEg}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.errorColor),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsLog() {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.015),
              blurRadius: 10,
              offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              children: [
                const Icon(LucideIcons.fileSpreadsheet,
                    color: AppColors.primaryColor, size: 20),
                const SizedBox(width: 10),
                Text(
                  l10n.dailyFinancialLog,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                      color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              constraints: const BoxConstraints(minWidth: 800),
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: AppColors.borderColor.withOpacity(0.5),
                ),
                child: DataTable(
                  horizontalMargin: 20,
                  headingTextStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                    color: AppColors.mutedColor,
                    fontSize: 12,
                  ),
                  dataTextStyle: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Cairo',
                    fontSize: 12,
                  ),
                  columnSpacing: 24,
                  columns: [
                    DataColumn(label: Text(l10n.invoiceNumberPdf)),
                    DataColumn(label: Text(l10n.cashierPdf)),
                    DataColumn(label: Text(l10n.operationTime)),
                    DataColumn(label: Text(l10n.operationType)),
                    DataColumn(
                        label: Text(l10n.totalAmountLabel), numeric: true),
                  ],
                  rows: report!.transactions.map((sale) {
                    final isRefund = sale.isRefund;
                    return DataRow(
                      cells: [
                        DataCell(Text(sale.id.length > 8
                            ? '#${sale.id.substring(0, 8).toUpperCase()}'
                            : '#${sale.id.toUpperCase()}')),
                        DataCell(Text(sale.cashierName ?? l10n.roleManager)),
                        DataCell(Text(DateFormat('hh:mm a').format(sale.date))),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: (isRefund
                                      ? AppColors.errorColor
                                      : AppColors.successColor)
                                  .withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: (isRefund
                                        ? AppColors.errorColor
                                        : AppColors.successColor)
                                    .withOpacity(0.16),
                              ),
                            ),
                            child: Text(
                              isRefund ? l10n.refundLabel : l10n.saleProcess,
                              style: TextStyle(
                                fontSize: 11,
                                fontFamily: 'Cairo',
                                color: isRefund
                                    ? AppColors.errorColor
                                    : AppColors.successColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            '${sale.total.toStringAsFixed(2)} ${l10n.currencyEg}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isRefund
                                  ? AppColors.errorColor
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
