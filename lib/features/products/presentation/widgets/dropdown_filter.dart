import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/functions/messege.dart';

class DropDownFilter extends StatefulWidget {
  const DropDownFilter({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.icon,
    this.iconRemove,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;
  final IconData icon;
  final IconData? iconRemove;

  @override
  State<DropDownFilter> createState() => _DropDownFilterState();
}

class _DropDownFilterState extends State<DropDownFilter> {
  late String selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        isDense: true,
        isExpanded: true,
        icon:
            const Icon(LucideIcons.chevronDown, color: AppColors.primaryColor),
        decoration: InputDecoration(
          labelText: widget.label,
          prefixIcon: Icon(widget.icon, color: AppColors.primaryColor),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        items: widget.items
            .map(
              (item) => DropdownMenuItem(
                value: item,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item),
                    // 👇 Hide delete icon when item is selected
                    if (item != selectedValue)
                      (widget.iconRemove != null)
                          ? IconButton(
                              onPressed: () {
                                showDeleteCategoryConfirmation(context);
                              },
                              icon: Icon(
                                widget.iconRemove,
                                color: Colors.red,
                              ),
                            )
                          : SizedBox()
                  ],
                ),
              ),
            )
            .toList(),
        onChanged: (v) {
          if (v != null) {
            setState(() => selectedValue = v);
            widget.onChanged(v);
          }
        },
      ),
    );
  }
  Future<bool?> showDeleteCategoryConfirmation(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.trash2, // أيقونة الحذف
              color: Colors.red.shade700,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'تأكيد حذف الفئة',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'هل أنت متأكد من حذف هذه الفئة؟',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 8),
      
        ],
      ),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        OutlinedButton.icon(
          onPressed: () => Navigator.pop(context, false),
          icon: const Icon(LucideIcons.x),
          label: const Text('إلغاء'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle:
                const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => Navigator.pop(context, true),
          icon: const Icon(LucideIcons.trash2),
          label: const Text('حذف'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade700,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle:
                const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );
}
}
