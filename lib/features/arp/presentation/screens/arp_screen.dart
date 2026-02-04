import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../../core/constants/app_colors.dart';

import '../cubit/arp_cubit.dart';
import '../cubit/arp_state.dart';


import 'session_history_screen.dart';
import '../../data/models/session_model.dart';
import '../../data/repositories/session_repository_impl.dart';
import '../../../../core/di/dependency_injection.dart';
import '../widgets/arp_summary_cards.dart';
import '../widgets/arp_chart_section.dart';

import '../widgets/arp_top_products.dart';
import '../widgets/arp_extra_charts.dart';



class ArpScreen extends StatefulWidget {
  const ArpScreen({super.key});

  @override
  State createState() => _ArpScreenState();
}

class _ArpScreenState extends State<ArpScreen> {
  DateTime? startDate;
  DateTime? endDate;
  String? selectedSessionId;
  List<Session> availableSessions = [];

  @override
  void initState() {
    super.initState();
    startDate = DateTime.now().subtract(const Duration(days: 30));
    endDate = DateTime.now();
    _loadSessions();
    context.read<ArpCubit>().loadAnalytics(start: startDate!, end: endDate!);
  }

  Future<void> _loadSessions() async {
    final sessionRepo = getIt<SessionRepositoryImpl>();
    final sessions = await sessionRepo.getSessionsInRange(
      startDate ?? DateTime.now().subtract(const Duration(days: 30)),
      endDate ?? DateTime.now(),
    );
    setState(() {
      availableSessions = sessions;
    });
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
                        padding: EdgeInsets.all(isDesktop
                            ? 32
                            : isTablet
                                ? 24
                                : 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.primaryColor.withOpacity(0.1),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                    icon: const Icon(Icons.date_range,
                                        color: Colors.white),
                                    onPressed: () => _selectDateRange(context),
                                    tooltip: 'اختيار الفترة',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (availableSessions.isNotEmpty) ...[
                                  _buildSessionFilter(),
                                  const SizedBox(width: 8),
                                ],
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.history),
                                  label: const Text('السجل'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange.shade700,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const SessionHistoryScreen(),
                                      ),
                                    );
                                  },
                                ),
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
                              CircularProgressIndicator(
                                  color: AppColors.primaryColor),
                              SizedBox(height: 16),
                              Text(
                                'جاري تحميل البيانات...',
                                style: TextStyle(
                                    fontSize: 16, color: AppColors.mutedColor),
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
                              Icon(Icons.error_outline,
                                  size: 64,
                                  color: AppColors.errorColor.withOpacity(0.4)),
                              const SizedBox(height: 16),
                              Text(
                                state.message,
                                style: const TextStyle(
                                    fontSize: 16, color: AppColors.mutedColor),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () =>
                                    context.read<ArpCubit>().refreshData(),
                                icon: const Icon(Icons.refresh),
                                label: const Text('إعادة المحاولة'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
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
                          // User requested to keep previous chart (Summary Comparison)
                          ArpChartSection(dailySales: state.dailySales),
                          SizedBox(height: isDesktop ? 32 : 24),
                          if (state.hourlySales.isNotEmpty) ...[
                            ArpHourlyChart(hourlySales: state.hourlySales),
                            SizedBox(height: isDesktop ? 32 : 24),
                          ],
                          if (state.categorySales.isNotEmpty) ...[
                            ArpCategoryPieChart(
                                categorySales: state.categorySales),
                            SizedBox(height: isDesktop ? 32 : 24),
                          ],
                          if ((state.summary.grossRevenue ?? 0) > 0) ...[
                            ArpSalesVsRefundChart(
                              grossSales: state.summary.grossRevenue ?? 0,
                              refunds: state.summary.refundedAmount ?? 0,
                            ),
                            SizedBox(height: isDesktop ? 32 : 24),
                          ],
                          ArpTopProducts(products: state.topProducts),
                          SizedBox(height: isDesktop ? 32 : 24),
                        ]),
                      ),
                    if (state is ArpInitial)
                      const SliverFillRemaining(
                        child: Center(
                          child: Text(
                            'لا توجد بيانات للعرض',
                            style: TextStyle(
                                fontSize: 16, color: AppColors.mutedColor),
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
        selectedSessionId = null; // Clear session filter when date changes
      });
      await _loadSessions(); // Reload sessions for new date range
      context
          .read<ArpCubit>()
          .loadAnalytics(start: picked.start, end: picked.end);
    }
  }

  Widget _buildSessionFilter() {
    return PopupMenuButton<String>(
      tooltip: 'تصفية حسب الجلسة',
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: selectedSessionId != null
              ? AppColors.secondaryColor
              : AppColors.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.filter_list,
          color:
              selectedSessionId != null ? Colors.white : AppColors.primaryColor,
        ),
      ),
      onSelected: (value) {
        setState(() {
          selectedSessionId = value.isEmpty ? null : value;
        });
        context.read<ArpCubit>().loadAnalytics(
              start: startDate,
              end: endDate,
              sessionId: selectedSessionId,
            );
      },
      itemBuilder: (context) {
        return [
          PopupMenuItem<String>(
            value: '',
            child: Row(
              children: [
                Icon(
                  Icons.clear,
                  color: selectedSessionId == null
                      ? AppColors.primaryColor
                      : AppColors.mutedColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'كل الجلسات',
                  style: TextStyle(
                    fontWeight: selectedSessionId == null
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          const PopupMenuDivider(),
          ...availableSessions.map((session) {
            final isSelected = selectedSessionId == session.id;
            return PopupMenuItem<String>(
              value: session.id,
              child: Row(
                children: [
                  Icon(
                    Icons.event_note,
                    color: isSelected
                        ? AppColors.primaryColor
                        : AppColors.mutedColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'جلسة #${session.id}',
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        if (session.closeTime != null)
                          Text(
                            '${DateFormat('yyyy-MM-dd HH:mm').format(session.closeTime!)}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.mutedColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ];
      },
    );
  }
}
