import 'package:dartz/dartz.dart';

import '../../../core/error/failure.dart';
import '../../sales/domain/sales_repository.dart';
import '../domain/arp_repository.dart';
import '../data/models/arp_summary_model.dart';

import 'models/dialy_report_model.dart';
import 'models/product_performance_model.dart';

class ArpRepositoryImpl implements ArpRepository {
  final SalesRepository salesRepository;

  ArpRepositoryImpl({required this.salesRepository});

  @override
  Future<Either<Failure, ArpSummaryModel>> getSummary(
      DateTime start, DateTime end) async {
    try {
      final salesResult = await salesRepository.getRecentSales(limit: 10000);
      return salesResult.fold(
        (failure) => Left(failure),
        (sales) {
          final filteredSales = sales
              .where((sale) =>
                  sale.date.isAfter(start.subtract(const Duration(days: 1))) &&
                  sale.date.isBefore(end.add(const Duration(days: 1))))
              .toList();

          double totalRevenue = 0.0;
          double totalCost = 0.0;

          for (var sale in filteredSales) {
            totalRevenue += sale.total;
            for (var item in sale.saleItems) {
              final wholesalePrice = item.wholesalePrice;
              totalCost += wholesalePrice * item.quantity;
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
            totalSales: filteredSales.length,
          ));
        },
      );
    } catch (e) {
      return Left(CacheFailure(":خطأ في تحميل الملخص]: ${e.toString()}"));
    }
  }

  @override
  Future<Either<Failure, List<ProductPerformanceModel>>> getTopProducts(
      int limit, DateTime start, DateTime end) async {
    try {
      final salesResult = await salesRepository.getRecentSales(
        limit: 10000,
        startDate: start,
        endDate: end,
      );
      return salesResult.fold(
        (failure) => Left(failure),
        (sales) {
          final Map<String, ProductPerformanceModel> productStats = {};

          for (var sale in sales) {
            for (var item in sale.saleItems) {
              final wholesalePrice = item.wholesalePrice;
              final revenue = (item.price) * item.quantity;

              if (productStats.containsKey(item.name)) {
                final existing = productStats[item.name]!;
                productStats[item.name] = existing.copyWith(
                  quantitySold: existing.quantitySold + item.quantity,
                  revenue: existing.revenue + revenue,
                  cost: existing.cost + (wholesalePrice * item.quantity),
                );
              } else {
                productStats[item.name] = ProductPerformanceModel(
                  productId: item.productId,
                  productName: item.name,
                  quantitySold: item.quantity,
                  revenue: revenue,
                  cost: wholesalePrice * item.quantity,
                  profit: 0.0,
                  profitMargin: 0.0,
                );
              }
            }
          }

          final products = productStats.values.map((p) {
            final profit = p.revenue - p.cost;
            final margin = p.revenue > 0 ? (profit / p.revenue) * 100 : 0.0;
            return p.copyWith(profit: profit, profitMargin: margin);
          }).toList();

          products.sort((a, b) => b.revenue.compareTo(a.revenue));
          return Right(products.take(limit).toList());
        },
      );
    } catch (e) {
      return Left(CacheFailure("خطأ في تحميل أفضل المنتجات ${e.toString()}"));
    }
  }

  Future<Either<Failure, DailyReportModel>> getDailyReport(
      DateTime date) async {
    try {
      final salesResult = await salesRepository.getRecentSales(limit: 10000);
      return salesResult.fold(
        (failure) => Left(failure),
        (sales) {
          final filteredSales = sales
              .where((sale) =>
                  sale.date.year == date.year &&
                  sale.date.month == date.month &&
                  sale.date.day == date.day)
              .toList();

          double totalRevenue = 0.0;
          double totalCost = 0.0;
          final Map<String, ProductPerformanceModel> productStats = {};

          for (var sale in filteredSales) {
            totalRevenue += sale.total;
            for (var item in sale.saleItems) {
              final wholesalePrice = item.wholesalePrice;
              final revenue = (item.price) * item.quantity;
              final cost = wholesalePrice * item.quantity;
              totalCost += cost;

              if (productStats.containsKey(item.name)) {
                final existing = productStats[item.name]!;
                productStats[item.name] = existing.copyWith(
                  quantitySold: existing.quantitySold + item.quantity,
                  revenue: existing.revenue + revenue,
                  cost: existing.cost + cost,
                );
              } else {
                productStats[item.name] = ProductPerformanceModel(
                  productId: item.productId,
                  productName: item.name,
                  quantitySold: item.quantity,
                  revenue: revenue,
                  cost: cost,
                  profit: 0.0,
                  profitMargin: 0.0,
                );
              }
            }
          }

          final profit = totalRevenue - totalCost;
          final profitMargin =
              totalRevenue > 0 ? (profit / totalRevenue) * 100 : 0.0;

          final topProducts = productStats.values.map((p) {
            final profit = p.revenue - p.cost;
            final margin = p.revenue > 0 ? (profit / p.revenue) * 100 : 0.0;
            return p.copyWith(profit: profit, profitMargin: margin);
          }).toList();

          topProducts.sort((a, b) => b.revenue.compareTo(a.revenue));

          return Right(DailyReportModel(
            date: date,
            totalRevenue: totalRevenue,
            totalCost: totalCost,
            totalProfit: profit,
            profitMargin: profitMargin,
            topProducts: topProducts,
          ));
        },
      );
    } catch (e) {
      return Left(CacheFailure("خطأ في تحميل التقرير اليومي: ${e.toString()}"));
    }
  }

  @override
  Future<Either<Failure, Map<String, double>>> getDailySales(
      DateTime start, DateTime end) async {
    try {
      final salesResult = await salesRepository.getRecentSales(limit: 10000);
      return salesResult.fold(
        (failure) => Left(failure),
        (sales) {
          final filteredSales = sales
              .where((sale) =>
                  sale.date.isAfter(start.subtract(const Duration(days: 1))) &&
                  sale.date.isBefore(end.add(const Duration(days: 1))))
              .toList();

          double totalRevenue = 0.0;
          double totalCost = 0.0;

          for (var sale in filteredSales) {
            totalRevenue += sale.total;
            for (var item in sale.saleItems) {
              final wholesalePrice = item.wholesalePrice;
              totalCost += wholesalePrice * item.quantity;
            }
          }

          final totalProfit = totalRevenue - totalCost;

          return Right({
            'اجمالي المبيعات': totalRevenue,
            'التكلفة الكلية': totalCost,
            'صافي الربح': totalProfit,
          });
        },
      );
    } catch (e) {
      return Left(CacheFailure(
          ":خطأ في تحميل بيانات المبيعات اليومية ${e.toString()}"));
    }
  }
}
