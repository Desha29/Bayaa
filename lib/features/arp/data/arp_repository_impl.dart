import 'package:dartz/dartz.dart';
import 'package:crazy_phone_pos/core/di/dependency_injection.dart';
import 'package:crazy_phone_pos/core/utils/hive_helper.dart'; 
import '../../../core/error/failure.dart';
import '../../sales/domain/sales_repository.dart';
import '../domain/arp_repository.dart';
import '../data/models/arp_summary_model.dart';
import 'models/daily_report_model.dart';
import 'models/product_performance_model.dart';
import 'package:crazy_phone_pos/features/sales/data/models/sale_model.dart';
import 'package:crazy_phone_pos/features/arp/data/repositories/session_repository_impl.dart';

class ArpRepositoryImpl implements ArpRepository {
  // We access Hive boxes directly via HiveHelper for simplicity and efficiency
  // matching the pattern in SessionRepositoryImpl

  @override
  Future<Either<Failure, List<DailyReport>>> getReportsInRange(
      DateTime start, DateTime end) async {
    try {
      final box = HiveHelper.dailyReportBox;
      final reports = box.values.where((r) {
        return !r.date.isBefore(start) && !r.date.isAfter(end);
      }).toList();
      return Right(reports);
    } catch (e) {
      return Left(CacheFailure('فشل في جلب التقارير: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ArpSummaryModel>> getSummary(
      DateTime start, DateTime end) async {
    try {
      final box = HiveHelper.dailyReportBox;
      final reports = box.values.where((r) {
         // Effective range filter
         return r.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
                r.date.isBefore(end.add(const Duration(seconds: 1)));
      }).toList();

      double totalRevenue = 0.0;
      double totalCost = 0.0;
      int totalSalesCount = 0;

      for (var report in reports) {
        totalRevenue += report.netRevenue; 
        totalSalesCount += report.totalTransactions;
        
        // Calculate cost from topProducts snapshot
        // If topProducts is comprehensive, this is accurate.
        // If topProducts is limited (e.g. top 10), this is WRONG.
        // BUT, SessionRepository closeSession saves ALL products stats in `productStats` then sorts.
        // Let's check session closing logic... 
        // In UserCubit.closeSession, it maps ALL `productStats` to `topProducts` list.
        // It does NOT limit them. It sorts them.
        // So `topProducts` in DailyReport actually contains ALL products sold in that session.
        for (var p in report.topProducts) {
           totalCost += p.cost;
        }
      }

      final profit = totalRevenue - totalCost;
      final profitMargin =
          totalRevenue > 0 ? (profit / totalRevenue) * 100 : 0.0;

      return Right(ArpSummaryModel(
        startDate: start,
        endDate: end,
        totalRevenue: totalRevenue,
        totalCost: totalCost,
        totalProfit: profit,
        profitMargin: profitMargin,
        totalSales: totalSalesCount,
      ));
    } catch (e) {
      return Left(CacheFailure("خطأ في تحميل ملخص الجلسات: ${e.toString()}"));
    }
  }

  @override
  Future<Either<Failure, List<ProductPerformanceModel>>> getTopProducts(
      int limit, DateTime start, DateTime end) async {
    try {
      final reportsResult = await getReportsInRange(start, end);
      return reportsResult.fold(
        (f) => Left(f),
        (reports) {
          final Map<String, ProductPerformanceModel> aggregated = {};

          for (var r in reports) {
            for (var p in r.topProducts) {
              if (aggregated.containsKey(p.productId)) {
                final ex = aggregated[p.productId]!;
                aggregated[p.productId] = ex.copyWith(
                  quantitySold: ex.quantitySold + p.quantitySold,
                  revenue: ex.revenue + p.revenue,
                  cost: ex.cost + p.cost,
                  profit: ex.profit + p.profit,
                  // margin recalc later
                );
              } else {
                aggregated[p.productId] = p;
              }
            }
          }

          final list = aggregated.values.map((p) {
             final margin = p.revenue > 0 ? (p.profit / p.revenue) * 100 : 0.0;
             return p.copyWith(profitMargin: margin);
          }).toList();

          list.sort((a, b) => b.revenue.compareTo(a.revenue));
          return Right(list.take(limit).toList());
        },
      );
    } catch (e) {
      return Left(CacheFailure("خطأ في تحميل المنتجات: ${e.toString()}"));
    }
  }

  @override
  Future<Either<Failure, DailyReport>> getDailyReport(DateTime date) async {
    try {
      final box = HiveHelper.dailyReportBox;

      // 1. Closed Reports (from History)
      final closedReports = box.values.where((r) =>
          r != null &&
          r.date.year == date.year &&
          r.date.month == date.month &&
          r.date.day == date.day
      ).cast<DailyReport>().toList();

      // 2. Open Session Report (Real-time Calculation)
      DailyReport? openReport;
      if (_isSameDay(date, DateTime.now())) {
        openReport = await _calculateOpenSessionReport();
      }

      // 3. Combine
      final allReports = [...closedReports];
      if (openReport != null) {
        allReports.add(openReport);
      }

      if (allReports.isEmpty) {
        return Left(CacheFailure("لم يتم العثور على بيانات لهذا اليوم."));
      }

      // 4. Merge into Single Report
      return Right(_mergeReports(allReports, date));
    } catch (e) {
      return Left(CacheFailure("خطأ في جلب التقرير اليومي: ${e.toString()}"));
    }
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Future<DailyReport?> _calculateOpenSessionReport() async {
    try {
      final sessionRepo = getIt<SessionRepositoryImpl>();
      final salesRepo = getIt<SalesRepository>();
      
      final session = sessionRepo.getCurrentSession();
      if (session == null || !session.isOpen) return null;

     
      final salesResult = await salesRepo.getRecentSales(limit: 10000); 
      final allSales = salesResult.getOrElse(() => []);
      
      final sessionSales = allSales.where((s) {
        if (s.sessionId == session.id) return true;
        // Orphan check
        if (s.sessionId == null && s.date.isAfter(session.openTime)) return true;
        return false;
      }).toList();

      if (sessionSales.isEmpty) return null;

      return _generateReportFromSales(sessionSales, DateTime.now());
    } catch (e) {
      // If error (e.g. deps not ready), return null to degrade gracefully
      return null;
    }
  }

  DailyReport _generateReportFromSales(List<Sale> sales, DateTime date) {
    double totalSales = 0.0;
    double totalRefunds = 0.0;
    final Map<String, ProductPerformanceModel> productStats = {};
    final Map<String, ProductPerformanceModel> refundStats = {};

    for (final sale in sales) {
      final isRefund = sale.isRefund;
      final sign = isRefund ? -1.0 : 1.0;

      if (isRefund) {
        totalRefunds += sale.total.abs();
      } else {
        totalSales += sale.total;
      }

      for (final item in sale.saleItems) {
        final revenue = (item.price * item.quantity) * sign;
        final cost = (item.wholesalePrice * item.quantity) * sign;
        final qty = item.quantity * (isRefund ? -1 : 1);

        // General Stats (Net)
        if (productStats.containsKey(item.productId)) {
          final existing = productStats[item.productId]!;
          productStats[item.productId] = existing.copyWith(
            quantitySold: (existing.quantitySold + qty).toInt(),
            revenue: existing.revenue + revenue,
            cost: existing.cost + cost,
          );
        } else {
          productStats[item.productId] = ProductPerformanceModel(
            productId: item.productId,
            productName: item.name,
            quantitySold: qty,
            revenue: revenue,
            cost: cost,
            profit: 0,
            profitMargin: 0,
          );
        }

        // Refund Specific Stats
        if (isRefund) {
          if (refundStats.containsKey(item.productId)) {
            final existing = refundStats[item.productId]!;
            refundStats[item.productId] = existing.copyWith(
              quantitySold: (existing.quantitySold + item.quantity).toInt(),
              revenue: existing.revenue + item.total,
            );
          } else {
            refundStats[item.productId] = ProductPerformanceModel(
              productId: item.productId,
              productName: item.name,
              quantitySold: item.quantity,
              revenue: item.total,
              cost: 0, // Not relevant for refund list display usually
              profit: 0,
              profitMargin: 0,
            );
          }
        }
      }
    }

    final topProducts = productStats.values.map((p) {
        final profit = p.revenue - p.cost;
        final margin = p.revenue > 0 ? (profit / p.revenue) * 100 : 0.0;
        return p.copyWith(profit: profit, profitMargin: margin);
    }).toList()..sort((a, b) => b.revenue.compareTo(a.revenue));

    // Note: Temporary ID for open report
    return DailyReport(
      id: "OPEN_SESSION",
      sessionId: "OPEN",
      date: date,
      totalSales: totalSales,
      totalRefunds: totalRefunds,
      netRevenue: totalSales - totalRefunds,
      totalTransactions: sales.length,
      closedByUserName: "Open Session",
      topProducts: topProducts,
      refundedProducts: refundStats.values.toList(),
      transactions: sales,
    );
  }

  DailyReport _mergeReports(List<DailyReport> reports, DateTime date) {
    if (reports.length == 1) return reports.first;

    double totalSales = 0.0;
    double totalRefunds = 0.0;
    double netRevenue = 0.0;
    int totalTransactions = 0;
    
    final Map<String, ProductPerformanceModel> productStats = {};
    final Map<String, ProductPerformanceModel> refundStats = {};

    for (var r in reports) {
      totalSales += r.totalSales;
      totalRefunds += r.totalRefunds;
      netRevenue += r.netRevenue;
      totalTransactions += r.totalTransactions;

      for (var p in r.topProducts) {
        if (productStats.containsKey(p.productId)) {
          final ex = productStats[p.productId]!;
          productStats[p.productId] = ex.copyWith(
            quantitySold: ex.quantitySold + p.quantitySold,
            revenue: ex.revenue + p.revenue,
            cost: ex.cost + p.cost,
          );
        } else {
          productStats[p.productId] = p;
        }
      }

      for (var p in r.refundedProducts) {
        if (refundStats.containsKey(p.productId)) {
          final ex = refundStats[p.productId]!;
          refundStats[p.productId] = ex.copyWith(
             quantitySold: ex.quantitySold + p.quantitySold,
             revenue: ex.revenue + p.revenue,
          );
        } else {
          refundStats[p.productId] = p;
        }
      }
    }

    final topProducts = productStats.values.map((p) {
        final profit = p.revenue - p.cost;
        final margin = p.revenue > 0 ? (profit / p.revenue) * 100 : 0.0;
        return p.copyWith(profit: profit, profitMargin: margin);
    }).toList()..sort((a, b) => b.revenue.compareTo(a.revenue));

    return DailyReport(
      id: "AGGREGATED_${date.millisecondsSinceEpoch}",
      sessionId: "AGGREGATED",
      date: date,
      totalSales: totalSales,
      totalRefunds: totalRefunds,
      netRevenue: netRevenue,
      totalTransactions: totalTransactions,
      closedByUserName: "Multiple",
      topProducts: topProducts,
      refundedProducts: refundStats.values.toList(),
      transactions: reports.expand((r) => r.transactions).toList(),
    );
  }

  @override
  Future<Either<Failure, Map<String, double>>> getDailySales(
      DateTime start, DateTime end) async {
    try {
      final reportsResult = await getReportsInRange(start, end);
      return reportsResult.fold(
        (f) => Left(f),
        (reports) {
           double totalRevenue = 0.0;
           double totalCost = 0.0;
           
           for(var r in reports) {
             totalRevenue += r.netRevenue;
             for(var p in r.topProducts) {
               totalCost += p.cost;
             }
           }
           final profit = totalRevenue - totalCost;

           return Right({
            'اجمالي المبيعات': totalRevenue,
            'التكلفة الكلية': totalCost,
            'صافي الربح': profit,
          });
        }
      );
    } catch (e) {
      return Left(CacheFailure("خطأ في تحميل مبيعات الجلسات: ${e.toString()}"));
    }
  }
}
