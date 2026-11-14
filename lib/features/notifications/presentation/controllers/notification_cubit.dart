import 'package:bayaa_pos/features/notifications/presentation/controllers/notification_state.dart';
import 'package:bayaa_pos/features/products/presentation/models/product_view_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:bayaa_pos/preview/branch_preview_controller.dart';

import 'package:bayaa_pos/app/bootstrap/service_locator.dart';
import 'package:bayaa_pos/features/notifications/presentation/models/notification_view_data.dart';
import 'package:bayaa_pos/features/inventory/presentation/controllers/stock_alerts_cubit.dart';

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit() : super(NotificationsLoading());

  List<NotifyItem> _notifications = [];
  Set<String> selected = {};
  NotifyFilter filter = NotifyFilter.all;
  int total = 0;
  int unread = 0;
  int urgent = 0;
  int opened = 0;
  String? _branch;
  List<(String, int, int)> _stockSnapshot = const [];

  loadData() {
    final products = getIt<StockAlertsCubit>().sendData();
    final branch = BranchPreviewController.instance.activeId;
    final snapshot = [
      for (final product in products)
        (product.barcode, product.quantity, product.minQuantity),
    ];
    if (_branch == branch && listEquals(_stockSnapshot, snapshot)) return;
    _branch = branch;
    _stockSnapshot = snapshot;
    selected.clear();
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
    if (this.filter != filter) selected.clear();
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

  addItem(ProductViewData product) async {
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
    urgent =
        _notifications.where((e) => e.priority == NotifyPriority.high).length;
    opened = total - unread;
    // await Future.delayed(const Duration(seconds: 1));
    emit(NotificationsError(
      product.quantity == 0
          ? 'productOutOfStock'
          : 'productLowStock: ${product.quantity}',
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
    filterData(filter);
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
    filterData(filter);
  }

  removeItem(String id) {
    _notifications.removeWhere((item) => item.id == id);
    total = _notifications.length;
    unread = _notifications.where((e) => !e.read).length;
    urgent =
        _notifications.where((e) => e.priority == NotifyPriority.high).length;
    opened = total - unread;
    selected.remove(id);
    filterData(filter);
  }

  addSelected(String id) {
    selected.add(id);
    filterData(filter);
  }

  removeSelectedId(String id) {
    selected.remove(id);
    filterData(filter);
  }

  removeSelected() {
    _notifications.removeWhere((item) => selected.contains(item.id));
    total = _notifications.length;
    unread = _notifications.where((e) => !e.read).length;
    urgent =
        _notifications.where((e) => e.priority == NotifyPriority.high).length;
    opened = total - unread;
    selected.clear();
    filterData(filter);
  }
}
