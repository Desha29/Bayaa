import 'package:bloc/bloc.dart';
import 'package:bayaa_pos/preview/data/preview_data.dart';
import 'package:bayaa_pos/features/inventory_summary/presentation/controllers/inventory_summary_state.dart';

class InventorySummaryCubit extends Cubit<InventorySummaryState> {
  InventorySummaryCubit() : super(StockSummaryInitial());
  void init() => loadData();
  Future<void> loadData() async {
    if (isClosed) return;
    final items = PreviewData.stockSummary;
    emit(StockSummaryLoaded(
        categories: items,
        totalStoreHistoricValue:
            items.fold(0.0, (sum, c) => sum + c.totalHistoricValue),
        totalStoreCurrentValue:
            items.fold(0.0, (sum, c) => sum + c.totalCurrentWholesaleValue),
        totalExpectedProfit:
            items.fold(0.0, (sum, c) => sum + c.expectedProfit)));
  }
}
