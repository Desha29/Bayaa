
import 'package:equatable/equatable.dart';
import '../../data/models/arp_summary_model.dart';
import '../../data/models/product_performance_model.dart';


abstract class ArpState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ArpInitial extends ArpState {}

class ArpLoading extends ArpState {}

class ArpLoaded extends ArpState {
  final ArpSummaryModel summary;
  final List<ProductPerformanceModel> topProducts;
  final Map<String, double> dailySales;

  ArpLoaded({
    required this.summary,
    required this.topProducts,
    required this.dailySales,
  });

  @override
  List<Object?> get props => [summary, topProducts, dailySales];
}

class ArpError extends ArpState {
  final String message;

  ArpError(this.message);

  @override
  List<Object?> get props => [message];
}

