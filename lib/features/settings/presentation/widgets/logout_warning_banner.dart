import 'package:crazy_phone_pos/core/functions/messege.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:crazy_phone_pos/features/auth/presentation/login_screen.dart';
import 'package:crazy_phone_pos/core/utils/hive_helper.dart';

class LogoutWarningBanner extends StatelessWidget {
  const LogoutWarningBanner({
    super.key,
    required this.isMobile,
  });

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: const Color(0xFFFEF2F2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.red.shade200),
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  LucideIcons.alertOctagon,
                  color: Colors.red.shade700,
                  size: isMobile ? 20 : 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'سيتم إنهاء جلسة العمل الحالية والعودة إلى شاشة تسجيل الدخول',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.red.shade700,
                      fontSize: isMobile ? 13 : null,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FilledButton.icon(
                  icon: const Icon(LucideIcons.logOut, size: 18),
                  label: Text(isMobile ? 'خروج' : 'تسجيل الخروج'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 12 : 16,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () => handleLogout(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  
}
