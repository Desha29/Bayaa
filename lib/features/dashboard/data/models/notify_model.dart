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