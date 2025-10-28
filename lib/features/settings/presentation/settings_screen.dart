// settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crazy_phone_pos/core/components/screen_header.dart';
import 'package:crazy_phone_pos/core/constants/app_colors.dart';
import 'package:crazy_phone_pos/features/auth/presentation/cubit/user_cubit.dart';
import 'package:crazy_phone_pos/features/settings/data/data_source/store_info_data_source.dart';
import 'package:crazy_phone_pos/features/settings/presentation/cubit/settings_cubit.dart';
import '../../../core/di/dependency_injection.dart';

import '../../auth/data/models/user_model.dart';
import '../data/repository/settings_repository_imp.dart';
import 'widgets/logout_warning_banner.dart';
import 'widgets/store_info_card.dart';
import 'widgets/users_management_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<UserCubit>.value(value: getIt<UserCubit>()..getAllUsers()),
        BlocProvider(
          create: (context) => SettingsCubit(
            userCubit: getIt<UserCubit>(),
            storeRepository: StoreInfoRepository(
              dataSource: StoreInfoDataSource(),
            ),
          ),
        )
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
        body: SafeArea(
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
                          StoreInfoCard(isMobile: isMobile),
                          SizedBox(height: isMobile ? 12 : 16),
                            getIt<UserCubit>().currentUser.userType==UserType.cashier? SizedBox():
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
    );
  }
}
