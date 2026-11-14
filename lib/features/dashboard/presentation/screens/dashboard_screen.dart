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
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minHeight: 120),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
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
          ),
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
        final crossAxisCount = constraints.maxWidth < 600
            ? 1
            : constraints.maxWidth < 950
                ? 2
                : 4;

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
              );
            },
          ),
        ];
        final cardWidth =
            (constraints.maxWidth - 14 * (crossAxisCount - 1)) / crossAxisCount;
        return Wrap(
            spacing: 14,
            runSpacing: 14,
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
    return BlocBuilder<InvoiceCubit, InvoiceState>(
      bloc: getIt<InvoiceCubit>(),
      builder: (context, state) {
        final today = DateTime.now();
        final days = List.generate(
            7,
            (index) => DateTime(today.year, today.month, today.day)
                .subtract(Duration(days: 6 - index)));
        final values = days
            .map((day) => state.sales
                .where((sale) =>
                    sale.date.year == day.year &&
                    sale.date.month == day.month &&
                    sale.date.day == day.day)
                .fold<double>(
                    0,
                    (sum, sale) =>
                        sum + (sale.isRefund ? -sale.total : sale.total)))
            .toList();
        final total = values.fold<double>(0, (sum, value) => sum + value);
        final maximum = values.fold<double>(
                100, (value, next) => next > value ? next : value) *
            1.2;
        return _chartSurface(
          title: l10n.salesTrendTitle,
          subtitle: arabic
              ? 'صافي المبيعات خلال آخر 7 أيام'
              : 'Net sales over the last 7 days',
          icon: Icons.show_chart_rounded,
          summary: LayoutBuilder(builder: (context, size) {
            final width =
                size.maxWidth < 520 ? size.maxWidth : (size.maxWidth - 12) / 2;
            return Wrap(spacing: 12, runSpacing: 12, children: [
              SizedBox(
                  width: width,
                  child: _financeValue(arabic ? 'إجمالي الأسبوع' : 'Week total',
                      total, l10n.currencyEg, AppColors.secondaryColor)),
              SizedBox(
                  width: width,
                  child: _financeValue(
                      arabic ? 'المتوسط اليومي' : 'Daily average',
                      total / 7,
                      l10n.currencyEg,
                      AppColors.primaryColor))
            ]);
          }),
          child: LayoutBuilder(builder: (context, size) {
            final compact = size.maxWidth < 500;
            return SizedBox(
                height: compact ? 230 : 280,
                child: Directionality(
                  textDirection: ui.TextDirection.ltr,
                  child: LineChart(LineChartData(
                    minX: 0,
                    maxX: 6,
                    minY: 0,
                    maxY: maximum,
                    gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: maximum / 4,
                        getDrawingHorizontalLine: (_) => FlLine(
                            color: AppColors.borderColor.withValues(alpha: .6),
                            strokeWidth: 1,
                            dashArray: [4, 4])),
                    borderData: FlBorderData(show: false),
                    lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => AppColors.primaryColor,
                      tooltipPadding: const EdgeInsets.all(10),
                      getTooltipItems: (spots) => spots
                          .map((spot) => LineTooltipItem(
                              '${DateFormat('d MMM', l10n.localeName).format(days[spot.x.toInt()])}\n${spot.y.toStringAsFixed(2)} ${l10n.currencyEg}',
                              TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryForeground)))
                          .toList(),
                    )),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 42,
                              interval: maximum / 4,
                              getTitlesWidget: (value, meta) => Text(
                                  NumberFormat.compact(locale: l10n.localeName)
                                      .format(value),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                      color: AppColors.mutedColor)))),
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
                                if (index < 0 ||
                                    index > 6 ||
                                    (compact &&
                                        index != 0 &&
                                        index != 3 &&
                                        index != 6)) {
                                  return const SizedBox();
                                }
                                return Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Text(
                                        DateFormat(compact ? 'd/M' : 'EEE',
                                                l10n.localeName)
                                            .format(days[index]),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                            color: AppColors.mutedColor)));
                              })),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: List.generate(values.length,
                            (index) => FlSpot(index.toDouble(), values[index])),
                        isCurved: true,
                        curveSmoothness: .25,
                        barWidth: 3,
                        color: AppColors.secondaryColor,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) =>
                                FlDotCirclePainter(
                                    radius: 4,
                                    color: AppColors.surfaceColor,
                                    strokeWidth: 2,
                                    strokeColor: AppColors.secondaryColor)),
                        belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  AppColors.secondaryColor
                                      .withValues(alpha: .14),
                                  AppColors.secondaryColor
                                      .withValues(alpha: .01)
                                ])),
                      )
                    ],
                  )),
                ));
          }),
        );
      },
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
    final start = DateTime(now.year, now.month, now.day);
    final l10n = AppLocalizations.of(context);
    final arabic = l10n.localeName == 'ar';
    final expenseLabel = arabic ? 'المصروفات' : 'Expenses';
    return FutureBuilder<double>(
      future: ExpensePreviewSource().total(start, now),
      builder: (context, snapshot) => BlocBuilder<InvoiceCubit, InvoiceState>(
        bloc: getIt<InvoiceCubit>(),
        builder: (context, state) {
          final sales = state.sales
              .where((sale) => !sale.isRefund && !sale.date.isBefore(start))
              .fold<double>(0, (sum, sale) => sum + sale.total);
          final expenses = snapshot.data ?? 0;
          final maximum =
              [sales, expenses, 1.0].reduce((a, b) => a > b ? a : b) * 1.2;
          return _chartSurface(
            title: arabic ? 'المبيعات مقابل المصروفات' : 'Sales vs expenses',
            subtitle: arabic
                ? 'مقارنة المبيعات والمصروفات لليوم'
                : "Today's sales and operating expenses",
            icon: Icons.bar_chart_rounded,
            summary: LayoutBuilder(builder: (context, size) {
              final width = size.maxWidth < 520
                  ? size.maxWidth
                  : (size.maxWidth - 12) / 2;
              return Wrap(spacing: 12, runSpacing: 12, children: [
                SizedBox(
                    width: width,
                    child: _financeValue(l10n.sales, sales, l10n.currencyEg,
                        AppColors.secondaryColor)),
                SizedBox(
                    width: width,
                    child: _financeValue(expenseLabel, expenses,
                        l10n.currencyEg, AppColors.accentColor)),
              ]);
            }),
            child: LayoutBuilder(
                builder: (context, size) => SizedBox(
                    height: size.maxWidth < 500 ? 230 : 280,
                    child: Directionality(
                      textDirection: ui.TextDirection.ltr,
                      child: BarChart(BarChartData(
                        maxY: maximum,
                        alignment: BarChartAlignment.spaceAround,
                        gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: maximum / 4,
                            getDrawingHorizontalLine: (_) => FlLine(
                                color:
                                    AppColors.borderColor.withValues(alpha: .6),
                                strokeWidth: 1,
                                dashArray: [4, 4])),
                        borderData: FlBorderData(show: false),
                        barTouchData: BarTouchData(
                            touchTooltipData: BarTouchTooltipData(
                                getTooltipColor: (_) => AppColors.primaryColor,
                                getTooltipItem: (group, groupIndex, rod,
                                        rodIndex) =>
                                    BarTooltipItem(
                                        '${group.x == 0 ? l10n.sales : expenseLabel}\n${rod.toY.toStringAsFixed(2)} ${l10n.currencyEg}',
                                        TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color:
                                                AppColors.primaryForeground)))),
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 42,
                                  interval: maximum / 4,
                                  getTitlesWidget: (value, meta) => Text(
                                      NumberFormat.compact(
                                              locale: l10n.localeName)
                                          .format(value),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                          color: AppColors.mutedColor)))),
                          bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: MediaQuery.textScalerOf(context)
                                              .scale(11) *
                                          1.5 +
                                      12,
                                  getTitlesWidget: (value, meta) => Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Text(
                                          value.toInt() == 0
                                              ? l10n.sales
                                              : expenseLabel,
                                          style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.mutedColor))))),
                        ),
                        barGroups: [
                          _financeBar(
                              0, sales, maximum, AppColors.secondaryColor),
                          _financeBar(
                              1, expenses, maximum, AppColors.accentColor),
                        ],
                      )),
                    ))),
          );
        },
      ),
    );
  }

  Widget _chartSurface(
          {required String title,
          required String subtitle,
          required IconData icon,
          required Widget summary,
          required Widget child}) =>
      LayoutBuilder(builder: (context, size) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(size.maxWidth < 500 ? 16 : 24),
          decoration: BoxDecoration(
              color: AppColors.surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderColor)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
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
            const SizedBox(height: 18),
            summary,
            const SizedBox(height: 24),
            child,
          ]),
        );
      });

  Widget _financeValue(
          String label, double value, String currency, Color color) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
            color: color.withOpacity(.055),
            borderRadius: BorderRadius.circular(13)),
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
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: AppColors.mutedColor))),
          ]),
          const SizedBox(height: 6),
          Text('${value.toStringAsFixed(2)} $currency',
              style: TextStyle(fontWeight: FontWeight.w800, color: color)),
        ]),
      );

  BarChartGroupData _financeBar(
          int x, double value, double maxValue, Color color) =>
      BarChartGroupData(
        x: x,
        barRods: [
          BarChartRodData(
            toY: value,
            width: 38,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(9)),
            gradient: LinearGradient(
                colors: [color.withOpacity(.72), color],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter),
            backDrawRodData: BackgroundBarChartRodData(
                show: true, toY: maxValue, color: color.withOpacity(.055)),
          )
        ],
      );
}
