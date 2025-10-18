// lib/features/arp/data/arp_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../../core/error/failure.dart';
import '../domain/arp_repository.dart';
import '../../sales/domain/sales_repository.dart';
import '../data/models/arp_summary_model.dart';


class ArpRepositoryImpl implements ArpRepository {
  final SalesRepository salesRepository;

  ArpRepositoryImpl({
    required this.salesRepository,
  });

  @override
  Future<Either<Failure, ArpSummaryModel>> getSummary(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final salesResult = await salesRepository.getRecentSales(limit: 10000);
      
      return salesResult.fold(
        (failure) => Left(failure),
        (sales) {
          final filteredSales = sales.where((sale) {
            return sale.date.isAfter(start.subtract(const Duration(days: 1))) &&
                sale.date.isBefore(end.add(const Duration(days: 1)));
          }).toList();

          double totalRevenue = 0;
          double totalCost = 0;

          for (var sale in filteredSales) {
            totalRevenue += sale.total;
            for (var item in sale.saleItems) {
              totalCost += item.price * 0.6 * item.quantity;
            }
          }

          final profit = totalRevenue - totalCost;
          final margin = totalRevenue > 0 ? (profit / totalRevenue) * 100 : 0.0;

          return Right(ArpSummaryModel(
            totalRevenue: totalRevenue,
            totalCost: totalCost,
            totalProfit: profit,
            profitMargin: margin,
            totalSales: filteredSales.length,
            startDate: start,
            endDate: end,
          ));
        },
      );
    } catch (e) {
      return Left(CacheFailure("Error fetching summary: ${e.toString()}"));
    }
  }

  @override
  Future<Either<Failure, List<ProductPerformanceModel>>> getTopProducts(int limit) async {
    try {
      final salesResult = await salesRepository.getRecentSales(limit: 10000);
      
      return salesResult.fold(
        (failure) => Left(failure),
        (sales) {
          final Map<String, ProductPerformanceModel> productStats = {};

          for (var sale in sales) {
            for (var item in sale.saleItems) {
              final productName = item.name; // Changed from item.productName to item.name
              final cost = item.price * 0.6 * item.quantity;
              
              if (productStats.containsKey(productName)) {
                final existing = productStats[productName]!;
                productStats[productName] = ProductPerformanceModel(
                  productId: existing.productId,
                  productName: productName,
                  quantitySold: existing.quantitySold + item.quantity,
                  revenue: existing.revenue + item.total,
                  cost: existing.cost + cost,
                  profit: 0.0,
                  profitMargin: 0.0,
                );
              } else {
                productStats[productName] = ProductPerformanceModel(
                  productId: item.productId,
                  productName: productName,
                  quantitySold: item.quantity,
                  revenue: item.total,
                  cost: cost,
                  profit: 0.0,
                  profitMargin: 0.0,
                );
              }
            }
          }

          final products = productStats.values.map((p) {
            final profit = p.revenue - p.cost;
            final margin = p.revenue > 0 ? (profit / p.revenue) * 100 : 0.0;
            return ProductPerformanceModel(
              productId: p.productId,
              productName: p.productName,
              quantitySold: p.quantitySold,
              revenue: p.revenue,
              cost: p.cost,
              profit: profit,
              profitMargin: margin,
            );
          }).toList();

          products.sort((a, b) => b.revenue.compareTo(a.revenue));
          return Right(products.take(limit).toList());
        },
      );
    } catch (e) {
      return Left(CacheFailure("Error fetching top products: ${e.toString()}"));
    }
  }

  @override
  Future<Either<Failure, Map<String, double>>> getDailySales(DateTime start, DateTime end) async {
    try {
      final salesResult = await salesRepository.getRecentSales(limit: 10000);
      
      return salesResult.fold(
        (failure) => Left(failure),
        (sales) {
          final filteredSales = sales.where((sale) {
            return sale.date.isAfter(start.subtract(const Duration(days: 1))) &&
                sale.date.isBefore(end.add(const Duration(days: 1)));
          }).toList();

          final Map<String, double> dailySales = {};

          for (var sale in filteredSales) {
            final dateKey = '${sale.date.year}-${sale.date.month.toString().padLeft(2, '0')}-${sale.date.day.toString().padLeft(2, '0')}';
            dailySales[dateKey] = (dailySales[dateKey] ?? 0) + sale.total;
          }

          final sortedKeys = dailySales.keys.toList()..sort();
          return Right({for (var key in sortedKeys) key: dailySales[key]!});
        },
      );
    } catch (e) {
      return Left(CacheFailure("Error fetching daily sales: ${e.toString()}"));
    }
  }
}
