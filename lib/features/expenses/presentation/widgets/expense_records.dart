import 'package:flutter/material.dart';
import 'package:bayaa_pos/shared/theme/app_colors.dart';
import 'package:bayaa_pos/shared/feedback/preview_action.dart';
import 'package:bayaa_pos/shared/widgets/workspace/workspace_data_table.dart';
import 'package:bayaa_pos/shared/widgets/workspace/workspace_summary.dart';
import '../models/expense_view_data.dart';
import 'expense_form_dialog.dart';
import 'expense_labels.dart';

class ExpenseRecords extends StatelessWidget {
  const ExpenseRecords(
      {super.key, required this.records, required this.onReset});
  final List<ExpenseViewData> records;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    final labels = ExpenseLabels.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(children: [
            Expanded(
                child: Text(labels.text('سجل المصروفات', 'Expense register'),
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: AppColors.textPrimary))),
            WorkspacePill(
                label: labels.text(
                    '${records.length} مصروف', '${records.length} records'),
                color: AppColors.primaryColor),
          ])),
      if (records.isEmpty)
        Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
                color: AppColors.surfaceColor,
                border: Border.all(color: AppColors.borderColor),
                borderRadius: BorderRadius.circular(16)),
            child: Column(children: [
              Icon(Icons.search_off_rounded,
                  size: 36, color: AppColors.mutedColor),
              const SizedBox(height: 12),
              Text(
                  labels.text(
                      'لا توجد مصروفات تطابق البحث', 'No matching expenses'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(
                  labels.text('جرّب وصفاً آخر أو أعد تعيين الفلاتر.',
                      'Try another description or reset your filters.'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppColors.mutedColor)),
              const SizedBox(height: 12),
              OutlinedButton(
                  onPressed: onReset,
                  child: Text(labels.text('إعادة تعيين', 'Reset filters'))),
            ]))
      else
        LayoutBuilder(builder: (context, size) {
          if (size.maxWidth >= 760 &&
              MediaQuery.textScalerOf(context).scale(1) <= 1.3) {
            return WorkspaceDataTable<ExpenseViewData>(
                records: records,
                minimumWidth: 940,
                columns: [
                  WorkspaceColumn(
                      label: labels.text('المصروف', 'Expense'),
                      compare: (a, b) => a.title.compareTo(b.title),
                      cell: (item) => SizedBox(
                          width: 230,
                          child: Row(children: [
                            _ExpenseIcon(),
                            const SizedBox(width: 12),
                            Expanded(
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Text(item.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 3),
                                  Text(item.id.toUpperCase(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                          color: AppColors.mutedColor)),
                                ])),
                          ]))),
                  WorkspaceColumn(
                      label: labels.text('الفئة', 'Category'),
                      compare: (a, b) => labels
                          .category(a.category)
                          .compareTo(labels.category(b.category)),
                      cell: (item) => WorkspacePill(
                          label: labels.category(item.category),
                          color: AppColors.secondaryColor,
                          icon: Icons.label_outline_rounded)),
                  WorkspaceColumn(
                      label: labels.text('التاريخ', 'Date'),
                      compare: (a, b) => a.date.compareTo(b.date),
                      cell: (item) => Text(labels.date(item.date))),
                  WorkspaceColumn(
                      label: labels.text('المبلغ', 'Amount'),
                      numeric: true,
                      compare: (a, b) => a.amount.compareTo(b.amount),
                      cell: (item) => Text(labels.money(item.amount),
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary))),
                  WorkspaceColumn(
                      label: labels.text('الإجراءات', 'Actions'),
                      cell: (item) => _RecordActions(expense: item)),
                ]);
          }
          final columns = size.maxWidth >= 580 ? 2 : 1;
          final width = (size.maxWidth - (columns - 1) * 12) / columns;
          return Wrap(spacing: 12, runSpacing: 12, children: [
            for (final item in records)
              SizedBox(width: width, child: _ExpenseCard(expense: item)),
          ]);
        }),
    ]);
  }
}

class _ExpenseIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
          color: AppColors.primaryColor.withValues(alpha: .07),
          borderRadius: BorderRadius.circular(11)),
      child: Icon(Icons.receipt_long_outlined,
          size: 18, color: AppColors.primaryColor));
}

class _ExpenseCard extends StatelessWidget {
  const _ExpenseCard({required this.expense});
  final ExpenseViewData expense;
  @override
  Widget build(BuildContext context) {
    final labels = ExpenseLabels.of(context);
    return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: AppColors.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderColor)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            _ExpenseIcon(),
            const SizedBox(width: 10),
            Expanded(
                child: Text(expense.title,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary))),
          ]),
          const SizedBox(height: 16),
          Text(labels.money(expense.amount),
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                WorkspacePill(
                    label: labels.category(expense.category),
                    color: AppColors.secondaryColor),
                Text(labels.date(expense.date),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: AppColors.mutedColor)),
              ]),
          if (expense.notes?.isNotEmpty ?? false) ...[
            const SizedBox(height: 12),
            Text(expense.notes!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.mutedColor,
                    fontSize: 12)),
          ],
          const SizedBox(height: 12),
          Divider(color: AppColors.borderColor, height: 1),
          const SizedBox(height: 6),
          Row(children: [
            Expanded(
                child: Text(expense.id.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        color: AppColors.mutedColor))),
            _RecordActions(expense: expense),
          ]),
        ]));
  }
}

class _RecordActions extends StatelessWidget {
  const _RecordActions({required this.expense});
  final ExpenseViewData expense;
  @override
  Widget build(BuildContext context) {
    final labels = ExpenseLabels.of(context);
    return Row(mainAxisSize: MainAxisSize.min, children: [
      IconButton(
          tooltip: labels.text('عرض التفاصيل', 'View expense'),
          icon: Icon(Icons.visibility_outlined,
              size: 18, color: AppColors.secondaryColor),
          onPressed: () => _showDetails(context)),
      IconButton(
          tooltip: labels.text('تعديل المصروف', 'Edit expense'),
          icon:
              Icon(Icons.edit_outlined, size: 18, color: AppColors.mutedColor),
          onPressed: () => showExpenseForm(context, expense: expense)),
      IconButton(
          tooltip: labels.text('حذف المصروف', 'Delete expense'),
          icon: Icon(Icons.delete_outline_rounded,
              size: 18, color: AppColors.errorColor),
          onPressed: () => showPreviewAction(context)),
    ]);
  }

  void _showDetails(BuildContext context) {
    final labels = ExpenseLabels.of(context);
    showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
              backgroundColor: AppColors.surfaceColor,
              surfaceTintColor: Colors.transparent,
              scrollable: true,
              title: Text(expense.title,
                  style: const TextStyle(
                      fontSize: 19, fontWeight: FontWeight.w800)),
              content: SizedBox(
                  width: 400,
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(labels.money(expense.amount),
                            style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryColor)),
                        const SizedBox(height: 18),
                        WorkspacePill(
                            label: labels.category(expense.category),
                            color: AppColors.secondaryColor),
                        const SizedBox(height: 16),
                        Text(labels.date(expense.date),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.mutedColor)),
                        const SizedBox(height: 12),
                        Text(expense.notes?.isNotEmpty == true
                            ? expense.notes!
                            : labels.text('لا توجد ملاحظات إضافية.',
                                'No additional notes.')),
                        const SizedBox(height: 16),
                        Text(expense.id.toUpperCase(),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                color: AppColors.mutedColor)),
                      ])),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: Text(labels.text('إغلاق', 'Close')))
              ],
            ));
  }
}
