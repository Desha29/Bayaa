// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'anim_wrappers.dart';
import '../constants/app_colors.dart';

class ScreenHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final double fontSize;
  final IconData? icon;
  final Color? titleColor;
  final Color? iconColor;
  final Color? subtitleColor;
  final List<Widget>? actions;

  const ScreenHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.fontSize = 24, // Minimized default size
    this.icon,
    this.titleColor,
    this.subtitleColor,
    this.iconColor,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Highly compact adaptive sizes
    final adaptiveFontSize = screenWidth < 600
        ? 18.0
        : screenWidth < 900
            ? 21.0
            : fontSize;

    final adaptiveSubtitleSize = screenWidth < 600 ? 11.0 : 13.0;

    return FadeSlideIn(
      beginOffset: const Offset(0, 0.1),
      duration: const Duration(milliseconds: 500),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: screenWidth > 768 ? 10 : 6,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (iconColor ?? AppColors.primaryColor).withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: (iconColor ?? AppColors.primaryColor).withOpacity(0.12),
                    width: 1,
                  ),
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? AppColors.primaryColor,
                  size: adaptiveFontSize * 0.85,
                ),
              ),
              const SizedBox(width: 12),
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
                        fontWeight: FontWeight.w800,
                        color: titleColor ?? AppColors.textPrimary,
                        fontSize: adaptiveFontSize,
                        letterSpacing: -0.3,
                        height: 1.1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: subtitleColor ?? AppColors.mutedColor,
                      fontSize: adaptiveSubtitleSize,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            if (actions != null) ...[
              const SizedBox(width: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: actions!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

