

import '../../../sales/data/models/sale_model.dart';

class InvoiceState {
  final List<Sale> sales;
  final bool loading;
  final String searchQuery;
  final DateTime? startDate;
  final DateTime? endDate;

  InvoiceState({
    required this.sales,
    required this.loading,
    required this.searchQuery,
    required this.startDate,
    required this.endDate,
  });

  // Factory constructors for basic state creation
  static InvoiceState initial() => InvoiceState(
        sales: [],
        loading: false,
        searchQuery: '',
        startDate: null,
        endDate: null,
      );

  static InvoiceState loadingState(
          String query, DateTime? start, DateTime? end) =>
      InvoiceState(
        sales: [],
        loading: true,
        searchQuery: query,
        startDate: start,
        endDate: end,
      );

  static InvoiceState loaded(
          List<Sale> sales, String query, DateTime? start, DateTime? end) =>
      InvoiceState(
        sales: sales,
        loading: false,
        searchQuery: query,
        startDate: start,
        endDate: end,
      );

  static InvoiceState error(
          String query, DateTime? start, DateTime? end) =>
      InvoiceState(
        sales: [],
        loading: false,
        searchQuery: query,
        startDate: start,
        endDate: end,
      );
}
