import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:motion_toast/motion_toast.dart';

import '../../features/auth/presentation/login_screen.dart';

void MotionSnackBarSuccess(BuildContext context, String message) {
  MotionToast.success(
    title: Text(
      message,
      style: TextStyle(fontWeight: FontWeight.w700),
    ),
    toastDuration: Duration(seconds: 2),
    toastAlignment: Alignment.bottomRight,
    animationType: AnimationType.slideInFromLeft,
    description: SizedBox(),
    animationDuration: Duration(milliseconds: 400),
    animationCurve: Curves.easeInOut,
    opacity: 0.95,
  ).show(context);
}

void MotionSnackBarError(BuildContext context, String message) {
  MotionToast.error(
    title: Text(
      message,
      style: TextStyle(fontWeight: FontWeight.w700),
    ),
    toastDuration: Duration(seconds: 2),
    toastAlignment: Alignment.bottomRight,
    animationType: AnimationType.slideInFromLeft,
    description: SizedBox(),
    animationDuration: Duration(seconds: 400),
    animationCurve: Curves.easeInOut,
    opacity: 0.95,
  ).show(context);
}

void MotionSnackBarInfo(BuildContext context, String message) {
  MotionToast.info(
    title: Text(
      message,
      style: TextStyle(fontWeight: FontWeight.w700),
    ),
    toastDuration: Duration(seconds: 2),
    toastAlignment: Alignment.bottomRight,
    animationType: AnimationType.slideInFromLeft,
    description: SizedBox(),
    animationDuration: Duration(milliseconds: 400),
    animationCurve: Curves.easeInOut,
    opacity: 0.95,
  ).show(context);
}

void MotionSnackBarWarning(BuildContext context, String message) {
  MotionToast.warning(
    title: Text(
      message,
      style: TextStyle(fontWeight: FontWeight.w700),
    ),
    toastDuration: Duration(seconds: 3),
    toastAlignment: Alignment.topRight,
    animationType: AnimationType.slideInFromLeft,
    description: SizedBox(),
    animationDuration: Duration(milliseconds: 400),
    animationCurve: Curves.easeInOut,
    opacity: 0.95,
  ).show(context);
}

Future<void> handleLogout(BuildContext context) async {
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
