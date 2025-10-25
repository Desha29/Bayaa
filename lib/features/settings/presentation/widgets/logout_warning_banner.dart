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
                  onPressed: () => _handleLogout(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final shouldLogout = await _showLogoutConfirmation(context);

    if (shouldLogout == true && context.mounted) {
      _showLoadingDialog(context);

      try {
        if (context.mounted) {
          Navigator.pop(context);

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );

          Future.delayed(const Duration(milliseconds: 300), () {
            if (context.mounted) {
              MotionSnackBarSuccess(context, "تم تسجيل الخروج بنجاح");
            }
          });
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.pop(context);

          MotionSnackBarError(context, "فشل تسجيل الخروج: $e");
        }
      }
    }
  }

  Future<bool?> _showLogoutConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.logOut,
                color: Colors.red.shade700,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Text(
                'تأكيد تسجيل الخروج',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'هل أنت متأكد من تسجيل الخروج؟',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'سيتم إنهاء جلسة العمل الحالية والعودة إلى شاشة تسجيل الدخول.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          OutlinedButton.icon(
            onPressed: () => Navigator.pop(context, false),
            icon: const Icon(LucideIcons.x),
            label: const Text('إلغاء'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              textStyle:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(LucideIcons.logOut),
            label: const Text('تسجيل الخروج'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              textStyle:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'جاري تسجيل الخروج...',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
