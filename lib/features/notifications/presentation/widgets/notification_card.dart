import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../dashboard/data/models/notify_model.dart';
import 'package:bayaa_pos/core/constants/app_colors.dart';

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
    switch (item.priority) {
      case NotifyPriority.high:
        return const Color(0xFFFEF2F2); // Soft light red
      case NotifyPriority.medium:
        return const Color(0xFFFFF7ED); // Soft light orange
    }
  }

  Color _priorityBorder() {
    switch (item.priority) {
      case NotifyPriority.high:
        return const Color(0xFFFCA5A5).withOpacity(0.6); // Soft red border
      case NotifyPriority.medium:
        return const Color(0xFFFED7AA).withOpacity(0.6); // Soft orange border
    }
  }

  Color _priorityPrimary() {
    switch (item.priority) {
      case NotifyPriority.high:
        return AppColors.errorColor;
      case NotifyPriority.medium:
        return AppColors.warningColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return Container(
          decoration: BoxDecoration(
            color: _priorityBg(),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _priorityBorder(), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.015),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Top Action bar
              Padding(
                padding: EdgeInsetsDirectional.only(
                  top: isMobile ? 6 : 8,
                  start: isMobile ? 8 : 12,
                  end: isMobile ? 8 : 12,
                ),
                child: Row(
                  children: [
                    // Custom Checkbox
                    InkWell(
                      onTap: onToggleCheck,
                      borderRadius: BorderRadius.circular(6),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color:
                              checked ? AppColors.secondaryColor : Colors.white,
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
                    const Spacer(),
                    // Mark as read/unread
                    Tooltip(
                      message: item.read ? 'وضع كغير مقروء' : 'وضع كمقروء',
                      child: IconButton(
                        onPressed: onMarkReadToggle,
                        icon: Icon(
                          item.read ? LucideIcons.eye : LucideIcons.eyeOff,
                          size: 16,
                        ),
                        color: AppColors.mutedColor,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.all(6),
                          minimumSize: const Size(30, 30),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Trash Delete Button
                    Tooltip(
                      message: 'حذف التنبيه',
                      child: IconButton(
                        onPressed: onDelete,
                        icon: const Icon(
                          LucideIcons.trash2,
                          size: 16,
                        ),
                        color: AppColors.errorColor,
                        style: IconButton.styleFrom(
                          backgroundColor:
                              AppColors.errorColor.withOpacity(0.08),
                          padding: const EdgeInsets.all(6),
                          minimumSize: const Size(30, 30),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Card Body
              if (isMobile)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _priorityPrimary().withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(item.icon,
                                color: _priorityPrimary(), size: 20),
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
                                        style: const TextStyle(
                                          fontFamily: 'Cairo',
                                          fontWeight: FontWeight.w800,
                                          fontSize: 13,
                                          color: AppColors.textPrimary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    _Badge(
                                      label: item.badge,
                                      color: _priorityPrimary(),
                                      compact: true,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.message,
                                  style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                    height: 1.3,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
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
                                text: item.quantityHint!,
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
                    ],
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _priorityPrimary().withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(item.icon,
                            color: _priorityPrimary(), size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    item.title,
                                    style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _Badge(
                                    label: item.badge,
                                    color: _priorityPrimary()),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.message,
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _MetaChip(
                                  icon: LucideIcons.hash,
                                  text: 'كود المنتج: ${item.sku}',
                                ),
                                if (item.quantityHint != null) ...[
                                  const SizedBox(width: 8),
                                  _MetaChip(
                                    icon: LucideIcons.package2,
                                    text: item.quantityHint!,
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
                    ],
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
