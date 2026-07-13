import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../dashboard/data/models/notify_model.dart';
import 'package:bayaa_pos/core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.item,
    required this.checked,
    required this.onToggleCheck,
    required this.onDelete,
    required this.onMarkReadToggle,
  });

  final NotifyItem item;
  final bool checked;
  final VoidCallback onToggleCheck;
  final VoidCallback onDelete;
  final VoidCallback onMarkReadToggle;

  Color _priorityBg() {
    if (item.read) {
      return Colors.white;
    }
    switch (item.priority) {
      case NotifyPriority.high:
        return const Color(0xFFFFF1F2); // Soft premium rose/red
      case NotifyPriority.medium:
        return const Color(0xFFFFFBEB); // Soft premium amber/yellow
    }
  }

  Color _priorityBorder() {
    if (item.read) {
      return AppColors.borderColor.withOpacity(0.5);
    }
    switch (item.priority) {
      case NotifyPriority.high:
        return const Color(0xFFFECDD3); // Soft rose border
      case NotifyPriority.medium:
        return const Color(0xFFFEF3C7); // Soft amber border
    }
  }

  BorderDirectional _cardBorder() {
    return BorderDirectional(
      start: BorderSide(
        color: item.read 
            ? Colors.transparent 
            : _priorityPrimary(), 
        width: 4,
      ),
      top: BorderSide(color: _priorityBorder(), width: 1),
      bottom: BorderSide(color: _priorityBorder(), width: 1),
      end: BorderSide(color: _priorityBorder(), width: 1),
    );
  }

  Color _priorityPrimary() {
    switch (item.priority) {
      case NotifyPriority.high:
        return AppColors.errorColor;
      case NotifyPriority.medium:
        return AppColors.warningColor;
    }
  }

  String _getTitle(AppLocalizations l10n) {
    if (item.notifyType == NotifyType.outOfStock) return l10n.notificationOutOfStockTitle;
    return l10n.notificationLowStockTitle;
  }

  String _getBadge(AppLocalizations l10n) {
    if (item.notifyType == NotifyType.outOfStock) return l10n.notificationOutOfStockBadge;
    return l10n.notificationLowStockBadge;
  }

  String _getMessage(AppLocalizations l10n) {
    final name = item.productName ?? item.sku;
    final qty = item.productQuantity?.toString() ?? '0';
    if (item.notifyType == NotifyType.outOfStock) return l10n.notificationOutOfStockMessage(name);
    return l10n.notificationLowStockMessage(qty, name);
  }

  String _getQuantityHint(AppLocalizations l10n) {
    return l10n.quantityUnits(item.productQuantity?.toString() ?? '0');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        final isUnread = !item.read;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _priorityBg(),
            borderRadius: BorderRadius.circular(16),
            border: _cardBorder(),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isUnread ? 0.03 : 0.01),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: isMobile
              ? Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row: Checkbox, Icon, Title + Badge, and Actions
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Checkbox
                          Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: InkWell(
                              onTap: onToggleCheck,
                              borderRadius: BorderRadius.circular(6),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: checked ? AppColors.secondaryColor : Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: checked
                                        ? AppColors.secondaryColor
                                        : AppColors.borderColor.withOpacity(0.8),
                                    width: 1.5,
                                  ),
                                ),
                                child: checked
                                    ? const Icon(
                                        LucideIcons.check,
                                        color: Colors.white,
                                        size: 12,
                                      )
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          
                          // Icon
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: item.read
                                  ? AppColors.mutedColor.withOpacity(0.08)
                                  : _priorityPrimary().withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              item.icon,
                              color: item.read ? AppColors.mutedColor : _priorityPrimary(),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          
                          // Title + Badge
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getTitle(l10n),
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: item.read ? AppColors.textSecondary : AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                _Badge(
                                  label: _getBadge(l10n),
                                  color: item.read ? AppColors.mutedColor : _priorityPrimary(),
                                  compact: true,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          
                          // Mobile Actions
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: onMarkReadToggle,
                                icon: Icon(
                                  item.read ? LucideIcons.eye : LucideIcons.eyeOff,
                                  size: 14,
                                ),
                                color: item.read ? AppColors.secondaryColor : AppColors.mutedColor,
                                style: IconButton.styleFrom(
                                  backgroundColor: item.read 
                                      ? AppColors.secondaryColor.withOpacity(0.08)
                                      : Colors.white,
                                  padding: const EdgeInsets.all(6),
                                  minimumSize: const Size(28, 28),
                                ),
                              ),
                              const SizedBox(width: 6),
                              IconButton(
                                onPressed: onDelete,
                                icon: const Icon(
                                  LucideIcons.trash2,
                                  size: 14,
                                ),
                                color: AppColors.errorColor,
                                style: IconButton.styleFrom(
                                  backgroundColor: AppColors.errorColor.withOpacity(0.08),
                                  padding: const EdgeInsets.all(6),
                                  minimumSize: const Size(28, 28),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      // Message Body
                      Padding(
                        padding: const EdgeInsetsDirectional.only(start: 38.0),
                        child: Text(
                          _getMessage(l10n),
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            color: item.read ? AppColors.mutedColor : AppColors.textSecondary,
                            height: 1.3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      
                      // Chips
                      Padding(
                        padding: const EdgeInsetsDirectional.only(start: 38.0),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _MetaChip(
                                icon: LucideIcons.hash,
                                text: item.sku,
                                compact: true,
                              ),
                              if (item.quantityHint != null) ...[
                                const SizedBox(width: 6),
                                _MetaChip(
                                  icon: LucideIcons.package2,
                                  text: _getQuantityHint(l10n),
                                  compact: true,
                                ),
                              ],
                              const SizedBox(width: 6),
                              _MetaChip(
                                  icon: LucideIcons.clock,
                                  text: item.createdAgo,
                                  compact: true,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 1. Checkbox
                      InkWell(
                        onTap: onToggleCheck,
                        borderRadius: BorderRadius.circular(6),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: checked ? AppColors.secondaryColor : Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: checked
                                  ? AppColors.secondaryColor
                                  : AppColors.borderColor.withOpacity(0.8),
                              width: 1.5,
                            ),
                          ),
                          child: checked
                              ? const Icon(
                                  LucideIcons.check,
                                  color: Colors.white,
                                  size: 14,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 14),
                      
                      // 2. Icon Indicator
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: item.read
                              ? AppColors.mutedColor.withOpacity(0.08)
                              : _priorityPrimary().withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          item.icon,
                          color: item.read ? AppColors.mutedColor : _priorityPrimary(),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // 3. Main Text Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    _getTitle(l10n),
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: item.read ? AppColors.textSecondary : AppColors.textPrimary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _Badge(
                                  label: _getBadge(l10n),
                                  color: item.read ? AppColors.mutedColor : _priorityPrimary(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getMessage(l10n),
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12.5,
                                color: item.read ? AppColors.mutedColor : AppColors.textSecondary,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                _MetaChip(
                                  icon: LucideIcons.hash,
                                  text: l10n.productCode(item.sku),
                                ),
                                if (item.quantityHint != null) ...[
                                  const SizedBox(width: 8),
                                  _MetaChip(
                                    icon: LucideIcons.package2,
                                    text: _getQuantityHint(l10n),
                                  ),
                                ],
                                const SizedBox(width: 8),
                                _MetaChip(
                                  icon: LucideIcons.clock,
                                  text: item.createdAgo,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // 4. Actions (Mark as Read, Delete)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Mark as Read button
                          Tooltip(
                            message: item.read ? l10n.markAsReadUnread : l10n.markAsRead,
                            child: IconButton(
                              onPressed: onMarkReadToggle,
                              icon: Icon(
                                item.read ? LucideIcons.eye : LucideIcons.eyeOff,
                                size: 16,
                              ),
                              color: item.read ? AppColors.secondaryColor : AppColors.mutedColor,
                              style: IconButton.styleFrom(
                                backgroundColor: item.read 
                                    ? AppColors.secondaryColor.withOpacity(0.08)
                                    : Colors.white,
                                side: BorderSide(
                                  color: item.read 
                                      ? AppColors.secondaryColor.withOpacity(0.2)
                                      : AppColors.borderColor.withOpacity(0.6),
                                ),
                                padding: const EdgeInsets.all(8),
                                minimumSize: const Size(34, 34),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Delete button
                          Tooltip(
                            message: l10n.deleteNotification,
                            child: IconButton(
                              onPressed: onDelete,
                              icon: const Icon(
                                LucideIcons.trash2,
                                size: 16,
                              ),
                              color: AppColors.errorColor,
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.errorColor.withOpacity(0.08),
                                side: BorderSide(
                                  color: AppColors.errorColor.withOpacity(0.2),
                                ),
                                padding: const EdgeInsets.all(8),
                                minimumSize: const Size(34, 34),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.color,
    this.compact = false,
  });

  final String label;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        border: Border.all(color: color.withOpacity(0.24)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w800,
            fontFamily: 'Cairo',
            fontSize: compact ? 10 : 11,
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.text,
    this.compact = false,
  });

  final IconData icon;
  final String text;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderColor.withOpacity(0.8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: compact ? 12 : 14,
            color: AppColors.mutedColor,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: compact ? 10 : 11,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
