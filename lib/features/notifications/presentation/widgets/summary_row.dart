import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:bayaa_pos/core/constants/app_colors.dart';

class SummaryRow extends StatelessWidget {
  const SummaryRow({
    super.key,
    required this.total,
    required this.opened,
    required this.urgent,
    required this.unread,
  });

  final int total;
  final int opened;
  final int urgent;
  final int unread;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final isTablet =
            constraints.maxWidth >= 600 && constraints.maxWidth < 920;

        final children = [
          SummaryCard(
            label: 'مقروءة',
            value: opened,
            icon: LucideIcons.eye,
            bg: const Color(0xFFECFDF5), // Soft green
            fg: AppColors.successColor,
            isMobile: isMobile,
          ),
          SummaryCard(
            label: 'عاجلة',
            value: urgent,
            icon: LucideIcons.alertTriangle,
            bg: const Color(0xFFFEF2F2), // Soft red
            fg: AppColors.errorColor,
            isMobile: isMobile,
          ),
          SummaryCard(
            label: 'غير مقروءة',
            value: unread,
            icon: LucideIcons.eyeOff,
            bg: const Color(0xFFFFFBEB), // Soft yellow
            fg: AppColors.warningColor,
            isMobile: isMobile,
          ),
        ];

        if (isMobile) {
          return Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1) const SizedBox(height: 10),
              ],
            ],
          );
        }

        if (isTablet) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: children[0]),
                  const SizedBox(width: 10),
                  Expanded(child: children[1]),
                ],
              ),
              const SizedBox(height: 10),
              children[2],
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: children[0]),
            const SizedBox(width: 12),
            Expanded(child: children[1]),
            const SizedBox(width: 12),
            Expanded(child: children[2]),
          ],
        );
      },
    );
  }
}

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.bg,
    required this.fg,
    required this.isMobile,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color bg;
  final Color fg;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 16,
        vertical: isMobile ? 12 : 16,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fg.withOpacity(0.2), width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: fg,
              size: isMobile ? 18 : 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                color: fg,
                fontWeight: FontWeight.w700,
                fontSize: isMobile ? 13 : 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: fg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$value',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
