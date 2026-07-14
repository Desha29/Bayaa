import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/components/screen_header.dart';
import '../../../../l10n/app_localizations.dart';

import '../cubit/analytics_cubit.dart';
import '../cubit/analytics_state.dart';

import '../../../sessions/data/models/session_model.dart';
import '../../../sessions/data/repositories/session_repository_impl.dart';
import '../../../../core/di/dependency_injection.dart';
import '../widgets/analytics_summary_cards.dart';
import '../widgets/analytics_chart_section.dart';
import '../widgets/analytics_top_products.dart';
import '../widgets/analytics_extra_charts.dart';
import '../widgets/analytics_monthly_sales_chart.dart';
import '../widgets/analytics_yearly_summary.dart';
import '../widgets/analytics_monthly_products_section.dart';

/// The available time period presets for analytics filtering.
enum AnalyticsPeriod {
  today,
  yesterday,
  thisWeek,
  thisMonth,
  thisYear,
  last7Days,
  last30Days,
  customDate,
  customRange,
}

class AnalyticsScreen extends StatefulWidget {
  final bool isEmbedded;
  const AnalyticsScreen({super.key, this.isEmbedded = false});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  DateTime? startDate;
  DateTime? endDate;
  String? selectedSessionId;
  List<Session> availableSessions = [];
  AnalyticsPeriod _selectedPeriod = AnalyticsPeriod.today;
  int _selectedTabIndex = 0;

  bool get _hasAnyFilter => selectedSessionId != null;

  @override
  void initState() {
    super.initState();
    _applyPeriod(AnalyticsPeriod.today, notify: true);
  }

  /// Apply a period preset and optionally trigger data reload.
  void _applyPeriod(AnalyticsPeriod period, {bool notify = true}) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    DateTime s;
    DateTime e;

