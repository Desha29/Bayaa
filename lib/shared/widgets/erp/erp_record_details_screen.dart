import 'package:flutter/material.dart';
import 'package:bayaa_pos/shared/feedback/preview_action.dart';
import 'package:bayaa_pos/shared/layout/layout_tokens.dart';
import 'package:bayaa_pos/shared/theme/app_colors.dart';
import 'erp_view_spec.dart';
import 'erp_record_avatar.dart';
import 'erp_status_badge.dart';
import 'erp_form_dialog.dart';

class ErpRecordDetailsScreen extends StatelessWidget {
  const ErpRecordDetailsScreen(
      {super.key, required this.spec, required this.record});
  final ErpViewSpec spec;
  final ErpRecordView record;
  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(title: Text(record.id), actions: [
          IconButton(
              tooltip: arabic ? 'تعديل' : 'Edit',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => showErpForm(context, spec, record: record))
        ]),
        body: LayoutBuilder(
            builder: (context, size) => SingleChildScrollView(
                padding: LayoutTokens.pagePadding(size.maxWidth),
                child: Center(
                    child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1000),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                ErpRecordAvatar(
                                    tag: '${spec.id}-${record.id}',
                                    icon: spec.icon,
                                    size: 72),
                                const SizedBox(width: 18),
                                Expanded(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                      Text(record.title,
                                          style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.textPrimary)),
                                      const SizedBox(height: 6),
                                      Text(record.subtitle,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.mutedColor)),
                                      const SizedBox(height: 10),
                                      ErpStatusBadge(
                                          label: record.status.of(context),
                                          tone: record.tone)
                                    ]))
                              ]),
                              const SizedBox(height: 24),
                              Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                      color: AppColors.surfaceColor,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                          color: AppColors.borderColor)),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(arabic ? 'نظرة عامة' : 'Overview',
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700)),
                                        const SizedBox(height: 24),
                                        AdaptiveColumns(
                                            minWidth: 220,
                                            maxColumns: 3,
                                            children: [
                                              for (var i = 0;
                                                  i < spec.columns.length &&
                                                      i < record.cells.length;
                                                  i++)
                                                Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 18),
                                                    child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                              spec.columns[i]
                                                                  .of(context),
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 12,
                                                                  color: AppColors
                                                                      .mutedColor)),
                                                          const SizedBox(
                                                              height: 8),
                                                          Text(record.cells[i],
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600))
                                                        ])),
                                            ]),
                                      ])),
                              const SizedBox(height: 20),
                              Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                      color: AppColors.surfaceColor,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                          color: AppColors.borderColor)),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            arabic
                                                ? 'المستندات والملاحظات'
                                                : 'Documents & notes',
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700)),
                                        const SizedBox(height: 16),
                                        Text(record.subtitle,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    AppColors.textSecondary)),
                                        const SizedBox(height: 16),
                                        Wrap(
                                            spacing: 12,
                                            runSpacing: 12,
                                            children: [
                                              OutlinedButton.icon(
                                                  onPressed: () =>
                                                      showPreviewAction(
                                                          context),
                                                  icon: const Icon(
                                                      Icons.attach_file,
                                                      size: 18),
                                                  label: Text(arabic
                                                      ? 'إرفاق مستند'
                                                      : 'Attach document')),
                                              OutlinedButton.icon(
                                                  onPressed: () =>
                                                      showPreviewAction(
                                                          context),
                                                  icon: const Icon(
                                                      Icons.note_add_outlined,
                                                      size: 18),
                                                  label: Text(arabic
                                                      ? 'إضافة ملاحظة'
                                                      : 'Add note')),
                                            ]),
                                      ])),
                            ]))))));
  }
}
