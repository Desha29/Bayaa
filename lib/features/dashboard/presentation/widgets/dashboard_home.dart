import 'dart:ui' as ui;

import 'package:bayaa_pos/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:bayaa_pos/l10n/app_localizations.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../invoice/presentation/cubit/invoice_cubit.dart';
import '../../../invoice/presentation/cubit/invoice_state.dart';
import '../../../stock/presentation/cubit/stock_cubit.dart';
import '../../../stock/presentation/cubit/stock_states.dart';
import '../../../notifications/presentation/cubit/notifications_cubit.dart';
import '../../../products/presentation/cubit/product_cubit.dart';
import '../../../sessions/data/repositories/session_repository_impl.dart';
import 'recent_operations.dart';
import '../../../../core/session/session_manager.dart';
import '../../../expenses/data/expense_repository.dart';

class DashboardHome extends StatefulWidget {
  const DashboardHome({
    super.key,
    required this.onCardTap,
    required this.isManager,
  });

  final void Function(String id) onCardTap;
  final bool isManager;

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  int? _sessionCount;

  // ignore: unused_element
  List<Map<String, dynamic>> _getCards(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return [
      {
        "id": "sales",
        "icon": LucideIcons.shoppingCart,
        "title": l10n.sales,
        "subtitle": l10n.salesSubtitle,
        "color": AppColors.primaryColor,
      },
      {
        "id": "invoices",
        "icon": LucideIcons.fileText,
        "title": l10n.invoices,
        "subtitle": l10n.invoicesSubtitle,
        "color": AppColors.accentGold,
      },
      {
        "id": "products",
        "icon": LucideIcons.package,
        "title": l10n.products,
        "subtitle": l10n.productsSubtitle,
        "color": AppColors.successColor,
      },
      {
        "id": "stock_alerts",
        "icon": LucideIcons.triangleAlert,
        "title": l10n.stockAlerts,
        "subtitle": l10n.stockAlertsSubtitle,
        "color": AppColors.warningColor,
      },
      {
        "id": "stock_summary",
        "icon": LucideIcons.layers,
        "title": l10n.stockSummary,
        "subtitle": l10n.stockSummarySubtitle,
        "color": Colors.teal,
      },
      if (widget.isManager) ...[
        {
          "id": "reports",
          "icon": LucideIcons.chartPie,
          "title": l10n.reports,
          "subtitle": l10n.reportsSubtitle,
          "color": AppColors.primaryColor,
        },
        {
          "id": "sessions",
          "icon": LucideIcons.history,
          "title": l10n.sessions,
          "subtitle": _sessionCount != null
              ? l10n.closedSessionsCount(_sessionCount!)
              : l10n.sessionsSubtitle,
          "color": Colors.orange,
        },
      ] else ...[
        {
          "id": "settings",
          "icon": LucideIcons.settings,
          "title": l10n.settings,
          "subtitle": l10n.settingsSubtitle,
          "color": Colors.blueGrey,
        },
      ],
      if (!widget.isManager)
        {
          "id": "notifications",
          "icon": LucideIcons.bell,
          "title": l10n.notifications,
          "subtitle": l10n.notificationsSubtitle,
          "color": AppColors.darkGold,
        },
    ];
  }

  // ignore: unused_element
  List<Map<String, dynamic>> get cards => _getCards(context);

  @override
  void initState() {
    super.initState();
    // Load data for dashboard stats
    getIt<InvoiceCubit>().loadSales();
    getIt<ProductCubit>().getAllCategories();
    getIt<StockCubit>().loadData();
    getIt<NotificationsCubit>().loadData();

    if (widget.isManager) {
      _loadSessionCount();
    }

  }

