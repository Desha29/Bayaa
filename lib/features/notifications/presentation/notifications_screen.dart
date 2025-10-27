import 'package:crazy_phone_pos/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:crazy_phone_pos/features/notifications/presentation/cubit/notifications_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:crazy_phone_pos/core/components/screen_header.dart';
import '../../../core/components/empty_state.dart';
import '../../../core/components/section_card.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/di/dependency_injection.dart';
import '../../dashboard/data/models/notify_model.dart';
import '../../stock/presentation/cubit/stock_cubit.dart';
import 'widgets/filters_bar.dart';
import 'widgets/notification_card.dart';
import 'widgets/summary_row.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;
              final padding = isMobile ? 16.0 : 24.0;
              final spacing = isMobile ? 12.0 : 20.0;

              return BlocBuilder<NotificationsCubit, NotificationsStates>(
                buildWhen: (previous, current) =>
                    current is! NotificationsError,
                builder: (context, state) {
                  if (state is NotificationsLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
                    );
                  } else if (state is NotificationsLoaded) {
                    return Padding(
                      padding: EdgeInsets.all(padding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header
                          ScreenHeader(
                            title: 'التنبيهات',
                            subtitle: 'إدارة التنبيهات والإشعارات',
                            icon: LucideIcons.bell,
                            titleColor: AppColors.kDarkChip,
                            iconColor: AppColors.primaryColor,
                          ),
                          SizedBox(height: spacing),

                          // Summary
                          SectionCard(
                            child: SummaryRow(
                              total: getIt<NotificationsCubit>().total,
                              opened: getIt<NotificationsCubit>().opened,
                              urgent: getIt<NotificationsCubit>().urgent,
                              unread: getIt<NotificationsCubit>().unread,
                            ),
                          ),
                          SizedBox(height: spacing),

                          // Filters
                          SectionCard(
                            child: FiltersBar(
                              filter: getIt<NotificationsCubit>().filter,
                              onFilterChanged: (f) {
                                getIt<NotificationsCubit>().filterData(f);
                              },
                              total: getIt<NotificationsCubit>().total,
                              unread: getIt<NotificationsCubit>().unread,
                              urgent: getIt<NotificationsCubit>().urgent,
                              onMarkAllRead: () {
                                getIt<NotificationsCubit>().markAllAsRead();
                              },
                              onDeleteSelected:
                                  getIt<NotificationsCubit>().selected.isEmpty
                                      ? null
                                      : () {
                                          getIt<NotificationsCubit>()
                                              .removeSelected();
                                        },
                            ),
                          ),
                          SizedBox(height: isMobile ? 8 : 12),

                          // Notifications list
                          Expanded(
                            child: SectionCard(
                              child: state.notifications.isEmpty
                                  ? EmptyState()
                                  : ListView.separated(
                                      padding:
                                          EdgeInsets.all(isMobile ? 8 : 12),
                                      itemCount: state.notifications.length,
                                      separatorBuilder: (_, __) => SizedBox(
                                        height: isMobile ? 8 : 12,
                                      ),
                                      itemBuilder: (context, index) {
                                        final n = state.notifications[index];
                                        final checked =
                                            getIt<NotificationsCubit>()
                                                .selected
                                                .contains(n.id);
                                        return NotificationCard(
                                          item: n,
                                          checked: checked,
                                          onToggleCheck: () {
                                            if (checked) {
                                              getIt<NotificationsCubit>()
                                                  .removeSelectedId(n.id);
                                            } else {
                                              getIt<NotificationsCubit>()
                                                  .addSelected(n.id);
                                            }
                                          },
                                          onDelete: () {
                                            getIt<NotificationsCubit>()
                                                .removeItem(n.id);
                                          },
                                          onMarkReadToggle: () {
                                            getIt<NotificationsCubit>()
                                                .markItemAsRead(n.id);
                                          },
                                        );
                                      },
                                    ),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Center(
                      child: Text(
                        'حدث خطأ غير متوقع',
                        style: TextStyle(
                          color: AppColors.kDarkChip,
                          fontSize: isMobile ? 16 : 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
