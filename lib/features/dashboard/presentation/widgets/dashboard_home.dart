import 'package:bayaa_pos/core/components/screen_header.dart';
import 'package:bayaa_pos/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart'
    show SettingsCubit;
import '../../../invoice/presentation/cubit/invoice_cubit.dart';
import '../../../invoice/presentation/cubit/invoice_state.dart';
import '../../../stock/presentation/cubit/stock_cubit.dart';
import '../../../stock/presentation/cubit/stock_states.dart';
import '../../../notifications/presentation/cubit/notifications_cubit.dart';
import '../../../notifications/presentation/cubit/notifications_states.dart';
import '../../../products/presentation/cubit/product_cubit.dart';
import '../../../sessions/data/repositories/session_repository_impl.dart';
import 'dashboard_card.dart';
import 'recent_operations.dart';
import '../../../../core/session/session_manager.dart';

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

class _DashboardHomeState extends State<DashboardHome>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  final store = getIt<SettingsCubit>().currentStoreInfo;
  late List<Map<String, dynamic>> cards;

  @override
  void initState() {
    super.initState();
    // Load data for dashboard stats
    getIt<InvoiceCubit>().loadSales();
    getIt<ProductCubit>().getAllCategories();
    getIt<StockCubit>().loadData();
    getIt<NotificationsCubit>().loadData();

    _initCards();

    if (widget.isManager) {
      _loadSessionCount();
    }

    _controllers = List.generate(
      cards.length,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      ),
    );

    _animations = _controllers
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeOutBack))
        .toList();

    Future.forEach(List.generate(cards.length, (i) => i), (i) async {
      await Future.delayed(Duration(milliseconds: i * 100));
      if (mounted && i < _controllers.length) {
        _controllers[i].forward();
      }
    });
  }

  void _initCards() {
    cards = [
      {
        "id": "sales",
        "icon": LucideIcons.shoppingCart,
        "title": "المبيعات",
        "subtitle": "إدارة عمليات البيع",
        "color": AppColors.primaryColor,
      },
      {
        "id": "invoices",
        "icon": LucideIcons.fileText,
        "title": "الفواتير",
        "subtitle": "إدارة الفواتير",
        "color": AppColors.accentGold,
      },
      {
        "id": "products",
        "icon": LucideIcons.package,
        "title": "المنتجات",
        "subtitle": "إدارة المخزون",
        "color": AppColors.successColor,
      },
      {
        "id": "stock_alerts",
        "icon": LucideIcons.triangleAlert,
        "title": "المنتجات الناقصة",
        "subtitle": "تنبيهات المخزون",
        "color": AppColors.warningColor,
      },
      {
        "id": "stock_summary",
        "icon": LucideIcons.layers,
        "title": "ملخص المخزون",
        "subtitle": "تصنيفات المخزون",
        "color": Colors.teal,
      },
      if (widget.isManager) ...[
        {
          "id": "reports",
          "icon": LucideIcons.chartPie,
          "title": "الإحصائيات",
          "subtitle": "تحليلات النظام",
          "color": AppColors.primaryColor,
        },
        {
          "id": "sessions",
          "icon": LucideIcons.history,
          "title": "الايام",
          "subtitle": "سجل الأيام المغلقة",
          "color": Colors.orange,
        },
      ] else ...[
        {
          "id": "settings",
          "icon": LucideIcons.settings,
          "title": "الإعدادات",
          "subtitle": "إدارة إعدادات النظام",
          "color": Colors.blueGrey,
        },
      ],
      if (!widget.isManager)
        {
          "id": "notifications",
          "icon": LucideIcons.bell,
          "title": "التنبيهات",
          "subtitle": "الإشعارات والتنبيهات",
          "color": AppColors.darkGold,
        },
    ];
  }

  Future<void> _loadSessionCount() async {
    try {
      final repo = getIt<SessionRepositoryImpl>();
      final count = await repo.getSessionsCount();

      if (mounted) {
        setState(() {
          final index = cards.indexWhere((c) => c['id'] == 'sessions');
          if (index != -1) {
            cards[index]['subtitle'] = '$count يوم مغلق';
          }
        });
      }
    } catch (e) {
      print('Failed to load session count: $e');
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryForeground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.12),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.mutedColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticalCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth < 600
            ? 1
            : constraints.maxWidth < 1100
                ? 2
                : 4;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.8,
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
                  title: "مبيعات اليوم (صافي)",
                  value: "${totalSales.toStringAsFixed(2)} ج.م",
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
                  title: "إجمالي المنتجات",
                  value: "$count منتج",
                  icon: LucideIcons.package,
                  color: AppColors.successColor,
                );
              },
            ),
            // Stock alerts
            BlocBuilder<StockCubit, StockStates>(
              bloc: getIt<StockCubit>(),
              builder: (context, state) {
                final count = getIt<StockCubit>().totalCount;
                return _buildStatCard(
                  title: "تنبيهات النواقص",
                  value: "$count منتج ناقص",
                  icon: LucideIcons.triangleAlert,
                  color: AppColors.warningColor,
                );
              },
            ),
            // Unread notifications
            BlocBuilder<NotificationsCubit, NotificationsStates>(
              bloc: getIt<NotificationsCubit>(),
              builder: (context, state) {
                final count = getIt<NotificationsCubit>().total;
                return _buildStatCard(
                  title: "تنبيهات غير مقروءة",
                  value: "$count تنبيه",
                  icon: LucideIcons.bell,
                  color: AppColors.accentGold,
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSalesTrendChart() {
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

        final dayLabels = days.map((d) {
          switch (d.weekday) {
            case DateTime.monday:
              return 'الإثنين';
            case DateTime.tuesday:
              return 'الثلاثاء';
            case DateTime.wednesday:
              return 'الأربعاء';
            case DateTime.thursday:
              return 'الخميس';
            case DateTime.friday:
              return 'الجمعة';
            case DateTime.saturday:
              return 'السبت';
            case DateTime.sunday:
              return 'الأحد';
            default:
              return '';
          }
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
                  const Text(
                    "مؤشر المبيعات (آخر 7 أيام)",
                    style: TextStyle(
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
                    child: const Text(
                      "صافي المبيعات اليومية",
                      style: TextStyle(
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
                              '${barSpot.y.toStringAsFixed(2)} ج.م',
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
                                '${value.toInt()} ج.م',
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
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 2;
        double aspectRatio = 1.4;

        if (constraints.maxWidth < 800) {
          crossAxisCount = 1;
          aspectRatio = 1.8;
        } else if (constraints.maxWidth < 1200) {
          crossAxisCount = 2;
          aspectRatio = 1.3;
        } else {
          crossAxisCount = 3;
          aspectRatio = 1.4;
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScreenHeader(
                title: "لوحة التحكم",
                subtitle:
                    "مرحباً بك في نظام ${store?.name ?? "Bayaa"} لإدارة نقاط البيع",
                icon: LucideIcons.layoutDashboard,
                titleColor: AppColors.textPrimary,
                iconColor: AppColors.primaryColor,
              ),
              const SizedBox(height: 12),

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
                                  final ageText = days > 0
                                      ? '$days يوم و $remainingHours ساعة'
                                      : '$hours ساعة';

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
                                            'اليوم الحالي مفتوح منذ $ageText — يُنصح بإغلاقه وفتح يوم جديد',
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
                                    ageText += '$hours ساعة ';
                                  }
                                  if (minutes > 0 || hours == 0) {
                                    ageText += '$minutes دقيقة';
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
                                            'أنت الآن تعمل على يومية مفتوحة مسبقاً منذ $ageText',
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

                            // Real-time statistical cards grid
                            _buildStatisticalCards(),

                            // 7-day Sales Trend chart
                            _buildSalesTrendChart(),

                            // Quick Actions title
                            const Padding(
                              padding: EdgeInsets.only(top: 8, bottom: 12),
                              child: Text(
                                "إجراءات سريعة",
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            // Original quick navigation cards grid
                            GridView.count(
                              crossAxisCount: crossAxisCount,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: aspectRatio,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              children: List.generate(cards.length, (index) {
                                final card = cards[index];
                                return _buildAnimatedCard(
                                  index: index,
                                  child: DashboardCard(
                                    icon: card["icon"],
                                    title: card["title"],
                                    subtitle: card["subtitle"],
                                    color: card["color"],
                                    onTap: () => widget.onCardTap(card["id"]),
                                  ),
                                );
                              }),
                            ),
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

  Widget _buildAnimatedCard({required int index, required Widget child}) {
    return ScaleTransition(
      scale: _animations[index],
      child: FadeTransition(opacity: _animations[index], child: child),
    );
  }
}
