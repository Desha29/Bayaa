import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crazy_phone_pos/core/components/screen_header.dart';
import 'package:crazy_phone_pos/core/constants/app_colors.dart';
import 'package:crazy_phone_pos/features/auth/presentation/cubit/user_cubit.dart';

import 'package:crazy_phone_pos/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:crazy_phone_pos/core/functions/messege.dart';
import '../../../core/di/dependency_injection.dart';

import '../../arp/data/models/daily_report_model.dart';
import '../../arp/presentation/screens/daily_report_preview_screen.dart'; // Corrected import
import '../../auth/data/models/user_model.dart';
import '../../auth/presentation/cubit/user_states.dart';

import 'widgets/logout_warning_banner.dart';
import 'widgets/store_info_card.dart';
import 'widgets/users_management_card.dart';
import 'widgets/close_day_card.dart';
// import 'widgets/data_protection_card.dart'; // Commented out as in user code

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<UserCubit>.value(value: getIt<UserCubit>()..getAllUsers()),
        BlocProvider.value(value: getIt<SettingsCubit>()),
      ],
      child: const _SettingsScreenContent(),
    );
  }
}

class _SettingsScreenContent extends StatelessWidget {
  const _SettingsScreenContent();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: BlocListener<UserCubit, UserStates>(
          listener: (context, state) {
            if (state is CloseSessionLoading) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (c) =>
                    const Center(child: CircularProgressIndicator()),
              );
            } else if (state is UserFailure) {
              if (state.error.contains("إغلاق")) {
                Navigator.of(context, rootNavigator: true)
                    .pop(); // Close loading only for session closure
              }
              // Replace SnackBar with MotionToast
              MotionSnackBarError(context, state.error);
            } else if (state is UserSuccessWithReport) {
              Navigator.of(context, rootNavigator: true).pop(); // Close loading

              final userCubit = getIt<UserCubit>();
              if (userCubit.currentUser.userType == UserType.manager) {
                _showReportDialog(context, state.report);
              } else {
                // For Cashier: Immediate Logout, No Report Dialog
                MotionSnackBarSuccess(
                    context, "تم إغلاق الجلسة بنجاح. جاري تسجيل الخروج...");
                // Short delay to let the toast show
                Future.delayed(const Duration(milliseconds: 1500), () {
                  userCubit.logout();
                   Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                });
              }
            } else if (state is UserSuccess) {
              // Replace SnackBar with MotionToast
              MotionSnackBarSuccess(context, state.message);
            }
          },
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;
                final padding = isMobile ? 16.0 : 24.0;

                return Padding(
                  padding: EdgeInsets.all(padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const ScreenHeader(
                        title: 'الإعدادات',
                        subtitle: 'إعدادات النظام وإدارة المستخدمين',
                        icon: Icons.settings,
                        titleColor: AppColors.kDarkChip,
                        iconColor: AppColors.primaryColor,
                      ),
                      SizedBox(height: isMobile ? 12 : 16),
                      LogoutWarningBanner(isMobile: isMobile),
                      SizedBox(height: isMobile ? 12 : 16),
                      Expanded(
                        child: ListView(
                          children: [
                            // DataProtectionCard(isMobile: isMobile),
                            // SizedBox(height: isMobile ? 12 : 16),
                            StoreInfoCard(isMobile: isMobile),
                            SizedBox(height: isMobile ? 12 : 16),
                            CloseDayCard(isMobile: isMobile),
                            SizedBox(height: isMobile ? 12 : 16),
                            if (getIt<UserCubit>().currentUser.userType !=
                                UserType.cashier)
                              UsersManagementCard(isMobile: isMobile),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showReportDialog(BuildContext context, DailyReport report) {
    final userCubit = getIt<UserCubit>();
    final isManager = userCubit.currentUser.userType == UserType.manager;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('تم إغلاق الجلسة بنجاح'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('تم حفظ تقرير الجلسة بنجاح.'),
            const SizedBox(height: 16),
            Text(
              isManager
                  ? 'يمكنك الآن عرض التقرير التفصيلي للجلسة.'
                  : 'سيتم تسجيل الخروج الآن.',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (isManager) {
                // Navigate to Daily Report Preview Screen
                 Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => DailyReportPreviewScreen(report: report), // Use Preview Screen
                  ),
                );
              } else {
                userCubit.logout();
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              }
            },
            child: Text(isManager ? 'عرض تقرير الجلسة' : 'حسناً'),
          ),
        ],
      ),
    );
  }
}
