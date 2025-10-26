import 'dart:async';
import 'package:crazy_phone_pos/core/components/screen_header.dart';
import 'package:crazy_phone_pos/core/utils/hive_helper.dart';
import 'package:crazy_phone_pos/features/sales/data/repository/sales_repository_impl.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import '../../../core/constants/app_colors.dart';
import '../data/arp_repository_impl.dart';
import '../data/models/dialy_report_model.dart';
import '../data/models/product_performance_model.dart';
import '../domain/daily_report_pdf_service.dart';
import 'daily_report_preview_screen.dart';
import '../../../core/components/message_overlay.dart';

class DailyReportScreen extends StatefulWidget {
  const DailyReportScreen({Key? key}) : super(key: key);

  @override
  State<DailyReportScreen> createState() => _DailyReportScreenState();
}

class _DailyReportScreenState extends State<DailyReportScreen>
    with SingleTickerProviderStateMixin {
  DateTime selectedDate = DateTime.now();
  DailyReportModel? report;
  bool loading = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    fetchReport();
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

    final repo = ArpRepositoryImpl(
      salesRepository: SalesRepositoryImpl(
        productsBox: HiveHelper.productsBox,
        salesBox: HiveHelper.salesBox,
      ),
    );

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
    print('Loaded report: $report');
    print('Top products: ${report?.topProducts}');

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
      await Printing.layoutPdf(
        onLayout: (format) =>
            DailyReportPdfService.generateDailyReportPDF(report!),
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
                subtitleColor: Colors.grey.shade600,
                iconColor: AppColors.primaryColor,
              ),
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 32 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
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
                                      size: 80, color: Colors.grey.shade300),
                                  const SizedBox(height: 16),
                                  Text(
                                    'لا توجد بيانات متاحة لهذا التاريخ',
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey.shade600,
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
    );
  }

  Widget _buildDateSelectionSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
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
                border: Border.all(color: Colors.grey.shade300),
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
                                fontSize: 12, color: Colors.grey.shade600)),
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

  Widget _buildReportContent() {
    return Column(
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
        Expanded(
          child: FadeTransition(
            opacity: _animationController,
            child: SlideTransition(
              position:
                  Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
                      .animate(CurvedAnimation(
                          parent: _animationController, curve: Curves.easeOut)),
              child: _buildTopProductsList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
              'إجمالي الإيرادات',
              '${report!.totalRevenue.toStringAsFixed(2)} ج.م',
              Icons.attach_money,
              Colors.green),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
              'إجمالي التكاليف',
              '${report!.totalCost.toStringAsFixed(2)} ج.م',
              Icons.money_off,
              Colors.red),
        ),
      ],
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
              color: Colors.black.withOpacity(0.04),
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
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(title,
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
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
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _handlePreview,
                icon: const Icon(Icons.visibility, size: 20),
                label: const Text('معاينة التقرير'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _handlePrint,
                icon: const Icon(Icons.print, size: 20),
                label: const Text('طباعة مباشرة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _handleShare,
            icon: const Icon(Icons.share, size: 20),
            label: const Text('مشاركة PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade100,
              foregroundColor: Colors.grey.shade700,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopProductsList() {
    if (report?.topProducts.isEmpty ?? true) {
      return Center(
          child: Text('لا توجد منتجات مباعة لهذا التاريخ',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 16)));
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
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
                  'جميع المنتجات المباعة (${report!.topProducts.length})',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.kDarkChip),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: report!.topProducts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  _buildProductCard(report!.topProducts[index], index),
            ),
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
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
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
                            size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text('${product.quantitySold} وحدة',
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
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
                          TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  Text('هامش: ${product.profitMargin.toStringAsFixed(1)}%',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
