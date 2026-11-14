import 'package:bayaa_pos/shared/widgets/workspace/record_view_switcher.dart';
import 'package:bayaa_pos/shared/feedback/preview_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:data_table_2/data_table_2.dart';

import 'package:bayaa_pos/app/bootstrap/service_locator.dart';
import 'package:bayaa_pos/l10n/app_localizations.dart';
import 'package:bayaa_pos/features/auth/presentation/models/user_view_data.dart';
import 'package:bayaa_pos/features/auth/presentation/controllers/user_cubit.dart';
import 'package:bayaa_pos/features/settings/presentation/models/user_row_view_data.dart';
import 'package:bayaa_pos/features/settings/presentation/widgets/add_edit_user_dialog.dart';
import 'package:bayaa_pos/shared/theme/app_colors.dart';
import 'package:bayaa_pos/shared/widgets/asset_image_view.dart';
import 'user_account_card.dart';

class DesktopUserTable extends StatelessWidget {
  const DesktopUserTable({
    super.key,
    required this.users,
    required this.usersData,
  });

  final List<UserRowViewData> users;
  final List<UserViewData> usersData;

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      height: 400,
      child: RecordViewSwitcher(
          cardViewBuilder: (context) => LayoutBuilder(builder: (context, size) {
                final scale = MediaQuery.textScalerOf(context).scale(1);
                final width = size.maxWidth;
                final baseColumns = switch (width) {
                  >= 1360 => 8,
                  >= 1180 => 7,
                  >= 1000 => 6,
                  >= 820 => 5,
                  >= 650 => 4,
                  >= 470 => 3,
                  >= 320 => 2,
                  _ => 1,
                };
                final columns =
                    (baseColumns / scale.clamp(1, 2)).floor().clamp(1, 8);
                final canEdit = getIt<UserCubit>().currentUser.userType !=
                    PreviewRole.cashier;
                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: users.length < usersData.length
                      ? users.length
                      : usersData.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      mainAxisExtent: 182 + ((scale - 1).clamp(0, 2) * 112)),
                  itemBuilder: (context, index) => UserAccountCard(
                      user: users[index],
                      details: usersData[index],
                      onEdit: canEdit
                          ? () => _showEditDialog(context, usersData[index])
                          : null,
                      onDelete: canEdit
                          ? () => _showDeleteDialog(context, usersData[index])
                          : null),
                );
              }),
          table: DataTable2(
            columnSpacing: 24,
            horizontalMargin: 16,
            minWidth: 900,
            headingRowHeight: 52,
            dataRowHeight: 64,
            headingRowColor: WidgetStatePropertyAll(AppColors.primaryColor),
            headingTextStyle: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
                color: AppColors.primaryForeground),
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
                  label: Center(child: Text(l10n.fullName)),
                  size: ColumnSize.L),
              DataColumn2(
                  label: Center(child: Text(l10n.usernameColumn)),
                  size: ColumnSize.L),
              DataColumn2(
                  label: Center(child: Text(l10n.permission)),
                  size: ColumnSize.M),
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
                        AssetImageView(
                          path: userData.imagePath,
                          width: 36,
                          height: 36,
                          borderRadius: 18,
                          fallback: Container(
                            color: AppColors.primaryColor.withOpacity(.1),
                            alignment: Alignment.center,
                            child: Icon(Icons.person_outline,
                                size: 18, color: AppColors.primaryColor),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            user.name,
                            style: TextStyle(
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
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
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
                          border: Border.all(
                              color: user.roleColor.withOpacity(0.24)),
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
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
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
                            onPressed:
                                getIt<UserCubit>().currentUser.userType ==
                                        PreviewRole.cashier
                                    ? null
                                    : () => _showEditDialog(context, userData),
                          ),
                          const SizedBox(width: 8),
                          _buildActionButton(
                            context: context,
                            icon: LucideIcons.trash2,
                            tooltip: l10n.deleteAccount,
                            color: AppColors.errorColor,
                            onPressed: getIt<UserCubit>()
                                        .currentUser
                                        .userType ==
                                    PreviewRole.cashier
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
          )),
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

  void _showEditDialog(BuildContext context, UserViewData user) async {
    await showDialog<UserViewData>(
      context: context,
      builder: (dialogContext) => AddEditUserDialog(userToEdit: user),
    );
  }

  void _showDeleteDialog(BuildContext context, UserViewData user) {
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
                child: Icon(LucideIcons.userMinus,
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
            style: TextStyle(
                fontWeight: FontWeight.bold,
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
                      side: BorderSide(color: AppColors.borderColor),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      l10n.cancel,
                      style: TextStyle(
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
                      showPreviewAction(context);
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
