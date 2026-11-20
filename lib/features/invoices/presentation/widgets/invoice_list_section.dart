import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bayaa_pos/shared/theme/app_colors.dart';
import 'package:bayaa_pos/shared/widgets/workspace/workspace_data_table.dart';
import 'package:bayaa_pos/shared/widgets/workspace/workspace_summary.dart';
import 'package:bayaa_pos/shared/widgets/loading/skeleton.dart';
import 'package:bayaa_pos/l10n/app_localizations.dart';
import 'package:bayaa_pos/features/pos/presentation/models/invoice_view_data.dart';
import 'invoice_card.dart';

class InvoiceListSection extends StatefulWidget {
  const InvoiceListSection(
      {super.key,
      required this.loading,
      required this.sales,
      required this.onOpenInvoice,
      required this.onDeleteSale,
      required this.onReturnSale,
      required this.onPrintInvoice,
      required this.isManager});
  final bool loading, isManager;
  final List<InvoiceViewData> sales;
  final ValueChanged<InvoiceViewData> onOpenInvoice,
      onDeleteSale,
      onReturnSale,
      onPrintInvoice;
  @override
  State<InvoiceListSection> createState() => _InvoiceListSectionState();
}

class _InvoiceListSectionState extends State<InvoiceListSection> {
  int _page = 0;
  bool _table = false;
  @override
  void didUpdateWidget(covariant InvoiceListSection old) {
    super.didUpdateWidget(old);
    if (old.sales != widget.sales) _page = 0;
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    final l = AppLocalizations.of(context);
    final ar = l.localeName == 'ar';
    if (widget.loading) return const SkeletonList();
    final pages = math.max(1, (widget.sales.length / 12).ceil());
    final page = math.min(_page, pages - 1);
    final visible = widget.sales.skip(page * 12).take(12).toList();
    return LayoutBuilder(
        builder: (context, size) =>
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(children: [
                Expanded(
                    child: Text(
                        ar
                            ? '${widget.sales.length} فاتورة'
                            : '${widget.sales.length} invoices',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: AppColors.mutedColor))),
                IconButton(
                    tooltip: ar ? 'عرض البطاقات' : 'Card view',
                    isSelected: !_table,
                    onPressed: () => setState(() => _table = false),
                    icon: const Icon(Icons.grid_view_rounded, size: 20)),
                if (size.maxWidth >= 600)
                  IconButton(
                      tooltip: ar ? 'عرض الجدول' : 'Table view',
                      isSelected: _table,
                      onPressed: () => setState(() => _table = true),
                      icon: const Icon(Icons.view_list_rounded, size: 21)),
              ]),
              const SizedBox(height: 8),
              if (widget.sales.isEmpty)
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 60),
                    child: Column(children: [
                      Icon(Icons.receipt_long_outlined,
                          size: 48, color: AppColors.mutedColor),
                      const SizedBox(height: 14),
                      Text(l.noRecentInvoices),
                      Text(l.tryChangingFilter,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.mutedColor,
                              fontSize: 12))
                    ]))
              else if (_table && size.maxWidth >= 600)
                WorkspaceDataTable<InvoiceViewData>(
                    showViewToggle: false,
                    records: widget.sales,
                    columns: [
                      WorkspaceColumn(
                          label: ar ? 'رقم الفاتورة' : 'Invoice',
                          cell: (s) => TextButton(
                              onPressed: () => widget.onOpenInvoice(s),
                              child: Text('#${s.id}'))),
                      WorkspaceColumn(
                          label: l.cashier,
                          cell: (s) => Text(s.cashierName ?? l.cashier)),
                      WorkspaceColumn(
                          label: ar ? 'التاريخ' : 'Date',
                          compare: (a, b) => a.date.compareTo(b.date),
                          cell: (s) => Text(
                              DateFormat('dd MMM yyyy', l.localeName)
                                  .format(s.date))),
                      WorkspaceColumn(
                          label: ar ? 'الإجمالي' : 'Total',
                          numeric: true,
                          compare: (a, b) => a.total.compareTo(b.total),
                          cell: (s) => Text(
                              '${s.isRefund ? '-' : ''}${s.total.abs().toStringAsFixed(2)} ${l.currencyEg}',
                              style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: s.isRefund
                                      ? AppColors.errorColor
                                      : AppColors.textPrimary))),
                      WorkspaceColumn(
                          label: l.status,
                          cell: (s) => WorkspacePill(
                              label: s.isRefund
                                  ? l.refundsFilter
                                  : (ar ? 'مدفوعة' : 'Paid'),
                              color: s.isRefund
                                  ? AppColors.errorColor
                                  : AppColors.primaryColor)),
                      WorkspaceColumn(
                          label: l.actions,
                          cell: (s) => IconButton(
                              tooltip: ar ? 'عرض الفاتورة' : 'View invoice',
                              onPressed: () => widget.onOpenInvoice(s),
                              icon: const Icon(Icons.visibility_outlined,
                                  size: 18))),
                    ])
              else ...[
                Builder(builder: (context) {
                  final isMobile = size.maxWidth < 600;
                  final crossAxisCount = size.maxWidth >= 1080
                      ? 6
                      : isMobile
                          ? 2
                          : (size.maxWidth / 200).floor().clamp(2, 6);
                  final cardExtent = isMobile
                      ? 198.0
                      : 212.0 +
                          ((MediaQuery.textScalerOf(context).scale(1) - 1)
                                  .clamp(0, 2) *
                              100);
                  return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: visible.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: isMobile ? 10 : 12,
                          mainAxisSpacing: isMobile ? 10 : 12,
                          mainAxisExtent: cardExtent),
                      itemBuilder: (context, i) {
                        final s = visible[i];
                        return InvoiceCard(
                            sale: s,
                            onOpen: () => widget.onOpenInvoice(s),
                            onDelete: () => widget.onDeleteSale(s),
                            onPrint: () => widget.onPrintInvoice(s),
                            onReturn:
                                s.isRefund ? null : () => widget.onReturnSale(s),
                            isManager: widget.isManager);
                      });
                }),
                const SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  IconButton(
                      tooltip: ar ? 'السابق' : 'Previous page',
                      onPressed: page > 0
                          ? () => setState(() => _page = page - 1)
                          : null,
                      icon: const BackButtonIcon()),
                  Text('${page + 1} / $pages',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.mutedColor,
                          fontSize: 12)),
                  IconButton(
                      tooltip: ar ? 'التالي' : 'Next page',
                      onPressed: page + 1 < pages
                          ? () => setState(() => _page = page + 1)
                          : null,
                      icon: const RotatedBox(
                          quarterTurns: 2, child: BackButtonIcon())),
                ]),
              ],
            ]));
  }
}
