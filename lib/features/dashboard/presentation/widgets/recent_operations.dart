// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/data/models/activity_log.dart';
import '../../../../core/services/activity_logger.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/presentation/cubit/user_cubit.dart';

class RecentOperations extends StatefulWidget {
  const RecentOperations({super.key});

  @override
  State<RecentOperations> createState() => _RecentOperationsState();
}

class _RecentOperationsState extends State<RecentOperations> {
  List<SessionActivityGroup> _groups = [];
  bool _loading = true;
  StreamSubscription? _activitySub;

  @override
  void initState() {
    super.initState();
    _loadGrouped();
    // Listen to stream for live updates — store subscription for proper disposal
    _activitySub =
        ActivityLogger().activitiesStream.listen((_) => _loadGrouped());
  }

  @override
  void dispose() {
    _activitySub?.cancel();
    super.dispose();
  }

  Future<void> _loadGrouped() async {
    try {
      final groups =
          await ActivityLogger().getActivitiesGroupedBySession(sessionLimit: 5);
      if (mounted) {
        setState(() {
          _groups = groups;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

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
      case ActivityType.restock:
        return LucideIcons.packagePlus;
      case ActivityType.expense:
        return LucideIcons.dollarSign;
      case ActivityType.invoiceDelete:
        return LucideIcons.fileMinus;
      case ActivityType.printReport:
        return LucideIcons.printer;
      case ActivityType.login:
        return LucideIcons.key;
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
      case ActivityType.restock:
        return Colors.indigo;
      case ActivityType.expense:
        return Colors.brown;
      case ActivityType.invoiceDelete:
        return Colors.redAccent;
      case ActivityType.printReport:
        return Colors.blueGrey;
      case ActivityType.login:
        return Colors.cyan;
    }
  }

  String _getTypeName(ActivityType type) {
    switch (type) {
      case ActivityType.sale:
        return 'بيع';
      case ActivityType.refund:
        return 'استرجاع';
      case ActivityType.productAdd:
        return 'إضافة منتج';
      case ActivityType.productUpdate:
        return 'تعديل منتج';
      case ActivityType.productDelete:
        return 'حذف منتج';
      case ActivityType.productQuantityUpdate:
        return 'تعديل كمية';
      case ActivityType.userAdd:
        return 'إضافة مستخدم';
      case ActivityType.userUpdate:
        return 'تعديل مستخدم';
      case ActivityType.userDelete:
        return 'حذف مستخدم';
      case ActivityType.sessionOpen:
        return 'فتح يوم';
      case ActivityType.sessionClose:
        return 'إغلاق يوم';
      case ActivityType.restock:
        return 'شحنة جديدة';
      case ActivityType.expense:
        return 'مصروفات';
      case ActivityType.invoiceDelete:
        return 'حذف فاتورة';
      case ActivityType.printReport:
        return 'طباعة تقرير';
      case ActivityType.login:
        return 'تسجيل دخول';
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
                  size: 20,
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
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _groups.isEmpty
                    ? _buildEmptyState()
                    : _buildGroupedList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
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

  Widget _buildGroupedList() {
    final userCubit = getIt<UserCubit>();
    final isCashier = userCubit.currentUser.userType == UserType.cashier;

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: _groups.length,
      itemBuilder: (context, groupIndex) {
        final group = _groups[groupIndex];

        // Filter activities for cashier
        var activities = group.activities;
        if (isCashier) {
          activities = activities
              .where((a) =>
                  a.userName == userCubit.currentUser.name &&
                  (a.type == ActivityType.sale ||
                      a.type == ActivityType.refund ||
                      a.type == ActivityType.sessionOpen ||
                      a.type == ActivityType.sessionClose ||
                      a.type == ActivityType.login))
              .toList();
        }

        if (activities.isEmpty) return const SizedBox.shrink();

        // Separate session events from operational activities
        final operationalActivities = activities
            .where((a) =>
                a.type != ActivityType.sessionOpen &&
                a.type != ActivityType.sessionClose)
            .toList();

        // Count logins for summary
        final loginCount =
            activities.where((a) => a.type == ActivityType.login).length;

        // Sort operational activities: newest first
        operationalActivities
            .sort((a, b) => b.timestamp.compareTo(a.timestamp));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Session header with operation count
            _buildSessionHeader(group,
                operationCount: operationalActivities.length),
            // Login summary if any
            if (loginCount > 0) _buildLoginSummary(loginCount),
            // Operational activities (no session open/close/login clutter)
            ...operationalActivities
                .map((activity) => _buildActivityTile(activity)),
            // Empty state for session with no real operations
            if (operationalActivities.isEmpty && loginCount == 0)
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: Text(
                  'لا توجد عمليات في هذا اليوم بعد',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.mutedColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            // Separator between session groups
            if (groupIndex < _groups.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Divider(
                  thickness: 2,
                  color: AppColors.borderColor.withOpacity(0.3),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildLoginSummary(int count) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.cyan.withOpacity(0.04),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.key, size: 13, color: Colors.cyan.shade600),
          const SizedBox(width: 8),
          Text(
            '$count تسجيل دخول',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.cyan.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionHeader(SessionActivityGroup group,
      {int operationCount = 0}) {
    final timeFormat = DateFormat('hh:mm a');
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: group.isOpen
              ? [Colors.green.withOpacity(0.1), Colors.green.withOpacity(0.03)]
              : [Colors.grey.withOpacity(0.08), Colors.grey.withOpacity(0.02)],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: group.isOpen
              ? Colors.green.withOpacity(0.3)
              : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            group.isOpen ? LucideIcons.playCircle : LucideIcons.checkCircle,
            size: 16,
            color: group.isOpen ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.isOpen
                      ? 'يوم نشط • ${group.openedBy}'
                      : 'يوم مغلق • ${group.openedBy}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: group.isOpen
                        ? Colors.green.shade700
                        : AppColors.textSecondary,
                  ),
                ),
                if (operationCount > 0)
                  Text(
                    '$operationCount عملية',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.mutedColor,
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                dateFormat.format(group.openTime),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                timeFormat.format(group.openTime),
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.mutedColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTile(ActivityLog activity) {
    final timeFormat = DateFormat('hh:mm a');
    final activityColor = _getColorForType(activity.type);

    // Special styling for session open/close
    final isSessionEvent = activity.type == ActivityType.sessionOpen ||
        activity.type == ActivityType.sessionClose;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: isSessionEvent
          ? BoxDecoration(
              color: activityColor.withOpacity(0.04),
              borderRadius: BorderRadius.circular(8),
            )
          : null,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  activityColor.withOpacity(0.15),
                  activityColor.withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getIconForType(activity.type),
              color: activityColor,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: activityColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _getTypeName(activity.type),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: activityColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        activity.description,
                        style: TextStyle(
                          fontWeight: isSessionEvent
                              ? FontWeight.w700
                              : FontWeight.w600,
                          fontSize: 13,
                          color: isSessionEvent
                              ? activityColor
                              : AppColors.textPrimary,
                          height: 1.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  activity.userName,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (activity.details != null &&
                    activity.details!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    ActivityLogger.formatDetailsArabic(
                        activity.type, activity.details),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            timeFormat.format(activity.timestamp),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
