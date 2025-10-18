import 'package:flutter/material.dart';
import 'anim_wrappers.dart';

class ScreenHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final double fontSize;
  final IconData? icon;
  final Color? titleColor;
  final Color? iconColor;
  final Color? subtitleColor;

  const ScreenHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.fontSize = 32,
    this.icon,
    this.titleColor,
    this.subtitleColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

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
          ],
        ),
      ),
    );
  }
}
