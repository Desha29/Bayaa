
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/arp_repository.dart';
import 'arp_state.dart';

class ArpCubit extends Cubit<ArpState> {
  final ArpRepository repository;

  ArpCubit(this.repository) : super(ArpInitial());

  Future<void> loadAnalytics({DateTime? start, DateTime? end}) async {
    emit(ArpLoading());

    final startDate = start ?? DateTime.now().subtract(const Duration(days: 30));
    final endDate = end ?? DateTime.now();

    final summaryResult = await repository.getSummary(startDate, endDate);
    final topProductsResult = await repository.getTopProducts(10);
    final dailySalesResult = await repository.getDailySales(startDate, endDate);

    summaryResult.fold(
      (failure) => emit(ArpError('فشل تحميل البيانات')),
      (summary) {
        topProductsResult.fold(
          (failure) => emit(ArpError('فشل تحميل المنتجات')),
          (topProducts) {
            dailySalesResult.fold(
              (failure) => emit(ArpError('فشل تحميل المبيعات اليومية')),
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
    await loadAnalytics();
  }
}
