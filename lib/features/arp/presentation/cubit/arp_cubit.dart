import 'package:flutter_bloc/flutter_bloc.dart';

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
    // Load session-specific data
    final reportResult = await repository.getReportForSession(sessionId);
    final topProductsResult = await repository.getTopProductsForSession(sessionId, 10);
    final hourlyResult = await repository.getHourlySalesForSession(sessionId);
    final categoryResult = await repository.getCategorySalesForSession(sessionId);

    reportResult.fold(
      (_) => emit(ArpError('فشل تحميل بيانات الجلسة')),
      (report) {
        if (report == null) {
          emit(ArpError('لم يتم العثور على بيانات لهذه الجلسة'));
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
              dailySales: {'الجلسة': report.netRevenue},
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
    final summaryResult = await repository.getSummary(startDate, endDate);
    final topProductsResult = await repository.getTopProducts(10, startDate, endDate);
    final dailySalesResult = await repository.getDailySales(startDate, endDate);

    summaryResult.fold(
      (_) => emit(ArpError('فشل تحميل البيانات')),
      (summary) {
        topProductsResult.fold(
          (_) => emit(ArpError('فشل تحميل المنتجات')),
          (topProducts) async {
            // Fetch new charts
            final hourlyResult = await repository.getHourlySales(startDate, endDate);
            final categoryResult = await repository.getSalesByCategory(startDate, endDate);
            final timeSeriesResult = await repository.getDailyTimeSeries(startDate, endDate);
            
            dailySalesResult.fold(
              (_) => emit(ArpError('فشل تحميل المبيعات اليومية')),
              (dailySales) => emit(ArpLoaded(
                summary: summary,
                topProducts: topProducts,
                dailySales: dailySales,
                hourlySales: hourlyResult.getOrElse(() => {}),
                categorySales: categoryResult.getOrElse(() => {}),
                dailyTimeSeries: timeSeriesResult.getOrElse(() => {}),
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
