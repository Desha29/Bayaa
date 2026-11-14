import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bayaa_pos/shared/theme/app_colors.dart';
import 'package:bayaa_pos/shared/widgets/screen_header.dart';
import 'package:bayaa_pos/shared/widgets/workspace/workspace_summary.dart';
import 'package:bayaa_pos/shared/feedback/preview_action.dart';
import 'package:bayaa_pos/l10n/app_localizations.dart';
import 'package:bayaa_pos/features/auth/presentation/models/user_view_data.dart';
import 'package:bayaa_pos/features/pos/presentation/models/invoice_view_data.dart';
import 'package:bayaa_pos/features/pos/presentation/sources/invoice_catalog_source.dart';
import 'package:bayaa_pos/preview/data/preview_data.dart';
import 'package:bayaa_pos/features/settings/presentation/controllers/settings_cubit.dart';
import 'package:bayaa_pos/app/bootstrap/service_locator.dart';
import '../models/invoice_document_view_data.dart';
import '../sources/refund_preview_source.dart';
import '../controllers/invoice_cubit.dart';
import '../controllers/invoice_state.dart';
import '../widgets/invoice_filter_section.dart';
import '../widgets/invoice_list_section.dart';
import '../widgets/partial_refund_dialog.dart';
import 'invoice_preview_screen.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen(
      {super.key, required this.repository, required this.currentUser});
  final InvoiceCatalogSource repository;
  final UserViewData currentUser;
  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  final _search = TextEditingController();
  final _focus = FocusNode();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _search.text = context.read<InvoiceCubit>().state.searchQuery;
        context.read<InvoiceCubit>().loadSales();
      }
    });
  }

  @override
  void dispose() {
    _search.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _selectDate(bool start) async {
    final state = context.read<InvoiceCubit>().state;
    final date = await showDatePicker(
        context: context,
        initialDate:
            (start ? state.startDate : state.endDate) ?? DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime.now());
    if (!mounted || date == null) return;
    context
        .read<InvoiceCubit>()
        .setDate(start ? date : state.startDate, start ? state.endDate : date);
  }

  Future<void> _handleReturnSale(InvoiceViewData sale) async {
    final selectedItems = await showDialog<List<RefundItem>>(
      context: context,
      builder: (_) => PartialRefundDialog(
          originalSale: sale,
          refundService: RefundPreviewSource(widget.repository)),
    );
    if (selectedItems != null && selectedItems.isNotEmpty && mounted) {
      showPreviewAction(context);
    }
  }

  Future<void> _openInvoice(InvoiceViewData sale) async {
    final l10n = AppLocalizations.of(context);
    final subtotal = sale.saleItems.fold<double>(0, (s, it) => s + it.total);
    final cashierName = sale.cashierName ?? l10n.cashier;

    final data = InvoiceData(
      invoiceId: sale.id,
      date: sale.date,
      storeName: getIt<SettingsCubit>().currentStoreInfo?.name ?? '',
      storeAddress: getIt<SettingsCubit>().currentStoreInfo?.address ?? '',
      storePhone: getIt<SettingsCubit>().currentStoreInfo?.phone ?? '',
      cashierName: cashierName,
      lines: sale.saleItems
          .map((it) => InvoiceLine(
                name: it.name,
                price: it.price,
                qty: it.quantity,
              ))
          .toList(),
      subtotal: subtotal,
      discount: 0.0,
      tax: 0.0,
      grandTotal: sale.total,
      paymentMethod: sale.paymentMethod,
    );

    await Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          InvoicePreviewScreen(data: data, receiptMode: true),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.1),
                end: Offset.zero,
              ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut)),
              child: child),
        );
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    final l = AppLocalizations.of(context);
    final ar = l.localeName == 'ar';
    final all = PreviewData.sales;
    final paid = all.where((s) => !s.isRefund).toList();
    final refunds = all.where((s) => s.isRefund).toList();
    return BlocBuilder<InvoiceCubit, InvoiceState>(
        builder: (context, state) => LayoutBuilder(
            builder: (context, size) => SingleChildScrollView(
                padding: EdgeInsets.all(size.maxWidth < 600 ? 12 : 24),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ScreenHeader(
                          title: l.invoices,
                          subtitle: l.invoicesSubtitle,
                          icon: Icons.receipt_long_outlined,
                          iconColor: AppColors.primaryColor),
                      const SizedBox(height: 20),
                      WorkspaceSummary(metrics: [
                        WorkspaceMetric(
                            ar ? 'إجمالي المبيعات' : 'Total sales',
                            '${paid.fold<double>(0, (v, s) => v + s.total).toStringAsFixed(0)} ${l.currencyEg}',
                            Icons.payments_outlined),
                        WorkspaceMetric(
                            ar ? 'إجمالي الفواتير' : 'Total invoices',
                            '${all.length}',
                            Icons.receipt_long_outlined),
                        WorkspaceMetric(
                            ar ? 'فواتير المبيعات' : 'Sales invoices',
                            '${paid.length}',
                            Icons.task_alt,
                            color: AppColors.secondaryColor),
                        WorkspaceMetric(l.refundsFilter, '${refunds.length}',
                            Icons.undo_rounded,
                            color: AppColors.errorColor),
                      ]),
                      const SizedBox(height: 20),
                      InvoiceFilterSection(
                          barcodeSearchController: _search,
                          focusNode: _focus,
                          searchQuery: state.searchQuery,
                          onSearch: context.read<InvoiceCubit>().setSearchQuery,
                          onChanged:
                              context.read<InvoiceCubit>().setSearchQuery,
                          onClearSearch: () {
                            _search.clear();
                            context.read<InvoiceCubit>().setSearchQuery('');
                          },
                          startDate: state.startDate,
                          endDate: state.endDate,
                          onSelectDate: _selectDate,
                          onClearFilters: () {
                            _search.clear();
                            context.read<InvoiceCubit>().resetFilters();
                          },
                          filterType: state.filterType,
                          onFilterTypeChanged:
                              context.read<InvoiceCubit>().setFilterType),
                      const SizedBox(height: 12),
                      InvoiceListSection(
                          loading: state.loading,
                          sales: state.sales,
                          onOpenInvoice: _openInvoice,
                          onDeleteSale: (_) => showPreviewAction(context),
                          onReturnSale: _handleReturnSale,
                          onPrintInvoice: (_) => showPreviewAction(context),
                          isManager: true),
                    ]))));
  }
}
