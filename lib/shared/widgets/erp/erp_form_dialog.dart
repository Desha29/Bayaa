import 'package:flutter/material.dart';
import 'package:bayaa_pos/shared/feedback/preview_action.dart';
import 'package:bayaa_pos/shared/theme/app_colors.dart';
import 'package:bayaa_pos/shared/layout/layout_tokens.dart';
import 'erp_view_spec.dart';

Future<void> showErpForm(BuildContext context, ErpViewSpec spec,
        {ErpRecordView? record}) =>
    showDialog<void>(
        context: context,
        builder: (dialogContext) => ErpFormDialog(
            spec: spec,
            record: record,
            onSubmit: () {
              Navigator.pop(dialogContext);
              showPreviewAction(context);
            }));

class ErpFormDialog extends StatelessWidget {
  const ErpFormDialog(
      {super.key, required this.spec, required this.onSubmit, this.record});
  final ErpViewSpec spec;
  final ErpRecordView? record;
  final VoidCallback onSubmit;
  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    final size = MediaQuery.sizeOf(context);
    return Dialog(
        insetPadding: EdgeInsets.all(size.width < 600 ? 12 : 32),
        backgroundColor: AppColors.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
            constraints:
                BoxConstraints(maxWidth: 760, maxHeight: size.height * .9),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(children: [
                    Icon(spec.icon, color: AppColors.secondaryColor),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Text(
                            record == null
                                ? spec.action.of(context)
                                : (arabic ? 'تعديل السجل' : 'Edit record'),
                            style: const TextStyle(
                                fontSize: 19, fontWeight: FontWeight.w700))),
                    IconButton(
                        tooltip: arabic ? 'إغلاق' : 'Close',
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close))
                  ])),
              Divider(height: 1, color: AppColors.borderColor),
              Flexible(
                  child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: AdaptiveColumns(
                          minWidth: 280,
                          maxColumns: 2,
                          children: spec.fields
                              .map((field) => TextFormField(
                                  initialValue: field == spec.fields.first
                                      ? record?.title
                                      : null,
                                  minLines: field.wide ? 3 : 1,
                                  maxLines: field.wide ? 4 : 1,
                                  decoration: InputDecoration(
                                      labelText: field.label.of(context),
                                      hintText: field.hint?.of(context))))
                              .toList()))),
              Padding(
                  padding: const EdgeInsets.all(20),
                  child: Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      alignment: WrapAlignment.end,
                      children: [
                        TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(arabic ? 'إلغاء' : 'Cancel')),
                        FilledButton.icon(
                            onPressed: onSubmit,
                            icon: const Icon(Icons.check, size: 18),
                            label: Text(arabic ? 'حفظ' : 'Save'))
                      ])),
            ])));
  }
}
