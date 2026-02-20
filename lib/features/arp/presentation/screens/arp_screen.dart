import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../../core/constants/app_colors.dart';

import '../../../sessions/presentation/cubit/arp_cubit.dart';
import '../../../sessions/presentation/cubit/arp_state.dart';


import '../../../sessions/presentation/screens/session_history_screen.dart';
import '../../../sessions/data/models/session_model.dart';
import '../../../sessions/data/repositories/session_repository_impl.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../sessions/presentation/widgets/arp_summary_cards.dart';
import '../../../sessions/presentation/widgets/arp_chart_section.dart';

import '../../../sessions/presentation/widgets/arp_top_products.dart';
import '../../../sessions/presentation/widgets/arp_extra_charts.dart';
import '../../../sessions/presentation/widgets/arp_monthly_sales_chart.dart';
import '../../../sessions/presentation/widgets/arp_yearly_summary.dart';
import '../../../sessions/presentation/widgets/arp_monthly_products_section.dart';



class ArpScreen extends StatefulWidget {
  final bool isEmbedded;
  const ArpScreen({super.key, this.isEmbedded = false});

  @override
  State<ArpScreen> createState() => _ArpScreenState();
}

class _ArpScreenState extends State<ArpScreen> {
  DateTime? startDate;
  DateTime? endDate;
  String? selectedSessionId;
  List<Session> availableSessions = [];

  // Default range for "no filter" state
  late final DateTime _defaultStart;
  late final DateTime _defaultEnd;

  bool get _hasDateFilter =>
      startDate != null &&
      endDate != null &&
      (startDate!.difference(_defaultStart).inDays.abs() > 0 ||
       endDate!.difference(_defaultEnd).inDays.abs() > 0);

  bool get _hasAnyFilter => _hasDateFilter || selectedSessionId != null;

  @override
  void initState() {
    super.initState();
    _defaultStart = DateTime.now().subtract(const Duration(days: 30));
    _defaultEnd = DateTime.now();
    startDate = _defaultStart;
    endDate = _defaultEnd;
    _loadSessions();
    context.read<ArpCubit>().loadAnalytics(start: startDate!, end: endDate!);
  }

  void _resetFilters() {
    setState(() {
      startDate = DateTime.now().subtract(const Duration(days: 30));
      endDate = DateTime.now();
      selectedSessionId = null;
    });
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

    final body = SafeArea(
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
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation, secondaryAnimation) =>
                                          const SessionHistoryScreen(),
                                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                        return FadeTransition(
                                          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
                                          child: SlideTransition(
                                            position: Tween<Offset>(
                                              begin: const Offset(0.0, 0.05),
                                              end: Offset.zero,
                                            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
                                            child: child,
                                          ),
                                        );
                                      },
                                      transitionDuration: const Duration(milliseconds: 300),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.orange.shade700, Colors.orange.shade500],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.orange.withOpacity(0.25),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.history_rounded, color: Colors.white, size: 18),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'السجل',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Active filter chips
                        if (_hasAnyFilter)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                if (_hasDateFilter)
                                  _buildFilterChip(
                                    icon: Icons.date_range_rounded,
                                    label: _getDateRangeText(),
                                    onRemove: () {
                                      setState(() {
                                        startDate = DateTime.now().subtract(const Duration(days: 30));
                                        endDate = DateTime.now();
                                        selectedSessionId = null;
                                      });
                                      _loadSessions();
                                      context.read<ArpCubit>().loadAnalytics(start: startDate!, end: endDate!);
                                    },
                                  ),
                                if (selectedSessionId != null)
                                  _buildFilterChip(
                                    icon: Icons.event_note_rounded,
                                    label: 'يوم #${selectedSessionId!.length > 8 ? selectedSessionId!.substring(0, 8) : selectedSessionId}',
                                    onRemove: () {
                                      setState(() => selectedSessionId = null);
                                      context.read<ArpCubit>().loadAnalytics(
                                        start: startDate,
                                        end: endDate,
                                      );
                                    },
                                  ),
                                // Clear all button
                                ActionChip(
                                  avatar: const Icon(Icons.clear_all_rounded, size: 16, color: AppColors.errorColor),
                                  label: const Text('مسح الكل', style: TextStyle(fontSize: 12, color: AppColors.errorColor, fontWeight: FontWeight.w600)),
                                  backgroundColor: AppColors.errorColor.withOpacity(0.06),
                                  side: BorderSide(color: AppColors.errorColor.withOpacity(0.15)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  onPressed: _resetFilters,
                                ),
                              ],
                            ),
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
                      // Daily sales line chart
                      ArpChartSection(dailySales: state.dailySales),
                      SizedBox(height: isDesktop ? 32 : 24),
                      // Monthly sales bar chart (enhanced)
                      if (state.monthlySales.isNotEmpty) ...[
                        ArpMonthlySalesChart(monthlySales: state.monthlySales),
                        SizedBox(height: isDesktop ? 32 : 24),
                      ],
                      // Top products by month (interactive)
                      if (state.monthlySales.isNotEmpty) ...[
                        ArpMonthlyProductsSection(monthlySales: state.monthlySales),
                        SizedBox(height: isDesktop ? 32 : 24),
                      ],
                      // Yearly summary
                      if (state.yearlySales.isNotEmpty) ...[
                        ArpYearlySummary(yearlySales: state.yearlySales),
                        SizedBox(height: isDesktop ? 32 : 24),
                      ],
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
    );

    if (widget.isEmbedded) {
      return Directionality(
        textDirection: TextDirection.rtl, 
        child: body
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: body,
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
      tooltip: 'تصفية حسب اليوم',
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
                  'كل الأيام',
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
                          'يوم #${session.id}',
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        if (session.closeTime != null)
                          Text(
                            '${DateFormat('yyyy-MM-dd hh:mm a').format(session.closeTime!)}',
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

  Widget _buildFilterChip({
    required IconData icon,
    required String label,
    required VoidCallback onRemove,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primaryColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded, size: 14, color: AppColors.primaryColor),
            ),
          ),
        ],
      ),
    );
  }
}
