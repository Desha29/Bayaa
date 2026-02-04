import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class ArpHourlyChart extends StatelessWidget {
  final Map<int, double> hourlySales;

  const ArpHourlyChart({super.key, required this.hourlySales});

  @override
  Widget build(BuildContext context) {
    // Fill missing hours
    final List<BarChartGroupData> barGroups = [];
    double maxY = 0;
    
    for (int i = 0; i < 24; i++) {
      final value = hourlySales[i] ?? 0;
      if (value > maxY) maxY = value;
      
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: value,
              gradient: const LinearGradient(
                colors: [AppColors.secondaryColor, AppColors.primaryColor],
                begin: Alignment.bottomCenter, 
                end: Alignment.topCenter
              ),
              width: 12,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)), // Rounded top only
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: maxY * 1.1, // slightly higher
                color: AppColors.mutedColor.withOpacity(0.05),
              ),
            ),
          ],
        ),
      );
    }
    
    // Ensure min height to avoid crash if all 0
    if (maxY == 0) maxY = 100;

    return _ResponsivePadding(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
             BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                 Container(
                   padding: const EdgeInsets.all(8),
                   decoration: BoxDecoration(color: AppColors.secondaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                   child: const Icon(Icons.access_time_filled, color: AppColors.secondaryColor, size: 20),
                 ),
                 const SizedBox(width: 12),
                 const Text("نشاط المبيعات بالساعة", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.kDarkChip)),
              ],
            ),
            const SizedBox(height: 24),
            // Fix: Use SizedBox height instead of AspectRatio to avoid stretch
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY * 1.2,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => AppColors.primaryColor.withOpacity(0.9),
                      tooltipPadding: const EdgeInsets.all(8),
                      tooltipMargin: 8,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${group.x}:00\n${rod.toY.toInt()} ج.م',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 4, 
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              '${value.toInt()}:00',
                              style: const TextStyle(
                                color: AppColors.mutedColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true, 
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) => FlLine(color: AppColors.mutedColor.withOpacity(0.05), strokeWidth: 1),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: barGroups,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ArpCategoryPieChart extends StatefulWidget {
  final Map<String, double> categorySales;

  const ArpCategoryPieChart({super.key, required this.categorySales});

  @override
  State<ArpCategoryPieChart> createState() => _ArpCategoryPieChartState();
}

class _ArpCategoryPieChartState extends State<ArpCategoryPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.categorySales.isEmpty) return const SizedBox();

    final List<PieChartSectionData> sections = [];
    final colors = [
      AppColors.primaryColor,
      AppColors.secondaryColor,
      AppColors.accentColor,
      Colors.purple,
      Colors.teal,
      Colors.pink, 
    ];
    
    double total = widget.categorySales.values.fold(0, (sum, item) => sum + item);
    int i = 0;
    
    widget.categorySales.forEach((key, value) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 16.0 : 13.0;
      final radius = isTouched ? 110.0 : 100.0; // Increased radius
      
      sections.add(PieChartSectionData(
        color: colors[i % colors.length],
        value: value,
        title: '${((value / total) * 100).toInt()}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ));
      i++;
    });

    return _ResponsivePadding(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
             BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                 Container(
                   padding: const EdgeInsets.all(8),
                   decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                   child: const Icon(Icons.category, color: Colors.purple, size: 20),
                 ),
                 const SizedBox(width: 12),
                 const Text("المبيعات حسب القسم", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.kDarkChip)),
              ],
            ),
             const SizedBox(height: 24),
             // Fix: Use SizedBox height for responsive consistency
             SizedBox(
               height: 300,
               child: Row(
                 children: [
                   Expanded(
                     child: PieChart(
                       PieChartData(
                         pieTouchData: PieTouchData(
                           touchCallback: (FlTouchEvent event, pieTouchResponse) {
                             setState(() {
                               if (!event.isInterestedForInteractions ||
                                   pieTouchResponse == null ||
                                   pieTouchResponse.touchedSection == null) {
                                 touchedIndex = -1;
                                 return;
                               }
                               touchedIndex = pieTouchResponse
                                   .touchedSection!.touchedSectionIndex;
                             });
                           },
                         ),
                         borderData: FlBorderData(show: false),
                         sectionsSpace: 2,
                         centerSpaceRadius: 40,
                         sections: sections,
                       ),
                     ),
                   ),
                   const SizedBox(width: 16),
                   Expanded(
                     child: Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: widget.categorySales.entries.map((e) {
                         final index = widget.categorySales.keys.toList().indexOf(e.key);
                         return Padding(
                           padding: const EdgeInsets.symmetric(vertical: 4),
                           child: Row(
                             children: [
                               Container(
                                 width: 12, height: 12,
                                 decoration: BoxDecoration(shape: BoxShape.circle, color: colors[index % colors.length]),
                               ),
                               const SizedBox(width: 8),
                               Expanded(
                                 child: Text(e.key, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                               ),
                             ],
                           ),
                         );
                       }).toList(),
                     ),
                   ),
                 ],
               ),
            ),
          ],
        ),
      ),
    );
  }
}


