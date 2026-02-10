import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/data/models/activity_log.dart';
import '../../../../core/services/activity_logger.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/presentation/cubit/user_cubit.dart';

class RecentOperations extends StatelessWidget {
  const RecentOperations({super.key});

  IconData _getIconForType(ActivityType type) {
    switch (type) {
      case ActivityType.sale:
        return LucideIcons.shoppingCart;
      case ActivityType.refund:
        return LucideIcons.cornerUpLeft;
      case ActivityType.productAdd:
        return LucideIcons.packagePlus;
      case ActivityType.productUpdate:
        return LucideIcons.edit3;
      case ActivityType.productDelete:
        return LucideIcons.trash2;
      case ActivityType.productQuantityUpdate:
        return LucideIcons.package;
      case ActivityType.userAdd:
        return LucideIcons.userPlus;
      case ActivityType.userUpdate:
        return LucideIcons.userCheck;
      case ActivityType.userDelete:
        return LucideIcons.userMinus;
      case ActivityType.sessionOpen:
        return LucideIcons.logIn;
      case ActivityType.sessionClose:
        return LucideIcons.logOut;
    }
  }

  Color _getColorForType(ActivityType type) {
    switch (type) {
      case ActivityType.sale:
        return AppColors.successColor;
      case ActivityType.refund:
        return AppColors.warningColor;
      case ActivityType.productAdd:
        return AppColors.primaryColor;
      case ActivityType.productUpdate:
        return AppColors.accentGold;
      case ActivityType.productDelete:
        return AppColors.errorColor;
      case ActivityType.productQuantityUpdate:
        return Colors.purple;
      case ActivityType.userAdd:
        return Colors.blue;
      case ActivityType.userUpdate:
        return Colors.teal;
      case ActivityType.userDelete:
        return Colors.red;
      case ActivityType.sessionOpen:
        return Colors.green;
      case ActivityType.sessionClose:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryColor.withOpacity(0.1),
                      AppColors.primaryColor.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  LucideIcons.activity, 
                  color: AppColors.primaryColor, 
                  size: 20
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'العمليات الأخيرة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<List<ActivityLog>>(
              stream: ActivityLogger().activitiesStream,
              initialData: ActivityLogger().getRecentActivities(limit: 20),
              builder: (context, snapshot) {
                var activities = snapshot.data ?? [];
                
                // If Cashier, filter ONLY their activities and specific types
                final userCubit = getIt<UserCubit>();
                if (userCubit.currentUser.userType == UserType.cashier) {
                   activities = activities.where((a) => 
                     a.userName == userCubit.currentUser.name &&
                     (a.type == ActivityType.sale || a.type == ActivityType.refund || 
                      a.type == ActivityType.sessionOpen || a.type == ActivityType.sessionClose)
                   ).toList();
                }

                if (activities.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.inbox,
                          size: 48,
                          color: AppColors.mutedColor.withOpacity(0.5),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'لا توجد عمليات حديثة',
                          style: TextStyle(
                            color: AppColors.mutedColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: activities.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.borderColor.withOpacity(0.5),
                  ),
                  itemBuilder: (context, index) {
                    final activity = activities[index];
                    final timeFormat = DateFormat('hh:mm a');
                    final dateFormat = DateFormat('dd/MM');
                    final activityColor = _getColorForType(activity.type);
                    
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  activityColor.withOpacity(0.15),
                                  activityColor.withOpacity(0.08),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getIconForType(activity.type),
                              color: activityColor,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  activity.description,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: AppColors.textPrimary,
                                    height: 1.3,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  activity.userName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.mutedColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                timeFormat.format(activity.timestamp),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                dateFormat.format(activity.timestamp),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.mutedColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
