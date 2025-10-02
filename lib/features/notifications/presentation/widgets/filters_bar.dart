import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../dashboard/data/models/notify_model.dart';

class FiltersBar extends StatelessWidget {
  const FiltersBar({super.key, 
    required this.filter,
    required this.onFilterChanged,
    required this.total,
    required this.unread,
    required this.urgent,
    required this.onMarkAllRead,
    required this.onDeleteSelected,
  });

  final NotifyFilter filter;
  final ValueChanged<NotifyFilter> onFilterChanged;
  final int total;
  final int unread;
  final int urgent;
  final VoidCallback onMarkAllRead;
  final VoidCallback? onDeleteSelected;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return Row(
      children: [
        // الأزرار الجماعية
        FilledButton.icon(
          onPressed: onMarkAllRead,
          icon: const Icon(LucideIcons.checkCheck, size: 18),
          label: const Text('تحديد الكل كمقروءة'),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: onDeleteSelected,
          icon: const Icon(LucideIcons.trash2, size: 18),
          label: const Text('حذف المحدد'),
        ),
        const Spacer(),
        // الفلاتر
        _FilterChip(
          selected: filter == NotifyFilter.all,
          onTap: () => onFilterChanged(NotifyFilter.all),
          label: 'الكل',
          count: total,
          color: c.primary,
        ),
        const SizedBox(width: 8),
        _FilterChip(
          selected: filter == NotifyFilter.unread,
          onTap: () => onFilterChanged(NotifyFilter.unread),
          label: 'غير مقروءة',
          count: unread,
          color: Colors.amber.shade800,
        ),
        const SizedBox(width: 8),
        _FilterChip(
          selected: filter == NotifyFilter.urgent,
          onTap: () => onFilterChanged(NotifyFilter.urgent),
          label: 'عاجلة',
          count: urgent,
          color: Colors.red.shade700,
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.selected,
    required this.onTap,
    required this.label,
    required this.count,
    required this.color,
  });

  final bool selected;
  final VoidCallback onTap;
  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final base = selected ? color : color.withOpacity(0.15);
    final fg = selected ? Colors.white : color;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: base,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(color: fg, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: selected ? Colors.white.withOpacity(0.2) : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: selected ? Colors.white : color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}