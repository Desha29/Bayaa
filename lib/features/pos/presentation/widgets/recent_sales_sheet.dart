import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bayaa_pos/features/pos/presentation/models/invoice_view_data.dart';
import 'package:bayaa_pos/features/invoices/presentation/models/invoice_document_view_data.dart';
import 'package:bayaa_pos/features/invoices/presentation/screens/invoice_preview_screen.dart';
import 'package:bayaa_pos/features/settings/presentation/controllers/settings_cubit.dart';
import 'package:bayaa_pos/app/bootstrap/service_locator.dart';
import 'package:bayaa_pos/l10n/app_localizations.dart';
import 'package:bayaa_pos/shared/theme/app_colors.dart';
import 'package:bayaa_pos/shared/widgets/workspace/workspace_data_table.dart';
import 'package:bayaa_pos/shared/widgets/workspace/workspace_summary.dart';

class RecentSalesSheet extends StatefulWidget {
  const RecentSalesSheet({super.key, required this.sales, this.onSelectSale});
  final List<InvoiceViewData> sales;
  final ValueChanged<InvoiceViewData>? onSelectSale;

  static Future<void> show(BuildContext context,
          {required List<InvoiceViewData> sales,
          ValueChanged<InvoiceViewData>? onSelectSale}) =>
      showDialog<void>(
          context: context,
          builder: (_) =>
              RecentSalesSheet(sales: sales, onSelectSale: onSelectSale));

  @override
  State<RecentSalesSheet> createState() => _RecentSalesSheetState();
}

class _RecentSalesSheetState extends State<RecentSalesSheet> {
  final _search = TextEditingController();
  final _focus = FocusNode();
  String _filter = 'all';
  bool _cards = false;
  bool get _ar => Localizations.localeOf(context).languageCode == 'ar';
  String _copy(String ar, String en) => _ar ? ar : en;
  String _money(double amount) =>
      '${amount.toStringAsFixed(2)} ${AppLocalizations.of(context).currencyEg}';
  String _date(DateTime date) =>
      DateFormat('dd MMM • hh:mm a', _ar ? 'ar' : 'en').format(date);

