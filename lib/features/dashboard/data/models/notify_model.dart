import 'package:crazy_phone_pos/features/products/data/models/product_model.dart';
import 'package:flutter/material.dart';

enum NotifyPriority { high, medium }

enum NotifyFilter { all, unread, urgent }

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
  });
  factory NotifyItem.fromProduct(Product Product) {
    return NotifyItem(
        id: Product.barcode,
        title:
            (Product.quantity <= Product.minQuantity && Product.quantity != 0)
                ? 'مخزون منخفض'
                : 'نفد من المخزون',
        message: '${Product.name} - باقي ${Product.quantity} قطع فقط',
        badge:
            (Product.quantity <= Product.minQuantity && Product.quantity != 0)
                ? 'متوسط'
                : 'عاجل',
        priority:
            (Product.quantity <= Product.minQuantity && Product.quantity != 0)
                ? NotifyPriority.medium
                : NotifyPriority.high,
        icon: Icons.inventory_2,
        createdAgo: '',
        sku: Product.barcode,
        quantityHint: '${Product.quantity} قطع',
        read: false);
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
}