class ArpSalesVsRefundChart extends StatefulWidget {
  final double grossSales;
  final double refunds;

  const ArpSalesVsRefundChart({super.key, required this.grossSales, required this.refunds});

  @override
  State<ArpSalesVsRefundChart> createState() => _ArpSalesVsRefundChartState();
}

class _ArpSalesVsRefundChartState extends State<ArpSalesVsRefundChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    // If no data
    if (widget.grossSales == 0 && widget.refunds == 0) return const SizedBox();

    final netSales = widget.grossSales - widget.refunds;
    
    final sections = [
       PieChartSectionData(
         color: AppColors.successColor,
         value: netSales,
         title: '${((netSales / widget.grossSales) * 100).toInt()}%',
         radius: touchedIndex == 0 ? 110 : 100, // Increased radius
         titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
         badgeWidget: _Badge(Icons.check_circle_outline, AppColors.successColor),
         badgePositionPercentageOffset: .98,
       ),
       PieChartSectionData(
         color: AppColors.errorColor,
         value: widget.refunds,
         title: '${((widget.refunds / widget.grossSales) * 100).toInt()}%',
         radius: touchedIndex == 1 ? 110 : 100, // Increased radius
         titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
         badgeWidget: _Badge(Icons.assignment_return_outlined, AppColors.errorColor),
         badgePositionPercentageOffset: .98,
       ),
    ];

    return _ResponsivePadding(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
             BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                 Container(
                   padding: const EdgeInsets.all(8),
                   decoration: BoxDecoration(color: AppColors.errorColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                   child: const Icon(Icons.compare_arrows, color: AppColors.errorColor, size: 20),
                 ),
                 const SizedBox(width: 12),
                 const Text("نسبة المرتجعات", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.kDarkChip)),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: Row(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback: (FlTouchEvent event, pieTouchResponse) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  pieTouchResponse == null ||
                                  pieTouchResponse.touchedSection == null) {
                                touchedIndex = -1;
                                return;
                              }
                              touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                            });
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: sections,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         _LegendItem(color: AppColors.successColor, text: "مبيعات صافية (${netSales.toStringAsFixed(0)})"),
                         const SizedBox(height: 8),
                         _LegendItem(color: AppColors.errorColor, text: "مرتجعات (${widget.refunds.toStringAsFixed(0)})"),
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String text;
  const _LegendItem({required this.color, required this.text});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _Badge(this.icon, this.color);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
      ),
      child: Icon(icon, color: color, size: 16),
    );
  }
}

class _ResponsivePadding extends StatelessWidget {
  final Widget child;
  const _ResponsivePadding({required this.child});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 32 : isTablet ? 24 : 16,
      ),
      child: child,
    );
  }
}
