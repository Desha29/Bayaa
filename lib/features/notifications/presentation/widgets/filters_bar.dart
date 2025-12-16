import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../dashboard/data/models/notify_model.dart';

import 'package:crazy_phone_pos/core/constants/app_colors.dart';

class FiltersBar extends StatelessWidget {
  const FiltersBar({
    super.key,
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;
        final isTablet =
            constraints.maxWidth >= 700 && constraints.maxWidth < 900;

        if (isMobile) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onMarkAllRead,
                      icon: const Icon(LucideIcons.checkCheck, size: 16),
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: const Text('كمقروءة'),
                      ),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onDeleteSelected,
                      icon: const Icon(LucideIcons.trash2, size: 16),
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: const Text('حذف'),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Filter chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _FilterChip(
                    selected: filter == NotifyFilter.all,
                    onTap: () => onFilterChanged(NotifyFilter.all),
                    label: 'الكل',
                    count: total,
                    color: c.primary,
                    compact: true,
                  ),
                  _FilterChip(
                    selected: filter == NotifyFilter.unread,
                    onTap: () => onFilterChanged(NotifyFilter.unread),
                    label: 'غير مقروءة',
                    count: unread,
                    color: AppColors.warningColor,
                    compact: true,
                  ),
                  _FilterChip(
                    selected: filter == NotifyFilter.urgent,
                    onTap: () => onFilterChanged(NotifyFilter.urgent),
                    label: 'عاجلة',
                    count: urgent,
                    color: AppColors.errorColor,
                    compact: true,
                  ),
                ],
              ),
            ],
          );
        }

        // Desktop and Tablet layout using Row
        return Row(
          children: [
            // Action buttons
            FilledButton.icon(
              onPressed: onMarkAllRead,
              icon: const Icon(LucideIcons.checkCheck, size: 18),
              label: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(isTablet ? 'مقروءة' : 'تحديد الكل كمقروءة'),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: onDeleteSelected,
              icon: const Icon(LucideIcons.trash2, size: 18),
              label: FittedBox(
                fit: BoxFit.scaleDown,
                child: const Text('حذف المحدد'),
              ),
            ),
            const Spacer(), // Now safely inside a Row
            // Filter chips
            _FilterChip(
              selected: filter == NotifyFilter.all,
              onTap: () => onFilterChanged(NotifyFilter.all),
              label: 'الكل',
              count: total,
              color: c.primary,
              compact: isTablet,
            ),
            const SizedBox(width: 8),
            _FilterChip(
              selected: filter == NotifyFilter.unread,
              onTap: () => onFilterChanged(NotifyFilter.unread),
              label: 'غير مقروءة',
              count: unread,
              color: AppColors.warningColor,
              compact: isTablet,
            ),
            const SizedBox(width: 8),
            _FilterChip(
              selected: filter == NotifyFilter.urgent,
              onTap: () => onFilterChanged(NotifyFilter.urgent),
              label: 'عاجلة',
              count: urgent,
              color: AppColors.errorColor,
              compact: isTablet,
            ),
          ],
        );
      },
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
    this.compact = false,
  });

  final bool selected;
  final VoidCallback onTap;
  final String label;
  final int count;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final base = selected ? color : color.withOpacity(0.15);
    final fg = selected ? Colors.white : color;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 10 : 12,
          vertical: compact ? 6 : 8,
        ),
        decoration: BoxDecoration(
          color: base,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(
                    color: fg,
                    fontWeight: FontWeight.w600,
                    fontSize: compact ? 13 : 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 5 : 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: selected ? Colors.white.withOpacity(0.2) : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: selected ? Colors.white : color,
                  fontWeight: FontWeight.w700,
                  fontSize: compact ? 11 : 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
