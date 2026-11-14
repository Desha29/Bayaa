import 'package:flutter/material.dart';
import 'package:bayaa_pos/shared/feedback/preview_action.dart';
import 'package:bayaa_pos/shared/theme/app_colors.dart';

class CategoryFormDialog extends StatefulWidget {
  const CategoryFormDialog(
      {super.key, required this.categories, this.subcategory = false});
  final List<String> categories;
  final bool subcategory;

  @override
  State<CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<CategoryFormDialog> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _description = TextEditingController();
  String? _parent;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    final title = widget.subcategory
        ? (ar ? 'إضافة تصنيف فرعي' : 'Add subcategory')
        : (ar ? 'إضافة تصنيف' : 'Add category');
    return Dialog(
      insetPadding: const EdgeInsets.all(12),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Form(
              key: _form,
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(children: [
                      Icon(
                          widget.subcategory
                              ? Icons.account_tree_outlined
                              : Icons.category_outlined,
                          color: AppColors.primaryColor),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Text(title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18))),
                      IconButton(
                          tooltip: ar ? 'إغلاق' : 'Close',
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close)),
                    ]),
                    const SizedBox(height: 20),
                    if (widget.subcategory) ...[
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: InputDecoration(
                            labelText:
                                ar ? 'التصنيف الرئيسي' : 'Parent category',
                            prefixIcon: const Icon(Icons.category_outlined)),
                        items: widget.categories
                            .toSet()
                            .map((category) => DropdownMenuItem(
                                value: category,
                                child: Text(category,
                                    overflow: TextOverflow.ellipsis)))
                            .toList(),
                        onChanged: (value) => _parent = value,
                        validator: (_) => _parent == null
                            ? (ar
                                ? 'اختر التصنيف الرئيسي'
                                : 'Select a parent category')
                            : null,
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextFormField(
                      controller: _name,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                          labelText: ar ? 'الاسم' : 'Name',
                          prefixIcon: const Icon(Icons.label_outline)),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? (ar ? 'أدخل الاسم' : 'Enter a name')
                              : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                        controller: _description,
                        minLines: 2,
                        maxLines: 4,
                        decoration: InputDecoration(
                            labelText: ar
                                ? 'الوصف (اختياري)'
                                : 'Description (optional)',
                            alignLabelWithHint: true)),
                    const SizedBox(height: 20),
                    Text(
                        ar
                            ? 'معاينة الواجهة فقط — لن يتم حفظ أي تغييرات.'
                            : 'UI preview only — changes are not saved.',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: AppColors.mutedColor)),
                    const SizedBox(height: 20),
                    Wrap(
                        alignment: WrapAlignment.end,
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(ar ? 'إلغاء' : 'Cancel')),
                          FilledButton.icon(
                              onPressed: () {
                                if (!(_form.currentState?.validate() ??
                                    false)) {
                                  return;
                                }
                                final navigator = Navigator.of(context);
                                navigator.pop();
                                showPreviewAction(navigator.context);
                              },
                              icon: const Icon(Icons.add),
                              label: Text(title)),
                        ]),
                  ])),
        ),
      ),
    );
  }
}
