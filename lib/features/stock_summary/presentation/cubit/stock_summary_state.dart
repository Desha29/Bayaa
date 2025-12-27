import 'package:equatable/equatable.dart';
import '../../data/models/stock_summary_category_model.dart';

abstract class StockSummaryState extends Equatable {
  const StockSummaryState();

  @override
  List<Object> get props => [];
}

class StockSummaryInitial extends StockSummaryState {}

class StockSummaryLoading extends StockSummaryState {}

class StockSummaryLoaded extends StockSummaryState {
  final List<StockSummaryCategoryModel> categories;
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

class StockSummaryError extends StockSummaryState {
  final String message;

  const StockSummaryError(this.message);

  @override
  List<Object> get props => [message];
}
