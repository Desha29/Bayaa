import 'package:crazy_phone_pos/features/notifications/presentation/cubit/notifications_states.dart';
import 'package:crazy_phone_pos/features/products/data/models/product_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

import '../../../../core/di/dependency_injection.dart';
import '../../../../core/state/state_synchronizer.dart';
import '../../../../core/logging/file_logger.dart';
import '../../../dashboard/data/models/notify_model.dart';
import '../../../stock/presentation/cubit/stock_cubit.dart';

class NotificationsCubit extends Cubit<NotificationsStates> {
  NotificationsCubit() : super(NotificationsLoading()) {
    _setupStateSync();
  }
  
  StreamSubscription? _subscription;
  List<NotifyItem> _notifications = [];
  Set<String> selected = {};
  NotifyFilter filter = NotifyFilter.all;
  int total = 0;
  int unread = 0;
  int urgent = 0;
  int opened = 0;
  
  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
  
  /// Set up state synchronization to auto-refresh when products change
  void _setupStateSync() {
    _subscription = StateSynchronizer.events.listen((event) {
      if (event.entityType == 'product' || event.entityType == 'product_stock') {
        FileLogger.debug('NotificationsCubit auto-refreshing due to ${event.entityType} ${event.operation}', source: 'NotificationsCubit');
        // Auto-refresh notifications when products or stock changes
        loadData();
      }
    });
  }
  loadData() {
    var products = getIt<StockCubit>().sendData();
    _notifications = products
        .map(
          (product) => NotifyItem.fromProduct(product),
        )
        .toList();
    total = _notifications.length;
    unread = _notifications.where((e) => !e.read).length;
    urgent =
        _notifications.where((e) => e.priority == NotifyPriority.high).length;
    opened = total - unread;
    filterData(filter);
  }

  filterData(NotifyFilter filter) {
    this.filter = filter;
    final filterd = _notifications.where((e) {
      switch (this.filter) {
        case NotifyFilter.all:
          return true;
        case NotifyFilter.unread:
          return !e.read;
        case NotifyFilter.urgent:
          return e.priority == NotifyPriority.high;
      }
    }).toList();
    emit(NotificationsLoaded(filterd));
  }

  addItem(Product product) async {
    if (_notifications.any((item) => item.id == product.barcode)) {
      if (product.quantity > product.minQuantity) {
        _notifications.removeWhere((item) => item.id == product.barcode);
        total = _notifications.length;
        unread = _notifications.where((e) => !e.read).length;
        opened = total - unread;
    // await Future.delayed(const Duration(seconds: 1));
        emit(NotificationsLoaded(_notifications));
        return;
      } else {
        _notifications.removeWhere((item) => item.id == product.barcode);
        total = _notifications.length;
        unread = _notifications.where((e) => !e.read).length;
        opened = total - unread;
      }
    }
    if (product.quantity > product.minQuantity) return;
    final newItem = NotifyItem.fromProduct(product);
    _notifications.insert(0, newItem);
    total = _notifications.length;
    unread = _notifications.where((e) => !e.read).length;
    opened = total - unread;
    // await Future.delayed(const Duration(seconds: 1));
    emit(NotificationsError(
      product.quantity == 0
          ? 'المنتج نفد من المخزون'
          : 'كمية المنتج في المخزون منخفضة (${product.quantity})',
    ));
    // Restore loaded state immediately so list view continues to work
    emit(NotificationsLoaded(_notifications));
  }

  markAllAsRead() {
    for (var item in _notifications) {
      item.read = true;
    }
    unread = 0;
    opened = total;
    selected.clear();
    filterData(this.filter);
  }

  markItemAsRead(String id) {
    final item = _notifications.firstWhere((item) => item.id == id);
    if (!item.read) {
      item.read = true;
      unread--;
      opened++;
    } else {
      item.read = false;
      unread++;
      opened--;
    }
    selected.remove(id);
    filterData(this.filter);
  }

  removeItem(String id) {
    _notifications.removeWhere((item) => item.id == id);
    total = _notifications.length;
    unread = _notifications.where((e) => !e.read).length;
    opened = total - unread;
    selected.remove(id);
    filterData(this.filter);
  }

  addSelected(String id) {
    selected.add(id);
    filterData(this.filter);
  }

  removeSelectedId(String id) {
    selected.remove(id);
    filterData(this.filter);
  }

  removeSelected() {
    _notifications.removeWhere((item) => selected.contains(item.id));
    total = _notifications.length;
    unread = _notifications.where((e) => !e.read).length;
    opened = total - unread;
    selected.clear();
    filterData(this.filter);
  }
}
