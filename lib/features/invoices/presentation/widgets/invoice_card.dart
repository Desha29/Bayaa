import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bayaa_pos/shared/theme/app_colors.dart';
import 'package:bayaa_pos/shared/widgets/workspace/workspace_summary.dart';
import 'package:bayaa_pos/shared/localization/translation_helper.dart';
import 'package:bayaa_pos/l10n/app_localizations.dart';
import 'package:bayaa_pos/features/pos/presentation/models/invoice_view_data.dart';

class InvoiceCard extends StatelessWidget {
  const InvoiceCard(
      {super.key,
      required this.sale,
      required this.onOpen,
      required this.onPrint,
      this.onDelete,
      this.onReturn,
      required this.isManager});
  final InvoiceViewData sale;
  final VoidCallback onOpen, onPrint;
  final VoidCallback? onDelete, onReturn;
  final bool isManager;
  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    final l = AppLocalizations.of(context);
    final ar = l.localeName == 'ar';
    final tone = sale.isRefund ? AppColors.errorColor : AppColors.primaryColor;
    return Material(
        color: AppColors.surfaceColor,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: tone.withValues(alpha: .2))),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
            onTap: onOpen,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 4, child: ColoredBox(color: tone)),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Expanded(
                                  child: Text(
                                      '#${sale.id.replaceFirst('DEMO-', '')}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textPrimary))),
                              WorkspacePill(
                                  label: sale.paymentMethod == 'cash'
                                      ? (ar ? 'نقدي' : 'Cash')
                                      : (ar ? 'بطاقة' : 'Card'),
                                  color: AppColors.secondaryColor,
                                  icon: Icons.payments_outlined)
                            ]),
                            const SizedBox(height: 12),
                            WorkspacePill(
                                label: sale.isRefund
                                    ? l.refundsFilter
                                    : (ar ? 'مدفوعة' : 'Paid'),
                                color: tone,
                                icon: sale.isRefund
                                    ? Icons.undo_rounded
                                    : Icons.check_circle_outline),
                            const SizedBox(height: 12),
                            Text(
                                '${sale.isRefund ? '-' : ''}${sale.total.abs().toStringAsFixed(2)} ${l.currencyEg}',
                                style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: tone)),
                            const SizedBox(height: 10),
                            _detail(
                                Icons.person_outline,
                                TranslationHelper.translateUserName(
                                    context, sale.cashierName ?? l.cashier)),
                            const SizedBox(height: 5),
                            _detail(Icons.inventory_2_outlined,
                                '${sale.items} ${ar ? 'أصناف' : 'items'}'),
                            const SizedBox(height: 5),
                            _detail(
                                Icons.schedule,
                                DateFormat('dd MMM · hh:mm a', l.localeName)
                                    .format(sale.date)),
                          ])),
                  const Spacer(),
                  Divider(height: 1, color: AppColors.borderColor),
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                                visualDensity: VisualDensity.compact,
                                tooltip: ar ? 'عرض الفاتورة' : 'View invoice',
                                onPressed: onOpen,
                                icon: Icon(Icons.visibility_outlined,
                                    size: 18, color: AppColors.primaryColor)),
                            IconButton(
                                visualDensity: VisualDensity.compact,
                                tooltip: ar ? 'طباعة' : 'Print',
                                onPressed: onPrint,
                                icon: Icon(Icons.print_outlined,
                                    size: 18, color: AppColors.secondaryColor)),
                            if (onReturn != null)
                              IconButton(
                                  visualDensity: VisualDensity.compact,
                                  tooltip: ar ? 'مرتجع' : 'Refund',
                                  onPressed: onReturn,
                                  icon: Icon(Icons.undo_rounded,
                                      size: 18, color: AppColors.warningColor)),
                            if (isManager)
                              IconButton(
                                  visualDensity: VisualDensity.compact,
                                  tooltip: l.delete,
                                  onPressed: onDelete,
                                  icon: Icon(Icons.delete_outline,
                                      size: 18, color: AppColors.errorColor)),
                          ])),
                ])));
  }

  Widget _detail(IconData icon, String text) => Row(children: [
        Icon(icon, size: 13, color: AppColors.mutedColor),
        const SizedBox(width: 6),
        Expanded(
            child: Text(text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: AppColors.mutedColor)))
      ]);
}
