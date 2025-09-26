import 'package:flutter/material.dart';

import 'package:lucide_icons/lucide_icons.dart';
import '../../auth/presentation/widgets/custom_button.dart';


class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // بيانات Placeholder ديناميكية للإعدادات
    final settingsOptions = [
      {
        'title': 'تغيير اللغة',
        'subtitle': 'اختر اللغة المناسبة للنظام',
        'icon': LucideIcons.globe,
      },
      {
        'title': 'إدارة الحساب',
        'subtitle': 'تحديث البيانات الشخصية وكلمة المرور',
        'icon': LucideIcons.user,
      },
      {
        'title': 'المظهر',
        'subtitle': 'التبديل بين الوضع الليلي والفاتح',
        'icon': LucideIcons.moon,
      },
    ];

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'الإعدادات',
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'إعدادات النظام وإدارة المستخدمين',
              style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
            ),
            const SizedBox(height: 24),

            // Content
            Expanded(
              child: ListView(
                children: [
                  // خيارات الإعدادات
                  ...settingsOptions.map(
                    (setting) => Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Icon(
                          setting['icon'] as IconData,
                          color: theme.colorScheme.primary,
                        ),
                        title: Text(
                          setting['title'] as String,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          setting['subtitle'] as String,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color:
                                theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        onTap: () {
                          // Placeholder → هنا ممكن تودّي لصفحات فرعية
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  '${setting['title']} سيتم تفعيلها لاحقاً'),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // زر تسجيل الخروج
                  Center(
                    child: CustomButton(
                      text: 'تسجيل الخروج',
                      icon: LucideIcons.logOut,
                      backgroundColor: theme.colorScheme.error,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('تأكيد تسجيل الخروج'),
                            content: const Text(
                              'هل أنت متأكد من تسجيل الخروج؟',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('إلغاء'),
                              ),
                              TextButton(
                                onPressed: () {
                                  
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'تسجيل الخروج',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
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
    );
  }
}
