

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../sales/data/models/sale_model.dart';
import '../../../sales/domain/sales_repository.dart';

import 'invoice_state.dart';

class InvoiceCubit extends Cubit<InvoiceState> {
  final SalesRepository repository;


  InvoiceCubit(this.repository)
      : super(InvoiceState.initial());

  // Load initial and filtered sales
  Future<void> loadSales() async {
    emit(InvoiceState.loadingState(state.searchQuery, state.startDate, state.endDate));
    final result =
        await repository.getRecentSales(limit: 10000);
    final sales = result.getOrElse(() => []);
    emit(InvoiceState.loaded(
        _filterSales(sales, state.searchQuery, state.startDate, state.endDate),
        state.searchQuery,
        state.startDate,
        state.endDate));
  }

  // Set search query and reload
  void setSearchQuery(String query) async {
    emit(InvoiceState.loadingState(query, state.startDate, state.endDate));
    final result = await repository.getRecentSales(limit: 10000);
    final sales = result.getOrElse(() => []);
    emit(InvoiceState.loaded(
        _filterSales(sales, query, state.startDate, state.endDate),
        query,
        state.startDate,
        state.endDate));
  }

  // Set date range and reload
  void setDate(DateTime? start, DateTime? end) async {
    emit(InvoiceState.loadingState(state.searchQuery, start, end));
    final result = await repository.getRecentSales(limit: 10000);
    final sales = result.getOrElse(() => []);
    emit(InvoiceState.loaded(
        _filterSales(sales, state.searchQuery, start, end),
        state.searchQuery,
        start,
        end));
  }

  List<Sale> _filterSales(
      List<Sale> sales, String searchQuery, DateTime? startDate, DateTime? endDate) {
    var filtered = sales;

    if (startDate != null || endDate != null) {
      filtered = filtered.where((sale) {
        if (startDate != null && sale.date.isBefore(startDate)) return false;
        if (endDate != null) {
          final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
          if (sale.date.isAfter(endOfDay)) return false;
        }
        return true;
      }).toList();
    }
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((sale) {
        if (sale.id.contains(searchQuery)) return true;
        return sale.saleItems.any((item) =>
            item.productId.contains(searchQuery) ||
            item.name.toLowerCase().contains(searchQuery.toLowerCase()));
      }).toList();
    }
    return filtered;
  }

  // Delete a single sale
  Future<void> deleteSale(String saleId) async {
    await repository.deleteSale(saleId);
    loadSales();
  }

  // Return a sale (restock items then delete sale)
  Future<void> returnSale(Sale sale) async {
    for (var item in sale.saleItems) {
      final prodResult = await repository.findProductByBarcode(item.productId);
      await prodResult.fold(
        (fail) => null,
        (product) async {
          if (product != null) {
            product.quantity += item.quantity;
            await repository.updateProductQuantity(product.barcode, product.quantity);
          }
        },
      );
    }
    await repository.deleteSale(sale.id);
    loadSales();
  }

  // Bulk delete (date range or query)
  Future<void> deleteInvoices(DateTime? start, DateTime? end, String searchQuery) async {
    if (start != null && end != null) {
      await repository.deleteSalesInRange(start, end);
    } else {
      await repository.deleteSalesByQuery(searchQuery);
    }
    loadSales();
  }
}
