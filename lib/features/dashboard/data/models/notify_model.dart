import 'package:bayaa_pos/features/products/data/models/product_model.dart';
import 'package:flutter/material.dart';

enum NotifyPriority { high, medium }

enum NotifyFilter { all, unread, urgent }

enum NotifyType { lowStock, outOfStock }

class NotifyItem {
  NotifyItem({
    required this.id,
    required this.title,
    required this.message,
    required this.badge,
    required this.priority,
    required this.icon,
    required this.createdAgo,
    required this.sku,
    this.quantityHint,
    this.read = false,
    this.notifyType,
    this.productName,
    this.productQuantity,
  });

  factory NotifyItem.fromProduct(Product product) {
    final isLowStock = product.quantity <= product.minQuantity && product.quantity != 0;
    return NotifyItem(
      id: product.barcode,
      // These will be overridden by localized text in the card widget
      title: '',
      message: '',
      badge: '',
      priority: isLowStock ? NotifyPriority.medium : NotifyPriority.high,
      icon: Icons.inventory_2,
      createdAgo: '',
      sku: product.barcode,
      quantityHint: '',
      read: false,
      notifyType: isLowStock ? NotifyType.lowStock : NotifyType.outOfStock,
      productName: product.name,
      productQuantity: product.quantity,
    );
  }

  final String id;
  final String title;
  final String message;
  final String badge;
  final NotifyPriority priority;
  final IconData icon;
  final String createdAgo;
  final String sku;
  final String? quantityHint;
  bool read;
  final NotifyType? notifyType;
  final String? productName;
  final int? productQuantity;
}
