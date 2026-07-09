import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../dashboard/data/models/notify_model.dart';
import 'package:bayaa_pos/core/constants/app_colors.dart';
import 'package:bayaa_pos/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);

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
                      icon: const Icon(LucideIcons.checkCheck, size: 15),
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          l10n.markSelectedRead,
                          style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.bold,
                              fontSize: 12),
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.secondaryColor,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onDeleteSelected,
                      icon: const Icon(LucideIcons.trash2, size: 15),
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          l10n.deleteSelected,
                          style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.bold,
                              fontSize: 12),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.errorColor,
                        side: const BorderSide(color: AppColors.errorColor),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
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
                    label: l10n.all,
                    count: total,
                    color: AppColors.primaryColor,
                    compact: true,
                  ),
                  _FilterChip(
                    selected: filter == NotifyFilter.unread,
                    onTap: () => onFilterChanged(NotifyFilter.unread),
                    label: l10n.unreadLabel,
                    count: unread,
                    color: AppColors.warningColor,
                    compact: true,
                  ),
                  _FilterChip(
                    selected: filter == NotifyFilter.urgent,
                    onTap: () => onFilterChanged(NotifyFilter.urgent),
                    label: l10n.urgentNotifications,
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
              icon: const Icon(LucideIcons.checkCheck, size: 16),
              label: Text(
                isTablet ? l10n.markSelectedRead : l10n.markAllRead,
                style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                    fontSize: 13),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.secondaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: onDeleteSelected,
              icon: const Icon(LucideIcons.trash2, size: 16),
              label: Text(
                l10n.deleteSelected,
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                    fontSize: 13),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.errorColor,
                side: BorderSide(
                    color: onDeleteSelected != null
                        ? AppColors.errorColor
                        : AppColors.borderColor),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const Spacer(),
            // Filter chips
            _FilterChip(
              selected: filter == NotifyFilter.all,
              onTap: () => onFilterChanged(NotifyFilter.all),
              label: l10n.all,
              count: total,
              color: AppColors.primaryColor,
              compact: isTablet,
            ),
            const SizedBox(width: 8),
            _FilterChip(
              selected: filter == NotifyFilter.unread,
              onTap: () => onFilterChanged(NotifyFilter.unread),
              label: l10n.unreadLabel,
              count: unread,
              color: AppColors.warningColor,
              compact: isTablet,
            ),
            const SizedBox(width: 8),
            _FilterChip(
              selected: filter == NotifyFilter.urgent,
              onTap: () => onFilterChanged(NotifyFilter.urgent),
              label: l10n.urgentNotifications,
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
    final baseColor = selected ? color : color.withOpacity(0.06);
    final textColor = selected ? Colors.white : color;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 12 : 16,
          vertical: compact ? 6 : 8,
        ),
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? Colors.transparent : color.withOpacity(0.24)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                color: textColor,
                fontWeight: FontWeight.w700,
                fontSize: compact ? 12 : 13,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withOpacity(0.2)
                    : color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: selected ? Colors.white : color,
                  fontWeight: FontWeight.bold,
                  fontSize: compact ? 10 : 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