    switch (period) {
      case AnalyticsPeriod.today:
        s = todayStart;
        e = todayEnd;
        break;
      case AnalyticsPeriod.yesterday:
        final yesterday = now.subtract(const Duration(days: 1));
        s = DateTime(yesterday.year, yesterday.month, yesterday.day);
        e = DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59);
        break;
      case AnalyticsPeriod.thisWeek:
        final weekday = now.weekday; // Monday=1, Sunday=7
        s = todayStart.subtract(Duration(days: weekday - 1));
        e = todayEnd;
        break;
      case AnalyticsPeriod.thisMonth:
        s = DateTime(now.year, now.month, 1);
        e = todayEnd;
        break;
      case AnalyticsPeriod.thisYear:
        s = DateTime(now.year, 1, 1);
        e = todayEnd;
        break;
      case AnalyticsPeriod.last7Days:
        s = todayStart.subtract(const Duration(days: 6));
        e = todayEnd;
        break;
      case AnalyticsPeriod.last30Days:
        s = todayStart.subtract(const Duration(days: 29));
        e = todayEnd;
        break;
      case AnalyticsPeriod.customDate:
      case AnalyticsPeriod.customRange:
        return;
    }

    setState(() {
      _selectedPeriod = period;
      startDate = s;
      endDate = e;
      selectedSessionId = null;
    });

    if (notify) {
      _loadSessions();
      context.read<AnalyticsCubit>().loadAnalytics(start: s, end: e);
    }
  }

  Future<void> _pickSpecificDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: _datePickerTheme,
    );
    if (picked != null && mounted) {
      final s = DateTime(picked.year, picked.month, picked.day, 0, 0, 0);
      final e = DateTime(picked.year, picked.month, picked.day, 23, 59, 59);
      setState(() {
        _selectedPeriod = AnalyticsPeriod.customDate;
        startDate = s;
        endDate = e;
        selectedSessionId = null;
      });
      _loadSessions();
      context.read<AnalyticsCubit>().loadAnalytics(start: s, end: e);
    }
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: startDate ?? DateTime.now().subtract(const Duration(days: 30)),
        end: endDate ?? DateTime.now(),
      ),
      builder: _datePickerTheme,
    );
    if (picked != null && mounted) {
      final s = DateTime(picked.start.year, picked.start.month, picked.start.day, 0, 0, 0);
      final e = DateTime(picked.end.year, picked.end.month, picked.end.day, 23, 59, 59);
      setState(() {
        _selectedPeriod = AnalyticsPeriod.customRange;
        startDate = s;
        endDate = e;
        selectedSessionId = null;
      });
      _loadSessions();
      context.read<AnalyticsCubit>().loadAnalytics(start: s, end: e);
    }
  }

  Widget _datePickerTheme(BuildContext context, Widget? child) {
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
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    final isWide = isDesktop || isTablet;

    final body = SafeArea(
      child: BlocBuilder<AnalyticsCubit, AnalyticsState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () => context.read<AnalyticsCubit>().refreshData(),
            color: AppColors.primaryColor,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      isDesktop ? 32 : isTablet ? 24 : 16,
                      8,
                      isDesktop ? 32 : isTablet ? 24 : 16,
                      isDesktop ? 32 : isTablet ? 24 : 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title row (History button removed)
                        _buildHeaderRow(isDesktop),
                        const ScreenHeaderGap(height: 16),
                        // Period selector chips
                        _buildPeriodSelector(),
                        // Tab Selector
                        _buildTabSelector(),
                        // Active session filter chips
                        if (_hasAnyFilter)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                if (selectedSessionId != null)
                                  _buildFilterChip(
                                    icon: Icons.event_note_rounded,
                                    label: l10n.sessionNumber(selectedSessionId!.length > 8 ? selectedSessionId!.substring(0, 8) : selectedSessionId!),
                                    onRemove: () {
                                      setState(() => selectedSessionId = null);
                                      context.read<AnalyticsCubit>().loadAnalytics(
                                            start: startDate,
                                            end: endDate,
                                          );
                                    },
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // --- LOADING STATE ---
                if (state is AnalyticsLoading) ...[
                  if (state.previousData != null) ...[
                    // Subsequent load: show a linear indicator at the top
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : isTablet ? 24 : 16, vertical: 8),
                        child: const ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                          child: LinearProgressIndicator(
                            color: AppColors.primaryColor,
                            backgroundColor: AppColors.borderColor,
                            minHeight: 4,
                          ),
                        ),
                      ),
                    ),
                    // Keep the previous data visible, but apply a subtle opacity with responsive grid
                    SliverToBoxAdapter(
                      child: Opacity(
                        opacity: 0.75,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_selectedTabIndex == 0) ...[
                              AnalyticsSummaryCards(summary: state.previousData!.summary),
                              SizedBox(height: isDesktop ? 32 : 24),
                              if (isWide) ...[
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 24),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (state.previousData!.dailyTimeSeries.isNotEmpty)
                                        Expanded(
                                          flex: 2,
                                          child: AnalyticsChartSection(
                                            dailySales: state.previousData!.dailyTimeSeries,
                                            usePadding: false,
                                          ),
                                        ),
                                      if (state.previousData!.dailyTimeSeries.isNotEmpty && (state.previousData!.summary.grossRevenue ?? 0) > 0)
                                        const SizedBox(width: 24),
                                      if ((state.previousData!.summary.grossRevenue ?? 0) > 0)
                                        Expanded(
                                          flex: 1,
                                          child: AnalyticsSalesVsRefundChart(
                                            grossSales: state.previousData!.summary.grossRevenue ?? 0,
                                            refunds: state.previousData!.summary.refundedAmount ?? 0,
                                            usePadding: false,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: isDesktop ? 32 : 24),
                              ] else ...[
                                if (state.previousData!.dailyTimeSeries.isNotEmpty) ...[
                                  AnalyticsChartSection(dailySales: state.previousData!.dailyTimeSeries),
                                  SizedBox(height: 24),
                                ],
                                if ((state.previousData!.summary.grossRevenue ?? 0) > 0) ...[
                                  AnalyticsSalesVsRefundChart(
                                    grossSales: state.previousData!.summary.grossRevenue ?? 0,
                                    refunds: state.previousData!.summary.refundedAmount ?? 0,
                                  ),
                                  SizedBox(height: 24),
                                ],
                              ],
                            ],
                            if (_selectedTabIndex == 1) ...[
                              if (isWide) ...[
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 24),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (state.previousData!.monthlySales.isNotEmpty)
                                        Expanded(
                                          flex: 12,
                                          child: AnalyticsMonthlySalesChart(
                                            monthlySales: state.previousData!.monthlySales,
                                            usePadding: false,
                                          ),
                                        ),
                                      if (state.previousData!.monthlySales.isNotEmpty && state.previousData!.hourlySales.isNotEmpty)
                                        const SizedBox(width: 24),
                                      if (state.previousData!.hourlySales.isNotEmpty)
                                        Expanded(
                                          flex: 10,
                                          child: AnalyticsHourlyChart(
                                            hourlySales: state.previousData!.hourlySales,
                                            usePadding: false,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: isDesktop ? 32 : 24),
                                if (state.previousData!.yearlySales.isNotEmpty) ...[
                                  AnalyticsYearlySummary(yearlySales: state.previousData!.yearlySales),
                                  SizedBox(height: isDesktop ? 32 : 24),
                                ],
                              ] else ...[
                                if (state.previousData!.monthlySales.isNotEmpty) ...[
                                  AnalyticsMonthlySalesChart(monthlySales: state.previousData!.monthlySales),
                                  SizedBox(height: 24),
                                ],
                                if (state.previousData!.yearlySales.isNotEmpty) ...[
                                  AnalyticsYearlySummary(yearlySales: state.previousData!.yearlySales),
                                  SizedBox(height: 24),
                                ],
                                if (state.previousData!.hourlySales.isNotEmpty) ...[
                                  AnalyticsHourlyChart(hourlySales: state.previousData!.hourlySales),
                                  SizedBox(height: 24),
                                ],
                              ],
                            ],
                            if (_selectedTabIndex == 2) ...[
                              if (isWide) ...[
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 24),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 5,
                                        child: AnalyticsTopProducts(
                                          products: state.previousData!.topProducts,
                                          usePadding: false,
                                        ),
                                      ),
                                      if (state.previousData!.categorySales.isNotEmpty) ...[
                                        const SizedBox(width: 24),
                                        Expanded(
                                          flex: 4,
                                          child: AnalyticsCategoryPieChart(
                                            categorySales: state.previousData!.categorySales,
                                            usePadding: false,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                SizedBox(height: isDesktop ? 32 : 24),
                                if (state.previousData!.monthlySales.isNotEmpty) ...[
                                  AnalyticsMonthlyProductsSection(monthlySales: state.previousData!.monthlySales),
                                  SizedBox(height: isDesktop ? 32 : 24),
                                ],
                              ] else ...[
                                AnalyticsTopProducts(products: state.previousData!.topProducts),
                                SizedBox(height: 24),
                                if (state.previousData!.categorySales.isNotEmpty) ...[
                                  AnalyticsCategoryPieChart(categorySales: state.previousData!.categorySales),
                                  SizedBox(height: 24),
                                ],
                                if (state.previousData!.monthlySales.isNotEmpty) ...[
                                  AnalyticsMonthlyProductsSection(monthlySales: state.previousData!.monthlySales),
                                  SizedBox(height: 24),
                                ],
                              ],
                            ],
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    // Initial load: show the beautiful shimmer skeleton placeholders
                    SliverToBoxAdapter(
                      child: _buildSkeletonLoader(isDesktop, isTablet),
                    ),
                  ],
                ],

                // --- ERROR STATE ---
                if (state is AnalyticsError)
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
                                context.read<AnalyticsCubit>().refreshData(),
                            icon: const Icon(Icons.refresh),
                            label: Text(l10n.retry),
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

                // --- LOADED STATE WITH RESPONSIVE LAYOUTS & TRANSITIONS ---
                if (state is AnalyticsLoaded)
                  SliverToBoxAdapter(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      child: Column(
                        key: ValueKey<int>(_selectedTabIndex),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- TAB 0: OVERVIEW ---
                          if (_selectedTabIndex == 0) ...[
                            AnalyticsSummaryCards(summary: state.summary),
                            SizedBox(height: isDesktop ? 32 : 24),
                            if (isWide) ...[
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 24),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (state.dailyTimeSeries.isNotEmpty)
                                      Expanded(
                                        flex: 2,
                                        child: AnalyticsChartSection(
                                          dailySales: state.dailyTimeSeries,
                                          usePadding: false,
                                        ),
                                      ),
                                    if (state.dailyTimeSeries.isNotEmpty && (state.summary.grossRevenue ?? 0) > 0)
                                      const SizedBox(width: 24),
                                    if ((state.summary.grossRevenue ?? 0) > 0)
                                      Expanded(
                                        flex: 1,
                                        child: AnalyticsSalesVsRefundChart(
                                          grossSales: state.summary.grossRevenue ?? 0,
                                          refunds: state.summary.refundedAmount ?? 0,
                                          usePadding: false,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              SizedBox(height: isDesktop ? 32 : 24),
                            ] else ...[
                              if (state.dailyTimeSeries.isNotEmpty) ...[
                                AnalyticsChartSection(dailySales: state.dailyTimeSeries),
                                SizedBox(height: 24),
                              ],
                              if ((state.summary.grossRevenue ?? 0) > 0) ...[
                                AnalyticsSalesVsRefundChart(
                                  grossSales: state.summary.grossRevenue ?? 0,
                                  refunds: state.summary.refundedAmount ?? 0,
                                ),
                                SizedBox(height: 24),
                              ],
                            ],
                          ],

                          // --- TAB 1: SALES PERFORMANCE ---
                          if (_selectedTabIndex == 1) ...[
                            if (isWide) ...[
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 24),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (state.monthlySales.isNotEmpty)
                                      Expanded(
                                        flex: 12,
                                        child: AnalyticsMonthlySalesChart(
                                          monthlySales: state.monthlySales,
                                          usePadding: false,
                                        ),
                                      ),
                                    if (state.monthlySales.isNotEmpty && state.hourlySales.isNotEmpty)
                                      const SizedBox(width: 24),
                                    if (state.hourlySales.isNotEmpty)
                                      Expanded(
                                        flex: 10,
                                        child: AnalyticsHourlyChart(
                                          hourlySales: state.hourlySales,
                                          usePadding: false,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              SizedBox(height: isDesktop ? 32 : 24),
                              if (state.yearlySales.isNotEmpty) ...[
                                AnalyticsYearlySummary(yearlySales: state.yearlySales),
                                SizedBox(height: isDesktop ? 32 : 24),
                              ],
                            ] else ...[
                              if (state.monthlySales.isNotEmpty) ...[
                                AnalyticsMonthlySalesChart(monthlySales: state.monthlySales),
                                SizedBox(height: 24),
                              ],
                              if (state.yearlySales.isNotEmpty) ...[
                                AnalyticsYearlySummary(yearlySales: state.yearlySales),
                                SizedBox(height: 24),
                              ],
                              if (state.hourlySales.isNotEmpty) ...[
                                AnalyticsHourlyChart(hourlySales: state.hourlySales),
                                SizedBox(height: 24),
                              ],
                            ],
                            if (state.monthlySales.isEmpty && state.yearlySales.isEmpty && state.hourlySales.isEmpty)
                               Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 64),
                                  child: Text(
                                    l10n.noDataSalesAnalytics,
                                    style: TextStyle(color: AppColors.mutedColor, fontSize: 16),
                                  ),
                                ),
                              ),
                          ],

                          // --- TAB 2: PRODUCT ANALYSIS ---
                          if (_selectedTabIndex == 2) ...[
                            if (isWide) ...[
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 24),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 5,
                                      child: AnalyticsTopProducts(
                                        products: state.topProducts,
                                        usePadding: false,
                                      ),
                                    ),
                                    if (state.categorySales.isNotEmpty) ...[
                                      const SizedBox(width: 24),
                                      Expanded(
                                        flex: 4,
                                        child: AnalyticsCategoryPieChart(
                                          categorySales: state.categorySales,
                                          usePadding: false,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              SizedBox(height: isDesktop ? 32 : 24),
                              if (state.monthlySales.isNotEmpty) ...[
                                AnalyticsMonthlyProductsSection(monthlySales: state.monthlySales),
                                SizedBox(height: isDesktop ? 32 : 24),
                              ],
                            ] else ...[
                              AnalyticsTopProducts(products: state.topProducts),
                              SizedBox(height: 24),
                              if (state.categorySales.isNotEmpty) ...[
                                AnalyticsCategoryPieChart(categorySales: state.categorySales),
                                SizedBox(height: 24),
                              ],
                              if (state.monthlySales.isNotEmpty) ...[
                                AnalyticsMonthlyProductsSection(monthlySales: state.monthlySales),
                                SizedBox(height: 24),
                              ],
                            ],
                          ],
                        ],
                      ),
                    ),
                  ),

                if (state is AnalyticsInitial)
                  SliverFillRemaining(
                    child: Center(
                      child: Text(
                        l10n.noDataToDisplay,
                        style: const TextStyle(
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
        textDirection: l10n.localeName == 'ar' ? TextDirection.rtl : TextDirection.ltr, 
        child: body
      );
    }

    return Directionality(
      textDirection: l10n.localeName == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: body,
      ),
    );
  }

  Widget _buildHeaderRow(bool isDesktop) {
    final l10n = AppLocalizations.of(context);
    return ScreenHeader(
      title: l10n.analyticsTitle,
      subtitle: _getDateRangeText(),
      icon: LucideIcons.barChart2,
      iconColor: AppColors.primaryColor,
      titleColor: AppColors.textPrimary,
      actions: [
        if (availableSessions.isNotEmpty) ...[
          _buildSessionFilter(),
          const SizedBox(width: 4),
        ],
      ],
    );
  }

  /// Builds the horizontal scrollable period chip selector bar.
  Widget _buildPeriodSelector() {
    final l10n = AppLocalizations.of(context);
    final presets = <_PeriodOption>[
      _PeriodOption(AnalyticsPeriod.today, l10n.todayFilter, Icons.today_rounded),
      _PeriodOption(AnalyticsPeriod.yesterday, l10n.yesterdayFilter, Icons.event_rounded),
      _PeriodOption(AnalyticsPeriod.last7Days, l10n.last7Days, Icons.date_range_rounded),
      _PeriodOption(AnalyticsPeriod.thisWeek, l10n.thisWeek, Icons.view_week_rounded),
      _PeriodOption(AnalyticsPeriod.last30Days, l10n.last30Days, Icons.calendar_month_rounded),
      _PeriodOption(AnalyticsPeriod.thisMonth, l10n.thisMonth, Icons.calendar_today_rounded),
      _PeriodOption(AnalyticsPeriod.thisYear, l10n.thisYear, Icons.calendar_view_month_rounded),
      _PeriodOption(AnalyticsPeriod.customDate, l10n.customDate, Icons.event_note_rounded),
      _PeriodOption(AnalyticsPeriod.customRange, l10n.customRange, Icons.edit_calendar_rounded),
    ];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: presets.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final option = presets[index];
          final isSelected = _selectedPeriod == option.period;
          return _buildPeriodChip(option, isSelected);
        },
      ),
    );
  }

  Widget _buildPeriodChip(_PeriodOption option, bool isSelected) {
    return GestureDetector(
      onTap: () {
        if (option.period == AnalyticsPeriod.customDate) {
          _pickSpecificDate();
        } else if (option.period == AnalyticsPeriod.customRange) {
          _pickDateRange();
        } else {
          _applyPeriod(option.period);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [AppColors.primaryColor, AppColors.secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : AppColors.borderColor,
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              option.icon,
              size: 16,
              color: isSelected ? Colors.white : AppColors.mutedColor,
            ),
            const SizedBox(width: 6),
            Text(
              option.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a professional, modern segmented tab selector.
  Widget _buildTabSelector() {
    final l10n = AppLocalizations.of(context);
    final tabs = [
      _TabOption(0, l10n.overviewTab, Icons.dashboard_outlined),
      _TabOption(1, l10n.salesTab, Icons.bar_chart_rounded),
      _TabOption(2, l10n.productsTab, Icons.shopping_bag_outlined),
    ];

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor.withOpacity(0.8), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmall = constraints.maxWidth < 500;
          return Row(
            children: tabs.map((tab) {
              final isSelected = _selectedTabIndex == tab.index;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTabIndex = tab.index;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primaryColor.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          tab.icon,
                          size: isSmall ? 16 : 18,
                          color: isSelected ? Colors.white : AppColors.mutedColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          tab.label,
                          style: TextStyle(
                            fontSize: isSmall ? 12 : 14,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  /// Builds a gorgeous shimmer/skeleton placeholder loader.
  Widget _buildSkeletonLoader(bool isDesktop, bool isTablet) {
    final padding = isDesktop ? 32.0 : isTablet ? 24.0 : 16.0;
    final crossAxisCount = isDesktop ? 4 : isTablet ? 2 : 1;
    final childAspectRatio = isDesktop ? 1.6 : isTablet ? 1.8 : 2.2;
    final isWide = isDesktop || isTablet;

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 4 summary cards skeleton
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: childAspectRatio,
            children: List.generate(
              4,
              (_) => const _SkeletonPlaceholder(
                width: double.infinity,
                height: double.infinity,
                borderRadius: 16,
              ),
            ),
          ),
          const SizedBox(height: 32),
          
          // Side-by-side or stacked chart skeleton depending on screen width
          if (isWide) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Expanded(
                  flex: 2,
                  child: _SkeletonPlaceholder(
                    width: double.infinity,
                    height: 300,
                    borderRadius: 16,
                  ),
                ),
                SizedBox(width: 24),
                Expanded(
                  flex: 1,
                  child: _SkeletonPlaceholder(
                    width: double.infinity,
                    height: 300,
                    borderRadius: 16,
                  ),
                ),
              ],
            ),
          ] else ...[
            const _SkeletonPlaceholder(
              width: double.infinity,
              height: 250,
              borderRadius: 16,
            ),
            const SizedBox(height: 24),
            const _SkeletonPlaceholder(
              width: double.infinity,
              height: 250,
              borderRadius: 16,
            ),
          ],
        ],
      ),
    );
  }

  String _getDateRangeText() {
    final l10n = AppLocalizations.of(context);
    if (startDate == null || endDate == null) {
      return l10n.last30Days;
    }

    final df = DateFormat('d/M/yyyy');

    if (startDate!.year == endDate!.year &&
        startDate!.month == endDate!.month &&
        startDate!.day == endDate!.day) {
      return df.format(startDate!);
    }

    return '${l10n.fromDateLabel} ${df.format(startDate!)} ${l10n.toDateLabel} ${df.format(endDate!)}';
  }

  Widget _buildSessionFilter() {
    final l10n = AppLocalizations.of(context);
    return PopupMenuButton<String>(
      tooltip: l10n.sessionFilter,
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
        context.read<AnalyticsCubit>().loadAnalytics(
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
                  l10n.allSessions,
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
                          l10n.sessionNumber(session.id),
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        if (session.closeTime != null)
                          Text(
                            DateFormat('yyyy-MM-dd hh:mm a').format(session.closeTime!),
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
          }),
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

/// Helper class for period option metadata.
class _PeriodOption {
  final AnalyticsPeriod period;
  final String label;
  final IconData icon;

  const _PeriodOption(this.period, this.label, this.icon);
}

/// Helper class for tab option metadata.
class _TabOption {
  final int index;
  final String label;
  final IconData icon;

  const _TabOption(this.index, this.label, this.icon);
}

/// A lightweight, custom animated Shimmer/Skeleton placeholder widget.
class _SkeletonPlaceholder extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const _SkeletonPlaceholder({
    required this.width,
    required this.height,
    this.borderRadius = 12,
  });

  @override
  State<_SkeletonPlaceholder> createState() => _SkeletonPlaceholderState();
}

class _SkeletonPlaceholderState extends State<_SkeletonPlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const [
                Color(0xFFE2E8F0), // Slate 200
                Color(0xFFF1F5F9), // Slate 100
                Color(0xFFE2E8F0), // Slate 200
              ],
              stops: [
                _animation.value - 1.0 < 0 ? 0 : (_animation.value - 1.0 > 1 ? 1 : _animation.value - 1.0),
                _animation.value < 0 ? 0 : (_animation.value > 1 ? 1 : _animation.value),
                _animation.value + 1.0 < 0 ? 0 : (_animation.value + 1.0 > 1 ? 1 : _animation.value + 1.0),
              ],
            ),
          ),
        );
      },
    );
  }
}
