import 'package:bayaa_pos/features/auth/presentation/models/user_view_data.dart';
import 'package:bayaa_pos/features/customers/presentation/views/customers_view.dart';
import 'package:bayaa_pos/features/finance/presentation/views/finance_view.dart';
import 'package:bayaa_pos/features/purchase_returns/presentation/views/purchase_returns_view.dart';
import 'package:bayaa_pos/features/purchases/presentation/views/purchases_view.dart';
import 'package:bayaa_pos/features/suppliers/presentation/views/suppliers_view.dart';
import 'package:bayaa_pos/features/warehouses/presentation/views/warehouses_view.dart';
import 'package:bayaa_pos/preview/branch_preview_controller.dart';
import 'package:bayaa_pos/preview/data/preview_data.dart';
import 'package:bayaa_pos/shared/widgets/erp/erp_view_spec.dart';
import 'package:flutter/material.dart';

typedef ReportValue = (String label, double value);
typedef TrendBucket = (
  DateTime start,
  DateTime end,
  double sales,
  double expenses
);

/// Read-only reporting projections of the same fixtures used by the ERP screens.
class AnalyticsSnapshot {
  AnalyticsSnapshot(DateTimeRange range) {
    final start = _day(range.start);
    final end = _day(range.end);
    bool includes(DateTime date) {
      final day = _day(date);
      return !day.isBefore(start) && !day.isAfter(end);
    }

    final invoices = PreviewData.sales.where((sale) => includes(sale.date));
    final expenses = PreviewData.expenses.where((item) => includes(item.date));
    final products = PreviewData.products;
    final categories = PreviewData.productCategories;
    final days = end.difference(start).inDays + 1;
    final step = (days / 12).ceil();
    final slots = (days / step).ceil();
    final saleBuckets = List<double>.filled(slots, 0);
    final expenseBuckets = List<double>.filled(slots, 0);
    final names = <String, String>{};
    for (final sale in invoices) {
      final signed = sale.isRefund ? -sale.total : sale.total;
      saleBuckets[_day(sale.date).difference(start).inDays ~/ step] += signed;
      if (sale.isRefund) {
        refunds += sale.total;
        refundCount++;
      } else {
        gross += sale.total;
        saleCount++;
        salesByHour.update(sale.date.hour, (count) => count + 1,
            ifAbsent: () => 1);
        _add(payments, sale.paymentMethod, sale.total);
      }
      for (final line in sale.saleItems) {
        final sign = sale.isRefund ? -1 : 1;
        cost += sign * line.quantity * line.wholesalePrice;
        names[line.productId] = line.name;
        _add(_productSales, line.productId, sign * line.total);
        if (categories[line.productId] case final category?) {
          _add(salesCategories, category, sign * line.total);
        }
      }
    }
    topProducts = [
      for (final entry in _productSales.entries)
        if (entry.value > 0) (names[entry.key]!, entry.value)
    ]..sort((a, b) => b.$2.compareTo(a.$2));
    for (final expense in expenses) {
      expenseTotal += expense.amount;
      expenseBuckets[_day(expense.date).difference(start).inDays ~/ step] +=
          expense.amount;
      _add(expenseCategories, expense.category, expense.amount);
    }
    trend = [
      for (var i = 0; i < slots; i++)
        (
          start.add(Duration(days: i * step)),
          start.add(Duration(days: ((i + 1) * step).clamp(1, days) - 1)),
          saleBuckets[i],
          expenseBuckets[i],
        )
    ];
    for (final product in products) {
      productCount++;
      units += product.quantity;
      final value = product.quantity * product.wholesalePrice;
      inventoryValue += value;
      _add(stockCategories, product.category, value);
      if (product.quantity == 0) {
        outOfStock++;
      } else if (product.quantity <= product.minQuantity) {
        lowStock++;
      }
    }
    for (final user in PreviewData.users) {
      user.userType == PreviewRole.manager ? managers++ : cashiers++;
    }
  }

  static DateTime _day(DateTime date) =>
      DateTime.utc(date.year, date.month, date.day);
  static void _add(Map<String, double> values, String key, double amount) =>
      values.update(key, (value) => value + amount, ifAbsent: () => amount);

  double gross = 0, refunds = 0, cost = 0, expenseTotal = 0, inventoryValue = 0;
  int saleCount = 0, refundCount = 0, units = 0, productCount = 0;
  int lowStock = 0, outOfStock = 0, managers = 0, cashiers = 0;
  final payments = <String, double>{};
  final salesByHour = <int, double>{};
  final expenseCategories = <String, double>{};
  final salesCategories = <String, double>{};
  final stockCategories = <String, double>{};
  final _productSales = <String, double>{};
  late final List<ReportValue> topProducts;
  late final List<TrendBucket> trend;
  double get net => gross - refunds;
  double get grossProfit => net - cost;
  double get operatingResult => grossProfit - expenseTotal;
  double get averageInvoice => saleCount == 0 ? 0 : gross / saleCount;

  static List<ErpViewSpec> get modules => [
        customersView,
        suppliersView,
        purchasesView,
        purchaseReturnsView,
        financeView,
        warehousesView,
      ]
          .where((module) =>
              BranchPreviewController.instance.moduleVisible(module.id))
          .toList();

  static Map<UiLabel, double> statuses(ErpViewSpec module) {
    final counts = <String, (UiLabel, double)>{};
    for (final record in BranchPreviewController.instance
        .scope(module.records, (record) => record.id)) {
      final label = record.status;
      counts.update(label.en, (entry) => (label, entry.$2 + 1),
          ifAbsent: () => (label, 1));
    }
    return {for (final entry in counts.values) entry.$1: entry.$2};
  }
}
