import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:data_table_2/data_table_2.dart';

import '../../data/models/user_row.dart';


class DesktopUserTable extends StatelessWidget {
  const DesktopUserTable({
    super.key,
    required this.users,
  });

  final List<UserRow> users;

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
        dataRowColor: WidgetStateProperty.resolveWith<Color?>(
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
        rows: users.map((user) {
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
                        onPressed: () {},
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
                        onPressed: () {},
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
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          LucideIcons.moreVertical,
                          size: 18,
                          color: Colors.grey[600],
                        ),
                        tooltip: 'المزيد',
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
        }).toList(),
      ),
    );
  }
}
