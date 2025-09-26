import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // بيانات وهمية Placeholder
    final notifications = [
      {
        'title': 'طلب جديد',
        'message': 'تم استلام طلب جديد من العميل رقم #1023',
        'icon': LucideIcons.shoppingCart,
        'color': Colors.blue,
      },
      {
        'title': 'نفاذ منتج',
        'message': 'المنتج "سكر 1 كجم" أوشك على النفاذ',
        'icon': LucideIcons.alertTriangle,
        'color': Colors.orange,
      },
      {
        'title': 'نجاح العملية',
        'message': 'تم تحديث المخزون بنجاح',
        'icon': LucideIcons.checkCircle,
        'color': Colors.green,
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
              'التنبيهات',
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'إدارة التنبيهات والإشعارات',
           style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
            ),
            const SizedBox(height: 24),

            // Content
            Expanded(
              child: notifications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            LucideIcons.bell,
                            size: 64,
                            color: theme.colorScheme.onSurface.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'لا توجد تنبيهات جديدة',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'سيتم عرض التنبيهات هنا عند توفرها',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color:
                                    (notification['color'] as Color).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                notification['icon'] as IconData,
                                color: notification['color'] as Color,
                              ),
                            ),
                            title: Text(
                              notification['title'] as String,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              notification['message'] as String,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
