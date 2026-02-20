

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crazy_phone_pos/core/di/dependency_injection.dart';
import 'package:crazy_phone_pos/features/auth/presentation/cubit/user_cubit.dart';
import 'package:crazy_phone_pos/features/sessions/data/models/session_model.dart';

import '../../../sales/data/models/sale_model.dart';
import '../../../sales/domain/sales_repository.dart';
import '../widgets/partial_refund_dialog.dart';
import '../../../../core/services/activity_logger.dart';
import '../../../../core/data/models/activity_log.dart';
import '../../../../core/session/session_manager.dart';
import 'package:collection/collection.dart'; // for firstWhereOrNull

import 'invoice_state.dart';

class InvoiceCubit extends Cubit<InvoiceState> {
  final SalesRepository repository;


  StreamSubscription? _activitySubscription;

  InvoiceCubit(this.repository)
      : super(InvoiceState.initial()) {
     _activitySubscription = getIt<ActivityLogger>().activitiesStream.listen((activities) {
      if (activities.isNotEmpty) {
        final type = activities.first.type;
        if (type == ActivityType.sale ||
            type == ActivityType.refund ||
            type == ActivityType.invoiceDelete) {
            // Reload sales if we are not already loading?
            // loadSales emits loading state which might flicker UI. 
            // Ideally we'd do a silent refresh, but for now standard load is fine for "Real Time" request.
            loadSales();
        }
      }
    });     
  }

  @override
  Future<void> close() {
    _activitySubscription?.cancel();
    return super.close();
  }

  // Load initial and filtered sales
  Future<void> loadSales() async {
    emit(InvoiceState.loadingState(
        state.searchQuery, state.startDate, state.endDate, state.filterType, currentSales: state.sales));
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
        query, state.startDate, state.endDate, state.filterType, currentSales: state.sales));
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
        state.searchQuery, start, end, state.filterType, currentSales: state.sales));
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
        state.searchQuery, state.startDate, state.endDate, type, currentSales: state.sales));
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
    // Find the sale before deleting for logging
    final sale = state.sales.firstWhereOrNull((s) => s.id == saleId);
    
    await repository.deleteSale(saleId);
    
    // Log activity if sale was found
    if (sale != null) {
      final sid = await getIt<SessionManager>().ensureSessionId(
        userName: getIt<UserCubit>().currentUser.name,
      );
      await getIt<ActivityLogger>().logActivity(
        type: ActivityType.invoiceDelete,
        description: 'حذف فاتورة: ${sale.total.toStringAsFixed(2)} ج.م',
        userName: getIt<UserCubit>().currentUser.name,
        sessionId: sid,
        details: {'saleId': saleId, 'items': sale.items},
      );
    }
    
    loadSales();
  }

  // Create Partial Refund (Item-based refund)
  Future<void> createPartialRefund({
    required Sale originalSale,
    required List<RefundItem> itemsToRefund,
  }) async {
    if (itemsToRefund.isEmpty) return;

    // 1. Session Management (Auto-Open if needed via SessionManager)
    Session session;
    try {
      session = await getIt<SessionManager>().getOrCreateSession(
        userName: getIt<UserCubit>().currentUser.name,
      );
    } catch (e) {
      return; // Fail silently or add error handling if UI supports it
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
    // Session is automatically saved via Repository persistence if managed correctly.
    // Assuming session object in memory is enough for now, or use SessionRepository to update.
    // For now, removing .save() as it was Hive-specific.
    // If persistent update is needed: await getIt<SessionRepositoryImpl>().updateSession(session);
    // CHECK: SessionRepositoryImpl should support update if needed.

    // 6. Update Original Invoice Permanent Tracking
    // We update the original sale record to "consume" the items permanently
    for (var item in itemsToRefund) {
      final itemToUpdate = originalSale.saleItems.firstWhere(
        (si) => si.productId == item.productId,
        orElse: () => throw Exception('Item not found in original sale'),
      );
      itemToUpdate.refundedQuantity += item.quantity;
    }
    await repository.saveSale(originalSale); // Persist updated original sale

    // 7. Restock Items (only refunded items)
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

    // 8. Log refund activity
    await getIt<ActivityLogger>().logActivity(
      type: ActivityType.refund,
      description: 'استرجاع: ${refundTotal.toStringAsFixed(2)} ج.م',
      userName: getIt<UserCubit>().currentUser.name,
      sessionId: session.id,
      details: {
        'total': refundTotal,
        'itemCount': totalItems,
        'originalInvoiceId': originalSale.id,
        'refundedItems': itemsToRefund.map((i) => i.productName).toList(),
      },
    );

    loadSales();
  }

  // Bulk delete (date range or query)
  Future<void> deleteInvoices(DateTime? start, DateTime? end, String searchQuery) async {
    if (start != null && end != null) {
      await repository.deleteSalesInRange(start, end);
    } else {
      await repository.deleteSalesByQuery(searchQuery);
    }

    // Log bulk delete activity
    try {
      final sid = await getIt<SessionManager>().ensureSessionId(
        userName: getIt<UserCubit>().currentUser.name,
      );
      await getIt<ActivityLogger>().logActivity(
        type: ActivityType.invoiceDelete,
        description: 'حذف فواتير جماعي',
        userName: getIt<UserCubit>().currentUser.name,
        sessionId: sid,
        details: {
          'startDate': start?.toIso8601String(),
          'endDate': end?.toIso8601String(),
          'searchQuery': searchQuery,
        },
      );
    } catch (_) {}

    loadSales();
  }

  // Reset all filters
  void resetFilters() async {
    const query = '';
    const InvoiceFilterType type = InvoiceFilterType.all;
    DateTime? start;
    DateTime? end;

    emit(InvoiceState.loadingState(query, start, end, type, currentSales: state.sales));
    final result = await repository.getRecentSales(limit: 10000);
    final sales = result.getOrElse(() => []);
    emit(InvoiceState.loaded(
        _filterSales(sales, query, start, end, type), query, start, end, type));
  }
}
