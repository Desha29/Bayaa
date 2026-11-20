import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:bayaa_pos/shared/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:bayaa_pos/l10n/app_localizations.dart';

import 'package:bayaa_pos/app/bootstrap/service_locator.dart';
import 'package:bayaa_pos/features/invoices/presentation/controllers/invoice_cubit.dart';
import 'package:bayaa_pos/features/invoices/presentation/controllers/invoice_state.dart';
import 'package:bayaa_pos/features/inventory/presentation/controllers/stock_alerts_cubit.dart';
import 'package:bayaa_pos/features/inventory/presentation/controllers/stock_alerts_state.dart';
import 'package:bayaa_pos/features/notifications/presentation/controllers/notification_cubit.dart';
import 'package:bayaa_pos/features/products/presentation/controllers/product_cubit.dart';
import 'package:bayaa_pos/features/dashboard/presentation/widgets/daily_target_gauge.dart';
import 'package:bayaa_pos/features/dashboard/presentation/widgets/stock_capacity_card.dart';
import 'package:bayaa_pos/features/dashboard/presentation/widgets/recent_invoices_table.dart';
import 'package:bayaa_pos/preview/sources/expense_preview_source.dart';
import 'package:bayaa_pos/features/expenses/presentation/models/expense_view_data.dart';
import 'package:bayaa_pos/features/customers/presentation/views/customers_view.dart';
import 'package:bayaa_pos/features/suppliers/presentation/views/suppliers_view.dart';
import 'package:bayaa_pos/features/purchases/presentation/views/purchases_view.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.onCardTap,
    required this.isManager,
  });

  final void Function(String id) onCardTap;
  final bool isManager;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _financeChartFilter = 0; // 0: All, 1: Sales, 2: Expenses, 3: Net Profit
  int _financePeriod = 7; // 7, 30, 365
  int _salesTrendDays = 7; // 7, 14, 30, 365

  @override
  void initState() {
    super.initState();
    // Load data for dashboard stats
    getIt<InvoiceCubit>().loadSales();
    getIt<ProductCubit>().getAllCategories();
    getIt<StockAlertsCubit>().loadData();
    getIt<NotificationCubit>().loadData();
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
    VoidCallback? onTap,
    bool compact = false,
  }) {
    final cardDecoration = BoxDecoration(
      color: AppColors.surfaceColor,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: AppColors.borderColor,
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF0F172A).withOpacity(0.035),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
      ],
    );

    if (compact) {
      // Mobile: vertically stacked, centered icon on top
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            constraints: const BoxConstraints(minHeight: 110),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: cardDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.mutedColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    height: 1.1,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    // Desktop: original side-by-side layout
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minHeight: 120),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: cardDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.mutedColor,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      height: 1.1,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  if (subtitle != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticalCards() {
    final l10n = AppLocalizations.of(context);
    final isArabic = l10n.localeName == 'ar';

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final crossAxisCount = constraints.maxWidth < 950 ? 2 : 4;

        final cards = [
          // Net sales today
          BlocBuilder<InvoiceCubit, InvoiceState>(
            bloc: getIt<InvoiceCubit>(),
            builder: (context, state) {
              final now = DateTime.now();
              final todaySales = state.sales.where((s) =>
                  s.date.year == now.year &&
                  s.date.month == now.month &&
                  s.date.day == now.day);
              double totalSales = 0;
              for (var sale in todaySales) {
                if (sale.isRefund) {
                  totalSales -= sale.total;
                } else {
                  totalSales += sale.total;
                }
              }
              return _buildStatCard(
                title: l10n.todaySalesNet,
                value: "${totalSales.toStringAsFixed(2)} ${l10n.currencyEg}",
                icon: LucideIcons.trendingUp,
                color: AppColors.primaryColor,
                subtitle: isArabic ? 'اليوم' : 'Today',
                onTap: () => widget.onCardTap('sales'),
                compact: isMobile,
              );
            },
          ),
          // Total products
          BlocBuilder<StockAlertsCubit, StockAlertsState>(
            bloc: getIt<StockAlertsCubit>(),
            builder: (context, state) {
              final count = getIt<StockAlertsCubit>().products.length;
              return _buildStatCard(
                title: l10n.totalProducts,
                value: l10n.productCount(count),
                icon: LucideIcons.package,
                color: AppColors.successColor,
                subtitle: isArabic ? 'في المخزن' : 'In Stock',
                onTap: () => widget.onCardTap('products'),
                compact: isMobile,
              );
            },
          ),
          // Invoices issued today
          BlocBuilder<InvoiceCubit, InvoiceState>(
            bloc: getIt<InvoiceCubit>(),
            builder: (context, state) {
              final now = DateTime.now();
              final count = state.sales
                  .where((sale) =>
                      !sale.isRefund &&
                      sale.date.year == now.year &&
                      sale.date.month == now.month &&
                      sale.date.day == now.day)
                  .length;
              return _buildStatCard(
                title: isArabic ? 'فواتير اليوم' : 'Today Invoices',
                value: '$count',
                icon: LucideIcons.receiptText,
                color: AppColors.accentColor,
                subtitle: isArabic ? 'فاتورة' : 'Invoices',
                onTap: () => widget.onCardTap('invoices'),
                compact: isMobile,
              );
            },
          ),
          // Today's operating expenses
          FutureBuilder<double>(
            future: ExpensePreviewSource().total(
              DateTime(DateTime.now().year, DateTime.now().month,
                  DateTime.now().day),
              DateTime.now(),
            ),
            builder: (context, snapshot) {
              final total = snapshot.data ?? 0;
              return _buildStatCard(
                title: isArabic ? 'مصروفات اليوم' : 'Today Expenses',
                value: '${total.toStringAsFixed(2)} ${l10n.currencyEg}',
                icon: LucideIcons.walletCards,
                color: AppColors.errorColor,
                subtitle: isArabic ? 'تشغيل' : 'Operating',
                onTap: () => widget.onCardTap('expenses'),
                compact: isMobile,
              );
            },
          ),
          // Stock Alerts (Low & Out of stock)
          BlocBuilder<StockAlertsCubit, StockAlertsState>(
            bloc: getIt<StockAlertsCubit>(),
            builder: (context, state) {
              final alertCount = getIt<StockAlertsCubit>().totalCount;
              return _buildStatCard(
                title: isArabic ? 'تنبيهات المخزون' : 'Stock Alerts',
                value: isArabic ? '$alertCount أصناف' : '$alertCount Items',
                icon: LucideIcons.triangleAlert,
                color: AppColors.warningColor,
                subtitle: isArabic ? 'نواقص' : 'Alerts',
                onTap: () => widget.onCardTap('stock_alerts'),
                compact: isMobile,
              );
            },
          ),
          // Total Customers
          _buildStatCard(
            title: isArabic ? 'إجمالي العملاء' : 'Total Customers',
            value: isArabic
                ? '${customersView.records.length} عميل'
                : '${customersView.records.length} Customers',
            icon: LucideIcons.users,
            color: const Color(0xFF8B5CF6),
            subtitle: isArabic ? 'حساب نشط' : 'Active',
            onTap: () => widget.onCardTap('customers'),
            compact: isMobile,
          ),
          // Suppliers
          _buildStatCard(
            title: isArabic ? 'الموردون' : 'Suppliers',
            value: isArabic
                ? '${suppliersView.records.length} مورد'
                : '${suppliersView.records.length} Suppliers',
            icon: LucideIcons.truck,
            color: const Color(0xFF0EA5E9),
            subtitle: isArabic ? 'شريك' : 'Partners',
            onTap: () => widget.onCardTap('suppliers'),
            compact: isMobile,
          ),
          // Purchase Orders
          _buildStatCard(
            title: isArabic ? 'أوامر الشراء' : 'Purchase Orders',
            value: isArabic
                ? '${purchasesView.records.length} طلب'
                : '${purchasesView.records.length} Orders',
            icon: LucideIcons.shoppingBag,
            color: const Color(0xFF10B981),
            subtitle: isArabic ? 'توريد' : 'Purchases',
            onTap: () => widget.onCardTap('purchases'),
            compact: isMobile,
          ),
        ];
        final spacing = isMobile ? 10.0 : 14.0;
        final cardWidth =
            (constraints.maxWidth - spacing * (crossAxisCount - 1)) / crossAxisCount;
        return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: cards
                .map((card) => SizedBox(width: cardWidth, child: card))
                .toList());
      },
    );
  }

  Widget _buildDailyPlanCard() {
    final l10n = AppLocalizations.of(context);
    final isArabic = l10n.localeName == 'ar';

    return BlocBuilder<InvoiceCubit, InvoiceState>(
      bloc: getIt<InvoiceCubit>(),
      builder: (context, state) {
        final now = DateTime.now();
        final todaySalesList = state.sales.where((s) =>
            s.date.year == now.year &&
            s.date.month == now.month &&
            s.date.day == now.day);

        double currentSales = 0;
        int invoicesCount = 0;
        for (var sale in todaySalesList) {
          if (sale.isRefund) {
            currentSales -= sale.total;
          } else {
            currentSales += sale.total;
            invoicesCount++;
          }
        }
        if (currentSales < 0) currentSales = 0;

        const int targetInvoices = 20;
        const double targetSales = 5000.0;

        final invoiceProgress =
            targetInvoices > 0 ? invoicesCount / targetInvoices : 0.0;
        final salesProgress =
            targetSales > 0 ? currentSales / targetSales : 0.0;
        final compositePercentage =
            ((invoiceProgress + salesProgress) / 2).clamp(0.0, 1.0);

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderColor),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withOpacity(0.03),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          LucideIcons.target,
                          size: 18,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Text(
                        isArabic ? 'خطة وأداء اليوم' : 'Daily Plan & Targets',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      )),
                    ],
                  )),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accentColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isArabic ? 'اليوم' : 'Today',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accentColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DailyTargetGauge(
                percentage: compositePercentage,
                invoicesCount: invoicesCount,
                invoicesTarget: targetInvoices,
                currentSales: currentSales,
                salesTarget: targetSales,
                currency: l10n.currencyEg,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSalesTrendChart() {
    final l10n = AppLocalizations.of(context);
    final arabic = l10n.localeName == 'ar';
    final isYear = _salesTrendDays >= 365;
    return BlocBuilder<InvoiceCubit, InvoiceState>(
      bloc: getIt<InvoiceCubit>(),
      builder: (context, state) {
        final today = DateTime.now();
        final days = isYear
            ? List.generate(12, (index) => DateTime(today.year, index + 1, 1))
            : List.generate(
                _salesTrendDays,
                (index) => DateTime(today.year, today.month, today.day)
                    .subtract(Duration(days: _salesTrendDays - 1 - index)));
        final values = days
            .map((day) => state.sales
                .where((sale) => isYear
                    ? (sale.date.year == day.year &&
                        sale.date.month == day.month)
                    : (sale.date.year == day.year &&
                        sale.date.month == day.month &&
                        sale.date.day == day.day))
                .fold<double>(
                    0,
                    (sum, sale) =>
                        sum + (sale.isRefund ? -sale.total : sale.total)))
            .map((v) => v < 0 ? 0.0 : v)
            .toList();

        final dailyInvoicesCount = days
            .map((day) => state.sales
                .where((sale) => isYear
                    ? (sale.date.year == day.year &&
                        sale.date.month == day.month)
                    : (sale.date.year == day.year &&
                        sale.date.month == day.month &&
                        sale.date.day == day.day))
                .length)
            .toList();

        final totalSales = values.fold<double>(0, (sum, value) => sum + value);
        final totalInvoices =
            dailyInvoicesCount.fold<int>(0, (sum, val) => sum + val);
        final dailyAverage = totalSales / (isYear ? 12 : _salesTrendDays);
        final peakSales = values.fold<double>(0, (m, v) => v > m ? v : m);
        final peakIndex = values.indexOf(peakSales);
        final peakDayName = peakIndex >= 0 && peakSales > 0
            ? DateFormat(isYear ? 'MMMM' : 'EEEE', l10n.localeName)
                .format(days[peakIndex])
            : (arabic ? 'لا يوجد' : 'None');

        final maximum =
            _niceCeiling((peakSales > 100 ? peakSales : 100.0) * 1.15);
        final interval = maximum / 4;

        return _chartSurface(
          title:
              '${l10n.salesTrendTitle} (${_salesTrendDays >= 365 ? (arabic ? 'سنة' : 'Year') : (arabic ? 'آخر $_salesTrendDays أيام' : 'Last $_salesTrendDays days')})',
          subtitle: arabic
              ? 'صافي المبيعات ومعدل العمليات اليومية'
              : 'Net sales & daily transaction trends',
          icon: Icons.show_chart_rounded,
          trailing: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSalesFilterChip(7, arabic ? '7 أيام' : '7 Days'),
                const SizedBox(width: 6),
                _buildSalesFilterChip(14, arabic ? '14 يوم' : '14 Days'),
                const SizedBox(width: 6),
                _buildSalesFilterChip(30, arabic ? '30 يوم' : '30 Days'),
                const SizedBox(width: 6),
                _buildSalesFilterChip(365, arabic ? 'سنة' : 'Year'),
              ],
            ),
          ),
          summary: LayoutBuilder(builder: (context, size) {
            final isNarrow = size.maxWidth < 640;
            final colCount = size.maxWidth < 420 ? 1 : (isNarrow ? 2 : 4);
            final width =
                (size.maxWidth - 12 * (colCount - 1)) / colCount;

            return Wrap(spacing: 12, runSpacing: 12, children: [
              SizedBox(
                  width: width,
                  child: _financeValue(
                    arabic ? 'إجمالي المبيعات' : 'Total sales',
                    totalSales,
                    l10n.currencyEg,
                    const Color(0xFF2563EB),
                    badge: isYear
                        ? '${today.year}'
                        : (arabic
                            ? '$_salesTrendDays أيام'
                            : '$_salesTrendDays Days'),
                  )),
              SizedBox(
                  width: width,
                  child: _financeValue(
                    isYear
                        ? (arabic ? 'المتوسط الشهري' : 'Monthly avg')
                        : (arabic ? 'المتوسط اليومي' : 'Daily average'),
                    dailyAverage,
                    l10n.currencyEg,
                    const Color(0xFF7C3AED),
                    badge: isYear
                        ? (arabic ? 'معدل شهري' : 'Monthly avg')
                        : (arabic ? 'معدل يومي' : 'Daily avg'),
                  )),
              SizedBox(
                  width: width,
                  child: _financeValue(
                    isYear
                        ? (arabic ? 'أعلى شهر' : 'Peak month')
                        : (arabic ? 'أعلى مبيعات' : 'Peak sales'),
                    peakSales,
                    l10n.currencyEg,
                    const Color(0xFF10B981),
                    badge: peakDayName,
                  )),
              SizedBox(
                  width: width,
                  child: _financeValue(
                    arabic ? 'إجمالي الفواتير' : 'Invoices count',
                    totalInvoices.toDouble(),
                    arabic ? 'فاتورة' : 'Invoices',
                    const Color(0xFFD97706),
                    badge: isYear ? (arabic ? 'سنوي' : 'Annual') : (arabic ? 'معاملة' : 'Orders'),
                  )),
            ]);
          }),
          child: LayoutBuilder(builder: (context, size) {
            final compact = size.maxWidth < 500;
            return SizedBox(
              height: compact ? 230 : 280,
              child: Directionality(
                textDirection: ui.TextDirection.ltr,
                child: LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: (days.length - 1).toDouble(),
                    minY: 0,
                    maxY: maximum,
                    extraLinesData: ExtraLinesData(
                      horizontalLines: dailyAverage > 0
                          ? [
                              HorizontalLine(
                                y: dailyAverage,
                                color:
                                    const Color(0xFF7C3AED).withValues(alpha: .55),
                                strokeWidth: 1.5,
                                dashArray: [4, 4],
                                label: HorizontalLineLabel(
                                  show: !compact,
                                  alignment: Alignment.topRight,
                                  padding: const EdgeInsets.only(
                                      right: 8, bottom: 2),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF7C3AED),
                                  ),
                                  labelResolver: (_) => arabic
                                      ? 'المتوسط: ${dailyAverage.toStringAsFixed(0)} ${l10n.currencyEg}'
                                      : 'Avg: ${dailyAverage.toStringAsFixed(0)}',
                                ),
                              ),
                            ]
                          : [],
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: interval,
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: AppColors.borderColor.withValues(alpha: .6),
                        strokeWidth: 1,
                        dashArray: [4, 4],
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (_) => AppColors.primaryColor,
                        tooltipPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        getTooltipItems: (touchedSpots) {
                          if (touchedSpots.isEmpty) return [];
                          return touchedSpots.map((spot) {
                            final dayIdx =
                                spot.x.toInt().clamp(0, days.length - 1);
                            final dayName = isYear
                                ? DateFormat('MMMM yyyy', l10n.localeName)
                                    .format(days[dayIdx])
                                : DateFormat('EEE d MMM', l10n.localeName)
                                    .format(days[dayIdx]);
                            final isPeak =
                                spot.y == peakSales && peakSales > 0;
                            final count = dailyInvoicesCount[dayIdx];
                            final extra = isPeak
                                ? (isYear
                                    ? (arabic ? '\n★ أعلى شهر مبيعات' : '\n★ Peak Month')
                                    : (arabic ? '\n★ أعلى مبيعات' : '\n★ Peak Day'))
                                : '';
                            return LineTooltipItem(
                              '$dayName\n${l10n.sales}: ${spot.y.toStringAsFixed(2)} ${l10n.currencyEg}\n${arabic ? 'الفواتير' : 'Invoices'}: $count$extra',
                              TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: isPeak
                                    ? const Color(0xFF34D399)
                                    : const Color(0xFF93C5FD),
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 56,
                          interval: interval,
                          getTitlesWidget: (value, meta) {
                            if (value < 0 || value > maximum) {
                              return const SizedBox();
                            }
                            if ((value != meta.min &&
                                    (value - meta.min).abs() < interval * 0.3) ||
                                (value != meta.max &&
                                    (value - meta.max).abs() < interval * 0.3) ||
                                (value != 0 && value.abs() < interval * 0.3)) {
                              return const SizedBox();
                            }
                            final cleanVal =
                                value.abs() < (interval * 0.05) ? 0.0 : value;
                            return Text(
                              NumberFormat.compact(locale: l10n.localeName)
                                  .format(cleanVal),
                              maxLines: 1,
                              softWrap: false,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                                color: AppColors.mutedColor,
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          reservedSize:
                              MediaQuery.textScalerOf(context).scale(11) *
                                      1.5 +
                                  12,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= days.length) {
                              return const SizedBox();
                            }
                            if (isYear) {
                              if (compact && index % 2 != 0 && index != 11) {
                                return const SizedBox();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                  DateFormat('MMM', l10n.localeName)
                                      .format(days[index]),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: compact ? 9.5 : 11,
                                    color: AppColors.mutedColor,
                                  ),
                                ),
                              );
                            }
                            final step = compact
                                ? (days.length <= 7
                                    ? 2
                                    : (days.length <= 14 ? 3 : 6))
                                : (days.length <= 7
                                    ? 1
                                    : (days.length <= 14 ? 2 : 5));
                            if (index % step != 0 &&
                                index != days.length - 1) {
                              return const SizedBox();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                DateFormat(
                                        compact || days.length > 7
                                            ? 'd/M'
                                            : 'EEE',
                                        l10n.localeName)
                                    .format(days[index]),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  color: AppColors.mutedColor,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: List.generate(
                            values.length,
                            (index) =>
                                FlSpot(index.toDouble(), values[index])),
                        isCurved: true,
                        curveSmoothness: .32,
                        barWidth: 3.5,
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF2563EB),
                            Color(0xFF06B6D4),
                            Color(0xFF7C3AED),
                          ],
                        ),
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            final isPeak =
                                spot.y == peakSales && peakSales > 0;
                            final isAboveAvg = spot.y >= dailyAverage;
                            final Color dotColor = isPeak
                                ? const Color(0xFF10B981)
                                : (isAboveAvg
                                    ? const Color(0xFF0284C7)
                                    : const Color(0xFF8B5CF6));
                            return FlDotCirclePainter(
                              radius: isPeak ? 5.5 : 4.0,
                              color: dotColor,
                              strokeWidth: 2.5,
                              strokeColor: AppColors.surfaceColor,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              const Color(0xFF2563EB).withValues(alpha: .22),
                              const Color(0xFF06B6D4).withValues(alpha: .08),
                              const Color(0xFF2563EB).withValues(alpha: .005),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildSalesFilterChip(int daysCount, String label) {
    final isSelected = _salesTrendDays == daysCount;
    const activeColor = Color(0xFF2563EB);
    return InkWell(
      onTap: () => setState(() => _salesTrendDays = daysCount),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: .15)
              : AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? activeColor
                : AppColors.borderColor.withValues(alpha: .8),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: activeColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? activeColor : AppColors.mutedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    return LayoutBuilder(builder: (context, size) {
      final narrow = size.maxWidth < 1100 ||
          MediaQuery.textScalerOf(context).scale(1) > 1.4;
      final padding = size.maxWidth < 600 ? 12.0 : 20.0;
      final recentInvoices =
          RecentInvoicesTable(onShowAll: () => widget.onCardTap('invoices'));
      final storeOverview =
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _buildDailyPlanCard(),
        const SizedBox(height: 18),
        StockCapacityCard(onShowAll: () => widget.onCardTap('stock_alerts')),
      ]);
      return SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: 18),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _buildStatisticalCards(),
          const SizedBox(height: 18),
          if (narrow) ...[
            recentInvoices,
            const SizedBox(height: 18),
            storeOverview,
          ] else
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(flex: 3, child: recentInvoices),
              const SizedBox(width: 18),
              Expanded(flex: 2, child: storeOverview),
            ]),
          const SizedBox(height: 20),
          _buildFinancialComparison(),
          const SizedBox(height: 20),
          _buildSalesTrendChart(),
        ]),
      );
    });
  }

  Widget _buildFinancialComparison() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isYear = _financePeriod >= 365;
    final days = isYear
        ? List.generate(12, (index) => DateTime(now.year, index + 1, 1))
        : List.generate(
            _financePeriod, (index) => today.subtract(Duration(days: _financePeriod - 1 - index)));
    final start = isYear ? DateTime(now.year, 1, 1) : days.first;
    final end = isYear ? DateTime(now.year, 12, 31, 23, 59, 59) : DateTime(now.year, now.month, now.day, 23, 59, 59);
    final l10n = AppLocalizations.of(context);
    final arabic = l10n.localeName == 'ar';
    final expenseLabel = arabic ? 'المصروفات' : 'Expenses';
    final periodLabel = _financePeriod >= 365
        ? (arabic ? 'سنة ${now.year}' : 'Year ${now.year}')
        : (arabic ? '$_financePeriod أيام' : '$_financePeriod Days');

    return FutureBuilder<List<ExpenseViewData>>(
      future: ExpensePreviewSource().getExpenses(start: start, end: end),
      builder: (context, snapshot) => BlocBuilder<InvoiceCubit, InvoiceState>(
        bloc: getIt<InvoiceCubit>(),
        builder: (context, state) {
          final expenseRecords = snapshot.data ?? [];

          // Calculate values for both Sales and Expenses across the period
          final salesValues = days.map((day) {
            return state.sales
                .where((sale) => isYear
                    ? (sale.date.year == day.year && sale.date.month == day.month)
                    : (sale.date.year == day.year &&
                        sale.date.month == day.month &&
                        sale.date.day == day.day))
                .fold<double>(
                    0.0,
                    (sum, sale) =>
                        sum + (sale.isRefund ? -sale.total : sale.total));
          }).map((v) => v < 0 ? 0.0 : v).toList();

          final expenseValues = days.map((day) {
            return expenseRecords
                .where((exp) => isYear
                    ? (exp.date.year == day.year && exp.date.month == day.month)
                    : (exp.date.year == day.year &&
                        exp.date.month == day.month &&
                        exp.date.day == day.day))
                .fold<double>(0.0, (sum, exp) => sum + exp.amount);
          }).toList();

          // Net profit (can be positive or negative)
          final profitValues = List.generate(
              days.length, (i) => salesValues[i] - expenseValues[i]);

          final totalSales = salesValues.fold<double>(0, (a, b) => a + b);
          final totalExpenses = expenseValues.fold<double>(0, (a, b) => a + b);
          final netProfit = totalSales - totalExpenses;
          final profitMargin =
              totalSales > 0 ? (netProfit / totalSales * 100) : 0.0;

          final maxSales =
              salesValues.fold<double>(0, (m, v) => v > m ? v : m);
          final maxExpense =
              expenseValues.fold<double>(0, (m, v) => v > m ? v : m);
          final maxProfit =
              profitValues.fold<double>(0, (m, v) => v > m ? v : m);
          final minProfit =
              profitValues.fold<double>(0, (m, v) => v < m ? v : m);

          double minY;
          double maxY;
          double interval;

          if (minProfit < -0.01) {
            final absMax = [
              maxSales,
              maxExpense,
              maxProfit.abs(),
              minProfit.abs(),
              100.0
            ].reduce((a, b) => a > b ? a : b);
            final ceiling = _niceCeiling(absMax * 1.15);
            maxY = ceiling;
            minY = -ceiling;
            interval = ceiling / 2;
          } else {
            final peakVal = [maxSales, maxExpense, maxProfit, 100.0]
                .reduce((a, b) => a > b ? a : b);
            final ceiling = _niceCeiling(peakVal * 1.15);
            minY = 0.0;
            maxY = ceiling;
            interval = ceiling / 4;
          }
          final range = maxY - minY;

          // Curve 1: Sales (Royal Blue)
          final salesBarData = LineChartBarData(
            spots: List.generate(
                salesValues.length,
                (i) => FlSpot(i.toDouble(), salesValues[i])),
            isCurved: true,
            curveSmoothness: 0.32,
            barWidth: 3.5,
            color: const Color(0xFF2563EB),
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) =>
                  FlDotCirclePainter(
                radius: 4,
                color: AppColors.surfaceColor,
                strokeWidth: 2.5,
                strokeColor: const Color(0xFF2563EB),
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF2563EB).withValues(alpha: .20),
                  const Color(0xFF2563EB).withValues(alpha: .01),
                ],
              ),
            ),
          );

          // Curve 2: Expenses (Vibrant Orange)
          final expenseBarData = LineChartBarData(
            spots: List.generate(
                expenseValues.length,
                (i) => FlSpot(i.toDouble(), expenseValues[i])),
            isCurved: true,
            curveSmoothness: 0.32,
            barWidth: 3.5,
            color: const Color(0xFFEA580C),
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) =>
                  FlDotCirclePainter(
                radius: 4,
                color: AppColors.surfaceColor,
                strokeWidth: 2.5,
                strokeColor: const Color(0xFFEA580C),
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFFEA580C).withValues(alpha: .18),
                  const Color(0xFFEA580C).withValues(alpha: .01),
                ],
              ),
            ),
          );

          // Curve 3: Net Profit (Color-changing: Green for profit, Red for deficit)
          final profitBarData = LineChartBarData(
            spots: List.generate(
                profitValues.length,
                (i) => FlSpot(i.toDouble(), profitValues[i])),
            isCurved: true,
            curveSmoothness: 0.32,
            barWidth: 3.5,
            color: netProfit >= 0
                ? const Color(0xFF10B981)
                : const Color(0xFFE11D48),
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                final isPositive = spot.y >= 0;
                final dotColor = isPositive
                    ? const Color(0xFF10B981)
                    : const Color(0xFFE11D48);
                return FlDotCirclePainter(
                  radius: 4.5,
                  color: dotColor,
                  strokeWidth: 2.5,
                  strokeColor: AppColors.surfaceColor,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  (netProfit >= 0
                          ? const Color(0xFF10B981)
                          : const Color(0xFFE11D48))
                      .withValues(alpha: .22),
                  (netProfit >= 0
                          ? const Color(0xFF10B981)
                          : const Color(0xFFE11D48))
                      .withValues(alpha: .01),
                ],
              ),
            ),
          );

          final lineBars = <LineChartBarData>[];
          if (_financeChartFilter == 0 || _financeChartFilter == 1) {
            lineBars.add(salesBarData);
          }
          if (_financeChartFilter == 0 || _financeChartFilter == 2) {
            lineBars.add(expenseBarData);
          }
          if (_financeChartFilter == 0 || _financeChartFilter == 3) {
            lineBars.add(profitBarData);
          }

          return _chartSurface(
            title: arabic ? 'المبيعات مقابل المصروفات' : 'Sales vs expenses',
            subtitle: arabic
                ? 'مقارنة المنحنيات ومؤشرات الأداء خلال $periodLabel'
                : '$periodLabel financial curves & performance statistics',
            icon: Icons.auto_graph_rounded,
            trailing: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildFinancePeriodChip(7, arabic ? '7 أيام' : '7 Days'),
                  const SizedBox(width: 6),
                  _buildFinancePeriodChip(30, arabic ? '30 يوم' : '30 Days'),
                  const SizedBox(width: 6),
                  _buildFinancePeriodChip(365, arabic ? 'سنة' : 'Year'),
                  const SizedBox(width: 10),
                  Container(height: 16, width: 1, color: AppColors.borderColor),
                  const SizedBox(width: 10),
                  _buildFilterChip(
                      0, arabic ? 'الكل' : 'All', AppColors.primaryColor),
                  const SizedBox(width: 6),
                  _buildFilterChip(
                      1, l10n.sales, const Color(0xFF2563EB)),
                  const SizedBox(width: 6),
                  _buildFilterChip(
                      2, expenseLabel, const Color(0xFFEA580C)),
                  const SizedBox(width: 6),
                  _buildFilterChip(
                      3, arabic ? 'صافي الربح' : 'Net profit', const Color(0xFF10B981)),
                ],
              ),
            ),
            summary: LayoutBuilder(builder: (context, size) {
              final isNarrow = size.maxWidth < 640;
              final colCount = size.maxWidth < 420 ? 1 : (isNarrow ? 2 : 4);
              final width =
                  (size.maxWidth - 12 * (colCount - 1)) / colCount;

              return Wrap(spacing: 12, runSpacing: 12, children: [
                SizedBox(
                    width: width,
                    child: _financeValue(
                      l10n.sales,
                      totalSales,
                      l10n.currencyEg,
                      const Color(0xFF2563EB),
                      badge: periodLabel,
                    )),
                SizedBox(
                    width: width,
                    child: _financeValue(
                      expenseLabel,
                      totalExpenses,
                      l10n.currencyEg,
                      const Color(0xFFEA580C),
                      badge: periodLabel,
                    )),
                SizedBox(
                    width: width,
                    child: _financeValue(
                      arabic ? 'صافي الربح' : 'Net profit',
                      netProfit,
                      l10n.currencyEg,
                      netProfit >= 0
                          ? const Color(0xFF059669)
                          : const Color(0xFFE11D48),
                      badge: netProfit >= 0
                          ? (arabic ? '+ أرباح' : '+ Profit')
                          : (arabic ? '- عجز' : '- Loss'),
                    )),
                SizedBox(
                    width: width,
                    child: _financeValue(
                      arabic ? 'هامش الربح' : 'Profit margin',
                      profitMargin,
                      '%',
                      profitMargin >= 0
                          ? const Color(0xFF10B981)
                          : const Color(0xFFE11D48),
                      badge: profitMargin >= 0
                          ? (arabic ? 'إيجابي' : 'Positive')
                          : (arabic ? 'سالب' : 'Negative'),
                    )),
              ]);
            }),
            child: LayoutBuilder(builder: (context, size) {
              final compact = size.maxWidth < 500;
              return SizedBox(
                height: compact ? 240 : 290,
                child: Directionality(
                  textDirection: ui.TextDirection.ltr,
                  child: LineChart(
                    LineChartData(
                      minX: 0,
                      maxX: (days.length - 1).toDouble(),
                      minY: minY,
                      maxY: maxY,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: interval,
                        getDrawingHorizontalLine: (value) {
                          final isZeroLine = value.abs() < (range * 0.01);
                          if (isZeroLine && minY < 0) {
                            return FlLine(
                              color: AppColors.mutedColor.withValues(alpha: .7),
                              strokeWidth: 1.5,
                              dashArray: [2, 2],
                            );
                          }
                          return FlLine(
                            color: AppColors.borderColor.withValues(alpha: .6),
                            strokeWidth: 1,
                            dashArray: [4, 4],
                          );
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (_) => AppColors.primaryColor,
                          tooltipPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          getTooltipItems: (touchedSpots) {
                            if (touchedSpots.isEmpty) return [];
                            return touchedSpots.map((spot) {
                              final barData = spot.bar;
                              String name;
                              Color textColor;
                              if (barData == salesBarData) {
                                name = l10n.sales;
                                textColor = const Color(0xFF93C5FD);
                              } else if (barData == expenseBarData) {
                                name = expenseLabel;
                                textColor = const Color(0xFFFDBA74);
                              } else {
                                name = arabic ? 'صافي الربح' : 'Net profit';
                                textColor = spot.y >= 0
                                    ? const Color(0xFF6EE7B7)
                                    : const Color(0xFFFDA4AF);
                              }
                              final dayIdx = spot.x.toInt().clamp(0, days.length - 1);
                              final dayName = isYear
                                  ? DateFormat('MMMM yyyy', l10n.localeName)
                                      .format(days[dayIdx])
                                  : DateFormat('EEE d MMM', l10n.localeName)
                                      .format(days[dayIdx]);
                              final sign = spot.y < 0 ? '-' : '';
                              return LineTooltipItem(
                                '$dayName\n$name: $sign${spot.y.abs().toStringAsFixed(2)} ${l10n.currencyEg}',
                                TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 56,
                            interval: interval,
                            getTitlesWidget: (value, meta) {
                              if (value < minY || value > maxY) {
                                return const SizedBox();
                              }
                              if ((value != meta.min &&
                                      (value - meta.min).abs() < interval * 0.3) ||
                                  (value != meta.max &&
                                      (value - meta.max).abs() < interval * 0.3) ||
                                  (value != 0 && value.abs() < interval * 0.3)) {
                                return const SizedBox();
                              }
                              final cleanVal =
                                  value.abs() < (interval * 0.05) ? 0.0 : value;
                              return Text(
                                NumberFormat.compact(locale: l10n.localeName)
                                    .format(cleanVal),
                                maxLines: 1,
                                softWrap: false,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                  color: AppColors.mutedColor,
                                ),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            reservedSize:
                                MediaQuery.textScalerOf(context).scale(11) *
                                        1.5 +
                                    12,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= days.length) {
                                return const SizedBox();
                              }
                              if (isYear) {
                                if (compact && index % 2 != 0 && index != 11) {
                                  return const SizedBox();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Text(
                                    DateFormat('MMM', l10n.localeName)
                                        .format(days[index]),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: compact ? 9.5 : 11,
                                      color: AppColors.mutedColor,
                                    ),
                                  ),
                                );
                              }
                              final step = compact
                                  ? (days.length <= 7
                                      ? 2
                                      : (days.length <= 14 ? 3 : 6))
                                  : (days.length <= 7
                                      ? 1
                                      : (days.length <= 14 ? 2 : 5));
                              if (index % step != 0 &&
                                  index != days.length - 1) {
                                return const SizedBox();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                  DateFormat(
                                          compact || days.length > 7
                                              ? 'd/M'
                                              : 'EEE',
                                          l10n.localeName)
                                      .format(days[index]),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                    color: AppColors.mutedColor,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      lineBarsData: lineBars,
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(int index, String label, Color activeColor) {
    final isSelected = _financeChartFilter == index;
    return InkWell(
      onTap: () => setState(() => _financeChartFilter = index),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: .15)
              : AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? activeColor
                : AppColors.borderColor.withValues(alpha: .8),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: activeColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? activeColor : AppColors.mutedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancePeriodChip(int period, String label) {
    final isSelected = _financePeriod == period;
    const activeColor = Color(0xFF2563EB);
    return InkWell(
      onTap: () => setState(() => _financePeriod = period),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: .15)
              : AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? activeColor
                : AppColors.borderColor.withValues(alpha: .8),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? activeColor : AppColors.mutedColor,
          ),
        ),
      ),
    );
  }

  double _niceCeiling(double val) {
    if (val <= 0) return 100.0;
    final exponent = (math.log(val) / math.ln10).floor();
    final powerOfTen = math.pow(10, exponent).toDouble();
    final fraction = val / powerOfTen;

    double niceFraction;
    if (fraction <= 1.0) {
      niceFraction = 1.0;
    } else if (fraction <= 2.0) {
      niceFraction = 2.0;
    } else if (fraction <= 4.0) {
      niceFraction = 4.0;
    } else if (fraction <= 6.0) {
      niceFraction = 6.0;
    } else if (fraction <= 8.0) {
      niceFraction = 8.0;
    } else {
      niceFraction = 10.0;
    }
    return niceFraction * powerOfTen;
  }

  Widget _chartSurface(
          {required String title,
          required String subtitle,
          required IconData icon,
          required Widget summary,
          required Widget child,
          Widget? trailing}) =>
      LayoutBuilder(builder: (context, size) {
        final isCompact = size.maxWidth < 580;
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(size.maxWidth < 500 ? 16 : 24),
          decoration: BoxDecoration(
              color: AppColors.surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderColor)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            if (isCompact) ...[
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                        color: AppColors.secondaryColor.withValues(alpha: .08),
                        borderRadius: BorderRadius.circular(10)),
                    child: Icon(icon, size: 20, color: AppColors.secondaryColor)),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(title,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      Text(subtitle,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              height: 1.5,
                              color: AppColors.mutedColor)),
                    ])),
              ]),
              if (trailing != null) ...[
                const SizedBox(height: 12),
                trailing,
              ],
            ] else ...[
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                        color: AppColors.secondaryColor.withValues(alpha: .08),
                        borderRadius: BorderRadius.circular(10)),
                    child: Icon(icon, size: 20, color: AppColors.secondaryColor)),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(title,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      Text(subtitle,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              height: 1.5,
                              color: AppColors.mutedColor)),
                    ])),
                if (trailing != null) ...[
                  const SizedBox(width: 10),
                  trailing,
                ],
              ]),
            ],
            const SizedBox(height: 18),
            summary,
            const SizedBox(height: 24),
            child,
          ]),
        );
      });

  Widget _financeValue(
          String label, double value, String currency, Color color,
          {String? badge}) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
            color: color.withOpacity(.055),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: color.withOpacity(.12))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
                width: 9,
                height: 9,
                decoration:
                    BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Expanded(
                child: Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: AppColors.mutedColor))),
            if (badge != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
          ]),
          const SizedBox(height: 6),
          Directionality(
            textDirection: ui.TextDirection.ltr,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${value < 0 ? '-' : ''}${value.abs().toStringAsFixed(2)}',
                  style: TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 15, color: color),
                ),
                const SizedBox(width: 4),
                Text(
                  currency,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13, color: color),
                ),
              ],
            ),
          ),
        ]),
      );
}
