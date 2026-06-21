import 'package:equatable/equatable.dart';
import '../../data/models/analytics_summary_model.dart';
import '../../../sessions/data/models/product_performance_model.dart';

abstract class AnalyticsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AnalyticsInitial extends AnalyticsState {}

class AnalyticsLoading extends AnalyticsState {
  final AnalyticsLoaded? previousData;

  AnalyticsLoading({this.previousData});

  @override
  List<Object?> get props => [previousData];
}

class AnalyticsLoaded extends AnalyticsState {
  final AnalyticsSummaryModel summary;
  final List<ProductPerformanceModel> topProducts;
  final Map<String, double> dailySales; // Legacy summary (Revenue/Cost/Profit)
  final Map<int, double> hourlySales;
  final Map<String, double> categorySales;
  final Map<String, double> dailyTimeSeries;
  final Map<String, double> monthlySales;
  final Map<String, double> yearlySales;

  AnalyticsLoaded({
    required this.summary,
    required this.topProducts,
    required this.dailySales,
    this.hourlySales = const {},
    this.categorySales = const {},
    this.dailyTimeSeries = const {},
    this.monthlySales = const {},
    this.yearlySales = const {},
  });

  @override
  List<Object?> get props => [
        summary,
        topProducts,
        dailySales,
        hourlySales,
        categorySales,
        dailyTimeSeries,
        monthlySales,
        yearlySales,
      ];
}

class AnalyticsError extends AnalyticsState {
  final String message;

  AnalyticsError(this.message);

  @override
  List<Object?> get props => [message];
}
