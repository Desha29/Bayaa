import 'package:flutter/material.dart';
import 'package:bayaa_pos/shared/theme/app_colors.dart';
import 'package:bayaa_pos/shared/feedback/preview_action.dart';
import '../models/expense_view_data.dart';
import 'expense_labels.dart';

Future<void> showExpenseForm(BuildContext context,
    {ExpenseViewData? expense}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => ExpenseFormDialog(expense: expense),
  );
  if (result == true && context.mounted) showPreviewAction(context);
}

class ExpenseFormDialog extends StatefulWidget {
  const ExpenseFormDialog({super.key, this.expense});
  final ExpenseViewData? expense;
  @override
  State<ExpenseFormDialog> createState() => _ExpenseFormDialogState();
}

class _ExpenseFormDialogState extends State<ExpenseFormDialog> {
  final _form = GlobalKey<FormState>();
  final _titleFocus = FocusNode();
  final _amountFocus = FocusNode();
  late final _title = TextEditingController(text: widget.expense?.title);
  late final _amount =
      TextEditingController(text: widget.expense?.amount.toStringAsFixed(2));
  late final _notes = TextEditingController(text: widget.expense?.notes);
  late String _category =
      ExpenseLabels.categoryKey(widget.expense?.category ?? 'operations');

  @override
  void dispose() {
    _titleFocus.dispose();
    _amountFocus.dispose();
    _title.dispose();
    _amount.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labels = ExpenseLabels.of(context);
    return AlertDialog(
      backgroundColor: AppColors.surfaceColor,
      surfaceTintColor: Colors.transparent,
      scrollable: true,
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: AppColors.borderColor)),
      title: Row(children: [
        Icon(Icons.receipt_long_outlined, color: AppColors.primaryColor),
        const SizedBox(width: 10),
        Expanded(
            child: Text(
                widget.expense == null
                    ? labels.text('إضافة مصروف', 'Add expense')
                    : labels.text('تعديل المصروف', 'Edit expense'),
                style: const TextStyle(
                    fontSize: 19, fontWeight: FontWeight.w800))),
        IconButton(
            tooltip: labels.text('إغلاق', 'Close'),
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, size: 20)),
      ]),
      content: SizedBox(
          width: 470,
          child: Form(
              key: _form,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        labels.text(
                            'معاينة بيانات المصروف. لن يتم حفظ أي تغييرات.',
                            'Preview expense details. Changes will not be saved.'),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: AppColors.mutedColor)),
                    const SizedBox(height: 20),
                    TextFormField(
                        controller: _title,
                        focusNode: _titleFocus,
                        autofocus: true,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                            labelText:
                                labels.text('وصف المصروف', 'Description'),
                            prefixIcon: const Icon(Icons.description_outlined)),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? labels.text('أدخل وصف المصروف',
                                    'Enter an expense description')
                                : null),
                    const SizedBox(height: 16),
                    TextFormField(
                        controller: _amount,
                        focusNode: _amountFocus,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                            labelText: labels.text('المبلغ', 'Amount'),
                            prefixIcon: const Icon(Icons.payments_outlined),
                            suffixText: labels.currency),
                        validator: (value) =>
                            (double.tryParse(value?.trim() ?? '') ?? 0) <= 0
                                ? labels.text('أدخل مبلغاً أكبر من صفر',
                                    'Enter an amount greater than zero')
                                : null),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                        initialValue: _category,
                        isExpanded: true,
                        decoration: InputDecoration(
                            labelText: labels.text('الفئة', 'Category'),
                            prefixIcon: const Icon(Icons.category_outlined)),
                        items: ExpenseLabels.categories
                            .map((key) => DropdownMenuItem(
                                value: key, child: Text(labels.category(key))))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _category = value ?? _category)),
                    const SizedBox(height: 16),
                    TextFormField(
                        controller: _notes,
                        minLines: 2,
                        maxLines: 4,
                        decoration: InputDecoration(
                            labelText: labels.text(
                                'ملاحظات (اختياري)', 'Notes (optional)'),
                            alignLabelWithHint: true)),
                  ]))),
      actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(labels.text('إلغاء', 'Cancel'))),
        FilledButton.icon(
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.accentColor,
                foregroundColor: AppColors.accentForeground),
            onPressed: () {
              if (_form.currentState!.validate()) {
                Navigator.pop(context, true);
              } else if (_title.text.trim().isEmpty) {
                _titleFocus.requestFocus();
              } else {
                _amountFocus.requestFocus();
              }
            },
            icon: const Icon(Icons.check, size: 18),
            label: Text(labels.text('معاينة الحفظ', 'Preview save'))),
      ],
    );
  }
}
