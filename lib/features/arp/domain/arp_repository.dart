import 'package:dartz/dartz.dart';
import '../../../core/error/failure.dart';

import '../data/models/arp_summary_model.dart';
import '../data/models/product_performance_model.dart';
import '../data/models/daily_report_model.dart';


abstract class ArpRepository {
  Future<Either<Failure, ArpSummaryModel>> getSummary(DateTime start, DateTime end);
  Future<Either<Failure, List<ProductPerformanceModel>>> getTopProducts(
    int limit,
    DateTime start,
    DateTime end,
  );

  Future<Either<Failure, Map<String, double>>> getDailySales(DateTime start, DateTime end);
  Future<Either<Failure, DailyReport>> getDailyReport(DateTime date);
  
  // New: Get raw session reports
  Future<Either<Failure, List<DailyReport>>> getReportsInRange(DateTime start, DateTime end);

  Future<Either<Failure, Map<int, double>>> getHourlySales(
      DateTime start, DateTime end);

  Future<Either<Failure, Map<String, double>>> getSalesByCategory(
      DateTime start, DateTime end);

  Future<Either<Failure, Map<String, double>>> getDailyTimeSeries(
      DateTime start, DateTime end);
  
  // Get report for a specific session
  Future<Either<Failure, DailyReport?>> getReportForSession(String sessionId);
  
  // Delete a report (for cleanup when session is deleted)
  Future<void> deleteReport(String reportId);
  
  // Session-specific analytics
  Future<Either<Failure, Map<int, double>>> getHourlySalesForSession(String sessionId);
  Future<Either<Failure, Map<String, double>>> getCategorySalesForSession(String sessionId);
  Future<Either<Failure, List<ProductPerformanceModel>>> getTopProductsForSession(String sessionId, int limit);
}