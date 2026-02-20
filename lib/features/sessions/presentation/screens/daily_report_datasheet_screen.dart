import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import '../../../../core/constants/app_colors.dart';
import '../../data/models/daily_report_model.dart';
import '../../../sales/data/models/sale_model.dart';

class DailyReportDatasheetScreen extends StatefulWidget {
  final DailyReport report;

  const DailyReportDatasheetScreen({super.key, required this.report});

  @override
  State<DailyReportDatasheetScreen> createState() =>
      _DailyReportDatasheetScreenState();
}

class _DailyReportDatasheetScreenState extends State<DailyReportDatasheetScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: _buildGradientAppBar(),
        body: Column(
          children: [
            _buildSummaryHeader(),
            Expanded(
              child: widget.report.transactions.isEmpty
                  ? _buildEmptyState()
                  : _buildTransactionsList(),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildGradientAppBar() {
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
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                  tooltip: 'إغلاق',
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'تفاصيل المعاملات',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${widget.report.totalTransactions} معاملة',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 48), // Balance the back button
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryHeader() {
    final report = widget.report;
    return FadeTransition(
      opacity: _animationController,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.15),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeOut,
        )),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildSummaryCard(
                'صافي المبيعات',
                report.netRevenue.toStringAsFixed(2),
                'ج.م',
                const Color(0xFF059669),
                Icons.trending_up_rounded,
                const Color(0xFFD1FAE5),
              ),
              const SizedBox(width: 14),
              _buildSummaryCard(
                'عدد المعاملات',
                '${report.totalTransactions}',
                'معاملة',
                AppColors.secondaryColor,
                Icons.receipt_long_rounded,
                const Color(0xFFDBEAFE),
              ),
              const SizedBox(width: 14),
              _buildSummaryCard(
                'المرتجعات',
                report.totalRefunds.toStringAsFixed(2),
                'ج.م',
                AppColors.errorColor,
                Icons.rotate_left_rounded,
                const Color(0xFFFEE2E2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    String unit,
    Color color,
    IconData icon,
    Color bgColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
        decoration: BoxDecoration(
          color: bgColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: FadeTransition(
        opacity: _animationController,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 56,
                color: AppColors.mutedColor.withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'لا توجد معاملات في هذا التقرير',
              style: TextStyle(
                color: AppColors.mutedColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'سيتم عرض المعاملات هنا عند توفرها',
              style: TextStyle(
                color: AppColors.mutedColor.withOpacity(0.6),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsList() {
    final transactions = List<Sale>.from(widget.report.transactions)
      ..sort((a, b) => b.date.compareTo(a.date));

    return FadeTransition(
      opacity: _animationController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.list_alt_rounded,
                    color: AppColors.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'سجل الحركات التفصيلي',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${transactions.length} عملية',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Column headers
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.06),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: const Row(
              children: [
                SizedBox(width: 90, child: Text('رقم المعاملة', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryColor, fontSize: 12))),
                SizedBox(width: 80, child: Text('الوقت', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryColor, fontSize: 12))),
                SizedBox(width: 70, child: Text('النوع', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryColor, fontSize: 12))),
                SizedBox(width: 80, child: Text('بواسطة', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryColor, fontSize: 12))),
                Expanded(child: Text('المنتجات', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryColor, fontSize: 12))),
                SizedBox(width: 90, child: Text('القيمة', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryColor, fontSize: 12), textAlign: TextAlign.left)),
              ],
            ),
          ),
          // Transaction rows
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                border: Border.all(color: AppColors.borderColor.withOpacity(0.5)),
              ),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: transactions.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: AppColors.borderColor.withOpacity(0.4),
                ),
                itemBuilder: (context, index) {
                  final sale = transactions[index];
                  return _buildTransactionRow(sale, index);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildTransactionRow(Sale sale, int index) {
    final isRefund = sale.isRefund;
    final itemsText = sale.saleItems
        .map((i) => '${i.name} (${i.quantity})')
        .join('، ');
    final isEven = index % 2 == 0;

    return Container(
      color: isEven ? Colors.transparent : AppColors.backgroundColor.withOpacity(0.5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '#${sale.id.substring(0, 8)}',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: AppColors.textPrimary,
                fontFamily: 'monospace',
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              intl.DateFormat('hh:mm a').format(sale.date),
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ),
          SizedBox(
            width: 70,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isRefund
                      ? [AppColors.errorColor.withOpacity(0.12), AppColors.errorColor.withOpacity(0.06)]
                      : [AppColors.successColor.withOpacity(0.12), AppColors.successColor.withOpacity(0.06)],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isRefund
                      ? AppColors.errorColor.withOpacity(0.2)
                      : AppColors.successColor.withOpacity(0.2),
                ),
              ),
              child: Text(
                isRefund ? 'مرتجع' : 'بيع',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isRefund ? AppColors.errorColor : AppColors.successColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              sale.cashierName ?? '-',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Text(
              itemsText,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.mutedColor,
              ),
            ),
          ),
          SizedBox(
            width: 90,
            child: Text(
              '${isRefund ? '-' : ''}${sale.total.toStringAsFixed(2)} ج.م',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isRefund ? AppColors.errorColor : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
