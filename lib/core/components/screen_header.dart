import 'package:crazy_phone_pos/features/auth/data/models/user_model.dart';
import 'package:flutter/material.dart';
import '../../features/auth/presentation/cubit/user_cubit.dart';
import '../constants/app_colors.dart';
import '../di/dependency_injection.dart';
import 'anim_wrappers.dart';

class ScreenHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final double fontSize;
  final IconData? icon;
  final Color? titleColor;
  final Color? iconColor;
  final Color? subtitleColor;

  const ScreenHeader(
      {super.key,
      required this.title,
      required this.subtitle,
      this.fontSize = 32,
      this.icon,
      this.titleColor,
      this.subtitleColor,
      this.iconColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final currentUser = getIt<UserCubit>().currentUser;
    final adaptiveFontSize = screenWidth < 600
        ? fontSize * 0.75
        : screenWidth < 900
            ? fontSize * 0.85
            : fontSize;

    final adaptiveSubtitleSize = screenWidth < 600 ? 14.0 : 16.0;

    return FadeSlideIn(
      beginOffset: const Offset(0, 0.2),
      duration: const Duration(milliseconds: 700),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: screenWidth > 768 ? 16 : 12,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      (titleColor ?? const Color(0xFF1A1A1A)).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? const Color(0xFF1A1A1A),
                  size: adaptiveFontSize * 0.7,
                ),
              ),
              SizedBox(width: screenWidth > 768 ? 16 : 12),
            ],
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      title,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: titleColor ?? const Color(0xFF1A1A1A),
                        fontSize: adaptiveFontSize,
                        letterSpacing: -0.5,
                        height: 1.2,
                      ),
                    ),
                  ),
                  SizedBox(height: screenWidth > 768 ? 8 : 6),
                  Text(
                    subtitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: subtitleColor ?? Colors.grey[600],
                      fontSize: adaptiveSubtitleSize,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'المستخدم الحالي',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        currentUser.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.kDarkChip,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: currentUser.userType == UserType.manager
                          ? Colors.orange.shade100
                          : Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                    currentUser.userType == UserType.manager
                          ? 'مدير'
                          : 'كاشير',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: currentUser.userType == UserType.manager
                            ? Colors.orange.shade900
                            : Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
