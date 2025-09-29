import 'package:flutter/material.dart';

class DropDownFilter extends StatelessWidget {
  const DropDownFilter({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.icon,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xff0fa2a9)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        items: items
            .map((item) => DropdownMenuItem(
                  value: item,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(item),
                  ),
                ))
            .toList(),
        onChanged: (v) => onChanged(v ?? value),
      ),
    );
  }
}