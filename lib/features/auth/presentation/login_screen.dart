// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:crazy_phone_pos/core/di/dependency_injection.dart';
import 'package:crazy_phone_pos/core/functions/messege.dart';
import 'package:crazy_phone_pos/features/auth/data/repository/user_repository_imp.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/components/logo.dart';


import '../../dashboard/presentation/dashboard_screen.dart';

import 'cubit/user_cubit.dart';
import 'cubit/user_states.dart';
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

  @override

  Widget build(BuildContext context) {
    return BlocProvider<UserCubit>.value(
          value: getIt<UserCubit>(),

      child: LayoutBuilder(
        builder: (context, c) {
          final isMobile = c.maxWidth < 520;
          final pad = isMobile ? 14.0 : 24.0;
          final cardWidth = isMobile ? c.maxWidth - 28 : 500.0;
      
          return BlocListener<UserCubit, UserStates>(
            listener: (context, state) {
              if (state is UserFailure) {
                MotionSnackBarError(context, state.error);
                
              } else if (state is UserSuccess) {
                MotionSnackBarSuccess(context, state.message);
                if (state.message == "تم تسجيل الدخول بنجاح") {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DashboardScreen(),
                      ));
                } else {
                  MotionSnackBarInfo(context, state.message);
                }
              }
            },
            child: Scaffold(
              backgroundColor: const Color(0xFFF8FAFC),
              body: LayoutBuilder(
                builder: (context, c2) {
                  final isShort = c2.maxHeight < 680;
                  final avatarRadius = isMobile
                      ? (isShort ? 56.0 : 68.0)
                      : (isShort ? 76.0 : 92.0);
          
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
                              Logo(
                                  isMobile: isMobile,
                                  avatarRadius: avatarRadius),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          'تسجيل الدخول',
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
                                          'أدخل بياناتك للوصول إلى النظام',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
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
                                        validator: (v) =>
                                            (v == null || v.trim().isEmpty)
                                                ? 'يرجى إدخال اسم المستخدم'
                                                : null,
                                      ),
                                      const SizedBox(height: 14),
                                      BlocBuilder<UserCubit, UserStates>(
                                        builder: (context, state) {
                                          final cubit = UserCubit.get(context);
                                          final isPasswordVisible =
                                              cubit.isPasswordVisible;
                                          return CustomTextField(
                                            controller: _passwordController,
                                            onEditingComplete: (){
                                              _handleLogin(context);
                                            },
                                            label: 'كلمة المرور',
                                            prefixIcon: isPasswordVisible
                                                ? LucideIcons.unlock
                                                : LucideIcons.lock,
                                            obscureText: !isPasswordVisible,
                                            textDirection: TextDirection.rtl,
                                            suffixIcon: isPasswordVisible
                                                ? LucideIcons.eye
                                                : LucideIcons.eyeOff,
                                            onSuffixTap: () {
                                              UserCubit.get(context)
                                                  .togglePasswordVisibility();
                                            },
                                            validator: (v) =>
                                                (v == null || v.isEmpty)
                                                    ? 'يرجى إدخال كلمة المرور'
                                                    : null,
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 20),
                                      BlocBuilder<UserCubit, UserStates>(
                                        builder: (context, state) =>
                                            CustomButton(
                                          text: (state is UserLoading)
                                              ? 'جاري تسجيل الدخول...'
                                              : 'تسجيل الدخول',
                                          onPressed: (state is UserLoading)
                                              ? null
                                              : () {
                                                  _handleLogin(context);
                                                },
                                          isLoading: (state is UserLoading),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
          
                              const SizedBox(height: 16),
          
                              // Footer
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
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
                                              ?.copyWith(
                                                  color: Colors.grey[600]),
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
            ),
          );
        },
      ),
    );
  }

  void _handleLogin(context) {
    if (_formKey.currentState!.validate()) {
      UserCubit.get(context).login(
        _usernameController.text.trim(),
        _passwordController.text,
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
