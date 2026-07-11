// lib/features/analytics/data/analytics_repository_impl.dart

import 'package:bayaa_pos/core/data/services/persistence_initializer.dart';
import 'package:bayaa_pos/core/data/services/repository_persistence_mixin.dart';
import 'package:dartz/dartz.dart';
import 'package:bayaa_pos/core/di/dependency_injection.dart';
import '../../../core/error/failure.dart';
import '../../sales/domain/sales_repository.dart';
import '../domain/analytics_repository.dart';
import 'models/analytics_summary_model.dart';
import '../../sessions/data/models/daily_report_model.dart';
import '../../sessions/data/models/product_performance_model.dart';
import 'package:bayaa_pos/features/sales/data/models/sale_model.dart';

import '../../sessions/data/repositories/session_repository_impl.dart';

class AnalyticsRepositoryImpl with RepositoryPersistenceMixin implements AnalyticsRepository {
  
  // Helper to access DB
  Future<List<Map<String, dynamic>>> _query(String sql, [List<Object?>? args]) async {
    final db = PersistenceInitializer.persistenceManager!.sqliteManager.database;
    return await db.rawQuery(sql, args);
  }

  @override
  Future<Either<Failure, Map<int, double>>> getHourlySales(DateTime start, DateTime end) async {
    try {
      final rows = await _query('''
        SELECT 
          CAST(strftime('%H', created_at) AS INTEGER) as hour,
          SUM(total) as revenue
        FROM sales
        WHERE is_refund = 0 AND created_at BETWEEN ? AND ?
        GROUP BY hour
        ORDER BY hour ASC
      ''', [start.toIso8601String(), end.toIso8601String()]);

      final Map<int, double> result = {};
      for (var row in rows) {
        result[row['hour'] as int] = (row['revenue'] as num?)?.toDouble() ?? 0.0;
      }
      return Right(result);
    } catch (e) {
      return Left(CacheFailure("فشل في جلب المبيعات بالساعة"));
    }
  }

  @override
  Future<Either<Failure, Map<String, double>>> getSalesByCategory(DateTime start, DateTime end) async {
    try {
      final rows = await _query('''
        SELECT 
          p.category_id as category,
          SUM(si.quantity * si.price) as revenue
        FROM sale_items si
        JOIN sales s ON si.sale_id = s.id
        JOIN products p ON si.product_id = p.barcode 
        WHERE s.is_refund = 0 AND s.created_at BETWEEN ? AND ?
        GROUP BY p.category_id
        ORDER BY revenue DESC
        LIMIT 10
      ''', [start.toIso8601String(), end.toIso8601String()]);
      
      final Map<String, double> result = {};
      for (var row in rows) {
        final cat = row['category'] as String?;
        if (cat != null && cat.isNotEmpty) {
           result[cat] = (row['revenue'] as num?)?.toDouble() ?? 0.0;
        }
      }
      return Right(result);
    } catch (e) {
       return Right({});
    }
  }

  @override
  Future<Either<Failure, Map<String, double>>> getDailyTimeSeries(DateTime start, DateTime end) async {
    try {
       final rows = await _query('''
        SELECT 
          date(created_at) as day,
          SUM(total) as revenue
        FROM sales
        WHERE is_refund = 0 AND created_at BETWEEN ? AND ?
        GROUP BY day
        ORDER BY day ASC
      ''', [start.toIso8601String(), end.toIso8601String()]);

      final Map<String, double> result = {};
      for (var row in rows) {
        result[row['day'] as String] = (row['revenue'] as num?)?.toDouble() ?? 0.0;
      }
      return Right(result);
    } catch (e) {
      return Left(CacheFailure("فشل في جلب التسلسل الزمني للمبيعات"));
    }
  }

