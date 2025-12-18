import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:crazy_phone_pos/core/constants/app_colors.dart';

class ActivationScreen extends StatelessWidget {
  const ActivationScreen({super.key});

  
  final String phone = "+201025461241";
  final String email = "mstfo23mr5@gmail.com";
  final String whatsapp = "https://wa.me/201025461241";
  Future<void> openGmail(String email, {String? subject, String? body}) async {
    final Uri gmailUrl = Uri.parse(
      'https://mail.google.com/mail/?view=cm&fs=1'
      '&to=$email'
      '&su=${Uri.encodeComponent(subject ?? '')}'
      '&body=${Uri.encodeComponent(body ?? '')}',
    );

    if (Platform.isWindows) {
      await Process.start('cmd', ['/c', 'start', gmailUrl.toString()]);
    } else {
      throw UnsupportedError("Not supported on this platform");
    }
  }

  Future<void> _launch(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint("❌ Launch error: $e");
      // لو عايز تظهر SnackBar أو Dialog
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 520;
    final pad = isMobile ? 14.0 : 24.0;
    final cardWidth = isMobile ? MediaQuery.of(context).size.width - 28 : 500.0;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Center(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.all(pad),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo (نفس فكرة صفحة الوجن)
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                    child: Icon(
                      LucideIcons.lock,
                      size: 50,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // الكارد الرئيسي
                  Container(
                    width: cardWidth,
                    padding: EdgeInsets.all(isMobile ? 20 : 28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '🔒 النسخة غير مفعّلة',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 6),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'يبدو أنك تستخدم نسخة غير مفعّلة من النظام.\nيرجى التواصل مع المطور لتفعيل نسختك.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppColors.mutedColor,
                                  fontWeight: FontWeight.w500,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () => _launch("tel:$phone"),
                          icon: const Icon(LucideIcons.phone),
                          label: const Text("اتصل بي"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            openGmail(
                              "mstfo23mr5@gmail.com",
                              subject: "طلب تفعيل التطبيق",
                              body: "مرحبًا، أود شراء نسخة من التطبيق.",
                            );
                          },
                          icon: const Icon(LucideIcons.mail),
                          label: const Text("راسلني عبر البريد"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.successColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () => _launch(whatsapp),
                          icon: const Icon(LucideIcons.messageCircle),
                          label: const Text("تواصل عبر واتساب"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentGold,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    '© 2025 Amr Store. جميع الحقوق محفوظة',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.mutedColor),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
