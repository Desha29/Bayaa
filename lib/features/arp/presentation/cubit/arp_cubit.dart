import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/arp_repository.dart';
import 'arp_state.dart';

class ArpCubit extends Cubit<ArpState> {
  final ArpRepository repository;
  DateTime? _lastStart;
  DateTime? _lastEnd;

  ArpCubit(this.repository) : super(ArpInitial());

  Future<void> loadAnalytics({DateTime? start, DateTime? end}) async {
    emit(ArpLoading());

    // Normalize to full day
    DateTime s = start ?? _lastStart ?? DateTime.now().subtract(const Duration(days: 30));
    DateTime e = end ?? _lastEnd ?? DateTime.now();
    final startDate = DateTime(s.year, s.month, s.day, 0, 0, 0, 0, 0);
    final endDate = DateTime(e.year, e.month, e.day, 23, 59, 59, 999, 999);

    _lastStart = startDate;
    _lastEnd = endDate;

    final summaryResult = await repository.getSummary(startDate, endDate);
    final topProductsResult = await repository.getTopProducts(10, startDate, endDate);
    final dailySalesResult = await repository.getDailySales(startDate, endDate);

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
              )),
            );
          },
        );
      },
    );
  }

  Future<void> refreshData() async {
    await loadAnalytics(start: _lastStart, end: _lastEnd);
  }
}