  @override
  void dispose() {
    _search.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    final query = _search.text.toLowerCase().trim();
    final filtered = widget.sales
        .where((sale) =>
            (_filter == 'all' ||
                (_filter == 'refund' ? sale.isRefund : !sale.isRefund)) &&
            (query.isEmpty ||
                '${sale.id} ${sale.cashierName ?? ''}'
                    .toLowerCase()
                    .contains(query)))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return Dialog(
      insetPadding: const EdgeInsets.all(12),
      backgroundColor: AppColors.surfaceColor,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1080, maxHeight: 850),
          child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(children: [
                      Icon(Icons.history_rounded,
                          color: AppColors.primaryColor, size: 24),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(_copy('آخر المبيعات', 'Recent sales'),
                                style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary)),
                            const SizedBox(height: 4),
                            Text(
                                _copy(
                                    'فواتير تجريبية • استعرض الإيصال دون تغيير البيانات',
                                    'Sample invoices • view receipts without changing records'),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                    color: AppColors.mutedColor)),
                          ])),
                      IconButton(
                          tooltip: _copy('إغلاق', 'Close'),
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded, size: 20)),
                    ]),
                    const SizedBox(height: 20),
                    TextField(
                        controller: _search,
                        focusNode: _focus,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                            hintText: _copy('ابحث برقم الفاتورة أو الكاشير...',
                                'Search invoice number or cashier...'),
                            prefixIcon:
                                const Icon(Icons.search_rounded, size: 20),
                            suffixIcon: _search.text.isEmpty
                                ? null
                                : IconButton(
                                    tooltip: _copy('مسح البحث', 'Clear search'),
                                    onPressed: () {
                                      setState(_search.clear);
                                      _focus.requestFocus();
                                    },
                                    icon: const Icon(Icons.close, size: 18)))),
                    const SizedBox(height: 12),
                    Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          for (final filter in [
                            ('all', _copy('الكل', 'All')),
                            ('sales', _copy('المبيعات', 'Sales')),
                            ('refund', _copy('المرتجعات', 'Refunds'))
                          ])
                            ChoiceChip(
                                selected: _filter == filter.$1,
                                label: Text(filter.$2),
                                showCheckmark: false,
                                selectedColor: AppColors.primaryColor,
                                labelStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: _filter == filter.$1
                                        ? AppColors.primaryForeground
                                        : AppColors.textSecondary),
                                onSelected: (_) =>
                                    setState(() => _filter = filter.$1)),
                          IconButton(
                              tooltip: _cards
                                  ? _copy('عرض الجدول', 'Table view')
                                  : _copy('عرض البطاقات', 'Card view'),
                              onPressed: () => setState(() => _cards = !_cards),
                              icon: Icon(
                                  _cards
                                      ? Icons.table_rows_outlined
                                      : Icons.grid_view_outlined,
                                  size: 20,
                                  color: AppColors.secondaryColor)),
                          Text(
                              _copy('${filtered.length} فاتورة',
                                  '${filtered.length} invoices'),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  color: AppColors.mutedColor)),
                        ]),
                    const SizedBox(height: 16),
                    if (filtered.isEmpty)
                      Padding(
                          padding: const EdgeInsets.symmetric(vertical: 36),
                          child: Column(children: [
                            Icon(Icons.search_off_rounded,
                                color: AppColors.mutedColor, size: 40),
                            const SizedBox(height: 12),
                            Text(_copy('لا توجد فواتير مطابقة',
                                'No matching invoices')),
                            const SizedBox(height: 8),
                            TextButton(
                                onPressed: () => setState(() {
                                      _search.clear();
                                      _filter = 'all';
                                    }),
                                child: Text(_copy(
                                    'إعادة تعيين البحث', 'Reset search'))),
                          ]))
                    else
                      LayoutBuilder(builder: (context, size) {
                        if (!_cards &&
                            size.maxWidth >= 760 &&
                            MediaQuery.textScalerOf(context).scale(1) <= 1.3) {
                          return WorkspaceDataTable<InvoiceViewData>(
                              records: filtered,
                              minimumWidth: 850,
                              columns: [
                                WorkspaceColumn(
                                    label: _copy('الفاتورة', 'Invoice'),
                                    cell: (sale) => Text('#${sale.id}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w800)),
                                    compare: (a, b) => a.id.compareTo(b.id)),
                                WorkspaceColumn(
                                    label: _copy('الكاشير', 'Cashier'),
                                    cell: (sale) =>
                                        Text(sale.cashierName ?? '—')),
                                WorkspaceColumn(
                                    label: _copy('التاريخ', 'Date'),
                                    cell: (sale) => Text(_date(sale.date)),
                                    compare: (a, b) =>
                                        a.date.compareTo(b.date)),
                                WorkspaceColumn(
                                    label: _copy('الإجمالي', 'Total'),
                                    numeric: true,
                                    compare: (a, b) =>
                                        a.total.compareTo(b.total),
                                    cell: (sale) => Text(_money(sale.total),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            color: sale.isRefund
                                                ? AppColors.errorColor
                                                : AppColors.primaryColor))),
                                WorkspaceColumn(
                                    label: _copy('الحالة', 'Status'),
                                    cell: _status),
                                WorkspaceColumn(
                                    label: _copy('الإيصال', 'Receipt'),
                                    cell: (sale) => IconButton(
                                        tooltip: _copy(
                                            'عرض الإيصال', 'View receipt'),
                                        onPressed: () => _openPreview(sale),
                                        icon: Icon(Icons.receipt_long_outlined,
                                            color: AppColors.secondaryColor,
                                            size: 19))),
                              ]);
                        }
                        final count = size.maxWidth >= 640 ? 2 : 1;
                        final width =
                            (size.maxWidth - (count - 1) * 12) / count;
                        return Wrap(spacing: 12, runSpacing: 12, children: [
                          for (final sale in filtered)
                            SizedBox(width: width, child: _card(sale)),
                        ]);
                      }),
                  ]))),
    );
  }

  Widget _status(InvoiceViewData sale) => WorkspacePill(
      label: sale.isRefund ? _copy('مرتجع', 'Refund') : _copy('مدفوعة', 'Paid'),
      icon: sale.isRefund ? Icons.undo_rounded : Icons.check_circle_outline,
      color: sale.isRefund ? AppColors.errorColor : AppColors.successColor);

  Widget _card(InvoiceViewData sale) => Material(
      color: AppColors.surfaceColor,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: AppColors.borderColor)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
          onTap: () => _openPreview(sale),
          child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  border: Border(
                      top: BorderSide(
                          width: 3,
                          color: sale.isRefund
                              ? AppColors.errorColor
                              : AppColors.successColor))),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                          child: Text('#${sale.id}',
                              style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  color: AppColors.textPrimary))),
                      _status(sale)
                    ]),
                    const SizedBox(height: 14),
                    Text(_money(sale.total),
                        style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.w900,
                            color: sale.isRefund
                                ? AppColors.errorColor
                                : AppColors.primaryColor)),
                    const SizedBox(height: 10),
                    Text(
                        sale.cashierName ??
                            AppLocalizations.of(context).cashier,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: AppColors.textSecondary)),
                    const SizedBox(height: 5),
                    Wrap(spacing: 8, runSpacing: 4, children: [
                      Text(_date(sale.date),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              color: AppColors.mutedColor)),
                      Text(
                          _copy('${sale.saleItems.length} أصناف',
                              '${sale.saleItems.length} items'),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              color: AppColors.mutedColor)),
                    ]),
                    const SizedBox(height: 12),
                    Row(children: [
                      Icon(Icons.receipt_long_outlined,
                          size: 16, color: AppColors.secondaryColor),
                      const SizedBox(width: 6),
                      Expanded(
                          child: Text(_copy('عرض الإيصال', 'View receipt'),
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.secondaryColor))),
                      Icon(Icons.arrow_forward_rounded,
                          size: 16, color: AppColors.secondaryColor),
                    ]),
                  ]))));

  void _openPreview(InvoiceViewData sale) {
    widget.onSelectSale?.call(sale);
    final store = getIt<SettingsCubit>().currentStoreInfo;
    final data = InvoiceData(
        invoiceId: sale.id,
        date: sale.date,
        storeName: store?.name ?? '',
        storeAddress: store?.address ?? '',
        storePhone: store?.phone ?? '',
        cashierName: sale.cashierName ?? AppLocalizations.of(context).cashier,
        lines: sale.saleItems
            .map((item) => InvoiceLine(
                name: item.name, price: item.price, qty: item.quantity))
            .toList(),
        subtotal:
            sale.saleItems.fold<double>(0, (sum, item) => sum + item.total),
        discount: 0,
        tax: 0,
        grandTotal: sale.total,
        paymentMethod: sale.paymentMethod);
    Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => InvoicePreviewScreen(data: data)));
  }
}
