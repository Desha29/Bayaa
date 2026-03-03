// lib/features/sessions/presentation/widgets/arp_monthly_sales_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';

class ArpMonthlySalesChart extends StatefulWidget {
  final Map<String, double> monthlySales;

  const ArpMonthlySalesChart({super.key, required this.monthlySales});

  @override
  State<ArpMonthlySalesChart> createState() => _ArpMonthlySalesChartState();
}

class _ArpMonthlySalesChartState extends State<ArpMonthlySalesChart> {
  int _touchedIndex = -1;

  static const _arabicMonths = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];

  String _monthLabel(String key) {
    final parts = key.split('-');
    if (parts.length == 2) {
      final m = int.tryParse(parts[1]);
      if (m != null && m >= 1 && m <= 12) {
        return _arabicMonths[m - 1];
      }
    }
    return key;
  }

  String _shortMonthLabel(String key) {
    final parts = key.split('-');
    if (parts.length == 2) {
      final m = int.tryParse(parts[1]);
      if (m != null && m >= 1 && m <= 12) {
        // Arabic short month names
        const shortMonths = [
          'ينا', 'فبر', 'مار', 'أبر', 'ماي', 'يون',
          'يول', 'أغس', 'سبت', 'أكت', 'نوف', 'ديس',
        ];
        return shortMonths[m - 1];
      }
    }
    return key;
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;

    final entries = widget.monthlySales.entries.toList();
    final maxY = entries.isEmpty
        ? 100.0
        : entries.map((e) => e.value).reduce((a, b) => a > b ? a : b) * 1.25;
    final totalSales = entries.fold<double>(0, (sum, e) => sum + e.value);
    final avgMonthly = entries.isNotEmpty ? totalSales / entries.length : 0.0;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 32 : isTablet ? 24 : 16,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.secondaryColor.withOpacity(0.15),
                          AppColors.primaryColor.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.bar_chart_rounded,
                      color: AppColors.secondaryColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'المبيعات الشهرية',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.kDarkChip,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Summary stats row
              if (entries.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryColor.withOpacity(0.05),
                        AppColors.secondaryColor.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          icon: Icons.monetization_on_rounded,
                          label: 'الإجمالي',
                          value: '${_formatAmount(totalSales)} ج.م',
                          color: AppColors.primaryColor,
                        ),
                      ),
                      Container(
                        height: 30,
                        width: 1,
                        color: AppColors.mutedColor.withOpacity(0.2),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          icon: Icons.trending_up_rounded,
                          label: 'المتوسط/شهر',
                          value: '${_formatAmount(avgMonthly)} ج.م',
                          color: AppColors.secondaryColor,
                        ),
                      ),
                      Container(
                        height: 30,
                        width: 1,
                        color: AppColors.mutedColor.withOpacity(0.2),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          icon: Icons.date_range_rounded,
                          label: 'الأشهر',
                          value: '${entries.length}',
                          color: const Color(0xFF6366F1),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              // Chart
              SizedBox(
                height: isDesktop ? 320 : isTablet ? 270 : 220,
                child: entries.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.bar_chart_rounded,
                              size: 48,
                              color: AppColors.mutedColor.withOpacity(0.3),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'لا توجد بيانات للعرض',
                              style: TextStyle(color: AppColors.mutedColor),
                            ),
                          ],
                        ),
                      )
                    : BarChart(
                        BarChartData(
                          maxY: maxY,
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchCallback: (event, response) {
                              setState(() {
                                if (response != null &&
                                    response.spot != null &&
                                    event.isInterestedForInteractions) {
                                  _touchedIndex = response.spot!.touchedBarGroupIndex;
                                } else {
                                  _touchedIndex = -1;
                                }
                              });
                            },
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipColor: (_) => AppColors.kDarkChip.withOpacity(0.95),
                              tooltipBorderRadius: BorderRadius.circular(10),
                              tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              tooltipMargin: 8,
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                final label = _monthLabel(entries[group.x.toInt()].key);
                                final value = rod.toY;
                                return BarTooltipItem(
                                  '$label\n${_formatAmount(value)} ج.م',
                                  const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    height: 1.5,
                                  ),
                                );
                              },
                            ),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: maxY / 4,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: AppColors.mutedColor.withOpacity(0.08),
                                strokeWidth: 1,
                                dashArray: [6, 4],
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
                                reservedSize: 36,
                                getTitlesWidget: (value, meta) {
                                  final index = value.toInt();
                                  if (index >= 0 && index < entries.length) {
                                    final isTouched = index == _touchedIndex;
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Text(
                                        entries.length > 6
                                            ? _shortMonthLabel(entries[index].key)
                                            : _monthLabel(entries[index].key),
                                        style: TextStyle(
                                          color: isTouched
                                              ? AppColors.primaryColor
                                              : AppColors.mutedColor.withOpacity(0.8),
                                          fontSize: isTouched ? 11 : 10,
                                          fontWeight: isTouched ? FontWeight.bold : FontWeight.w600,
                                        ),
                                      ),
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 50,
                                getTitlesWidget: (value, meta) {
                                  if (value == meta.min || value == meta.max) return const SizedBox();
                                  return Text(
                                    _formatAmount(value),
                                    style: TextStyle(
                                      color: AppColors.mutedColor.withOpacity(0.7),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: List.generate(entries.length, (index) {
                            final isTouched = index == _touchedIndex;
                            return BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: entries[index].value,
                                  width: entries.length <= 6
                                      ? (isDesktop ? 40 : 24)
                                      : (isDesktop ? 24 : 14),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(8),
                                  ),
                                  gradient: LinearGradient(
                                    colors: isTouched
                                        ? [
                                            AppColors.accentColor,
                                            AppColors.secondaryColor,
                                          ]
                                        : [
                                            AppColors.secondaryColor,
                                            AppColors.primaryColor,
                                          ],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                  backDrawRodData: BackgroundBarChartRodData(
                                    show: true,
                                    toY: maxY,
                                    color: AppColors.mutedColor.withOpacity(0.04),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.mutedColor,
          ),
        ),
      ],
    );
  }
}
