import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../sessions/data/models/daily_report_model.dart';
import '../../../sessions/data/models/product_performance_model.dart';
import '../../domain/analytics_repository.dart';
import '../../data/models/analytics_summary_model.dart';
import 'analytics_state.dart';

class AnalyticsCubit extends Cubit<AnalyticsState> {
  final AnalyticsRepository repository;
  DateTime? _lastStart;
  DateTime? _lastEnd;
  String? _lastSessionId;

  AnalyticsCubit(this.repository) : super(AnalyticsInitial());

  Future<void> loadAnalytics({DateTime? start, DateTime? end, String? sessionId}) async {
    final previousState = state;
    AnalyticsLoaded? prevData;
    if (previousState is AnalyticsLoaded) {
      prevData = previousState;
    } else if (previousState is AnalyticsLoading && previousState.previousData != null) {
      prevData = previousState.previousData;
    }
    emit(AnalyticsLoading(previousData: prevData));

    // Yield to let the UI render the loading state before starting heavy work
    await Future.delayed(Duration.zero);

    // Normalize to full day
    DateTime s = start ?? _lastStart ?? DateTime.now().subtract(const Duration(days: 30));
    DateTime e = end ?? _lastEnd ?? DateTime.now();
    final startDate = DateTime(s.year, s.month, s.day, 0, 0, 0, 0, 0);
    final endDate = DateTime(e.year, e.month, e.day, 23, 59, 59, 999, 999);

    _lastStart = startDate;
    _lastEnd = endDate;
    _lastSessionId = sessionId;

    try {
      // Check if we're filtering by session
      if (sessionId != null && sessionId.isNotEmpty) {
        await _loadSessionAnalytics(sessionId, startDate, endDate);
      } else {
        await _loadAggregateAnalytics(startDate, endDate);
      }
    } catch (error, stackTrace) {
      print('Error loading analytics: $error\n$stackTrace');
      if (!isClosed) {
        emit(AnalyticsError('Unexpected error loading data: ${error.toString()}'));
      }
    }
  }

  Future<void> _loadSessionAnalytics(String sessionId, DateTime startDate, DateTime endDate) async {
    try {
      // Fetch session analytics queries concurrently
      final results = await Future.wait([
        repository.getReportForSession(sessionId),
        repository.getTopProductsForSession(sessionId, 10),
        repository.getHourlySalesForSession(sessionId),
        repository.getCategorySalesForSession(sessionId),
      ]);

      if (isClosed) return;

      final reportRes = results[0] as Either<Failure, DailyReport?>;
      final topProductsRes = results[1] as Either<Failure, List<ProductPerformanceModel>>;
      final hourlyRes = results[2] as Either<Failure, Map<int, double>>;
      final categoryRes = results[3] as Either<Failure, Map<String, double>>;

      if (reportRes.isLeft()) {
        emit(AnalyticsError(reportRes.fold((f) => f.message, (_) => '')));
        return;
      }

      final report = reportRes.getOrElse(() => null);
      if (report == null) {
        emit(AnalyticsError('No data found for this day'));
        return;
      }

      if (topProductsRes.isLeft()) {
        emit(AnalyticsError(topProductsRes.fold((f) => f.message, (_) => '')));
        return;
      }

      final summary = AnalyticsSummaryModel(
        startDate: startDate,
        endDate: endDate,
        totalRevenue: report.netRevenue,
        totalCost: 0,
        totalProfit: 0,
        profitMargin: 0,
        totalSales: report.totalTransactions,
        grossRevenue: report.totalSales,
        refundedAmount: report.totalRefunds,
      );

      emit(AnalyticsLoaded(
        summary: summary,
        topProducts: topProductsRes.getOrElse(() => []),
        dailySales: {'Today': report.netRevenue},
        hourlySales: hourlyRes.getOrElse(() => {}),
        categorySales: categoryRes.getOrElse(() => {}),
        dailyTimeSeries: const {},
      ));
    } catch (error) {
      if (!isClosed) {
        emit(AnalyticsError('Failed to load session data: ${error.toString()}'));
      }
    }
  }

  Future<void> _loadAggregateAnalytics(DateTime startDate, DateTime endDate) async {
    try {
      // Fetch aggregate analytics queries concurrently
      final results = await Future.wait([
        repository.getSummary(startDate, endDate),
        repository.getTopProducts(10, startDate, endDate),
        repository.getHourlySales(startDate, endDate),
        repository.getSalesByCategory(startDate, endDate),
        repository.getDailyTimeSeries(startDate, endDate),
        repository.getMonthlySales(startDate, endDate),
        repository.getYearlySales(startDate, endDate),
      ]);

      if (isClosed) return;

      final summaryRes = results[0] as Either<Failure, AnalyticsSummaryModel>;
      final topProductsRes = results[1] as Either<Failure, List<ProductPerformanceModel>>;
      final hourlyRes = results[2] as Either<Failure, Map<int, double>>;
      final categoryRes = results[3] as Either<Failure, Map<String, double>>;
      final timeSeriesRes = results[4] as Either<Failure, Map<String, double>>;
      final monthlyRes = results[5] as Either<Failure, Map<String, double>>;
      final yearlyRes = results[6] as Either<Failure, Map<String, double>>;

      // Check critical results
      if (summaryRes.isLeft()) {
        emit(AnalyticsError(summaryRes.fold((f) => f.message, (_) => '')));
        return;
      }
      if (topProductsRes.isLeft()) {
        emit(AnalyticsError(topProductsRes.fold((f) => f.message, (_) => '')));
        return;
      }

      final summary = summaryRes.getOrElse(() => AnalyticsSummaryModel(
        startDate: startDate,
        endDate: endDate,
        totalRevenue: 0,
        totalCost: 0,
        totalProfit: 0,
        profitMargin: 0,
        totalSales: 0,
      ));

      // Derive dailySales from summary directly — avoids duplicate getSummary call
      final dailySales = <String, double>{
        'Total sales': summary.totalRevenue,
        'Total cost': summary.totalCost,
        'Net profit': summary.totalProfit,
      };

      emit(AnalyticsLoaded(
        summary: summary,
        topProducts: topProductsRes.getOrElse(() => []),
        dailySales: dailySales,
        hourlySales: hourlyRes.getOrElse(() => {}),
        categorySales: categoryRes.getOrElse(() => {}),
        dailyTimeSeries: timeSeriesRes.getOrElse(() => {}),
        monthlySales: monthlyRes.getOrElse(() => {}),
        yearlySales: yearlyRes.getOrElse(() => {}),
      ));
    } catch (error) {
      if (!isClosed) {
        emit(AnalyticsError('Failed to load analytics: ${error.toString()}'));
      }
    }
  }

  Future<void> refreshData() async {
    await loadAnalytics(start: _lastStart, end: _lastEnd, sessionId: _lastSessionId);
  }
}
