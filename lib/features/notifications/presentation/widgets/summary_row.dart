import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

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
            bg: Colors.green.shade50,
            fg: Colors.green.shade700,
            isMobile: isMobile,
          ),
          SummaryCard(
            label: 'عاجلة',
            value: urgent,
            icon: LucideIcons.alertTriangle,
            bg: Colors.red.shade50,
            fg: Colors.red.shade700,
            isMobile: isMobile,
          ),
          SummaryCard(
            label: 'غير مقروءة',
            value: unread,
            icon: LucideIcons.eyeOff,
            bg: Colors.amber.shade50,
            fg: Colors.amber.shade800,
            isMobile: isMobile,
          ),
        ];

        if (isMobile) {
          return Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1) const SizedBox(height: 12),
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
                  const SizedBox(width: 12),
                  Expanded(child: children[1]),
                ],
              ),
              const SizedBox(height: 12),
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
    this.val,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color bg;
  final Color fg;
  final Color? val;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 16,
        vertical: isMobile ? 14 : 18,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fg.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: fg,
            size: isMobile ? 20 : 24,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                label,
                style: text.labelLarge?.copyWith(
                  color: fg,
                  fontSize: isMobile ? 13 : null,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: isMobile ? 14 : 16,
            backgroundColor: Colors.white,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Text(
                  '$value',
                  style: text.titleMedium?.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w700,
                    fontSize: isMobile ? 13 : null,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
