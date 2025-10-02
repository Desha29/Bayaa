import 'package:crazy_phone_pos/core/components/screen_header.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/components/section_card.dart';
import '../../../core/constants/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Mock store data
    final store = {
      'name': 'Crazy Phone',
      'phone': '966+ 11 123 4567',
      'email': 'info@crazyphone.sa',
      'address': 'شارع الملك فهد، الرياض، المملكة العربية السعودية',
      'vat': '123456789012345',
    };

    // Mock users data
    final users = <UserRow>[
      UserRow(
        name: 'أحمد محمد',
        email: 'ahmed@crazyphone.sa',
        roleLabel: 'مدير النظام',
        roleTint: const Color(0xFFFEE2E2),
        roleColor: const Color(0xFFDC2626),
        active: true,
        lastLogin: '١٤٥٣/٢/٣',
      ),
      UserRow(
        name: 'فاطمة علي',
        email: 'fatima@crazyphone.sa',
        roleLabel: 'كاشير',
        roleTint: const Color(0xFFE0F2FE),
        roleColor: const Color(0xFF0369A1),
        active: true,
        lastLogin: '١٤٥٣/٢/٣',
      ),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ScreenHeader(
                  title: 'الإعدادات',
                  subtitle: 'إعدادات النظام وإدارة المستخدمين',
                ),

                const SizedBox(height: 16),

                // Warning banner
                Card(
                  elevation: 0,
                  color: const Color(0xFFFEF2F2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.red.shade200),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Icon(
                            LucideIcons.alertOctagon,
                            color: Colors.red.shade700,
                          ),
                          Text(
                            'سيتم إنهاء جلسة العمل الحالية والعودة إلى شاشة تسجيل الدخول',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.red.shade700,
                            ),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            icon: const Icon(LucideIcons.logOut),
                            label: const Text('تسجيل الخروج'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red.shade700,
                              side: BorderSide(color: Colors.red.shade300),
                            ),
                            onPressed: () {},
                          ),
                          FilledButton.icon(
                            icon: const Icon(LucideIcons.logOut),
                            label: const Text('تسجيل الخروج من النظام'),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Content fills rest
                Expanded(
                  child: ListView(
                    children: [
                      // Store info card
                      SectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  LucideIcons.store,
                                  size: 18,
                                  color: Colors.grey[700],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'معلومات المتجر',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  LucideIcons.shield,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Two-column feel without table: Wrap + fixed label/value rows
                            LayoutBuilder(
                              builder: (context, c) {
                                final isWide = c.maxWidth > 820;
                                final children = [
                                  _LabeledStaticField(
                                    label: 'اسم المتجر',
                                    value: store['name']!,
                                  ),
                                  _LabeledStaticField(
                                    label: 'رقم الهاتف',
                                    value: store['phone']!,
                                  ),
                                  _LabeledStaticField(
                                    label: 'البريد الإلكتروني',
                                    value: store['email']!,
                                  ),
                                  _LabeledStaticField(
                                    label: 'العنوان',
                                    value: store['address']!,
                                    maxLines: 2,
                                  ),
                                  _LabeledStaticField(
                                    label: 'الرقم الضريبي',
                                    value: store['vat']!,
                                  ),
                                ];

                                if (!isWide) {
                                  return Column(
                                    children: [
                                      for (final w in children) ...[
                                        w,
                                        const Divider(height: 28),
                                      ],
                                    ],
                                  );
                                }

                                // Simulate two columns with Wrap
                                return Wrap(
                                  runSpacing: 16,
                                  spacing: 24,
                                  children: [
                                    SizedBox(
                                      width: (c.maxWidth - 24) / 2,
                                      child: Column(
                                        children: [
                                          children[0],
                                          const Divider(height: 28),
                                          children[2],
                                          const Divider(height: 28),
                                          children[4],
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: (c.maxWidth - 24) / 2,
                                      child: Column(
                                        children: [
                                          children[1],
                                          const Divider(height: 28),
                                          children[3],
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: FilledButton.icon(
                                icon: const Icon(LucideIcons.lock),
                                label: const Text('حفظ معلومات المتجر'),
                                onPressed: () {},
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Users list (ListView.builder inside fixed height via shrinkWrap)
                      // Replace the current _SectionCard users list with this DataTable version:
                      SectionCard(
                        child: LayoutBuilder(
                          builder: (context, c) {
                            final t = Theme.of(context).textTheme;
                            // Data source
                            final rows = users.map((u) {
                              return DataRow(

                                cells: [
                                  DataCell(Text(u.name, style: t.bodyMedium)),
                                  DataCell(Text(u.email, style: t.bodyMedium)),
                                  DataCell(
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: u.roleTint,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: u.roleColor.withOpacity(
                                              0.25,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          u.roleLabel,
                                          style: t.labelMedium?.copyWith(
                                            color: u.roleColor,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: u.active
                                              ? const Color(0xFFE7F8EF)
                                              : const Color(0xFFFEE2E2),
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                          border: Border.all(
                                            color: u.active
                                                ? const Color(0xFF34D399)
                                                : const Color(0xFFDC2626),
                                            width: 0.6,
                                          ),
                                        ),
                                        child: Text(
                                          u.active ? 'نشط' : 'غير نشط',
                                          style: t.labelSmall?.copyWith(
                                            color: u.active
                                                ? const Color(0xFF059669)
                                                : const Color(0xFFB91C1C),
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(u.lastLogin, style: t.bodyMedium),
                                  ),
                                  DataCell(
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          onPressed: () {},
                                          icon: const Icon(
                                            LucideIcons.edit,
                                            size: 18,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {},
                                          icon: const Icon(
                                            LucideIcons.trash2,
                                            size: 18,
                                            color: Color(0xFFDC2626),
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {},
                                          icon: const Icon(
                                            LucideIcons.moreVertical,
                                            size: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }).toList();

                            // Header row actions + add button
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      LucideIcons.users,
                                      size: 18,
                                      color: Colors.grey[700],
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'إدارة المستخدمين',
                                      style: t.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const Spacer(),
                                    FilledButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(LucideIcons.plus),
                                      label: const Text('إضافة مستخدم جديد'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Make the table horizontally scrollable if constrained
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: ConstrainedBox(
                                    // Ensure minimum width so columns don't collapse
                                    constraints: const BoxConstraints(
                                      minWidth: 820,
                                    ),
                                    child: DataTable(
                                      headingRowHeight: 42,
                                      dataRowMinHeight: 46,
                                      columnSpacing: 20,
                                      horizontalMargin: 12,
                                      headingTextStyle: t.labelLarge?.copyWith(
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.w700,
                                      ),
                                      columns: const [
                                        DataColumn(label: Text('الاسم')),
                                        DataColumn(
                                          label: Text('البريد الإلكتروني'),
                                        ),
                                        DataColumn(label: Text('الدور')),
                                        DataColumn(label: Text('الحالة')),
                                        DataColumn(label: Text('آخر دخول')),
                                        DataColumn(
                                          label: Center(
                                            child: Text('العمليات'),
                                          ),
                                        ),
                                      ],
                                      rows: rows,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class UserRow {
  UserRow({
    required this.name,
    required this.email,
    required this.roleLabel,
    required this.roleTint,
    required this.roleColor,
    required this.active,
    required this.lastLogin,
  });

  final String name;
  final String email;
  final String roleLabel;
  final Color roleTint;
  final Color roleColor;
  final bool active;
  final String lastLogin;
}

class _LabeledStaticField extends StatelessWidget {
  const _LabeledStaticField({
    required this.label,
    required this.value,
    this.maxLines = 1,
  });
  final String label;
  final String value;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: maxLines > 1
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: t.bodyMedium?.copyWith(color: Colors.grey[700]),
          ),
        ),
        Expanded(
          flex: 5,
          child: Text(
            value,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.left,
            style: t.bodyMedium?.copyWith(color: Colors.grey[900]),
          ),
        ),
      ],
    );
  }
}
