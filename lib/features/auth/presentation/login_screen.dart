// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:crazy_phone_pos/core/constants/app_colors.dart';
import 'package:crazy_phone_pos/core/di/dependency_injection.dart';
import 'package:crazy_phone_pos/core/functions/messege.dart';
import 'package:crazy_phone_pos/features/auth/data/models/user_model.dart';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/components/logo.dart';

import '../../dashboard/presentation/dashboard_screen.dart';

import 'cubit/user_cubit.dart';
import 'cubit/user_states.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch users on init
    getIt<UserCubit>().getAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = 3;
    double childAspectRatio = 1.1;

    if (screenWidth < 900) {
      crossAxisCount = 2;
      childAspectRatio = 1.0;
    }
    if (screenWidth < 600) {
      crossAxisCount = 1;
      childAspectRatio = 1.1;
    }

    return BlocProvider<UserCubit>.value(
      value: getIt<UserCubit>(),
      child: BlocListener<UserCubit, UserStates>(
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
          backgroundColor: AppColors.backgroundColor,
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  const Logo(isMobile: false, avatarRadius: 90),
                  const SizedBox(height: 24),
                  Text(
                    'اختر المستخدم لتسجيل الدخول',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: BlocBuilder<UserCubit, UserStates>(
                      builder: (context, state) {
                        if (state is UserLoading) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (state is UsersLoaded) {
                          if (state.users.isEmpty) {
                            return const Center(child: Text("لا يوجد مستخدمين. يرجى إضافة مستخدم أولاً."));
                          }
                          return GridView.builder(
                            padding: const EdgeInsets.all(20),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: childAspectRatio,
                            ),
                            itemCount: state.users.length,
                            itemBuilder: (context, index) {
                              final user = state.users[index];
                              return _buildUserCard(context, user);
                            },
                          );
                        } else if (state is UserFailure) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(state.error, style: const TextStyle(color: Colors.red)),
                                const SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: () {
                                     UserCubit.get(context).getAllUsers();
                                  },
                                  child: const Text("إعادة المحاولة"),
                                )
                              ],
                            ),
                          );
                        }
                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '© 2026 Bayaa. جميع الحقوق محفوظة.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, User user) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showPasswordDialog(context, user),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primaryColor.withOpacity(0.1),
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : "?",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: user.userType == UserType.manager
                    ? AppColors.accentColor.withOpacity(0.2)
                    : AppColors.secondaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                user.userType == UserType.manager ? "مدير" : "كاشير",
                style: TextStyle(
                  color: user.userType == UserType.manager
                      ? AppColors.darkGold // Use darker orange for text
                      : AppColors.primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPasswordDialog(BuildContext context, User user) {
    final passwordController = TextEditingController();
    bool isPasswordVisible = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              "أدخل كلمة المرور لـ ${user.name}",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            content: SizedBox(
              width: 300,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: passwordController,
                    obscureText: !isPasswordVisible,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: "كلمة المرور",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(isPasswordVisible
                            ? LucideIcons.eye
                            : LucideIcons.eyeOff),
                        onPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    onSubmitted: (_) {
                       Navigator.pop(dialogContext);
                       _attemptLogin(context, user.username, passwordController.text);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text("إلغاء", style: TextStyle(color: Colors.red)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryColor, // Use Secondary Blue
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  Navigator.pop(dialogContext);
                  _attemptLogin(context, user.username, passwordController.text);
                },
                child: const Text("دخول"),
              ),
            ],
            actionsAlignment: MainAxisAlignment.center,
          );
        },
      ),
    );
  }

  void _attemptLogin(BuildContext context, String username, String password) {
    if (password.isEmpty) {
      MotionSnackBarError(context, "الرجاء إدخال كلمة المرور");
      return;
    }
    // Use the UserCubit provided by the parent via getIt/context
    getIt<UserCubit>().login(username, password);
  }
}
