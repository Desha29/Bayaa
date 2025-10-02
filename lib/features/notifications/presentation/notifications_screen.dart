import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:crazy_phone_pos/core/components/screen_header.dart';

import '../../../core/components/empty_state.dart';
import '../../../core/components/section_card.dart';
import '../../../core/constants/app_colors.dart';
import '../../dashboard/data/models/notify_model.dart';

import 'widgets/filters_bar.dart';
import 'widgets/notification_card.dart';
import 'widgets/summary_row.dart';



class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<NotifyItem> _items = [
    NotifyItem(
      id: 'IP13',
      title: 'نفد من المخزون',
      message: 'آيفون 13 - نفد من المخزون تماماً',
      badge: 'عاجل',
      priority: NotifyPriority.high,
      icon: LucideIcons.package,
      createdAgo: 'منذ 6س 25د',
      sku: 'IP13',
      quantityHint: null,
    ),
    NotifyItem(
      id: 'SGS23',
      title: 'مخزون منخفض',
      message: 'سامسونج جالاكسي S23 - باقي 6 قطع فقط',
      badge: 'متوسط',
      priority: NotifyPriority.medium,
      icon: LucideIcons.package,
      createdAgo: 'منذ 8س 45د',
      sku: 'SGS23',
      quantityHint: '6 قطع',
    ),
    NotifyItem(
      id: 'POCO',
      title: 'مخزون منخفض',
      message: 'بوكو X6 برو - باقي 3 قطع فقط',
      badge: 'متوسط',
      priority: NotifyPriority.medium,
      icon: LucideIcons.package,
      createdAgo: 'منذ 1ي',
      sku: 'POCOX6',
      quantityHint: '3 قطع',
    ),
  ];

  NotifyFilter _filter = NotifyFilter.all;
  final Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {


    final total = _items.length;
    final unread = _items.where((e) => !e.read).length;
    final urgent = _items
        .where((e) => e.priority == NotifyPriority.high)
        .length;
    final opened = total - unread;

    final visible = _items.where((e) {
      switch (_filter) {
        case NotifyFilter.all:
          return true;
        case NotifyFilter.unread:
          return !e.read;
        case NotifyFilter.urgent:
          return e.priority == NotifyPriority.high;
      }
    }).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                ScreenHeader(
                  title: 'التنبيهات',
                  subtitle: 'إدارة التنبيهات والإشعارات',
                ),

                const SizedBox(height: 20),

                // Summary
                SectionCard(
                  child: SummaryRow(
                    total: total,
                    opened: opened,
                    urgent: urgent,
                    unread: unread,
                  ),
                ),

                const SizedBox(height: 20),

                // Filters
                SectionCard(
                  child: FiltersBar(
                    filter: _filter,
                    onFilterChanged: (f) => setState(() => _filter = f),
                    total: total,
                    unread: unread,
                    urgent: urgent,
                    onMarkAllRead: () {
                      setState(() {
                        for (final e in _items) {
                          e.read = true;
                        }
                        _selected.clear();
                      });
                    },
                    onDeleteSelected: _selected.isEmpty
                        ? null
                        : () {
                            setState(() {
                              _items.removeWhere(
                                (e) => _selected.contains(e.id),
                              );
                              _selected.clear();
                            });
                          },
                  ),
                ),

                const SizedBox(height: 12),

              
                Expanded(
                  child: SectionCard(
                    
                    child: visible.isEmpty
                        ? EmptyState()
                        : ListView.separated(
                            itemCount: visible.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final n = visible[index];
                              final checked = _selected.contains(n.id);
                              return NotificationCard(
                                item: n,
                                checked: checked,
                                onToggleCheck: () {
                                  setState(() {
                                    if (checked) {
                                      _selected.remove(n.id);
                                    } else {
                                      _selected.add(n.id);
                                    }
                                  });
                                },
                                onDelete: () {
                                  setState(() {
                                    _items.removeWhere((e) => e.id == n.id);
                                    _selected.remove(n.id);
                                  });
                                },
                                onMarkReadToggle: () {
                                  setState(() {
                                    n.read = !n.read;
                                  });
                                },
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}







