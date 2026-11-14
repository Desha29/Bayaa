import 'package:flutter/material.dart';
import 'package:bayaa_pos/l10n/app_localizations.dart';
import 'package:bayaa_pos/shared/theme/app_colors.dart';
import 'package:bayaa_pos/shared/widgets/workspace/workspace_summary.dart';
import '../models/notification_view_data.dart';

enum _AlertAction { read, delete }

class NotificationCard extends StatelessWidget {
  const NotificationCard(
      {super.key,
      required this.item,
      required this.checked,
      required this.onToggleCheck,
      required this.onDelete,
      required this.onMarkReadToggle});
  final NotifyItem item;
  final bool checked;
  final VoidCallback onToggleCheck, onDelete, onMarkReadToggle;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final ar = l.localeName == 'ar';
    final out = item.notifyType == NotifyType.outOfStock;
    final color = out ? AppColors.errorColor : AppColors.warningColor;
    final name = item.productName ?? item.sku;
    final toggleLabel = ar
        ? (item.read ? 'تحديد كغير مقروء' : 'تحديد كمقروء')
        : (item.read ? 'Mark unread' : 'Mark read');
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: checked
            ? AppColors.primaryColor.withValues(alpha: .05)
            : AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: checked ? AppColors.primaryColor : AppColors.borderColor),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                  color: color.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(9)),
              child: Icon(
                  out ? Icons.error_outline : Icons.warning_amber_rounded,
                  size: 19,
                  color: color)),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(name, style: Theme.of(context).textTheme.titleMedium),
                Text(
                    out
                        ? l.notificationOutOfStockTitle
                        : l.notificationLowStockTitle,
                    style:
                        TextStyle(fontSize: 12, color: AppColors.mutedColor)),
              ])),
          Checkbox(
              value: checked,
              onChanged: (_) => onToggleCheck(),
              semanticLabel:
                  ar ? 'تحديد تنبيه $name' : 'Select notification for $name'),
          PopupMenuButton<_AlertAction>(
              tooltip: ar ? 'خيارات التنبيه' : 'Notification actions',
              icon: const Icon(Icons.more_horiz),
              onSelected: (action) => switch (action) {
                    _AlertAction.read => onMarkReadToggle(),
                    _AlertAction.delete => onDelete(),
                  },
              itemBuilder: (_) => [
                    PopupMenuItem(
                        value: _AlertAction.read, child: Text(toggleLabel)),
                    PopupMenuItem(
                        value: _AlertAction.delete,
                        child: Text(l.delete,
                            style: TextStyle(color: AppColors.errorColor))),
                  ]),
        ]),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 6, children: [
          WorkspacePill(
              label: item.read ? (ar ? 'مقروء' : 'Read') : l.unreadLabel,
              color:
                  item.read ? AppColors.mutedColor : AppColors.secondaryColor,
              icon: item.read ? Icons.done : Icons.circle),
          WorkspacePill(
              label: out
                  ? l.notificationOutOfStockBadge
                  : l.notificationLowStockBadge,
              color: color),
          WorkspacePill(
              label: item.sku,
              color: AppColors.mutedColor,
              icon: Icons.qr_code),
          WorkspacePill(
              label: l.quantityUnits('${item.productQuantity ?? 0}'),
              color: AppColors.mutedColor,
              icon: Icons.inventory_2_outlined),
        ]),
      ]),
    );
  }
}