  Future<void> _loadSessionCount() async {
    try {
      final repo = getIt<SessionRepositoryImpl>();
      final count = await repo.getSessionsCount();

      if (mounted) {
        setState(() {
          _sessionCount = count;
        });
      }
    } catch (e) {
      print('Failed to load session count: $e');
    }
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withOpacity(0.18),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Stack(
        children: [
          PositionedDirectional(
            top: 0,
            end: 0,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: color.withOpacity(0.055),
                borderRadius: const BorderRadiusDirectional.only(
                  bottomStart: Radius.circular(72),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 23),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.mutedColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          height: 1.1,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticalCards() {
    final l10n = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth < 560
            ? 1
            : constraints.maxWidth < 760
                ? 2
                : 4;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: constraints.maxWidth < 560 ? 3.1 : 2.05,
          children: [
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
                );
              },
            ),
            // Total products
            BlocBuilder<StockCubit, StockStates>(
              bloc: getIt<StockCubit>(),
              builder: (context, state) {
                final count = getIt<StockCubit>().products.length;
                return _buildStatCard(
                  title: l10n.totalProducts,
                  value: l10n.productCount(count),
                  icon: LucideIcons.package,
                  color: AppColors.successColor,
                );
              },
            ),
            // Invoices issued today
            BlocBuilder<InvoiceCubit, InvoiceState>(
              bloc: getIt<InvoiceCubit>(),
              builder: (context, state) {
                final now = DateTime.now();
                final count = state.sales.where((sale) =>
                    !sale.isRefund && sale.date.year == now.year &&
                    sale.date.month == now.month && sale.date.day == now.day).length;
                return _buildStatCard(
                  title: l10n.localeName == 'ar' ? 'فواتير اليوم' : 'Today invoices',
                  value: '$count',
                  icon: LucideIcons.receiptText,
                  color: AppColors.accentColor,
                );
              },
            ),
            // Today's operating expenses
            FutureBuilder<double>(
              future: ExpenseRepository().total(
                DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
                DateTime.now(),
              ),
              builder: (context, snapshot) {
                final total = snapshot.data ?? 0;
                return _buildStatCard(
                  title: l10n.localeName == 'ar' ? 'مصروفات اليوم' : 'Today expenses',
                  value: '${total.toStringAsFixed(2)} ${l10n.currencyEg}',
                  icon: LucideIcons.walletCards,
                  color: AppColors.errorColor,
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSalesTrendChart() {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<InvoiceCubit, InvoiceState>(
      bloc: getIt<InvoiceCubit>(),
      builder: (context, state) {
        final days = List.generate(7, (index) {
          return DateTime.now().subtract(Duration(days: 6 - index));
        });

        final spots = <FlSpot>[];
        double maxVal = 100.0;

        for (int i = 0; i < 7; i++) {
          final day = days[i];
          final daySales = state.sales.where((s) =>
              s.date.year == day.year &&
              s.date.month == day.month &&
              s.date.day == day.day);

          double total = 0.0;
          for (final s in daySales) {
            if (s.isRefund) {
              total -= s.total;
            } else {
              total += s.total;
            }
          }
          spots.add(FlSpot(i.toDouble(), total));
          if (total > maxVal) {
            maxVal = total;
          }
        }

        maxVal = (maxVal * 1.15).roundToDouble();
        if (maxVal == 0.0) {
          maxVal = 100.0;
        }

        // Professional locale-aware day labels using DateFormat
        final dayLabels = days.map((d) {
          return DateFormat('EEEE', l10n.localeName).format(d);
        }).toList();

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primaryForeground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.015),
                blurRadius: 10,
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
                  Text(
                    l10n.salesTrendTitle,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      l10n.dailyNetSales,
                      style: const TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 220,
                child: LineChart(
                  LineChartData(
                    lineTouchData: LineTouchData(
                      handleBuiltInTouches: true,
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (touchedSpot) =>
                            AppColors.primaryColor.withOpacity(0.9),
                        tooltipBorderRadius: BorderRadius.circular(8),
                        tooltipPadding: const EdgeInsets.all(8),
                        tooltipMargin: 8,
                        getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                          return touchedBarSpots.map((barSpot) {
                            return LineTooltipItem(
                              '${barSpot.y.toStringAsFixed(2)} ${l10n.currencyEg}',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: AppColors.mutedColor.withOpacity(0.08),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt();
                            if (idx >= 0 && idx < 7) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  dayLabels[idx],
                                  style: TextStyle(
                                    color: AppColors.mutedColor.withOpacity(0.9),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 52,
                          getTitlesWidget: (value, meta) {
                            if (value == meta.min) return const SizedBox();
                            return Padding(
                              padding: const EdgeInsets.only(right: 6.0),
                              child: Text(
                                '${value.toInt()} ${l10n.currencyEg}',
                                style: TextStyle(
                                  color: AppColors.mutedColor.withOpacity(0.8),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    minX: 0,
                    maxX: 6,
                    minY: 0,
                    maxY: maxVal,
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        curveSmoothness: 0.35,
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.secondaryColor,
                            AppColors.primaryColor,
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        barWidth: 4,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 4,
                              color: AppColors.accentColor,
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryColor.withOpacity(0.1),
                              AppColors.primaryColor.withOpacity(0.0),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // The global dashboard header owns the page title. Keep the
              // key business metrics immediately below it.
              _buildStatisticalCards(),
              const SizedBox(height: 18),

              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main Dashboard content column - Takes 60% width
                    Expanded(
                      flex: 6,
                      child: SingleChildScrollView(
                        child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Stale session warning banner
                            Builder(
                              builder: (context) {
                                final manager = getIt<SessionManager>();
                                final sessionAge = manager.sessionAge;

                                if (sessionAge == null) return const SizedBox.shrink();

                                if (manager.isSessionStale) {
                                  final hours = sessionAge.inHours;
                                  final days = hours ~/ 24;
                                  final remainingHours = hours % 24;
                                  String ageText = '';
                                  if (days > 0) {
                                    ageText += '$days ${l10n.daysText} ';
                                  }
                                  if (remainingHours > 0 || days == 0) {
                                    ageText += '$remainingHours ${l10n.hoursText}';
                                  }

                                  return Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.orange.shade300),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(LucideIcons.triangleAlert,
                                            color: Colors.orange.shade700, size: 20),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            l10n.sessionStaleWarning(ageText),
                                            style: TextStyle(
                                              color: Colors.orange.shade900,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                // Info banner for existing previously opened session
                                else if (sessionAge.inMinutes > 5) {
                                  final hours = sessionAge.inHours;
                                  final minutes = sessionAge.inMinutes % 60;

                                  String ageText = '';
                                  if (hours > 0) {
                                    ageText += '$hours ${l10n.hoursText} ';
                                  }
                                  if (minutes > 0 || hours == 0) {
                                    ageText += '$minutes ${l10n.minutesText}';
                                  }

                                  return Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.blue.shade200),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(LucideIcons.info,
                                            color: Colors.blue.shade700, size: 20),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            l10n.sessionOpenInfo(ageText),
                                            style: TextStyle(
                                              color: Colors.blue.shade900,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                return const SizedBox.shrink();
                              },
                            ),

                            // 7-day Sales Trend chart
                            _buildSalesTrendChart(),

                            _buildFinancialComparison(),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Recent Operations list - Takes 30% width
                    const Expanded(
                      flex: 3,
                      child: RecentOperations(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFinancialComparison() {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    final l10n = AppLocalizations.of(context);
    final isArabic = l10n.localeName == 'ar';
    final expenseLabel = isArabic ? 'المصروفات' : 'Expenses';
    return FutureBuilder<double>(
      future: ExpenseRepository().total(start, today),
      builder: (context, expenseSnapshot) => BlocBuilder<InvoiceCubit, InvoiceState>(
        bloc: getIt<InvoiceCubit>(),
        builder: (context, state) {
          final sales = state.sales
              .where((sale) => !sale.isRefund && sale.date.isAfter(start.subtract(const Duration(seconds: 1))))
              .fold<double>(0, (sum, sale) => sum + sale.total);
          final expenses = expenseSnapshot.data ?? 0;
          final maxValue = [sales, expenses, 1.0]
                  .reduce((a, b) => a > b ? a : b) *
              1.2;
          return Container(
            margin: const EdgeInsets.only(top: 8, bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.borderColor),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(.035), blurRadius: 16, offset: const Offset(0, 6))],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 38, height: 38, decoration: BoxDecoration(color: AppColors.secondaryColor.withOpacity(.09), borderRadius: BorderRadius.circular(12)), child: const Icon(LucideIcons.trendingUp, size: 19, color: AppColors.secondaryColor)),
                const SizedBox(width: 10),
                Expanded(child: Text(
                  l10n.localeName == 'ar' ? 'مقارنة المبيعات والمصروفات اليوم' : 'Today sales and expenses',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                )),
              ]),
              const SizedBox(height: 16),
              Directionality(
                textDirection: ui.TextDirection.ltr,
                child: Row(
                  children: [
                    Expanded(
                      child: Directionality(
                        textDirection: isArabic
                            ? ui.TextDirection.rtl
                            : ui.TextDirection.ltr,
                        child: isArabic
                            ? _financeValue(expenseLabel, expenses,
                                l10n.currencyEg, AppColors.errorColor)
                            : _financeValue(l10n.sales, sales,
                                l10n.currencyEg, AppColors.secondaryColor),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Directionality(
                        textDirection: isArabic
                            ? ui.TextDirection.rtl
                            : ui.TextDirection.ltr,
                        child: isArabic
                            ? _financeValue(l10n.sales, sales,
                                l10n.currencyEg, AppColors.secondaryColor)
                            : _financeValue(expenseLabel, expenses,
                                l10n.currencyEg, AppColors.errorColor),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (sales == 0 && expenses == 0)
                SizedBox(height: 130, child: Center(child: Text(l10n.localeName == 'ar' ? 'لا توجد حركات مالية اليوم' : 'No financial activity today', style: const TextStyle(color: AppColors.mutedColor))))
              else
                Directionality(textDirection: ui.TextDirection.ltr, child: SizedBox(
                  height: 145,
                  child: BarChart(BarChartData(
                    maxY: maxValue,
                    alignment: BarChartAlignment.spaceAround,
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (_) => FlLine(color: AppColors.borderColor.withOpacity(.65), strokeWidth: 1)),
                    titlesData: const FlTitlesData(leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false))),
                    barGroups: [
                      if (isArabic) ...[
                        _financeBar(0, expenses, maxValue, AppColors.errorColor),
                        _financeBar(1, sales, maxValue, AppColors.secondaryColor),
                      ] else ...[
                        _financeBar(0, sales, maxValue, AppColors.secondaryColor),
                        _financeBar(1, expenses, maxValue, AppColors.errorColor),
                      ],
                    ],
                  )),
                )),
            ]),
          );
        },
      ),
    );
  }

  Widget _financeValue(String label, double value, String currency, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(color: color.withOpacity(.055), borderRadius: BorderRadius.circular(13)),
        child: Row(children: [
          Container(width: 9, height: 9, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.mutedColor))),
          Text('${value.toStringAsFixed(2)} $currency', style: TextStyle(fontWeight: FontWeight.w800, color: color)),
        ]),
      );

  BarChartGroupData _financeBar(int x, double value, double maxValue, Color color) => BarChartGroupData(
        x: x,
        barRods: [BarChartRodData(
          toY: value,
          width: 38,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(9)),
          gradient: LinearGradient(colors: [color.withOpacity(.72), color], begin: Alignment.bottomCenter, end: Alignment.topCenter),
          backDrawRodData: BackgroundBarChartRodData(show: true, toY: maxValue, color: color.withOpacity(.055)),
        )],
      );
}
