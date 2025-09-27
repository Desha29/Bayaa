import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  final bool isOut;
  final bool isLow;

  const StatusChip({super.key, required this.isOut, required this.isLow});

  @override
  Widget build(BuildContext context) {
    if (isOut) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'غير متوفر',
            style: TextStyle(color: Color(0xFFDC2626), fontSize: 13),
          ),
        ),
      );
    } else if (isLow) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.yellow.shade50,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'مخزون منخفض',
            style: TextStyle(color: Color(0xFFCA8A04), fontSize: 13),
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'متوفر',
            style: TextStyle(color: Color(0xFF059669), fontSize: 13),
          ),
        ),
      );
    }
  }
}