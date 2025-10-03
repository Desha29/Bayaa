import 'package:crazy_phone_pos/features/auth/data/models/user_model.dart';
import 'package:crazy_phone_pos/features/auth/presentation/cubit/user_states.dart';
import 'package:crazy_phone_pos/features/dashboard/presentation/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/di/dependency_injection.dart';
import '../data/repository/user_repository_imp.dart';
import 'cubit/user_cubit.dart';
import 'widgets/custom_button.dart';
import 'widgets/custom_text_field.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();

  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          UserCubit(userRepository: getIt<UserRepositoryImp>()),
      child: BlocListener<UserCubit, UserStates>(
        listener: (context, state) {
          if (state is UserFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is UserSuccess) {
            if (state.message == "Login successful") {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DashboardScreen(),
                  ));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
            }
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF8FAFC), // خلفية فاتحة مثل الصورة
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo and Title
                  Column(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          LucideIcons.smartphone,
                          size: 36,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Crazy Phone',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'نظام نقاط البيع الاحترافي',
                        style: Theme.of(
                          context,
                        )
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.grey[700]),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Login Form
                  Container(
                    width: 500, // عشان يفضل متناسق في الشاشات الكبيرة
                    padding: const EdgeInsets.all(32),
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
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'تسجيل الدخول',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'أدخل بياناتك للوصول إلى النظام',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.grey[600],
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),

                          // Username Field
                          CustomTextField(
                            controller: _usernameController,
                            label: 'اسم المستخدم',
                            prefixIcon: LucideIcons.user,
                            textDirection: TextDirection.rtl,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'يرجى إدخال اسم المستخدم';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // Password Field
                          CustomTextField(
                            controller: _passwordController,
                            label: 'كلمة المرور',
                            prefixIcon: LucideIcons.lock,
                            obscureText: true,
                            textDirection: TextDirection.rtl,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'يرجى إدخال كلمة المرور';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 24),

                          // Login Button
                          BlocBuilder<UserCubit, UserStates>(
                            builder: (context, state) => CustomButton(
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
                          const SizedBox(height: 24),

                          // Demo Credentials
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'بيانات تجريبية:',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'اسم المستخدم: أي اسم',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                'كلمة المرور: 123456',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Footer
                  Text(
                    '© 2025 Crazy Phone. جميع الحقوق محفوظة',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
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

  void _handleLogin(context) {
    if (_formKey.currentState!.validate()) {
      UserCubit.get(context).login(
        _usernameController.text.trim(),
        _passwordController.text,
      );
    }
  }
}
