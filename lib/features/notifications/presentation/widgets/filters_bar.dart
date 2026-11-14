import 'package:flutter/material.dart';
import 'package:bayaa_pos/l10n/app_localizations.dart';
import 'package:bayaa_pos/shared/theme/app_colors.dart';
import '../models/notification_view_data.dart';

class FiltersBar extends StatelessWidget {
  const FiltersBar(
      {super.key,
      required this.filter,
      required this.onFilterChanged,
      required this.total,
      required this.unread,
      required this.urgent,
      required this.selectedCount,
      required this.onMarkAllRead,
      this.onDeleteSelected});

  final NotifyFilter filter;
  final ValueChanged<NotifyFilter> onFilterChanged;
  final int total, unread, urgent, selectedCount;
  final VoidCallback onMarkAllRead;
  final VoidCallback? onDeleteSelected;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final ar = l.localeName == 'ar';
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Wrap(spacing: 8, runSpacing: 6, children: [
        for (final entry in [
          (NotifyFilter.all, l.allFilter, total),
          (NotifyFilter.unread, l.unreadLabel, unread),
          (NotifyFilter.urgent, l.urgentNotifications, urgent),
        ])
          ChoiceChip(
              label: Text('${entry.$2} (${entry.$3})'),
              selected: filter == entry.$1,
              selectedColor: AppColors.primaryColor,
              labelStyle: TextStyle(
                  color: filter == entry.$1
                      ? AppColors.primaryForeground
                      : AppColors.textPrimary),
              onSelected: (_) => onFilterChanged(entry.$1)),
      ]),
      const SizedBox(height: 10),
      Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            OutlinedButton.icon(
                onPressed: unread == 0 ? null : onMarkAllRead,
                icon: const Icon(Icons.done_all, size: 18),
                label: Text(l.markAllRead)),
            if (onDeleteSelected != null)
              OutlinedButton.icon(
                  onPressed: onDeleteSelected,
                  icon: Icon(Icons.delete_outline,
                      size: 18, color: AppColors.errorColor),
                  label: Text('${l.deleteSelectedLabel} ($selectedCount)')),
            if (selectedCount > 0)
              Text(ar ? '$selectedCount محدد' : '$selectedCount selected',
                  style: TextStyle(color: AppColors.mutedColor)),
          ]),
    ]);
  }
}
