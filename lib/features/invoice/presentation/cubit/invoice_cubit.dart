

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crazy_phone_pos/core/di/dependency_injection.dart';
import 'package:crazy_phone_pos/features/auth/presentation/cubit/user_cubit.dart';
import 'package:crazy_phone_pos/features/arp/data/repositories/session_repository_impl.dart';
import 'package:crazy_phone_pos/features/arp/data/models/session_model.dart';

import '../../../sales/data/models/sale_model.dart';
import '../../../sales/domain/sales_repository.dart';
import '../widgets/partial_refund_dialog.dart';

import 'invoice_state.dart';

class InvoiceCubit extends Cubit<InvoiceState> {
  final SalesRepository repository;


  InvoiceCubit(this.repository)
      : super(InvoiceState.initial());

  // Load initial and filtered sales
  Future<void> loadSales() async {
    emit(InvoiceState.loadingState(
        state.searchQuery, state.startDate, state.endDate, state.filterType));
    final result = await repository.getRecentSales(limit: 10000);
    final sales = result.getOrElse(() => []);
    emit(InvoiceState.loaded(
        _filterSales(sales, state.searchQuery, state.startDate, state.endDate,
            state.filterType),
        state.searchQuery,
        state.startDate,
        state.endDate,
        state.filterType));
  }

  // Set search query and reload
  void setSearchQuery(String query) async {
    emit(InvoiceState.loadingState(
        query, state.startDate, state.endDate, state.filterType));
    final result = await repository.getRecentSales(limit: 10000);
    final sales = result.getOrElse(() => []);
    emit(InvoiceState.loaded(
        _filterSales(sales, query, state.startDate, state.endDate,
            state.filterType),
        query,
        state.startDate,
        state.endDate,
        state.filterType));
  }

  // Set date range and reload
  void setDate(DateTime? start, DateTime? end) async {
    emit(InvoiceState.loadingState(
        state.searchQuery, start, end, state.filterType));
    final result = await repository.getRecentSales(limit: 10000);
    final sales = result.getOrElse(() => []);
    emit(InvoiceState.loaded(
        _filterSales(sales, state.searchQuery, start, end, state.filterType),
        state.searchQuery,
        start,
        end,
        state.filterType));
  }

  // Set filter type and reload
  void setFilterType(InvoiceFilterType type) async {
    emit(InvoiceState.loadingState(
        state.searchQuery, state.startDate, state.endDate, type));
    final result = await repository.getRecentSales(limit: 10000);
    final sales = result.getOrElse(() => []);
    emit(InvoiceState.loaded(
        _filterSales(
            sales, state.searchQuery, state.startDate, state.endDate, type),
        state.searchQuery,
        state.startDate,
        state.endDate,
        type));
  }

  List<Sale> _filterSales(List<Sale> sales, String searchQuery,
      DateTime? startDate, DateTime? endDate, InvoiceFilterType filterType) {
    var filtered = sales;

    // Filter by Type
    if (filterType == InvoiceFilterType.sales) {
      filtered = filtered.where((s) => !s.isRefund).toList();
    } else if (filterType == InvoiceFilterType.refunded) {
      filtered = filtered.where((s) => s.isRefund).toList();
    }

    if (startDate != null || endDate != null) {
      filtered = filtered.where((sale) {
        if (startDate != null && sale.date.isBefore(startDate)) return false;
        if (endDate != null) {
          final endOfDay =
              DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
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

  // Create Partial Refund (Item-based refund)
  Future<void> createPartialRefund({
    required Sale originalSale,
    required List<RefundItem> itemsToRefund,
  }) async {
    if (itemsToRefund.isEmpty) return;

    // 1. Session Management (Auto-Open if needed)
    final sessionRepo = getIt<SessionRepositoryImpl>();
    var currentSession = sessionRepo.getCurrentSession();
    Session session;

    if (currentSession == null || !currentSession.isOpen) {
      final currentUser = getIt<UserCubit>().currentUser;
      try {
        session = await sessionRepo.openSession(currentUser);
      } catch (e) {
        return; // Fail silently or add error handling if UI supports it
      }
    } else {
      session = currentSession;
    }

    // 2. Calculate total and create refund sale items
    double refundTotal = 0;
    int totalItems = 0;
    
    final refundSaleItems = itemsToRefund.map((item) {
      refundTotal += item.total;
      totalItems += item.quantity;
      
      return SaleItem(
        productId: item.productId,
        name: item.productName,
        price: item.unitPrice,
        quantity: item.quantity,
        total: item.total,
        wholesalePrice: item.wholesalePrice,
      );
    }).toList();

    // 3. Create Refund Invoice
    final refundSale = Sale(
      id: "${DateTime.now().millisecondsSinceEpoch}_REFUND",
      total: refundTotal,
      items: totalItems,
      date: DateTime.now(),
      saleItems: refundSaleItems,
      cashierName: getIt<UserCubit>().currentUser.name,
      cashierUsername: getIt<UserCubit>().currentUser.username,
      sessionId: session.id, // Linked to CURRENT session
      invoiceTypeIndex: 1, // REFUND
      refundOriginalInvoiceId: originalSale.id,
    );

    // 4. Save Refund
    await repository.saveSale(refundSale);

    // 5. Link to Session
    session.invoiceIds.add(refundSale.id);
    await session.save();

    // 6. Restock Items (only refunded items)
    for (var item in itemsToRefund) {
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

  // Reset all filters
  void resetFilters() async {
    const query = '';
    const InvoiceFilterType type = InvoiceFilterType.all;
    DateTime? start;
    DateTime? end;

    emit(InvoiceState.loadingState(query, start, end, type));
    final result = await repository.getRecentSales(limit: 10000);
    final sales = result.getOrElse(() => []);
    emit(InvoiceState.loaded(
        _filterSales(sales, query, start, end, type), query, start, end, type));
  }
}
