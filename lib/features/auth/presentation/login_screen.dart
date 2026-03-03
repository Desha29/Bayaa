// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:crazy_phone_pos/core/constants/app_colors.dart';
import 'package:crazy_phone_pos/core/di/dependency_injection.dart';
import 'package:crazy_phone_pos/core/functions/messege.dart';
import 'package:crazy_phone_pos/features/auth/data/models/user_model.dart';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/components/logo.dart';
import '../../../core/data/services/persistence_initializer.dart';
import '../../../core/session/session_manager.dart';

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
    
    // Check if persistence needs setup (after build)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      
      // Check if persistence is already enabled
      if (!PersistenceInitializer.isEnabled) {
        // First launch - mandatory setup
        final success = await PersistenceInitializer.promptForDataPath(
          context,
          allowCancel: false,
        );
        if (success && mounted) {
           getIt<UserCubit>().getAllUsers();
           await getIt<SessionManager>().loadSession();
           setState(() {});
        }
      } else {
        await getIt<SessionManager>().loadSession();
        if (mounted) setState(() {});
      }
    });
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
          } else if (state is LoginSuccess) {
            if (state.isExistingSession) {
              MotionSnackBarInfo(context, state.message);
            } else {
              MotionSnackBarSuccess(context, state.message);
            }
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const DashboardScreen(),
                ));
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
                  Builder(
                    builder: (context) {
                       final session = getIt<SessionManager>().currentSession;
                       if (session != null && session.isOpen) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(LucideIcons.info, color: Colors.blue.shade700, size: 20),
                                const SizedBox(width: 10),
                                Flexible(
                                  child: Text(
                                    'يوجد يومية مفتوحة حالياً. تسجيل الدخول سيتابع عليها.',
                                    style: TextStyle(
                                      color: Colors.blue.shade900,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          );
                       }
                       return const SizedBox.shrink();
                    },
                  ),
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
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Container(
              width: 380,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.08),
                    blurRadius: 32,
                    offset: const Offset(0, 16),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: Colors.white.withOpacity(0.8), width: 2),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Elegant Avatar
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primaryColor.withOpacity(0.2),
                          AppColors.primaryColor.withOpacity(0.05),
                        ],
                      ),
                      border: Border.all(
                        color: AppColors.primaryColor.withOpacity(0.3),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryColor.withOpacity(0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : "?",
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Greetings
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "مرحباً بك مجدداً",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Input Field
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: TextField(
                      controller: passwordController,
                      obscureText: !isPasswordVisible,
                      autofocus: true,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 3,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: "••••••••",
                        hintStyle: TextStyle(
                          fontSize: 18,
                          letterSpacing: 3,
                          color: AppColors.mutedColor.withOpacity(0.4),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(right: 12.0),
                          child: Icon(LucideIcons.keyRound, color: AppColors.primaryColor, size: 22),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isPasswordVisible ? LucideIcons.eye : LucideIcons.eyeOff,
                            color: AppColors.mutedColor,
                            size: 22,
                          ),
                          onPressed: () {
                            setState(() {
                              isPasswordVisible = !isPasswordVisible;
                            });
                          },
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey.shade200, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
                        ),
                      ),
                      onSubmitted: (_) {
                        Navigator.pop(dialogContext);
                        _attemptLogin(context, user.username, passwordController.text);
                      },
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            side: BorderSide(color: Colors.grey.shade300, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            "إلغاء",
                            style: TextStyle(
                              color: AppColors.mutedColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(dialogContext);
                            _attemptLogin(context, user.username, passwordController.text);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            elevation: 4,
                            shadowColor: AppColors.primaryColor.withOpacity(0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "دخول",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(LucideIcons.logIn, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
