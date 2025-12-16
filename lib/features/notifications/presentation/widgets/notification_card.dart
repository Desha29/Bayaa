import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../dashboard/data/models/notify_model.dart';

import 'package:crazy_phone_pos/core/constants/app_colors.dart';

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

  Color _priorityTint() {
    switch (item.priority) {
      case NotifyPriority.high:
        return AppColors.errorColor.withOpacity(0.1);
      case NotifyPriority.medium:
        return AppColors.warningColor.withOpacity(0.1);
    }
  }

  Color _priorityBorder() {
    switch (item.priority) {
      case NotifyPriority.high:
        return AppColors.errorColor.withOpacity(0.3);
      case NotifyPriority.medium:
        return AppColors.warningColor.withOpacity(0.3);
    }
  }

  Color _iconColor() {
    switch (item.priority) {
      case NotifyPriority.high:
        return AppColors.errorColor;
      case NotifyPriority.medium:
        return AppColors.warningColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return Container(
          decoration: BoxDecoration(
            color: _priorityTint(),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _priorityBorder()),
          ),
          child: Column(
            children: [
              // Action bar
              Padding(
                padding: EdgeInsetsDirectional.only(
                  top: isMobile ? 6 : 8,
                  start: isMobile ? 6 : 8,
                  end: isMobile ? 6 : 8,
                ),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'حذف',
                      onPressed: onDelete,
                      icon: Icon(
                        LucideIcons.trash2,
                        size: isMobile ? 16 : 18,
                      ),
                      color: AppColors.errorColor,
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.errorColor.withOpacity(0.1),
                        padding: EdgeInsets.all(isMobile ? 6 : 8),
                        minimumSize:
                            Size(isMobile ? 32 : 40, isMobile ? 32 : 40),
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      tooltip: checked ? 'إلغاء التحديد' : 'تحديد',
                      onPressed: onToggleCheck,
                      icon: Icon(
                        checked ? LucideIcons.checkSquare : LucideIcons.square,
                        size: isMobile ? 16 : 18,
                      ),
                      color: AppColors.mutedColor,
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.mutedColor.withOpacity(0.15),
                        padding: EdgeInsets.all(isMobile ? 6 : 8),
                        minimumSize:
                            Size(isMobile ? 32 : 40, isMobile ? 32 : 40),
                      ),
                    ),
                  ],
                ),
              ),

              // Card body
              if (isMobile)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: _iconColor().withOpacity(0.12),
                            child:
                                Icon(item.icon, color: _iconColor(), size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        item.title,
                                        style: text.titleSmall?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    _Badge(
                                      label: item.badge,
                                      color: _iconColor(),
                                      compact: true,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.message,
                                  style: text.bodySmall,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _MetaChip(
                            icon: LucideIcons.hash,
                            text: item.sku,
                            compact: true,
                          ),
                          if (item.quantityHint != null)
                            _MetaChip(
                              icon: LucideIcons.packageOpen,
                              text: item.quantityHint!,
                              compact: true,
                            ),
                          _MetaChip(
                            icon: LucideIcons.clock3,
                            text: item.createdAgo,
                            compact: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          tooltip: item.read ? 'وضع كغير مقروء' : 'وضع كمقروء',
                          onPressed: onMarkReadToggle,
                          icon: Icon(
                            item.read ? LucideIcons.eye : LucideIcons.eyeOff,
                            size: 18,
                          ),
                          color: AppColors.mutedColor,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    radius: 22,
                    backgroundColor: _iconColor().withOpacity(0.12),
                    child: Icon(item.icon, color: _iconColor()),
                  ),
                  title: Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.title,
                          style: text.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _Badge(label: item.badge, color: _iconColor()),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(item.message, style: text.bodyMedium),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 10,
                        runSpacing: 6,
                        children: [
                          _MetaChip(
                            icon: LucideIcons.hash,
                            text: 'كود المنتج: ${item.sku}',
                          ),
                          if (item.quantityHint != null)
                            _MetaChip(
                              icon: LucideIcons.packageOpen,
                              text: item.quantityHint!,
                            ),
                          _MetaChip(
                            icon: LucideIcons.clock3,
                            text: item.createdAgo,
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    tooltip: item.read ? 'وضع كغير مقروء' : 'وضع كمقروء',
                    onPressed: onMarkReadToggle,
                    icon:
                        Icon(item.read ? LucideIcons.eye : LucideIcons.eyeOff),
                    color: AppColors.mutedColor,
                  ),
                ),
            ],
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
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        border: Border.all(color: color.withOpacity(0.35)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: compact ? 10 : 12,
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
        horizontal: compact ? 6 : 8,
        vertical: compact ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.mutedColor.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: compact ? 12 : 14,
            color: AppColors.mutedColor,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: AppColors.mutedColor,
                fontSize: compact ? 11 : 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
