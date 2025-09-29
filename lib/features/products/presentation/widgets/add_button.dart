import 'package:flutter/material.dart';

class AddButton extends StatelessWidget {
  const AddButton({
    super.key,
    required this.onAddPressed,
  });

  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xff0fa2a9),
            Color(0xff0891a6),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff0fa2a9).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onAddPressed,
        icon: const Icon(Icons.add_rounded, size: 20),
        label: FittedBox(
          fit: BoxFit.scaleDown,
          child: const Text(
            'إضافة منتج جديد',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}