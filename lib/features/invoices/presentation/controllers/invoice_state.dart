import 'package:bayaa_pos/features/pos/presentation/models/invoice_view_data.dart';

enum InvoiceFilterType { all, sales, refunded }

class InvoiceState {
  final List<InvoiceViewData> sales;
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

  static InvoiceState loadingState(String query, DateTime? start, DateTime? end,
          InvoiceFilterType filterType,
          {List<InvoiceViewData>? currentSales}) =>
      InvoiceState(
        sales: currentSales ?? [],
        loading: true,
        searchQuery: query,
        startDate: start,
        endDate: end,
        filterType: filterType,
      );

  static InvoiceState loaded(List<InvoiceViewData> sales, String query,
          DateTime? start, DateTime? end, InvoiceFilterType filterType) =>
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
