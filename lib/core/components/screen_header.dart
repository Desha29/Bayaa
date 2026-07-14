// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'anim_wrappers.dart';
import '../constants/app_colors.dart';

/// Lets the dashboard present page titles in its global app header instead of
/// repeating them inside every screen.
class ScreenHeaderScope extends InheritedWidget {
  final bool showInPage;

  const ScreenHeaderScope({
    super.key,
    required this.showInPage,
    required super.child,
  });

  static ScreenHeaderScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ScreenHeaderScope>();

  @override
  bool updateShouldNotify(ScreenHeaderScope oldWidget) =>
      showInPage != oldWidget.showInPage;
}

/// Preserves spacing for standalone screens and removes it when the global
/// dashboard header has replaced the in-page header.
class ScreenHeaderGap extends StatelessWidget {
  final double height;
  const ScreenHeaderGap({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    final headerIsHidden =
        ScreenHeaderScope.maybeOf(context)?.showInPage == false;
    return SizedBox(height: headerIsHidden ? 0 : height);
  }
}

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
    this.fontSize = 24,
    this.icon,
    this.titleColor,
    this.subtitleColor,
    this.iconColor,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    if (ScreenHeaderScope.maybeOf(context)?.showInPage == false) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    // Adaptive text sizing built for clean readability thresholds
    final adaptiveFontSize = screenWidth < 600
        ? 18.0
        : screenWidth < 900
            ? 22.0
            : fontSize;

    final adaptiveSubtitleSize = screenWidth < 600 ? 12.0 : 14.0;
    final isDesktop = screenWidth > 768;

    return FadeSlideIn(
      beginOffset: const Offset(0, 0.05),
      duration: const Duration(milliseconds: 400),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: isDesktop ? 16 : 12,
          horizontal: isDesktop ? 4 : 0,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: theme.dividerColor.withOpacity(0.08),
              width: 1,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Container(
                padding: EdgeInsets.all(isDesktop ? 12 : 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      (iconColor ?? AppColors.primaryColor).withOpacity(0.08),
                      (iconColor ?? AppColors.primaryColor).withOpacity(0.03),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        (iconColor ?? AppColors.primaryColor).withOpacity(0.15),
                    width: 1,
                  ),
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? AppColors.primaryColor,
                  size: adaptiveFontSize * 0.9,
                ),
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      title,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: titleColor ?? AppColors.textPrimary,
                        fontSize: adaptiveFontSize,
                        letterSpacing: -0.5,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: subtitleColor ?? AppColors.mutedColor,
                      fontSize: adaptiveSubtitleSize,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.1,
                      height: 1.3,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            if (actions != null && actions!.isNotEmpty) ...[
              const SizedBox(width: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: actions!.map((action) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: action,
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
