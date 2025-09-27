import 'package:flutter/material.dart';

class PriorityChip extends StatelessWidget {
  final String priority;

  const PriorityChip({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color textColor;
    switch (priority) {
      case "عاجل جداً":
        bg = Colors.red.shade100;
        textColor = Colors.red.shade800;
        break;
      case "عاجل":
        bg = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        break;
      case "متوسط":
        bg = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        break;
      default:
        bg = Colors.green.shade100;
        textColor = Colors.green.shade800;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          priority,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
