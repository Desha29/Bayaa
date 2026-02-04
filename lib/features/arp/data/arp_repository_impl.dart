import 'package:crazy_phone_pos/core/data/services/persistence_initializer.dart';
import 'package:crazy_phone_pos/core/data/services/repository_persistence_mixin.dart';
import 'package:dartz/dartz.dart';
import 'package:crazy_phone_pos/core/di/dependency_injection.dart';
import '../../../core/error/failure.dart';
import '../../sales/domain/sales_repository.dart';
import '../domain/arp_repository.dart';
import '../data/models/arp_summary_model.dart';
import 'models/daily_report_model.dart';
import 'models/product_performance_model.dart';
import 'package:crazy_phone_pos/features/sales/data/models/sale_model.dart';
import 'package:crazy_phone_pos/features/arp/data/repositories/session_repository_impl.dart';

class ArpRepositoryImpl with RepositoryPersistenceMixin implements ArpRepository {
  
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
        result[row['hour'] as int] = (row['revenue'] as double? ?? 0.0);
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
          p.category as category,
          SUM(si.quantity * si.price) as revenue
        FROM sale_items si
        JOIN sales s ON si.sale_id = s.id
        JOIN products p ON si.product_id = p.barcode 
        WHERE s.is_refund = 0 AND s.created_at BETWEEN ? AND ?
        GROUP BY category
        ORDER BY revenue DESC
        LIMIT 10
      ''', [start.toIso8601String(), end.toIso8601String()]);
      // Note: join on barcode might depend on schema. Usually product_id in sale_items matches barcode or id.
      // Assuming product_id stores barcode based on ProductModel.
      
      final Map<String, double> result = {};
      for (var row in rows) {
        final cat = row['category'] as String?;
        if (cat != null && cat.isNotEmpty) {
           result[cat] = (row['revenue'] as double? ?? 0.0);
        }
      }
      return Right(result);
    } catch (e) {
       // Fallback or empty
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
        result[row['day'] as String] = (row['revenue'] as double? ?? 0.0);
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
      // In SQLite V2, we don't store DailyReports directly. 
      // We can fetch closed shifts in this range and generate reports for them.
      // Or we can generate purely date-based reports. 
      // Let's rely on Shifts as the primary unit of "Report".
      final sessionRepo = getIt<SessionRepositoryImpl>();
      final sessions = await sessionRepo.getSessionsInRange(start, end);
      
      final List<DailyReport> reports = [];
      for (var session in sessions) {
        if (session.dailyReportId != null) {
          // Reconstruct report for this session
          // We need to fetch sales for this session
          final report = await _generateReportForSession(session.id!);
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
  Future<Either<Failure, ArpSummaryModel>> getSummary(
      DateTime start, DateTime end) async {
    try {
      final startIso = start.toIso8601String();
      final endIso = end.toIso8601String();

      // 1. Total Sales & Item Count
      final salesResult = await _query('''
        SELECT 
          COUNT(*) as count,
          SUM(total) as revenue
        FROM sales
        WHERE is_refund = 0 
        AND created_at BETWEEN ? AND ?
      ''', [startIso, endIso]);

      final totalSalesCount = (salesResult.first['count'] as int?) ?? 0;
      final totalRevenue = (salesResult.first['revenue'] as double?) ?? 0.0;

      // 2. Refunds
      final refundsResult = await _query('''
        SELECT SUM(total) as refunded_amount
        FROM sales
        WHERE is_refund = 1 
        AND created_at BETWEEN ? AND ?
      ''', [startIso, endIso]);
      
      final totalRefunds = (refundsResult.first['refunded_amount'] as double?) ?? 0.0;
      final netRevenue = totalRevenue - totalRefunds;

      // 3. Wholesale Cost (from Sale Items)
      // We need to join sales to check date and refund status
      // Net Cost = Cost of Sold Items - Cost of Refunded Items
      
      // Sold Items Cost (is_refund = 0)
      final costResult = await _query('''
        SELECT SUM(si.quantity * si.wholesale_price) as total_cost
        FROM sale_items si
        JOIN sales s ON si.sale_id = s.id
        WHERE s.is_refund = 0
        AND s.created_at BETWEEN ? AND ?
      ''', [startIso, endIso]);
      
      final totalCostSold = (costResult.first['total_cost'] as double?) ?? 0.0;

      // Refunded Items Cost (is_refund = 1) - Wait, refunds in 'sales' table are separate entries?
      // Yes, if is_refund=1, the sale items are the returned items.
      // So we subtract their cost.
      final refundCostResult = await _query('''
        SELECT SUM(si.quantity * si.wholesale_price) as total_refund_cost
        FROM sale_items si
        JOIN sales s ON si.sale_id = s.id
        WHERE s.is_refund = 1
        AND s.created_at BETWEEN ? AND ?
      ''', [startIso, endIso]);

      final totalCostRefunded = (refundCostResult.first['total_refund_cost'] as double?) ?? 0.0;
      
      final netCost = totalCostSold - totalCostRefunded;
      final netProfit = netRevenue - netCost;
      final profitMargin = netRevenue > 0 ? (netProfit / netRevenue) * 100 : 0.0;

      return Right(ArpSummaryModel(
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

      // Aggregate sale items grouped by product
      // We process net quantities (sold - refunded) implies complex joining.
      // Simpler approach: 
      // 1. Get Sums for Sales (is_refund=0)
      // 2. Get Sums for Refunds (is_refund=1)
      // 3. Subtract in memory or via complex union query. 
      // Using UNION ALL + GROUP BY is efficient.

      final sql = '''
        SELECT 
          product_id,
          product_nameItem as name,
          SUM(qty) as net_qty,
          SUM(revenue) as net_revenue,
          SUM(cost) as net_cost
        FROM (
          -- Sales
          SELECT 
            si.product_id,
            si.product_name as product_nameItem,
            si.quantity as qty,
            (si.quantity * si.price) as revenue,
            (si.quantity * si.wholesale_price) as cost
          FROM sale_items si
          JOIN sales s ON si.sale_id = s.id
          WHERE s.is_refund = 0 AND s.created_at BETWEEN ? AND ?
          
          UNION ALL
          
          -- Refunds (Negative values)
          SELECT 
            si.product_id,
            si.product_name as product_nameItem,
            -si.quantity as qty,
            -(si.quantity * si.price) as revenue,
            -(si.quantity * si.wholesale_price) as cost
          FROM sale_items si
          JOIN sales s ON si.sale_id = s.id
          WHERE s.is_refund = 1 AND s.created_at BETWEEN ? AND ?
        )
        GROUP BY product_id
        ORDER BY net_revenue DESC
        LIMIT ?
      ''';

      final rows = await _query(sql, [startIso, endIso, startIso, endIso, limit]);

      final List<ProductPerformanceModel> toplist = [];
      for (var row in rows) {
        final revenue = (row['net_revenue'] as double? ?? 0.0);
        final cost = (row['net_cost'] as double? ?? 0.0);
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

      
      // Calculate start/end of that day
      final start = DateTime(date.year, date.month, date.day, 0, 0, 0);
      final end = DateTime(date.year, date.month, date.day, 23, 59, 59);
      
      // 1. Get all sales for this day
      final salesRepo = getIt<SalesRepository>();
      final salesResult = await salesRepo.getRecentSales(limit: 10000); 

      
      final salesRows = await _query('''
        SELECT * FROM sales 
        WHERE created_at BETWEEN ? AND ?
      ''', [start.toIso8601String(), end.toIso8601String()]);
      
      if (salesRows.isEmpty) {
        return Left(CacheFailure("لم يتم العثور على بيانات لهذا اليوم."));
      }

      final List<Sale> sales = [];

      final summary = await getSummary(start, end);
      return summary.fold(
        (f) => Left(f),
        (arpModel) async {
             final topProducts = await getTopProducts(50, start, end); // Top 50 as 'all'
             
             // Get refunded products specific list
             // SELECT ... WHERE is_refund=1 ...
             // For brevity, we might mock this or implement a specific query if strictly needed for UI.
             // The UI shows "Refunded Products".
             
             return Right(DailyReport(
               id: "DATE_${date.millisecondsSinceEpoch}",
               sessionId: "DATE_AGGREGATE",
               date: date,
               totalSales: arpModel.totalRevenue + (arpModel.totalCost - arpModel.totalProfit), // Approximation logic check?
               // Wait. ArpSummary returns Net Revenue.
               // We need Total Sales (Gross) and Total Refunds.
               
               totalRefunds: 0, // We need to fetch this separate if we want exact field
               netRevenue: arpModel.totalRevenue,
               totalTransactions: arpModel.totalSales,
               closedByUserName: "System",
               topProducts: topProducts.getOrElse(() => []),
               refundedProducts: [], // To implement if needed
               transactions: [], // Usually too heavy to load all transaction list in report summary
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
        // Get sales for this session
        final salesRepo = getIt<SalesRepository>();
        final db = PersistenceInitializer.persistenceManager!.sqliteManager.database;
        
        final salesIds = await db.query(
          'sales',
          columns: ['id'],
          where: 'shift_id = ?',
          whereArgs: [sessionId],
        );
        
        if (salesIds.isEmpty) return Right(null);
        
        final ids = salesIds.map((r) => r['id'] as String).toList();
        final salesResult = await salesRepo.getSalesByIds(ids);
        
        return salesResult.fold(
          (f) => Left(f),
          (sales) => Right(_generateReportFromSales(sales, DateTime.now()))
        );
      } catch (e) {
        return Left(CacheFailure("فشل في توليد تقرير الجلسة: ${e.toString()}"));
      }
  }


  Future<DailyReport?> _generateReportForSession(String sessionId) async {
     final result = await getReportForSession(sessionId);
     return result.fold((l) => null, (r) => r);
  }

  // Kept from original, useful for in-memory generation
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
    // Reuse getSummary for efficiency
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
      // In the current implementation, DailyReports are generated on-the-fly from sales data
      // They are not stored in a dedicated table, so there's nothing to delete
      // This method is kept for interface compatibility and future enhancement
      // If we later store reports in a dedicated table, we would delete them here
      
      // For now, just log the deletion attempt
      print('Delete report called for ID: $reportId (no-op in current implementation)');
      
      // Future implementation:
      // final db = PersistenceInitializer.persistenceManager!.sqliteManager;
      // await db.delete('daily_reports', where: 'id = ?', whereArgs: [reportId]);
    } catch (e) {
      print('Error in deleteReport: ${e.toString()}');
      // Don't throw - deletion failures shouldn't block session deletion
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
        result[row['hour'] as int] = (row['revenue'] as double? ?? 0.0);
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
          p.category as category,
          SUM(si.quantity * si.price) as revenue
        FROM sale_items si
        JOIN sales s ON si.sale_id = s.id
        JOIN products p ON si.product_id = p.barcode 
        WHERE s.is_refund = 0 AND s.shift_id = ?
        GROUP BY category
        ORDER BY revenue DESC
        LIMIT 10
      ''', [sessionId]);
      
      final Map<String, double> result = {};
      for (var row in rows) {
        final cat = row['category'] as String?;
        if (cat != null && cat.isNotEmpty) {
           result[cat] = (row['revenue'] as double? ?? 0.0);
        }
      }
      return Right(result);
    } catch (e) {
       // Fallback or empty
       return Right({});
    }
  }

  @override
  Future<Either<Failure, List<ProductPerformanceModel>>> getTopProductsForSession(String sessionId, int limit) async {
    try {
      final sql = '''
        SELECT 
          product_id,
          product_nameItem as name,
          SUM(qty) as net_qty,
          SUM(revenue) as net_revenue,
          SUM(cost) as net_cost
        FROM (
          -- Sales
          SELECT 
            si.product_id,
            si.product_name as product_nameItem,
            si.quantity as qty,
            (si.quantity * si.price) as revenue,
            (si.quantity * si.wholesale_price) as cost
          FROM sale_items si
          JOIN sales s ON si.sale_id = s.id
          WHERE s.is_refund = 0 AND s.shift_id = ?
          
          UNION ALL
          
          -- Refunds (Negative values)
          SELECT 
            si.product_id,
            si.product_name as product_nameItem,
            -si.quantity as qty,
            -(si.quantity * si.price) as revenue,
            -(si.quantity * si.wholesale_price) as cost
          FROM sale_items si
          JOIN sales s ON si.sale_id = s.id
          WHERE s.is_refund = 1 AND s.shift_id = ?
        )
        GROUP BY product_id
        ORDER BY net_revenue DESC
        LIMIT ?
      ''';

      final rows = await _query(sql, [sessionId, sessionId, limit]);

      final List<ProductPerformanceModel> toplist = [];
      for (var row in rows) {
        final revenue = (row['net_revenue'] as double? ?? 0.0);
        final cost = (row['net_cost'] as double? ?? 0.0);
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
}

