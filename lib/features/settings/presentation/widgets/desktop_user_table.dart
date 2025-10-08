// desktop_user_table.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/presentation/cubit/user_cubit.dart';
import '../../data/models/user_row.dart';
import 'add_edit_user_dialog.dart';

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
    final theme = Theme.of(context);

    return SizedBox(
      height: 400,
      child: DataTable2(
        columnSpacing: 24,
        horizontalMargin: 16,
        minWidth: 900,
        headingRowHeight: 48,
        dataRowHeight: 64,
        headingRowColor: WidgetStateProperty.all(Colors.grey[100]),
        headingTextStyle: theme.textTheme.labelLarge?.copyWith(
          color: Colors.grey[700],
          fontWeight: FontWeight.w700,
        ),
        dataRowColor: WidgetStateProperty.resolveWith(
          (states) {
            if (states.contains(WidgetState.hovered)) {
              return theme.colorScheme.primary.withOpacity(0.04);
            }
            return null;
          },
        ),
        border: TableBorder(
          horizontalInside: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
        columns: const [
          DataColumn2(label: Text('الاسم'), size: ColumnSize.L),
          DataColumn2(label: Text('البريد الإلكتروني'), size: ColumnSize.L),
          DataColumn2(
            label: Center(child: Text('الدور')),
            size: ColumnSize.M,
          ),
          DataColumn2(
            label: Center(child: Text('الحالة')),
            size: ColumnSize.S,
          ),
          DataColumn2(
            label: Center(child: Text('آخر دخول')),
            size: ColumnSize.M,
          ),
          DataColumn2(
            label: Center(child: Text('العمليات')),
            fixedWidth: 140,
          ),
        ],
        rows: List.generate(users.length, (index) {
          final user = users[index];
          final userData = usersData[index];

          return DataRow2(
            cells: [
              DataCell(
                Text(
                  user.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              DataCell(
                Text(
                  user.email,
                  style: theme.textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              DataCell(
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: user.roleTint,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: user.roleColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      user.roleLabel,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: user.roleColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              DataCell(
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: user.active
                          ? const Color(0xFFE7F8EF)
                          : const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: user.active
                            ? const Color(0xFF34D399)
                            : const Color(0xFFDC2626),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      user.active ? 'نشط' : 'غير نشط',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: user.active
                            ? const Color(0xFF059669)
                            : const Color(0xFFB91C1C),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
              DataCell(
                Center(
                  child: Text(
                    user.lastLogin,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ),
              DataCell(
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: getIt<UserCubit>().currentUser.userType==UserType.cashier ? null :()=> _showEditDialog(context, userData),
                        icon: Icon(
                          LucideIcons.edit,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                        tooltip: 'تعديل',
                        padding: const EdgeInsets.all(6),
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                      IconButton(
                        onPressed: getIt<UserCubit>().currentUser.userType==UserType.cashier ? null :()=> _showDeleteDialog(context, userData),
                        icon: const Icon(
                          LucideIcons.trash2,
                          size: 18,
                          color: Color(0xFFDC2626),
                        ),
                        tooltip: 'حذف',
                        padding: const EdgeInsets.all(6),
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
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

  void _showEditDialog(BuildContext context, User user) async {
    final result = await showDialog<User>(
      context: context,
      builder: (dialogContext) => AddEditUserDialog(userToEdit: user),
    );

    if (result != null && context.mounted) {
      context.read<UserCubit>().saveUser(user);
    }
  }

  void _showDeleteDialog(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف المستخدم "${user.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<UserCubit>().deleteUser(user.username);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
