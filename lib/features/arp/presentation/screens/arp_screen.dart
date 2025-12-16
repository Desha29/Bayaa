import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';

import '../cubit/arp_cubit.dart';
import '../cubit/arp_state.dart';

import 'dialy_report_screen.dart';
import '../widgets/arp_summary_cards.dart';
import '../widgets/arp_chart_section.dart';
import '../widgets/arp_top_products.dart';

import 'package:crazy_phone_pos/core/constants/app_colors.dart';

class ArpScreen extends StatefulWidget {
  const ArpScreen({super.key});

  @override
  State createState() => _ArpScreenState();
}

class _ArpScreenState extends State<ArpScreen> {
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    startDate = DateTime.now().subtract(const Duration(days: 30));
    endDate = DateTime.now();
    context.read<ArpCubit>().loadAnalytics(start: startDate!, end: endDate!);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SafeArea(
          child: BlocBuilder<ArpCubit, ArpState>(
            builder: (context, state) {
              return RefreshIndicator(
                onRefresh: () => context.read<ArpCubit>().refreshData(),
                color: AppColors.primaryColor,
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(isDesktop ? 32 : isTablet ? 24 : 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.analytics_outlined,
                                    color: AppColors.primaryColor,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'التحليلات والتقارير',
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.kDarkChip,
                                        ),
                                      ),
                                      Text(
                                        _getDateRangeText(),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.mutedColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.date_range, color: Colors.white),
                                    onPressed: () => _selectDateRange(context),
                                    tooltip: 'اختيار الفترة',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.picture_as_pdf),
                                  label: const Text('تقرير يومي'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => const DailyReportScreen(),
                                      ),
                                    );
                                  },
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (state is ArpLoading)
                      const SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(color: AppColors.primaryColor),
                              SizedBox(height: 16),
                              Text(
                                'جاري تحميل البيانات...',
                                style: TextStyle(fontSize: 16, color: AppColors.mutedColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (state is ArpError)
                      SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline, size: 64, color: AppColors.errorColor.withOpacity(0.4)),
                              const SizedBox(height: 16),
                              Text(
                                state.message,
                                style: const TextStyle(fontSize: 16, color: AppColors.mutedColor),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () => context.read<ArpCubit>().refreshData(),
                                icon: const Icon(Icons.refresh),
                                label: const Text('إعادة المحاولة'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (state is ArpLoaded)
                      SliverList(
                        delegate: SliverChildListDelegate([
                          ArpSummaryCards(summary: state.summary),
                          SizedBox(height: isDesktop ? 32 : 24),
                          ArpChartSection(dailySales: state.dailySales),
                          SizedBox(height: isDesktop ? 32 : 24),
                          ArpTopProducts(products: state.topProducts),
                          SizedBox(height: isDesktop ? 32 : 24),
                        ]),
                      ),
                    if (state is ArpInitial)
                      const SliverFillRemaining(
                        child: Center(
                          child: Text(
                            'لا توجد بيانات للعرض',
                            style: TextStyle(fontSize: 16, color: AppColors.mutedColor),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _getDateRangeText() {
    if (startDate == null || endDate == null) {
      return 'آخر 30 يوم';
    }
    final start = '${startDate!.day}/${startDate!.month}/${startDate!.year}';
    final end = '${endDate!.day}/${endDate!.month}/${endDate!.year}';
    return 'من $start إلى $end';
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: startDate ?? DateTime.now().subtract(const Duration(days: 30)),
        end: endDate ?? DateTime.now(),
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
      context.read<ArpCubit>().loadAnalytics(start: picked.start, end: picked.end);

    }
  }
}
