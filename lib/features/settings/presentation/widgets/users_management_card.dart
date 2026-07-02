// ignore_for_file: deprecated_member_use
// users_management_card.dart
import 'package:bayaa_pos/core/di/dependency_injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/functions/messege.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/cubit/user_cubit.dart';
import '../../../auth/presentation/cubit/user_states.dart';
import '../../../auth/data/models/user_model.dart';
import '../../data/models/user_row.dart';

import 'desktop_user_table.dart';
import 'add_edit_user_dialog.dart';

import 'package:bayaa_pos/core/localization/translation_helper.dart';

import 'package:bayaa_pos/core/constants/app_colors.dart';

class UsersManagementCard extends StatelessWidget {
  const UsersManagementCard({
    super.key,
    required this.isMobile,
  });

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserCubit, UserStates>(
      listener: (context, state) {
        if (state is UserSuccess) {
          MotionSnackBarSuccess(
              context, TranslationHelper.translate(context, state.message));
        } else if (state is UserFailure) {
          MotionSnackBarError(
              context, TranslationHelper.translate(context, state.error));
        }
      },
      builder: (context, state) {
        List<UserRow> userRows = [];
        List<User> usersData = [];

        // Use state data if available, otherwise fallback to cached data in Cubit
        // This persists the list even if state changes to UserSuccess etc.
        if (state is UsersLoaded) {
          usersData = state.users as List<User>;
        } else {
          usersData = context.read<UserCubit>().users;
        }

        userRows = _convertUsersToRows(context, usersData);

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.borderColor.withOpacity(0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.015),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Card header
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.borderColor.withOpacity(0.4),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        LucideIcons.users,
                        size: 16,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context).usersManagement,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: getIt<UserCubit>().currentUser.userType ==
                                UserType.cashier
                            ? null
                            : () => _showAddUserDialog(context),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryColor.withOpacity(0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(LucideIcons.plus,
                                  size: 14, color: Colors.white),
                              const SizedBox(width: 6),
                              Text(
                                isMobile
                                    ? AppLocalizations.of(context).add
                                    : AppLocalizations.of(context).addUser,
                                style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Card body
              Padding(
                padding: const EdgeInsets.all(16),
                child: userRows.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.mutedColor.withOpacity(0.05),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  LucideIcons.users,
                                  size: 36,
                                  color: AppColors.mutedColor.withOpacity(0.5),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                AppLocalizations.of(context).noUsers,
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 13,
                                  color: AppColors.mutedColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : DesktopUserTable(
                        users: userRows,
                        usersData: usersData,
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<UserRow> _convertUsersToRows(BuildContext context, List<User> users) {
    final l10n = AppLocalizations.of(context);
    return users.map((user) {
      final isManager =
          user.userType == UserType.manager; // ✅ Fixed: was UserType.manager
      return UserRow(
        name: user.name,
        email: user.username,
        roleLabel: isManager ? l10n.roleManager : l10n.roleCashier,
        roleTint: isManager ? const Color(0xFFFEE2E2) : const Color(0xFFE0F2FE),
        roleColor:
            isManager ? const Color(0xFFDC2626) : const Color(0xFF0369A1),
        active: true,
        lastLogin: l10n.today,
      );
    }).toList();
  }

  void _showAddUserDialog(BuildContext context) async {
    final result = await showDialog<User>(
      context: context,
      builder: (dialogContext) => const AddEditUserDialog(),
    );

    if (result != null && context.mounted) {
      // Dialog handles checking context and saving internally.
      // Do not call saveUser here to avoid duplicates.
    }
  }
}