  @override
  Future<Either<Failure, List<DailyReport>>> getReportsInRange(
      DateTime start, DateTime end) async {
    try {
      final sessionRepo = getIt<SessionRepositoryImpl>();
      final sessions = await sessionRepo.getSessionsInRange(start, end);
      
      final List<DailyReport> reports = [];
      for (var session in sessions) {
        if (session.dailyReportId != null) {
          final report = await _generateReportForSession(session.id);
          if (report != null) {
            reports.add(report);
          }
        }
      }
      return Right(reports);
    } catch (e) {
      return Left(CacheFailure('فشل في جلب التقارير: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, AnalyticsSummaryModel>> getSummary(
      DateTime start, DateTime end) async {
    try {
      final startIso = start.toIso8601String();
      final endIso = end.toIso8601String();

      // 1. Total Sales Count, Gross Revenue & Refunded Amount in a single query
      final salesResult = await _query('''
        SELECT 
          COUNT(CASE WHEN is_refund = 0 THEN 1 END) as sales_count,
          SUM(CASE WHEN is_refund = 0 THEN total ELSE 0.0 END) as gross_revenue,
          SUM(CASE WHEN is_refund = 1 THEN total ELSE 0.0 END) as refunded_amount
        FROM sales
        WHERE created_at BETWEEN ? AND ?
      ''', [startIso, endIso]);

      final totalSalesCount = (salesResult.first['sales_count'] as int?) ?? 0;
      final totalRevenue = (salesResult.first['gross_revenue'] as num?)?.toDouble() ?? 0.0;
      final totalRefunds = (salesResult.first['refunded_amount'] as num?)?.toDouble() ?? 0.0;
      final netRevenue = totalRevenue - totalRefunds;

      // 2. Wholesale Cost for both sales and refunds in a single query
      final costResult = await _query('''
        SELECT 
          SUM(CASE WHEN s.is_refund = 0 THEN si.quantity * si.wholesale_price ELSE 0.0 END) as total_cost_sold,
          SUM(CASE WHEN s.is_refund = 1 THEN si.quantity * si.wholesale_price ELSE 0.0 END) as total_cost_refunded
        FROM sale_items si
        JOIN sales s ON si.sale_id = s.id
        WHERE s.created_at BETWEEN ? AND ?
      ''', [startIso, endIso]);
      
      final totalCostSold = (costResult.first['total_cost_sold'] as num?)?.toDouble() ?? 0.0;
      final totalCostRefunded = (costResult.first['total_cost_refunded'] as num?)?.toDouble() ?? 0.0;
      
      final netCost = totalCostSold - totalCostRefunded;
      final netProfit = netRevenue - netCost;
      final profitMargin = netRevenue > 0 ? (netProfit / netRevenue) * 100 : 0.0;

      return Right(AnalyticsSummaryModel(
        startDate: start,
        endDate: end,
        totalRevenue: netRevenue,
        totalCost: netCost,
        totalProfit: netProfit,
        profitMargin: profitMargin,
        totalSales: totalSalesCount,
        grossRevenue: totalRevenue,
        refundedAmount: totalRefunds,
      ));
    } catch (e) {
      return Left(CacheFailure("خطأ في تحميل ملخص الجلسات: ${e.toString()}"));
    }
  }

  @override
  Future<Either<Failure, List<ProductPerformanceModel>>> getTopProducts(
      int limit, DateTime start, DateTime end) async {
    try {
      final startIso = start.toIso8601String();
      final endIso = end.toIso8601String();

      final sql = '''
        SELECT 
          si.product_id,
          MAX(si.product_name) as name,
          SUM(CASE WHEN s.is_refund = 0 THEN si.quantity ELSE -si.quantity END) as net_qty,
          SUM(CASE WHEN s.is_refund = 0 THEN si.quantity * si.price ELSE -(si.quantity * si.price) END) as net_revenue,
          SUM(CASE WHEN s.is_refund = 0 THEN si.quantity * si.wholesale_price ELSE -(si.quantity * si.wholesale_price) END) as net_cost
        FROM sale_items si
        JOIN sales s ON si.sale_id = s.id
        WHERE s.created_at BETWEEN ? AND ?
        GROUP BY si.product_id
        ORDER BY net_revenue DESC
        LIMIT ?
      ''';

      final rows = await _query(sql, [startIso, endIso, limit]);

      final List<ProductPerformanceModel> toplist = [];
      for (var row in rows) {
        final revenue = (row['net_revenue'] as num?)?.toDouble() ?? 0.0;
        final cost = (row['net_cost'] as num?)?.toDouble() ?? 0.0;
        final profit = revenue - cost;
        final margin = revenue > 0 ? (profit / revenue) * 100 : 0.0;

        toplist.add(ProductPerformanceModel(
          productId: row['product_id'] as String,
          productName: row['name'] as String,
          quantitySold: (row['net_qty'] as num? ?? 0).toInt(),
          revenue: revenue,
          cost: cost,
          profit: profit,
          profitMargin: margin,
        ));
      }

      return Right(toplist);
    } catch (e) {
      return Left(CacheFailure("خطأ في تحميل المنتجات: ${e.toString()}"));
    }
  }

  @override
  Future<Either<Failure, DailyReport>> getDailyReport(DateTime date) async {
    try {
      final start = DateTime(date.year, date.month, date.day, 0, 0, 0);
      final end = DateTime(date.year, date.month, date.day, 23, 59, 59);
      
      final salesRepo = getIt<SalesRepository>();
      await salesRepo.getRecentSales(limit: 10000); 

      final salesRows = await _query('''
        SELECT * FROM sales 
        WHERE created_at BETWEEN ? AND ?
      ''', [start.toIso8601String(), end.toIso8601String()]);
      
      if (salesRows.isEmpty) {
        return Left(CacheFailure("لم يتم العثور على بيانات لهذا اليوم."));
      }

      final summary = await getSummary(start, end);
      return summary.fold(
        (f) => Left(f),
        (analyticsModel) async {
             final topProducts = await getTopProducts(50, start, end);
             
             return Right(DailyReport(
               id: "DATE_${date.millisecondsSinceEpoch}",
               sessionId: "DATE_AGGREGATE",
               date: date,
               totalSales: analyticsModel.totalRevenue + (analyticsModel.totalCost - analyticsModel.totalProfit),
               totalRefunds: 0,
               netRevenue: analyticsModel.totalRevenue,
               totalTransactions: analyticsModel.totalSales,
               closedByUserName: "System",
               topProducts: topProducts.getOrElse(() => []),
               refundedProducts: [],
               transactions: [],
             ));
        }
      );
    } catch (e) {
      return Left(CacheFailure("خطأ في جلب التقرير اليومي: ${e.toString()}"));
    }
  }

  @override
  Future<Either<Failure, DailyReport?>> getReportForSession(String sessionId) async {
      try {
        final salesRepo = getIt<SalesRepository>();
        final db = PersistenceInitializer.persistenceManager!.sqliteManager.database;
        
        final salesIds = await db.query(
          'sales',
          columns: ['id'],
          where: 'shift_id = ?',
          whereArgs: [sessionId],
        );
        
        if (salesIds.isEmpty) {
          return Right(DailyReport(
            id: 'EMPTY_$sessionId',
            sessionId: sessionId,
            date: DateTime.now(),
            totalSales: 0,
            totalRefunds: 0,
            netRevenue: 0,
            totalTransactions: 0,
            closedByUserName: 'System',
            topProducts: [],
            transactions: [],
            refundedProducts: [],
          ));
        }
        
        final ids = salesIds.map((r) => r['id'] as String).toList();
        final salesResult = await salesRepo.getSalesByIds(ids);
        
        return salesResult.fold(
          (f) => Left(f),
          (sales) => Right(_generateReportFromSales(sales, DateTime.now()))
        );
      } catch (e) {
        return Left(CacheFailure("فشل في تقرير تقرير الجلسة: ${e.toString()}"));
      }
  }

  Future<DailyReport?> _generateReportForSession(String sessionId) async {
     final result = await getReportForSession(sessionId);
     return result.fold((l) => null, (r) => r);
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
              cost: 0, 
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

    return DailyReport(
      id: "SESSION_REP",
      sessionId: "SESSION",
      date: date,
      totalSales: totalSales,
      totalRefunds: totalRefunds,
      netRevenue: totalSales - totalRefunds,
      totalTransactions: sales.length,
      closedByUserName: "System",
      topProducts: topProducts,
      refundedProducts: refundStats.values.toList(),
      transactions: sales,
    );
  }

  @override
  Future<Either<Failure, Map<String, double>>> getDailySales(
      DateTime start, DateTime end) async {
    final result = await getSummary(start, end);
    return result.fold(
      (f) => Left(f),
      (summary) => Right({
        'اجمالي المبيعات': summary.totalRevenue,
        'التكلفة الكلية': summary.totalCost,
        'صافي الربح': summary.totalProfit,
      })
    );
  }

  @override
  Future<void> deleteReport(String reportId) async {
    try {
      print('Delete report called for ID: $reportId (no-op in current implementation)');
    } catch (e) {
      print('Error in deleteReport: ${e.toString()}');
    }
  }

  @override
  Future<Either<Failure, Map<int, double>>> getHourlySalesForSession(String sessionId) async {
    try {
      final rows = await _query('''
        SELECT 
          CAST(strftime('%H', created_at) AS INTEGER) as hour,
          SUM(total) as revenue
        FROM sales
        WHERE is_refund = 0 AND shift_id = ?
        GROUP BY hour
        ORDER BY hour ASC
      ''', [sessionId]);

      final Map<int, double> result = {};
      for (var row in rows) {
        result[row['hour'] as int] = (row['revenue'] as num?)?.toDouble() ?? 0.0;
      }
      return Right(result);
    } catch (e) {
      return Left(CacheFailure("فشل في جلب المبيعات بالساعة للجلسة: ${e.toString()}"));
    }
  }

  @override
  Future<Either<Failure, Map<String, double>>> getCategorySalesForSession(String sessionId) async {
    try {
      final rows = await _query('''
        SELECT 
          p.category_id as category,
          SUM(si.quantity * si.price) as revenue
        FROM sale_items si
        JOIN sales s ON si.sale_id = s.id
        JOIN products p ON si.product_id = p.barcode 
        WHERE s.is_refund = 0 AND s.shift_id = ?
        GROUP BY p.category_id
        ORDER BY revenue DESC
        LIMIT 10
      ''', [sessionId]);
      
      final Map<String, double> result = {};
      for (var row in rows) {
        final cat = row['category'] as String?;
        if (cat != null && cat.isNotEmpty) {
           result[cat] = (row['revenue'] as num?)?.toDouble() ?? 0.0;
        }
      }
      return Right(result);
    } catch (e) {
       return Right({});
    }
  }

  @override
  Future<Either<Failure, List<ProductPerformanceModel>>> getTopProductsForSession(String sessionId, int limit) async {
    try {
      final sql = '''
        SELECT 
          si.product_id,
          MAX(si.product_name) as name,
          SUM(CASE WHEN s.is_refund = 0 THEN si.quantity ELSE -si.quantity END) as net_qty,
          SUM(CASE WHEN s.is_refund = 0 THEN si.quantity * si.price ELSE -(si.quantity * si.price) END) as net_revenue,
          SUM(CASE WHEN s.is_refund = 0 THEN si.quantity * si.wholesale_price ELSE -(si.quantity * si.wholesale_price) END) as net_cost
        FROM sale_items si
        JOIN sales s ON si.sale_id = s.id
        WHERE s.shift_id = ?
        GROUP BY si.product_id
        ORDER BY net_revenue DESC
        LIMIT ?
      ''';

      final rows = await _query(sql, [sessionId, limit]);

      final List<ProductPerformanceModel> toplist = [];
      for (var row in rows) {
        final revenue = (row['net_revenue'] as num?)?.toDouble() ?? 0.0;
        final cost = (row['net_cost'] as num?)?.toDouble() ?? 0.0;
        final profit = revenue - cost;
        final margin = revenue > 0 ? (profit / revenue) * 100 : 0.0;

        toplist.add(ProductPerformanceModel(
          productId: row['product_id'] as String,
          productName: row['name'] as String,
          quantitySold: (row['net_qty'] as num? ?? 0).toInt(),
          revenue: revenue,
          cost: cost,
          profit: profit,
          profitMargin: margin,
        ));
      }

      return Right(toplist);
    } catch (e) {
      return Left(CacheFailure("خطأ في تحميل المنتجات للجلسة: ${e.toString()}"));
    }
  }

  @override
  Future<Either<Failure, Map<String, double>>> getMonthlySales(DateTime start, DateTime end) async {
    try {
      final rows = await _query('''
        SELECT 
          strftime('%Y-%m', created_at) as month,
          SUM(CASE WHEN is_refund = 0 THEN total ELSE -total END) as net_revenue
        FROM sales
        WHERE created_at BETWEEN ? AND ?
        GROUP BY month
        ORDER BY month ASC
      ''', [start.toIso8601String(), end.toIso8601String()]);

      final Map<String, double> result = {};
      for (var row in rows) {
        final value = (row['net_revenue'] as num?)?.toDouble() ?? 0.0;
        if (value > 0) {
          result[row['month'] as String] = value;
        }
      }
      return Right(result);
    } catch (e) {
      return Left(CacheFailure("فشل في جلب المبيعات الشهرية"));
    }
  }

  @override
  Future<Either<Failure, Map<String, double>>> getYearlySales(DateTime start, DateTime end) async {
    try {
      final rows = await _query('''
        SELECT 
          strftime('%Y', created_at) as year,
          SUM(CASE WHEN is_refund = 0 THEN total ELSE -total END) as net_revenue
        FROM sales
        WHERE created_at BETWEEN ? AND ?
        GROUP BY year
        ORDER BY year ASC
      ''', [start.toIso8601String(), end.toIso8601String()]);

      final Map<String, double> result = {};
      for (var row in rows) {
        final value = (row['net_revenue'] as num?)?.toDouble() ?? 0.0;
        if (value > 0) {
          result[row['year'] as String] = value;
        }
      }
      return Right(result);
    } catch (e) {
      return Left(CacheFailure("فشل في جلب المبيعات السنوية"));
    }
  }

  @override
  Future<Either<Failure, List<ProductPerformanceModel>>> getTopProductsForMonth(String yearMonth, int limit) async {
    try {
      final rows = await _query('''
        SELECT 
          si.product_id,
          si.product_name,
          SUM(si.quantity) as qty,
          SUM(si.subtotal) as revenue,
          COALESCE(SUM(si.wholesale_price * si.quantity), 0) as cost
        FROM sale_items si
        JOIN sales s ON si.sale_id = s.id
        WHERE s.is_refund = 0 AND strftime('%Y-%m', s.created_at) = ?
        GROUP BY si.product_id
        ORDER BY revenue DESC
        LIMIT ?
      ''', [yearMonth, limit]);

      final products = rows.map((row) {
        final revenue = (row['revenue'] as num?)?.toDouble() ?? 0.0;
        final cost = (row['cost'] as num?)?.toDouble() ?? 0.0;
        final profit = revenue - cost;
        return ProductPerformanceModel(
          productId: row['product_id'] as String,
          productName: row['product_name'] as String,
          quantitySold: (row['qty'] as num?)?.toInt() ?? 0,
          revenue: revenue,
          cost: cost,
          profit: profit,
          profitMargin: revenue > 0 ? (profit / revenue) * 100 : 0,
        );
      }).toList();

      return Right(products);
    } catch (e) {
      return Left(CacheFailure("فشل في جلب منتجات الشهر"));
    }
  }
}
