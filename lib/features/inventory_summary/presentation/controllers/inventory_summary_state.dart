import 'package:equatable/equatable.dart';
import 'package:bayaa_pos/features/inventory_summary/presentation/models/inventory_category_view_data.dart';

abstract class InventorySummaryState extends Equatable {
  const InventorySummaryState();

  @override
  List<Object> get props => [];
}

class StockSummaryInitial extends InventorySummaryState {}

class StockSummaryLoading extends InventorySummaryState {}

class StockSummaryLoaded extends InventorySummaryState {
  final List<InventoryCategoryViewData> categories;
  final double totalStoreHistoricValue;
  final double totalStoreCurrentValue;
  final double totalExpectedProfit;

  const StockSummaryLoaded({
    required this.categories,
    required this.totalStoreHistoricValue,
    required this.totalStoreCurrentValue,
    required this.totalExpectedProfit,
  });

  @override
  List<Object> get props => [
        categories,
        totalStoreHistoricValue,
        totalStoreCurrentValue,
        totalExpectedProfit,
      ];
}

class StockSummaryError extends InventorySummaryState {
  final String message;

  const StockSummaryError(this.message);

  @override
  List<Object> get props => [message];
}
