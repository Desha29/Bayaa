import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../data/models/daily_report_model.dart';
import '../../data/models/product_performance_model.dart';
import '../../domain/arp_repository.dart';
import '../../data/models/arp_summary_model.dart';
import 'arp_state.dart';

class ArpCubit extends Cubit<ArpState> {
  final ArpRepository repository;
  DateTime? _lastStart;
  DateTime? _lastEnd;
  String? _lastSessionId;

  ArpCubit(this.repository) : super(ArpInitial());

  Future<void> loadAnalytics({DateTime? start, DateTime? end, String? sessionId}) async {
    emit(ArpLoading());

    // Normalize to full day
    DateTime s = start ?? _lastStart ?? DateTime.now().subtract(const Duration(days: 30));
    DateTime e = end ?? _lastEnd ?? DateTime.now();
    final startDate = DateTime(s.year, s.month, s.day, 0, 0, 0, 0, 0);
    final endDate = DateTime(e.year, e.month, e.day, 23, 59, 59, 999, 999);

    _lastStart = startDate;
    _lastEnd = endDate;
    _lastSessionId = sessionId;

    // Check if we're filtering by session
    if (sessionId != null && sessionId.isNotEmpty) {
      await _loadSessionAnalytics(sessionId, startDate, endDate);
    } else {
      await _loadAggregateAnalytics(startDate, endDate);
    }
  }

  Future<void> _loadSessionAnalytics(String sessionId, DateTime startDate, DateTime endDate) async {
    // Load session-specific data concurrently
    final results = await Future.wait([
      repository.getReportForSession(sessionId),
      repository.getTopProductsForSession(sessionId, 10),
      repository.getHourlySalesForSession(sessionId),
      repository.getCategorySalesForSession(sessionId),
    ]);

    final reportResult = results[0] as dartz.Either<Failure, DailyReport?>;
    final topProductsResult = results[1] as dartz.Either<Failure, List<ProductPerformanceModel>>;
    final hourlyResult = results[2] as dartz.Either<Failure, Map<int, double>>;
    final categoryResult = results[3] as dartz.Either<Failure, Map<String, double>>;

    reportResult.fold(
      (_) => emit(ArpError('فشل تحميل بيانات اليوم')),
      (report) {
        if (report == null) {
          emit(ArpError('لم يتم العثور على بيانات لهذا اليوم'));
          return;
        }

        topProductsResult.fold(
          (_) => emit(ArpError('فشل تحميل المنتجات')),
          (topProducts) {
            // Build summary from report
            final summary = ArpSummaryModel(
              startDate: startDate,
              endDate: endDate,
              totalRevenue: report.netRevenue,
              totalCost: 0, // Not available in report
              totalProfit: 0,
              profitMargin: 0,
              totalSales: report.totalTransactions,
              grossRevenue: report.totalSales,
              refundedAmount: report.totalRefunds,
            );

            emit(ArpLoaded(
              summary: summary,
              topProducts: topProducts,
              dailySales: {'اليوم': report.netRevenue},
              hourlySales: hourlyResult.getOrElse(() => {}),
              categorySales: categoryResult.getOrElse(() => {}),
              dailyTimeSeries: {},
            ));
          },
        );
      },
    );
  }

  Future<void> _loadAggregateAnalytics(DateTime startDate, DateTime endDate) async {
    final results = await Future.wait([
      repository.getSummary(startDate, endDate),
      repository.getTopProducts(10, startDate, endDate),
      repository.getDailySales(startDate, endDate),
      repository.getHourlySales(startDate, endDate),
      repository.getSalesByCategory(startDate, endDate),
      repository.getDailyTimeSeries(startDate, endDate),
      repository.getMonthlySales(startDate, endDate),
      repository.getYearlySales(startDate, endDate),
    ]);

    final summaryResult = results[0] as dartz.Either<Failure, ArpSummaryModel>;
    final topProductsResult = results[1] as dartz.Either<Failure, List<ProductPerformanceModel>>;
    final dailySalesResult = results[2] as dartz.Either<Failure, Map<String, double>>;
    final hourlyResult = results[3] as dartz.Either<Failure, Map<int, double>>;
    final categoryResult = results[4] as dartz.Either<Failure, Map<String, double>>;
    final timeSeriesResult = results[5] as dartz.Either<Failure, Map<String, double>>;
    final monthlyResult = results[6] as dartz.Either<Failure, Map<String, double>>;
    final yearlyResult = results[7] as dartz.Either<Failure, Map<String, double>>;

    summaryResult.fold(
      (_) => emit(ArpError('فشل تحميل البيانات')),
      (summary) {
        topProductsResult.fold(
          (_) => emit(ArpError('فشل تحميل المنتجات')),
          (topProducts) {
            dailySalesResult.fold(
              (_) => emit(ArpError('فشل تحميل المبيعات اليومية')),
              (dailySales) => emit(ArpLoaded(
                summary: summary,
                topProducts: topProducts,
                dailySales: dailySales,
                hourlySales: hourlyResult.getOrElse(() => {}),
                categorySales: categoryResult.getOrElse(() => {}),
                dailyTimeSeries: timeSeriesResult.getOrElse(() => {}),
                monthlySales: monthlyResult.getOrElse(() => {}),
                yearlySales: yearlyResult.getOrElse(() => {}),
              )),
            );
          },
        );
      },
    );
  }

  Future<void> refreshData() async {
    await loadAnalytics(start: _lastStart, end: _lastEnd, sessionId: _lastSessionId);
  }
}
