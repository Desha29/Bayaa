import 'package:bayaa_pos/features/settings/presentation/widgets/appearance_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:bayaa_pos/shared/widgets/screen_header.dart';
import 'package:bayaa_pos/shared/theme/app_colors.dart';
import 'package:bayaa_pos/features/auth/presentation/controllers/user_cubit.dart';

import 'package:bayaa_pos/features/settings/presentation/controllers/settings_cubit.dart';
import 'package:bayaa_pos/shared/feedback/app_messages.dart';
import 'package:bayaa_pos/app/bootstrap/service_locator.dart';

import 'package:bayaa_pos/l10n/app_localizations.dart';
import 'package:bayaa_pos/features/auth/presentation/models/user_view_data.dart';
import 'package:bayaa_pos/features/auth/presentation/controllers/user_state.dart';

import 'package:bayaa_pos/features/settings/presentation/widgets/logout_warning_banner.dart';
import 'package:bayaa_pos/features/settings/presentation/widgets/store_info_card.dart';
import 'package:bayaa_pos/features/settings/presentation/widgets/users_management_card.dart';
import 'package:bayaa_pos/features/settings/presentation/widgets/data_management_card.dart'; // New Import
// import 'package:bayaa_pos/features/settings/presentation/widgets/data_protection_card.dart'; // Commented out as in user code

import 'package:bayaa_pos/shared/localization/translation_helper.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
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
    Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: BlocListener<UserCubit, UserState>(
        listener: (context, state) {
          if (state is UserFailure) {
            showErrorMessage(
                context, TranslationHelper.translate(context, state.error));
          } else if (state is UserSuccess) {
            showSuccessMessage(
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
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: ScreenHeader(
                      title: AppLocalizations.of(context).settings,
                      subtitle:
                          AppLocalizations.of(context).settingsScreenSubtitle,
                      icon: LucideIcons.settings,
                      titleColor: AppColors.kDarkChip,
                      iconColor: AppColors.primaryColor,
                    ),
                  ),
                  const ScreenHeaderGap(height: 12),
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
                            PreviewRole.manager) ...[
                          DataManagementCard(isMobile: isMobile),
                          const SizedBox(height: 12),
                        ],
                        const AppearanceCard(),
                        const SizedBox(height: 12),
                        StoreInfoCard(isMobile: isMobile),
                        const SizedBox(height: 12),
                        if (getIt<UserCubit>().currentUser.userType !=
                            PreviewRole.cashier)
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
}
