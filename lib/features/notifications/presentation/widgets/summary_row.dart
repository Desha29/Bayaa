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
    final c = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 920;
        final children = [
          SummaryCard(
            label: 'مقروءة',
            value: opened,
            icon: LucideIcons.eye,
            bg: Colors.green.shade50,
            fg: Colors.green.shade700,
          ),
          SummaryCard(
            label: 'عاجلة',
            value: urgent,
            icon: LucideIcons.alertTriangle,
            bg: Colors.red.shade50,
            fg: Colors.red.shade700,
          ),
          SummaryCard(
            label: 'غير مقروءة',
            value: unread,
            icon: LucideIcons.eyeOff,
            bg: Colors.amber.shade50,
            fg: Colors.amber.shade800,
          ),
        ];
        return isWide
            ? Row(
                children: [
                  Expanded(child: children[0]),
                  const SizedBox(width: 12),
                  Expanded(child: children[1]),
                  const SizedBox(width: 12),
                  Expanded(child: children[2]),
                  const SizedBox(width: 12),
                ],
              )
            : Column(
                children: [
                  children[0],
                  const SizedBox(height: 12),
                  children[1],
                  const SizedBox(height: 12),
                  children[2],
                  const SizedBox(height: 12),
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
    this.val,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color bg;
  final Color fg;
  final Color? val;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fg.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Icon(icon, color: fg),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: text.labelLarge?.copyWith(color: fg),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white,
            child: Text(
              '$value',
              style: text.titleMedium?.copyWith(
                color: fg,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
