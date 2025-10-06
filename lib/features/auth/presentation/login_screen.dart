// ignore_for_file: use_build_context_synchronously, deprecated_member_use
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/components/logo.dart';
import '../../dashboard/presentation/dashboard_screen.dart';
import 'widgets/custom_button.dart';
import 'widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool isPasswordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final isMobile = c.maxWidth < 520;
        final pad = isMobile ? 14.0 : 24.0;
        final cardWidth = isMobile ? c.maxWidth - 28 : 500.0;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: LayoutBuilder(
            builder: (context, c2) {
              final isShort = c2.maxHeight < 680;
              final avatarRadius = isMobile ? (isShort ? 56.0 : 68.0) : (isShort ? 76.0 : 92.0);

              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 720,
                      minHeight: c2.maxHeight - pad * 2,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(pad),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Logo + titles
                          Logo(isMobile: isMobile, avatarRadius: avatarRadius),
                          SizedBox(height: isShort ? 16 : 24),

                          // Form card
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
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      'تسجيل الدخول',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
                                      'أدخل بياناتك للوصول إلى النظام',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  CustomTextField(
                                    controller: _usernameController,
                                    label: 'اسم المستخدم',
                                    prefixIcon: LucideIcons.user,
                                    textDirection: TextDirection.rtl,
                                    validator: (v) => (v == null || v.trim().isEmpty)
                                        ? 'يرجى إدخال اسم المستخدم'
                                        : null,
                                  ),
                                  const SizedBox(height: 14),

                                  CustomTextField(
                                    controller: _passwordController,
                                    label: 'كلمة المرور',
                                    prefixIcon:
                                        isPasswordVisible ? LucideIcons.unlock : LucideIcons.lock,
                                    obscureText: !isPasswordVisible,
                                    textDirection: TextDirection.rtl,
                                    suffixIcon:
                                        isPasswordVisible ? LucideIcons.eyeOff : LucideIcons.eye,
                                    onSuffixTap: () =>
                                        setState(() => isPasswordVisible = !isPasswordVisible),
                                    validator: (v) =>
                                        (v == null || v.isEmpty) ? 'يرجى إدخال كلمة المرور' : null,
                                  ),
                                  const SizedBox(height: 20),

                                  CustomButton(
                                    text: _isLoading ? 'جاري تسجيل الدخول...' : 'تسجيل الدخول',
                                    onPressed: _isLoading ? null : _handleLogin,
                                    isLoading: _isLoading,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Footer
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      '© 2025 Crazy Phone. جميع الحقوق محفوظة',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: Colors.grey[600]),
                                      textAlign: TextAlign.center,
                                    ),
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
            },
          ),
        );
      },
    );
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      Future.delayed(const Duration(seconds: 2), () async {
        setState(() => _isLoading = false);

        if (_passwordController.text == "123456") {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("تم تسجيل الدخول بنجاح ✅")),
          );
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("كلمة المرور غير صحيحة ❌")),
          );
        }
      });
    }
  }
}
