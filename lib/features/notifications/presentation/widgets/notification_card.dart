import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../dashboard/data/models/notify_model.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({super.key, 
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
        return Colors.red.shade50;
      case NotifyPriority.medium:
        return Colors.amber.shade50;
    }
  }

  Color _priorityBorder() {
    switch (item.priority) {
      case NotifyPriority.high:
        return Colors.red.shade200;
      case NotifyPriority.medium:
        return Colors.amber.shade200;
    }
  }

  Color _iconColor() {
    switch (item.priority) {
      case NotifyPriority.high:
        return Colors.red.shade700;
      case NotifyPriority.medium:
        return Colors.amber.shade800;
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: _priorityTint(),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _priorityBorder()),
      ),
      child: Column(
        children: [
          // شريط الأفعال الصغير (حذف – رؤية/تحديد)
          Padding(
            padding: const EdgeInsetsDirectional.only(top: 8, start: 8, end: 8),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'حذف',
                  onPressed: onDelete,
                  icon: const Icon(LucideIcons.trash2, size: 18),
                  color: Colors.red.shade700,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  tooltip: checked ? 'إلغاء التحديد' : 'تحديد',
                  onPressed: onToggleCheck,
                  icon: Icon(
                    checked ? LucideIcons.checkSquare : LucideIcons.square,
                  ),
                  color: Colors.grey.shade700,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                  ),
                ),
              ],
            ),
          ),

          // جسم البطاقة
          ListTile(
            leading: CircleAvatar(
              radius: 22,
              backgroundColor: _iconColor().withOpacity(0.12),
              child: Icon(item.icon, color: _iconColor()),
            ),
            title: Row(
              children: [
                Text(
                  item.title,
                  style: text.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
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
                    _MetaChip(icon: LucideIcons.clock3, text: item.createdAgo),
                  ],
                ),
              ],
            ),
            trailing: IconButton(
              tooltip: item.read ? 'وضع كغير مقروء' : 'وضع كمقروء',
              onPressed: onMarkReadToggle,
              icon: Icon(item.read ? LucideIcons.eye : LucideIcons.eyeOff),
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        border: Border.all(color: color.withOpacity(0.35)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade700),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(color: Colors.grey.shade800, fontSize: 12),
          ),
        ],
      ),
    );
  }
}


