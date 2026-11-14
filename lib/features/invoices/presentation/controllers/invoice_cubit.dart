import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bayaa_pos/features/pos/presentation/models/invoice_view_data.dart';
import 'package:bayaa_pos/features/pos/presentation/sources/invoice_catalog_source.dart';
import 'package:bayaa_pos/features/invoices/presentation/controllers/invoice_state.dart';

/// Search/date/type selection only. Sample invoices are never mutated.
class InvoiceCubit extends Cubit<InvoiceState> {
  InvoiceCubit(this.repository) : super(InvoiceState.initial());
  final InvoiceCatalogSource repository;
  List<InvoiceViewData> _sales = [];

  Future<void> loadSales() async {
    final result = await repository.getAllSales();
    if (isClosed) return;
    _sales = result.getOrElse(() => []);
    _filter(
        state.searchQuery, state.startDate, state.endDate, state.filterType);
  }

  void setSearchQuery(String query) =>
      _filter(query, state.startDate, state.endDate, state.filterType);
  void setDate(DateTime? start, DateTime? end) =>
      _filter(state.searchQuery, start, end, state.filterType);
  void setFilterType(InvoiceFilterType type) =>
      _filter(state.searchQuery, state.startDate, state.endDate, type);
  void resetFilters() => _filter('', null, null, InvoiceFilterType.all);

  void _filter(
      String query, DateTime? start, DateTime? end, InvoiceFilterType type) {
    final search = query.trim().toLowerCase();
    final endExclusive =
        end == null ? null : DateTime(end.year, end.month, end.day + 1);
    final sales = _sales.where((sale) {
      if (type == InvoiceFilterType.sales && sale.isRefund) return false;
      if (type == InvoiceFilterType.refunded && !sale.isRefund) return false;
      if (start != null && sale.date.isBefore(start)) return false;
      if (endExclusive != null && !sale.date.isBefore(endExclusive)) {
        return false;
      }
      return search.isEmpty ||
          sale.id.toLowerCase().contains(search) ||
          sale.saleItems.any((item) =>
              item.productId.contains(search) ||
              item.name.toLowerCase().contains(search));
    }).toList();
    emit(InvoiceState.loaded(sales, query, start, end, type));
  }
}
