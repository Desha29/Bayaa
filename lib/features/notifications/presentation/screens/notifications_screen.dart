import 'package:bayaa_pos/l10n/app_localizations.dart';
import 'package:bayaa_pos/shared/layout/layout_tokens.dart';
import 'package:bayaa_pos/shared/theme/app_colors.dart';
import 'package:bayaa_pos/shared/widgets/empty_state.dart';
import 'package:bayaa_pos/shared/widgets/loading/skeleton.dart';
import 'package:bayaa_pos/shared/widgets/workspace/workspace_panel.dart';
import 'package:bayaa_pos/shared/widgets/workspace/workspace_summary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../controllers/notification_cubit.dart';
import '../controllers/notification_state.dart';
import '../models/notification_view_data.dart';
import '../widgets/filters_bar.dart';
import '../widgets/notification_card.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final ar = l.localeName == 'ar';
    String tr(String en, String arabic) => ar ? arabic : en;
    final cubit = context.read<NotificationCubit>();
    return BlocBuilder<NotificationCubit, NotificationState>(
      buildWhen: (_, state) => state is! NotificationsError,
      builder: (context, state) => LayoutBuilder(builder: (context, size) {
        final padding = LayoutTokens.pagePadding(size.maxWidth);
        if (state is NotificationsLoading) {
          return ListView(padding: padding, children: const [SkeletonList()]);
        }
        if (state is! NotificationsLoaded) {
          return ListView(
              padding: padding,
              children: [EmptyState(title: l.unexpectedError)]);
        }
        final items = [...state.notifications]..sort((a, b) {
            int order(NotifyItem item) =>
                (item.read ? 2 : 0) +
                (item.priority == NotifyPriority.high ? 0 : 1);
            final priority = order(a).compareTo(order(b));
            return priority == 0 ? a.sku.compareTo(b.sku) : priority;
          });
        return ListView(padding: padding, children: [
          WorkspacePanel(
              prominent: true,
              title: tr('Notification inbox', 'صندوق التنبيهات'),
              caption: tr(
                  'Review stock alerts and keep track of what still needs attention.',
                  'راجع تنبيهات المخزون وتابع ما يحتاج إلى مراجعة.'),
              icon: Icons.notifications_outlined,
              child: WorkspaceSummary(metrics: [
                WorkspaceMetric(
                    l.notifications, '${cubit.total}', Icons.inbox_outlined),
                WorkspaceMetric(l.unreadLabel, '${cubit.unread}',
                    Icons.mark_email_unread_outlined,
                    color: AppColors.secondaryColor),
                WorkspaceMetric(l.urgentNotifications, '${cubit.urgent}',
                    Icons.priority_high,
                    color: AppColors.errorColor),
                WorkspaceMetric(tr('Read', 'مقروء'), '${cubit.opened}',
                    Icons.done_all_outlined,
                    color: AppColors.successColor),
              ])),
          const SizedBox(height: 16),
          WorkspacePanel(
              title: tr('Stock messages', 'رسائل المخزون'),
              caption: tr('${items.length} shown · unread and urgent first',
                  'المعروض: ${items.length} · غير المقروء والعاجل أولاً'),
              icon: Icons.markunread_mailbox_outlined,
              child: FiltersBar(
                  filter: cubit.filter,
                  onFilterChanged: cubit.filterData,
                  total: cubit.total,
                  unread: cubit.unread,
                  urgent: cubit.urgent,
                  onMarkAllRead: cubit.markAllAsRead,
                  selectedCount: cubit.selected.length,
                  onDeleteSelected:
                      cubit.selected.isEmpty ? null : cubit.removeSelected)),
          const SizedBox(height: 14),
          if (items.isEmpty)
            EmptyState(
                title: tr(
                    'No messages in this view', 'لا توجد رسائل في هذا العرض'),
                message: tr('Switch filters to see other stock messages.',
                    'غيّر الفلتر لعرض رسائل المخزون الأخرى.'),
                actionText:
                    cubit.filter == NotifyFilter.all ? null : l.allFilter,
                onAction: () => cubit.filterData(NotifyFilter.all))
          else
            AdaptiveColumns(minWidth: 355, maxColumns: 2, children: [
              for (final item in items)
                NotificationCard(
                    key: ValueKey(item.id),
                    item: item,
                    checked: cubit.selected.contains(item.id),
                    onToggleCheck: () => cubit.selected.contains(item.id)
                        ? cubit.removeSelectedId(item.id)
                        : cubit.addSelected(item.id),
                    onDelete: () => cubit.removeItem(item.id),
                    onMarkReadToggle: () => cubit.markItemAsRead(item.id)),
            ]),
        ]);
      }),
    );
  }
}
