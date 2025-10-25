// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class DashboardCard extends StatefulWidget {
  const DashboardCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;

  @override
  State<DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<DashboardCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 50),
          curve: Curves.easeOut,
          transform: _isHovered
              ? (Matrix4.identity()..scale(1.04))
              : Matrix4.identity(),
          decoration: BoxDecoration(
            color: AppColors.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered
                  ? widget.color.withOpacity(0.6)
                  : AppColors.borderColor,
              width: 1.3,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: widget.color.withOpacity(0.25),
                      blurRadius: 18,
                      spreadRadius: 1,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            splashColor: widget.color.withOpacity(0.15),
            highlightColor: Colors.transparent,
            onTap: widget.onTap,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: FittedBox(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 50),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: _isHovered
                                ? [
                                    BoxShadow(
                                      color: widget.color.withOpacity(0.4),
                                      blurRadius: 12,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : [],
                          ),
                          child: CircleAvatar(
                            radius: 28,
                            backgroundColor: widget.color.withOpacity(0.15),
                            child: Icon(
                              widget.icon,
                              color: widget.color,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Flexible(
                      child: FittedBox(
                        child: Text(
                          widget.title,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15, // Reduced from 18
                            color: AppColors.secondaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Flexible(
                      child: FittedBox(
                        child: Text(
                          widget.subtitle,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.mutedColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
