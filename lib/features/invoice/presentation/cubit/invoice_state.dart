

import '../../../sales/data/models/sale_model.dart';

enum InvoiceFilterType { all, sales, refunded }

class InvoiceState {
  final List<Sale> sales;
  final bool loading;
  final String searchQuery;
  final DateTime? startDate;
  final DateTime? endDate;
  final InvoiceFilterType filterType;

  InvoiceState({
    required this.sales,
    required this.loading,
    required this.searchQuery,
    required this.startDate,
    required this.endDate,
    required this.filterType,
  });

  // Factory constructors for basic state creation
  static InvoiceState initial() => InvoiceState(
        sales: [],
        loading: false,
        searchQuery: '',
        startDate: null,
        endDate: null,
        filterType: InvoiceFilterType.all,
      );

  static InvoiceState loadingState(String query, DateTime? start,
          DateTime? end, InvoiceFilterType filterType) =>
      InvoiceState(
        sales: [],
        loading: true,
        searchQuery: query,
        startDate: start,
        endDate: end,
        filterType: filterType,
      );

  static InvoiceState loaded(List<Sale> sales, String query, DateTime? start,
          DateTime? end, InvoiceFilterType filterType) =>
      InvoiceState(
        sales: sales,
        loading: false,
        searchQuery: query,
        startDate: start,
        endDate: end,
        filterType: filterType,
      );

  static InvoiceState error(String query, DateTime? start, DateTime? end,
          InvoiceFilterType filterType) =>
      InvoiceState(
        sales: [],
        loading: false,
        searchQuery: query,
        startDate: start,
        endDate: end,
        filterType: filterType,
      );
}
