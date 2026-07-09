// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:bayaa_pos/core/constants/app_colors.dart';
import 'package:bayaa_pos/core/di/dependency_injection.dart';
import 'package:bayaa_pos/core/functions/messege.dart';
import 'package:bayaa_pos/features/auth/data/models/user_model.dart';
import 'package:bayaa_pos/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:bayaa_pos/core/components/app_logo.dart';
import 'package:bayaa_pos/l10n/app_localizations.dart';
import 'package:bayaa_pos/core/localization/locale_provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();

  bool _isPasswordVisible = false;
  bool _rememberMe = true;

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
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final l10n = AppLocalizations.of(context);
    if (username.isEmpty) {
      MotionSnackBarError(context, l10n.enterUsername);
      return;
    }
    if (password.isEmpty) {
      MotionSnackBarError(context, l10n.enterPassword);
      return;
    }
    getIt<UserCubit>().login(username, password);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

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
            if (state.message == AppLocalizations.of(context).msgLoginSuccess) {
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
            child: isDesktop
                ? _buildDesktopLayout(context)
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: _buildMobileLayout(context),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: 1050,
        maxHeight: MediaQuery.of(context).size.height > 750
            ? 680
            : MediaQuery.of(context).size.height - 48,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left Column (Login Form) - 55% width
            Expanded(
              flex: 55,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(40),
                child: SingleChildScrollView(
                  child: _buildLoginForm(context),
                ),
              ),
            ),
            // Right Column (Branding & Gradient banner) - 45% width
            Expanded(
              flex: 45,
              child: _buildBrandingBanner(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 450),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: _buildLoginForm(context),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Language Toggle Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox.shrink(),
            TextButton.icon(
              icon: const Icon(Icons.language,
                  size: 18, color: Color(0xFFD77E46)),
              label: Text(
                l10n.localeName == 'ar' ? 'English' : l10n.switchLanguageLabel,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD77E46),
                ),
              ),
              onPressed: () {
                getIt<LocaleProvider>().toggleLocale();
              },
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Welcome text
        Text(
          l10n.loginWelcome,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.loginSubtitle,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.mutedColor,
          ),
        ),
        const SizedBox(height: 24),

        // Session status warning
        Builder(
          builder: (context) {
            final session = getIt<SessionManager>().currentSession;
            if (session != null && session.isOpen) {
              return Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.info,
                        color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        l10n.sessionOpenWarning,
                        style: TextStyle(
                          color: Colors.blue.shade900,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),

        // Username Field Labeled
        Text(
          l10n.username,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _usernameController,
          textDirection: TextDirection.ltr,
          style: const TextStyle(fontSize: 15),
          cursorColor: const Color(0xFFD77E46),
          decoration: InputDecoration(
            hintText: l10n.usernameHint,
            hintStyle: TextStyle(
                color: AppColors.mutedColor.withOpacity(0.4), fontSize: 14),
            prefixIcon: const Icon(LucideIcons.user,
                color: AppColors.mutedColor, size: 20),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.borderColor, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.borderColor, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD77E46), width: 2),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Password Field Labeled
        Text(
          l10n.password,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          focusNode: _passwordFocusNode,
          obscureText: !_isPasswordVisible,
          textDirection: TextDirection.ltr,
          style: const TextStyle(fontSize: 15),
          cursorColor: const Color(0xFFD77E46),
          decoration: InputDecoration(
            hintText: l10n.passwordHint,
            hintStyle: TextStyle(
                color: AppColors.mutedColor.withOpacity(0.4), fontSize: 14),
            prefixIcon: const Icon(LucideIcons.lock,
                color: AppColors.mutedColor, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? LucideIcons.eye : LucideIcons.eyeOff,
                color: AppColors.mutedColor,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.borderColor, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.borderColor, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD77E46), width: 2),
            ),
          ),
          onFieldSubmitted: (_) => _onLoginPressed(),
        ),
        const SizedBox(height: 16),

        // Remember Me checkbox
        Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: _rememberMe,
                activeColor: const Color(0xFFD77E46),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
                onChanged: (val) {
                  setState(() {
                    _rememberMe = val ?? true;
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            Text(
              l10n.rememberMe,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Login Button
        BlocBuilder<UserCubit, UserStates>(
          builder: (context, state) {
            final isLoading = state is UserLoading;
            return SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2F557D),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: isLoading ? null : _onLoginPressed,
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.logIn, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            l10n.loginButton,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            );
          },
        ),
        const SizedBox(height: 32),

        // Quick login grid header
        Row(
          children: [
            const Icon(LucideIcons.sparkles,
                size: 16, color: Color(0xFFD77E46)),
            const SizedBox(width: 8),
            Text(
              l10n.quickLoginHeader,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD77E46),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Quick login users grid
        BlocBuilder<UserCubit, UserStates>(
          builder: (context, state) {
            final cubit = getIt<UserCubit>();
            final users = cubit.users;

            if (users.isEmpty) {
              if (state is UserLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              return Text(
                l10n.noData,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              );
            }

            final screenWidth = MediaQuery.of(context).size.width;
            int crossAxisCount = screenWidth < 500 ? 2 : 3;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2.2,
              ),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return HoverableUserCard(
                  user: user,
                  isSelected: _usernameController.text == user.username,
                  onTap: () {
                    setState(() {
                      _usernameController.text = user.username;
                      _passwordController.text = ''; // Reset password
                    });
                    _passwordFocusNode.requestFocus();
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildBrandingBanner(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final storeName =
        getIt<SettingsCubit>().currentStoreInfo?.name.isNotEmpty == true
            ? getIt<SettingsCubit>().currentStoreInfo!.name
            : l10n.appName;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF2F557D), // Soft Steel Blue
            Color(
                0xFF142233), // Deep Dark Slate Blue (Slightly darker for premium contrast)
          ],
          stops: [0.0, 1.0],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo & Name Row
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: const Color(0xFFD77E46), width: 2.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(8),
                child: const AppLogo(
                  width: 54,
                  height: 54,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      storeName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      l10n.systemSubtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(flex: 3),

          // Main Call to Action Header
          Text(
            l10n.appName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.systemDescription,
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 14,
              height: 1.6,
            ),
          ),
          const Spacer(flex: 2),

          // Bullet Highlights
          _buildFeatureItem(
            icon: LucideIcons.wifiOff,
            title: l10n.offlineFeature,
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            icon: LucideIcons.barcode,
            title: l10n.barcodeFeature,
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            icon: LucideIcons.trendingUp,
            title: l10n.reportsFeature,
          ),
          const Spacer(flex: 4),

          // Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${l10n.version} 2.2',
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                ),
              ),
              Text(
                '© 2026 $storeName. ${l10n.copyright}',
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({required IconData icon, required String title}) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFD77E46).withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: const Color(0xFFD77E46),
            size: 18,
          ),
        ),
        const SizedBox(width: 14),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class HoverableUserCard extends StatefulWidget {
  final User user;
  final bool isSelected;
  final VoidCallback onTap;

  const HoverableUserCard({
    super.key,
    required this.user,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<HoverableUserCard> createState() => _HoverableUserCardState();
}

class _HoverableUserCardState extends State<HoverableUserCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    const logoColor = Color(0xFFD77E46);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        transform: Matrix4.identity()
          ..translate(_isHovered ? -2.0 : 0.0, _isHovered ? -2.0 : 0.0)
          ..scale(_isHovered ? 1.03 : 1.0),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.isSelected
                    ? logoColor
                    : (_isHovered
                        ? logoColor.withOpacity(0.5)
                        : AppColors.borderColor),
                width: widget.isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.isSelected
                      ? logoColor.withOpacity(0.15)
                      : (_isHovered
                          ? Colors.black.withOpacity(0.08)
                          : Colors.black.withOpacity(0.02)),
                  blurRadius: _isHovered ? 8 : 4,
                  offset: Offset(0, _isHovered ? 4 : 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.user.name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  widget.user.username,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.mutedColor,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
