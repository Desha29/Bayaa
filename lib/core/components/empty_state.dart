import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    this.icon, 
    this.title,
    this.message,
    this.variant = EmptyStateVariant.notifications,
    this.background,
    this.useCircle = true, 
    this.gap = 14,
    this.center = true, 
    this.actionText,
    this.onAction,
  });

  final IconData? icon;
  final String? title;
  final String? message;
  final EmptyStateVariant variant;
  final Color? background;
  final bool useCircle;
  final double gap;
  final bool center;
  final String? actionText;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Defaults per variant
    final defaults = _defaultsFor(variant, theme);

    final iconColor = defaults.iconColor;
    final bgColor = background ?? defaults.bgColor;
    final tStyle = defaults.titleStyle;
    final mStyle = defaults.messageStyle;

    final content = Column(
      mainAxisAlignment:
          center ? MainAxisAlignment.center : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (useCircle)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon ?? defaults.icon,
              size: 64,
              color: iconColor,
            ),
          )
        else
          Icon(
            icon ?? defaults.icon,
            size: 64,
            color: iconColor,
          ),
        SizedBox(height: gap),
        Text(
          title ?? defaults.title,
          textAlign: TextAlign.center,
          style: tStyle,
        ),
        SizedBox(height: gap - 6),
        Text(
          message ?? defaults.message,
          textAlign: TextAlign.center,
          style: mStyle,
        ),
        if (onAction != null && actionText != null) ...[
          SizedBox(height: gap * 1.5),
          ElevatedButton(
            onPressed: onAction,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(actionText!),
          ),
        ],
      ],
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Center(child: content),
    );
  }

  _EmptyDefaults _defaultsFor(EmptyStateVariant v, ThemeData theme) {
    switch (v) {
      case EmptyStateVariant.products:
        return _EmptyDefaults(
          icon: Icons.inventory_2_outlined,
          title: 'لا توجد منتجات',
          message: 'لم يتم العثور على منتجات تطابق البحث',
          bgColor: Colors.grey.shade100,
          iconColor: Colors.grey[400]!,
          titleStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B7280), // grey[600]
          ),
          messageStyle: const TextStyle(
            fontSize: 14,
            color: Color(0xFF9CA3AF), // grey[500]
          ),
        );

      case EmptyStateVariant.notifications:
        return _EmptyDefaults(
          icon: LucideIcons.bell,
          title: 'لا توجد تنبيهات',
          message: 'سيتم عرض التنبيهات هنا عند توفرها',
          bgColor: Colors.transparent,
          iconColor: theme.colorScheme.onSurface.withOpacity(0.25),
          titleStyle: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w700,
              ) ??
              const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          messageStyle: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ) ??
              const TextStyle(fontSize: 14),
        );
    }
  }
}

enum EmptyStateVariant { notifications, products }

class _EmptyDefaults {
  _EmptyDefaults({
    required this.icon,
    required this.title,
    required this.message,
    required this.bgColor,
    required this.iconColor,
    required this.titleStyle,
    required this.messageStyle,
  });

  final IconData icon;
  final String title;
  final String message;
  final Color bgColor;
  final Color iconColor;
  final TextStyle titleStyle;
  final TextStyle messageStyle;
}
