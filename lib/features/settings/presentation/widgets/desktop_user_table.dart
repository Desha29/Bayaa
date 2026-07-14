import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:data_table_2/data_table_2.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/presentation/cubit/user_cubit.dart';
import '../../data/models/user_row.dart';
import 'add_edit_user_dialog.dart';
import 'package:bayaa_pos/core/constants/app_colors.dart';
import '../../../../core/components/local_image_view.dart';

class DesktopUserTable extends StatelessWidget {
  const DesktopUserTable({
    super.key,
    required this.users,
    required this.usersData,
  });

  final List<UserRow> users;
  final List<User> usersData;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      height: 400,
      child: DataTable2(
        columnSpacing: 24,
        horizontalMargin: 16,
        minWidth: 900,
        headingRowHeight: 52,
        dataRowHeight: 64,
        headingRowColor:
            WidgetStateProperty.all(AppColors.borderColor.withOpacity(0.24)),
        headingTextStyle: const TextStyle(
          fontFamily: 'Cairo',
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w800,
          fontSize: 13,
        ),
        dataRowColor: WidgetStateProperty.resolveWith(
          (states) {
            if (states.contains(WidgetState.hovered)) {
              return AppColors.primaryColor.withOpacity(0.03);
            }
            return null;
          },
        ),
        border: TableBorder(
          horizontalInside: BorderSide(
              color: AppColors.borderColor.withOpacity(0.8), width: 1),
          bottom: BorderSide(
              color: AppColors.borderColor.withOpacity(0.8), width: 1),
        ),
        columns: [
          DataColumn2(
              label: Center(child: Text(l10n.fullName)), size: ColumnSize.L),
          DataColumn2(
              label: Center(child: Text(l10n.usernameColumn)),
              size: ColumnSize.L),
          DataColumn2(
              label: Center(child: Text(l10n.permission)), size: ColumnSize.M),
          DataColumn2(
              label: Center(child: Text(l10n.accountStatus)),
              size: ColumnSize.S),
          DataColumn2(
              label: Center(child: Text(l10n.lastLoginColumn)),
              size: ColumnSize.M),
          DataColumn2(
              label: Center(child: Text(l10n.actions)), fixedWidth: 140),
        ],
        rows: List.generate(users.length, (index) {
          final user = users[index];
          final userData = usersData[index];

          return DataRow2(
            cells: [
              DataCell(
                Row(
                  children: [
                    LocalImageView(
                      path: userData.imagePath,
                      width: 36,
                      height: 36,
                      borderRadius: 18,
                      fallback: Container(
                        color: AppColors.primaryColor.withOpacity(.1),
                        alignment: Alignment.center,
                        child: const Icon(Icons.person_outline,
                            size: 18, color: AppColors.primaryColor),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        user.name,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              DataCell(
                Center(
                  child: Text(
                    user.email,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              DataCell(
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: user.roleColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: user.roleColor.withOpacity(0.24)),
                    ),
                    child: Text(
                      user.roleLabel,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: user.roleColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              DataCell(
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: user.active
                          ? AppColors.successColor.withOpacity(0.08)
                          : AppColors.errorColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: user.active
                            ? AppColors.successColor.withOpacity(0.24)
                            : AppColors.errorColor.withOpacity(0.24),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      user.active ? l10n.active : l10n.disabled,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: user.active
                            ? AppColors.successColor
                            : AppColors.errorColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              DataCell(
                Center(
                  child: Text(
                    user.lastLogin,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              DataCell(
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildActionButton(
                        context: context,
                        icon: LucideIcons.pencil,
                        tooltip: l10n.editPermissions,
                        color: AppColors.primaryColor,
                        onPressed: getIt<UserCubit>().currentUser.userType ==
                                UserType.cashier
                            ? null
                            : () => _showEditDialog(context, userData),
                      ),
                      const SizedBox(width: 8),
                      _buildActionButton(
                        context: context,
                        icon: LucideIcons.trash2,
                        tooltip: l10n.deleteAccount,
                        color: AppColors.errorColor,
                        onPressed: getIt<UserCubit>().currentUser.userType ==
                                UserType.cashier
                            ? null
                            : () => _showDeleteDialog(context, userData),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String tooltip,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    final isDisabled = onPressed == null;
    final finalColor =
        isDisabled ? AppColors.mutedColor.withOpacity(0.4) : color;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDisabled
                  ? AppColors.borderColor.withOpacity(0.3)
                  : color.withOpacity(0.06),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDisabled
                    ? AppColors.borderColor
                    : color.withOpacity(0.15),
              ),
            ),
            child: Icon(
              icon,
              size: 16,
              color: finalColor,
            ),
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, User user) async {
    await showDialog<User>(
      context: context,
      builder: (dialogContext) => AddEditUserDialog(userToEdit: user),
    );
  }

  void _showDeleteDialog(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final l10n = AppLocalizations.of(context);
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.errorColor.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.userMinus,
                    color: AppColors.errorColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  l10n.confirmDeleteUser,
                  style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
              ),
            ],
          ),
          content: Text(
            l10n.confirmDeleteUserMessage(user.name),
            style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: AppColors.textSecondary),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.borderColor),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      l10n.cancel,
                      style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      context.read<UserCubit>().deleteUser(user.username);
                      if (context.mounted) {
                        context.read<UserCubit>().getAllUsers();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.errorColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    child: Text(
                      l10n.delete,
                      style: const TextStyle(
                          fontFamily: 'Cairo', fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
