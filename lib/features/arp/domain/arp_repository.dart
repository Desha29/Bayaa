import 'package:dartz/dartz.dart';
import '../../../core/error/failure.dart';

import '../data/models/arp_summary_model.dart';
import '../data/models/product_performance_model.dart';


abstract class ArpRepository {
  Future<Either<Failure, ArpSummaryModel>> getSummary(DateTime start, DateTime end);
Future<Either<Failure, List<ProductPerformanceModel>>> getTopProducts(
  int limit,
  DateTime start,
  DateTime end,
);

  Future<Either<Failure, Map<String, double>>> getDailySales(DateTime start, DateTime end);
}