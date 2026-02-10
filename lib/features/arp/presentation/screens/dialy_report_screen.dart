import 'dart:async';
import 'package:crazy_phone_pos/core/components/screen_header.dart';


import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import '../../../../core/constants/app_colors.dart';

import '../../data/models/daily_report_model.dart';
import '../../data/models/product_performance_model.dart';
import '../../domain/daily_report_pdf_service.dart';
import 'daily_report_preview_screen.dart';
import 'daily_report_datasheet_screen.dart';
import '../../../../core/components/message_overlay.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../domain/arp_repository.dart';



class DailyReportScreen extends StatefulWidget {
  final DailyReport? initialReport;
  
  const DailyReportScreen({Key? key, this.initialReport}) : super(key: key);

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
    
    // Use initialReport if provided (for session closure)
    if (widget.initialReport != null) {
      report = widget.initialReport;
      // Extract date from report if available
      if (report!.date != null) {
        selectedDate = report!.date!;
      }
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


    final repo = getIt<ArpRepository>();
    final result = await repo.getDailyReport(selectedDate);

    result.fold((failure) {
      GlobalMessage.showError("خطأ في تحميل التقرير: ${failure.toString()}");
      setState(() => report = null);
    }, (loadedReport) {
      setState(() {
        report = loadedReport;
      });
      GlobalMessage.showSuccess("تم تحميل التقرير بنجاح");
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
                begin: const Offset(0.0, 0.1),
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
    GlobalMessage.showLoading("جاري إعداد التقرير للطباعة...");
    try {
      final pdfBytes = await DailyReportPdfService.generateDailyReportPDF(report!);
      await Printing.layoutPdf(
        onLayout: (format) => pdfBytes,
      );
      GlobalMessage.showSuccess("تم إرسال التقرير للطباعة بنجاح");
    } catch (e) {
      GlobalMessage.showError("خطأ في الطباعة: ${e.toString()}");
    }
  }

  Future<void> _handleShare() async {
    if (report == null) return;
    GlobalMessage.showLoading("جاري إعداد التقرير للمشاركة...");
    try {
      final bytes = await DailyReportPdfService.generateDailyReportPDF(report!);
      await Printing.sharePdf(
        bytes: bytes,
        filename:
            'daily_report_${DateFormat('yyyy-MM-dd').format(selectedDate)}.pdf',
      );
      GlobalMessage.showSuccess("تم مشاركة التقرير بنجاح");
    } catch (e) {
      GlobalMessage.showError("خطأ في مشاركة التقرير: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.kDarkChip),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Center(
          child: FadeTransition(
            opacity: _animationController,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -0.2),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _animationController,
                curve: Curves.easeOut,
              )),
              child: ScreenHeader(
                title: 'تقرير المبيعات اليومية',
                icon: Icons.analytics,
                subtitle: 'عرض وطباعة تقارير المبيعات اليومية',
                subtitleColor: AppColors.mutedColor,
                iconColor: AppColors.primaryColor,
              ),
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Padding(
                padding: EdgeInsets.all(isDesktop ? 32 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    if (widget.initialReport == null)
                      FadeTransition(
                        opacity: _animationController,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, -0.1),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: _animationController,
                            curve: Curves.easeOut,
                          )),
                          child: _buildDateSelectionSection(),
                        ),
                      )
                    else 
                      FadeTransition(
                        opacity: _animationController,
                         child: _buildReadOnlyDateSection(),
                      ),
                    
                    const SizedBox(height: 24),
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
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.analytics_outlined,
                                            size: 80, color: AppColors.mutedColor.withValues(alpha: 0.4)),
                                        const SizedBox(height: 16),
                                        Text(
                                          'لا توجد بيانات متاحة لهذا التاريخ',
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: AppColors.mutedColor,
                                              fontWeight: FontWeight.w600),
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
    );
  }

  Widget _buildDateSelectionSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
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
              Icon(Icons.calendar_today,
                  color: AppColors.primaryColor, size: 24),
              const SizedBox(width: 12),
              Text(
                'اختيار التاريخ',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.kDarkChip),
              ),
            ],
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: _selectDate,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.mutedColor.withValues(alpha: 0.4)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today,
                      color: AppColors.primaryColor, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('التاريخ المحدد',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.mutedColor)),
                        const SizedBox(height: 4),
                        Text(DateFormat('yyyy-MM-dd').format(selectedDate),
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.kDarkChip)),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, color: AppColors.primaryColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyDateSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.date_range,
                color: AppColors.primaryColor, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تاريخ الجلسة',
                style: TextStyle(
                    fontSize: 14,
                    color: AppColors.mutedColor,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('yyyy-MM-dd   hh:mm a', 'en').format(report?.date ?? DateTime.now()),
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.kDarkChip),
              ),
            ],
          ),
          if (report?.closedByUserName != null) ...[
            const Spacer(),
             Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.secondaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(Icons.person,
                      size: 16, color: AppColors.secondaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'بواسطة: ${report!.closedByUserName}',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
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
          // Summary Cards
          FadeTransition(
            opacity: _animationController,
            child: SlideTransition(
              position:
                  Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
                      .animate(CurvedAnimation(
                          parent: _animationController, curve: Curves.easeOut)),
              child: _buildSummaryCards(),
            ),
          ),
          const SizedBox(height: 24),
          FadeTransition(
            opacity: _animationController,
            child: SlideTransition(
              position:
                  Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
                      .animate(CurvedAnimation(
                          parent: _animationController, curve: Curves.easeOut)),
              child: _buildActionButtons(),
            ),
          ),
          const SizedBox(height: 24),
          if (report?.refundedProducts.isNotEmpty == true) ...[
            SizedBox(
              height: 300, 
              child: FadeTransition(
                opacity: _animationController,
                child: _buildRefundedProductsList(),
              ),
            ),
            const SizedBox(height: 24),
          ],
          if (report?.transactions.isNotEmpty == true) ...[
            SizedBox(
              height: 400,
              child: FadeTransition(
                opacity: _animationController,
                child: _buildTransactionsLog(),
              ),
            ),
            const SizedBox(height: 24),
          ],
          FadeTransition(
            opacity: _animationController,
            child: SlideTransition(
              position:
                  Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
                      .animate(CurvedAnimation(
                          parent: _animationController, curve: Curves.easeOut)),
              child: _buildTopProductsList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        if (isMobile) {
          return Column(
            children: [
              _buildSummaryCard(
                  'إجمالي المبيعات',
                  '${report!.totalSales.toStringAsFixed(2)} ج.م',
                  Icons.attach_money,
                  AppColors.successColor),
              const SizedBox(height: 12),
              _buildSummaryCard(
                  'صافي الإيراد',
                  '${report!.netRevenue.toStringAsFixed(2)} ج.م',
                  Icons.trending_up,
                  Color(0xFF2E7D32)),
            ],
          );
        }
        return Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                  'إجمالي المبيعات',
                  '${report!.totalSales.toStringAsFixed(2)} ج.م',
                  Icons.attach_money,
                  AppColors.successColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                  'صافي الإيراد',
                  '${report!.netRevenue.toStringAsFixed(2)} ج.م',
                  Icons.trending_up,
                  Color(0xFF2E7D32)),
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
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(title,
                      style: TextStyle(
                          fontSize: 14,
                          color: AppColors.mutedColor,
                          fontWeight: FontWeight.w600))),
            ],
          ),
          const SizedBox(height: 12),
          Text(value,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        
        if (isMobile) {
          return Column(
            children: [
              _buildActionButton(
                onPressed: _handlePreview,
                icon: Icons.visibility,
                label: 'معاينة التقرير',
                color: AppColors.primaryColor,
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                onPressed: () {
                   if (report == null) return;
                   Navigator.of(context).push(MaterialPageRoute(
                     builder: (context) => DailyReportDatasheetScreen(report: report!),
                   ));
                },
                icon: Icons.table_chart,
                label: 'عرض كجدول',
                color: AppColors.secondaryColor,
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                onPressed: _handlePrint,
                icon: Icons.print,
                label: 'طباعة مباشرة',
                color: Color(0xFF2E7D32),
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                onPressed: _handleShare,
                icon: Icons.share,
                label: 'مشاركة PDF',
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
                    icon: Icons.visibility,
                    label: 'معاينة التقرير',
                    color: AppColors.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    onPressed: () {
                       if (report == null) return;
                       Navigator.of(context).push(MaterialPageRoute(
                         builder: (context) => DailyReportDatasheetScreen(report: report!),
                       ));
                    },
                    icon: Icons.table_chart,
                    label: 'عرض كجدول',
                    color: AppColors.secondaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    onPressed: _handlePrint,
                    icon: Icons.print,
                    label: 'طباعة مباشرة',
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: _buildActionButton(
                onPressed: _handleShare,
                icon: Icons.share,
                label: 'مشاركة PDF',
                color: AppColors.mutedColor,
                isOutlined: true,
              ),
            ),
          ],
        );
      }
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
    bool isOutlined = false,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isOutlined ? color.withValues(alpha: 0.15) : color,
        foregroundColor: isOutlined ? color : Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        minimumSize: const Size(double.infinity, 50), // Ensure consistent height
      ),
    );
  }

  Widget _buildTopProductsList() {
    if (report?.topProducts.isEmpty ?? true) {
      return Center(
          child: Text('لا توجد منتجات مباعة لهذا التاريخ',
              style: TextStyle(color: AppColors.mutedColor.withValues(alpha: 0.1), fontSize: 16)));
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
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
                Icon(Icons.trending_up,
                    color: AppColors.primaryColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  'أداء المنتجات (${report!.topProducts.length})',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.kDarkChip),
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
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            (index * 0.1).clamp(0.0, 1.0),
            ((index * 0.1) + 0.3).clamp(0.0, 1.0),
            curve: Curves.easeOut,
          ),
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(
              (index * 0.1).clamp(0.0, 1.0),
              ((index * 0.1) + 0.3).clamp(0.0, 1.0),
              curve: Curves.easeOut,
            ),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.mutedColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.mutedColor.withValues(alpha: 0.3)),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.inventory_2,
                    color: AppColors.primaryColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.productName,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.kDarkChip)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.shopping_cart_outlined,
                            size: 14, color: AppColors.mutedColor),
                        const SizedBox(width: 4),
                        Text('${product.quantitySold} وحدة',
                            style: TextStyle(
                                fontSize: 13,
                                color: AppColors.mutedColor,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${product.revenue.toStringAsFixed(2)} ج.م',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor)),
                  const SizedBox(height: 2),
                  Text('ربح: ${product.profit.toStringAsFixed(2)} ج.م',
                      style:
                          TextStyle(fontSize: 12, color: AppColors.mutedColor)),
                  Text('هامش: ${product.profitMargin.toStringAsFixed(1)}%',
                      style:
                          TextStyle(fontSize: 12, color: AppColors.mutedColor)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRefundedProductsList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(Icons.remove_shopping_cart,
                    color: AppColors.errorColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  'تفاصيل المرتجعات (${report!.refundedProducts.length})',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.kDarkChip),
                ),
              ],
            ),
          ),
          Expanded(
            child: Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.grey.withValues(alpha: 0.1),
              ),
              child: SingleChildScrollView(
                child: DataTable(
                  headingTextStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.mutedColor,
                  ),
                  dataTextStyle: const TextStyle(
                    color: AppColors.kDarkChip,
                    fontWeight: FontWeight.w500,
                  ),
                  columnSpacing: 20,
                  columns: const [
                    DataColumn(label: Text('المنتج')),
                    DataColumn(label: Text('الكمية المرتجعة'), numeric: true),
                    DataColumn(label: Text('قيمة الاسترجاع'), numeric: true),
                  ],
                  rows: report!.refundedProducts.map((product) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.errorColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(Icons.inventory_2_outlined,
                                    size: 16, color: AppColors.errorColor),
                              ),
                              const SizedBox(width: 8),
                              Text(product.productName),
                            ],
                          ),
                        ),
                        DataCell(Text('${product.quantitySold}')),
                        DataCell(Text('${product.revenue.toStringAsFixed(2)} ج.م',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.errorColor))),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTransactionsLog() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(Icons.receipt_long,
                    color: AppColors.primaryColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  'سجل العمليات (${report!.transactions.length})',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.kDarkChip),
                ),
              ],
            ),
          ),
          Expanded(
            child: Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.grey.withValues(alpha: 0.1),
              ),
              child: SingleChildScrollView(
                child: DataTable(
                  headingTextStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.mutedColor,
                  ),
                  dataTextStyle: const TextStyle(
                    color: AppColors.kDarkChip,
                    fontWeight: FontWeight.w500,
                  ),
                  columnSpacing: 20,
                  columns: const [
                    DataColumn(label: Text('رقم الفاتورة')),
                    DataColumn(label: Text('مجري العملية')), // User Column
                    DataColumn(label: Text('الوقت')),
                    DataColumn(label: Text('النوع')),
                    DataColumn(label: Text('الإجمالي'), numeric: true),
                  ],
                  rows: report!.transactions.map((sale) {
                    final isRefund = sale.isRefund;
                    return DataRow(
                      cells: [
                        DataCell(Text(sale.id.length > 8 ? '#${sale.id.substring(0, 8)}' : '#${sale.id}')),
                        DataCell(Text(sale.cashierName ?? 'Admin')), // Display User Name
                        DataCell(Text(DateFormat('hh:mm a').format(sale.date))),
                        DataCell(Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: (isRefund ? AppColors.errorColor : AppColors.successColor).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isRefund ? 'مرتجع' : 'بيع',
                            style: TextStyle(
                              fontSize: 12,
                              color: isRefund ? AppColors.errorColor : AppColors.successColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )),
                        DataCell(Text('${sale.total.toStringAsFixed(2)} ج.م',
                            style: const TextStyle(fontWeight: FontWeight.bold))),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

