// users_management_card.dart
import 'package:crazy_phone_pos/core/di/dependency_injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/components/section_card.dart';
import '../../../../core/functions/messege.dart';
import '../../../auth/presentation/cubit/user_cubit.dart';
import '../../../auth/presentation/cubit/user_states.dart';
import '../../../auth/data/models/user_model.dart';
import '../../data/models/user_row.dart';
import 'mobile_user_list.dart';
import 'desktop_user_table.dart';
import 'add_edit_user_dialog.dart';

import 'package:crazy_phone_pos/core/constants/app_colors.dart';

class UsersManagementCard extends StatelessWidget {
  const UsersManagementCard({
    super.key,
    required this.isMobile,
  });

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<UserCubit, UserStates>(
      listener: (context, state) {
        if (state is UserSuccess) {
          MotionSnackBarSuccess(context, state.message);
        } else if (state is UserFailure) {
          MotionSnackBarError(context, state.error);
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
        
        userRows = _convertUsersToRows(usersData);

        return SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    LucideIcons.users,
                    size: 18,
                    color: AppColors.mutedColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'إدارة المستخدمين',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: getIt<UserCubit>().currentUser.userType ==
                            UserType.cashier
                        ? null
                        : () => _showAddUserDialog(context),
                    icon: const Icon(LucideIcons.plus, size: 18),
                    label: Text(isMobile ? 'إضافة' : 'إضافة مستخدم جديد'),
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 12 : 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: isMobile ? 12 : 16),
              if (userRows.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(48.0),
                    child: Column(
                      children: [
                        Icon(
                          LucideIcons.users,
                          size: 48,
                          color: AppColors.mutedColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'لا يوجد مستخدمين',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.mutedColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                DesktopUserTable(
                  users: userRows,
                  usersData: usersData,
                ),
            ],
          ),
        );
      },
    );
  }

  List<UserRow> _convertUsersToRows(List<User> users) {
    return users.map((user) {
      final isManager =
          user.userType == UserType.manager; // ✅ Fixed: was UserType.manager
      return UserRow(
        name: user.name,
        email: user.username,
        roleLabel: isManager ? 'مدير النظام' : 'كاشير',
        roleTint: isManager ? const Color(0xFFFEE2E2) : const Color(0xFFE0F2FE),
        roleColor:
            isManager ? const Color(0xFFDC2626) : const Color(0xFF0369A1),
        active: true,
        lastLogin: 'اليوم',
      );
    }).toList();
  }

  void _showAddUserDialog(BuildContext context) async {
    final result = await showDialog<User>(
      context: context,
      builder: (dialogContext) => const AddEditUserDialog(),
    );

    if (result != null && context.mounted) {
      context.read<UserCubit>().saveUser(result);
    }
  }
}
