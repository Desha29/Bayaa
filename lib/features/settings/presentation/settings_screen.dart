import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:bayaa_pos/core/components/screen_header.dart';
import 'package:bayaa_pos/core/constants/app_colors.dart';
import 'package:bayaa_pos/features/auth/presentation/cubit/user_cubit.dart';

import 'package:bayaa_pos/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:bayaa_pos/core/functions/messege.dart';
import '../../../core/di/dependency_injection.dart';

import '../../../l10n/app_localizations.dart';
import '../../auth/data/models/user_model.dart';
import '../../auth/presentation/cubit/user_states.dart';

import '../../sessions/data/models/daily_report_model.dart';
import '../../sessions/presentation/screens/daily_report_preview_screen.dart';
import 'widgets/logout_warning_banner.dart';
import 'widgets/store_info_card.dart';
import 'widgets/users_management_card.dart';
import 'widgets/close_day_card.dart';
import 'widgets/data_management_card.dart'; // New Import
// import 'widgets/data_protection_card.dart'; // Commented out as in user code

import 'package:bayaa_pos/core/localization/translation_helper.dart';

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
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: BlocListener<UserCubit, UserStates>(
        listener: (context, state) {
          if (state is CloseSessionLoading) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (c) => const Center(child: CircularProgressIndicator()),
            );
          } else if (state is UserFailure) {
            if (state.error.contains("إغلاق") ||
                state.error.contains("Close") ||
                state.error.contains("closeSession")) {
              Navigator.of(context, rootNavigator: true)
                  .pop(); // Close loading only for session closure
            }
            MotionSnackBarError(
                context, TranslationHelper.translate(context, state.error));
          } else if (state is UserSuccessWithReport) {
            Navigator.of(context, rootNavigator: true).pop(); // Close loading

            final userCubit = getIt<UserCubit>();
            if (userCubit.currentUser.userType == UserType.manager) {
              _showReportDialog(context, state.report);
            } else {
              // For Cashier: Immediate Logout, No Report Dialog
              MotionSnackBarSuccess(
                  context, AppLocalizations.of(context).dayClosedSuccess);
              // Short delay to let the toast show
              Future.delayed(const Duration(milliseconds: 1500), () {
                userCubit.logout();
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/login', (route) => false);
              });
            }
          } else if (state is UserSuccess) {
            MotionSnackBarSuccess(
                context, TranslationHelper.translate(context, state.message));
          }
        },
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: ScreenHeader(
                      title: AppLocalizations.of(context).settings,
                      subtitle:
                          AppLocalizations.of(context).settingsScreenSubtitle,
                      icon: LucideIcons.settings,
                      titleColor: AppColors.kDarkChip,
                      iconColor: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Content
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      children: [
                        LogoutWarningBanner(isMobile: isMobile),
                        const SizedBox(height: 12),
                        // DataProtectionCard(isMobile: isMobile),
                        // SizedBox(height: isMobile ? 12 : 16),
                        if (getIt<UserCubit>().currentUser.userType ==
                            UserType.manager) ...[
                          DataManagementCard(isMobile: isMobile),
                          const SizedBox(height: 12),
                        ],
                        StoreInfoCard(isMobile: isMobile),
                        const SizedBox(height: 12),
                        CloseDayCard(isMobile: isMobile),
                        const SizedBox(height: 12),
                        if (getIt<UserCubit>().currentUser.userType !=
                            UserType.cashier)
                          UsersManagementCard(isMobile: isMobile),
                      ],
                    ),
                  ),
                ],
              );
            },
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
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dialog header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.successColor.withOpacity(0.04),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.successColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        LucideIcons.checkCircle,
                        color: AppColors.successColor,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      AppLocalizations.of(context).dayClosedSuccessReport,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isManager
                          ? AppLocalizations.of(context).savedReportManager
                          : AppLocalizations.of(context).savedReportCashier,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              // Action
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(ctx);
                        if (isManager) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  DailyReportPreviewScreen(report: report),
                            ),
                          );
                        } else {
                          userCubit.logout();
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              '/login', (route) => false);
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isManager
                                  ? LucideIcons.fileText
                                  : LucideIcons.check,
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isManager
                                  ? AppLocalizations.of(context).viewDayReport
                                  : AppLocalizations.of(context).ok,
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
