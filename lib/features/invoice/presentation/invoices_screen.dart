import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printing/printing.dart';

import '../../../core/constants/app_colors.dart';
import '../../auth/data/models/user_model.dart';
import '../../sales/data/models/sale_model.dart';
import '../../../core/components/screen_header.dart';
import '../../sales/domain/sales_repository.dart';
import '../data/invoice_models.dart';
import '../domain/invoice_pdf_service.dart';
import '../domain/refund_calculation_service.dart';
import 'cubit/invoice_cubit.dart';
import 'cubit/invoice_state.dart';
import 'invoice_preview_screen.dart';
import 'widgets/invoice_filter_section.dart';
import 'widgets/invoice_list_section.dart';
import 'widgets/partial_refund_dialog.dart';
import '../../settings/presentation/cubit/settings_cubit.dart';
import '../../../core/di/dependency_injection.dart';



class InvoiceScreen extends StatefulWidget {
  final SalesRepository repository;
  final User currentUser;

  const InvoiceScreen({
    Key? key,
    required this.repository,
    required this.currentUser,
  }) : super(key: key);

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final TextEditingController _barcodeSearchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  final StringBuffer _hidBuffer = StringBuffer();
  Timer? _hidTimer;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.forward();

    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InvoiceCubit>().loadSales();
    });


    
    _searchFocusNode.addListener(_onFocusChange);
    RawKeyboard.instance.addListener(_onRawKey);
  }

  void _onFocusChange() {
    if (_searchFocusNode.hasFocus) {
      RawKeyboard.instance.removeListener(_onRawKey);
    } else {
      RawKeyboard.instance.addListener(_onRawKey);
    }
  }

  @override
  void dispose() {
    _searchFocusNode.removeListener(_onFocusChange);
    RawKeyboard.instance.removeListener(_onRawKey);
    _hidTimer?.cancel();
    _debounceTimer?.cancel();
    _barcodeSearchController.dispose();
    _searchFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onRawKey(RawKeyEvent event) {
    if (event is! RawKeyDownEvent) return;
    
    if (ModalRoute.of(context)?.isCurrent != true) return;
  
    if (_searchFocusNode.hasFocus) return; 

    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.numpadEnter) {
      _hidTimer?.cancel();
      final code = _hidBuffer.toString().trim();
      _hidBuffer.clear();
      _searchByBarcode(code);
      return;
    }
    String? ch = event.character;
    if ((ch == null || ch.isEmpty) && event.logicalKey.keyLabel.length == 1) {
      ch = event.logicalKey.keyLabel;
    }
    if (ch != null && ch.isNotEmpty && ch.codeUnitAt(0) >= 32) {
      _hidBuffer.write(ch);
      _barcodeSearchController.text = _hidBuffer.toString();

      _hidTimer?.cancel();
      _hidTimer = Timer(const Duration(milliseconds: 120), () {
        final code = _hidBuffer.toString().trim();
        _hidBuffer.clear();
        _searchByBarcode(code);
      });
    }
  }

  void _searchByBarcode(String barcode) {
    context.read<InvoiceCubit>().setSearchQuery(barcode);
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    if (query.isEmpty) {
      _searchByBarcode('');
      return;
    }
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _searchByBarcode(query);
    });
  }

  void _clearFilters() {
    context.read<InvoiceCubit>().resetFilters();
  }

  Future<void> _selectDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final cubit = context.read<InvoiceCubit>();
      cubit.setDate(
          isStart ? picked : cubit.state.startDate,
          !isStart ? picked : cubit.state.endDate);
    }
  }

  Future<void> _handleDeleteSale(Sale sale) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد حذف الفاتورة'),
        content: Text('هل أنت متأكد من حذف الفاتورة (#${sale.id}) نهائياً؟\n\nهذا الإجراء لا يمكن التراجع عنه.'),
        actions: [
          TextButton(
            child: const Text('إلغاء'),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorColor,
            ),
            child: const Text('تأكيد الحذف'),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;

    try {
      await context.read<InvoiceCubit>().deleteSale(sale.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حذف الفاتورة بنجاح')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل حذف الفاتورة: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _handleReturnSale(Sale sale) async {
    // Show partial refund dialog
    final refundService = RefundCalculationService(widget.repository);
    
    final selectedItems = await showDialog<List<RefundItem>>(
      context: context,
      builder: (ctx) => PartialRefundDialog(
        originalSale: sale,
        refundService: refundService,
      ),
    );

    if (selectedItems == null || selectedItems.isEmpty) return;

    // Create partial refund
    await context.read<InvoiceCubit>().createPartialRefund(
      originalSale: sale,
      itemsToRefund: selectedItems,
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم المرتجع بنجاح')),
      );
    }
  }

  Future<void> _deleteInvoices(
      DateTime? startDate, DateTime? endDate, String searchQuery) async {
    // Require date range for bulk deletion
    if (startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب تحديد نطاق التاريخ لحذف الفواتير'),
          backgroundColor: AppColors.errorColor,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد حذف الفواتير'),
        content: Text(
            'هل أنت متأكد من حذف جميع الفواتير من ${startDate.year}-${startDate.month}-${startDate.day} إلى ${endDate.year}-${endDate.month}-${endDate.day}؟\n\nهذا الإجراء لا يمكن التراجع عنه.'),
        actions: [
          TextButton(
            child: const Text('إلغاء'),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorColor,
            ),
            child: const Text('تأكيد الحذف'),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;

    try {
      await context
          .read<InvoiceCubit>()
          .deleteInvoices(startDate, endDate, searchQuery);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حذف الفواتير بنجاح')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل حذف الفواتير: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _openInvoice(Sale sale) async {
    final subtotal = sale.saleItems.fold<double>(0, (s, it) => s + it.total);
    final cashierName = sale.cashierName ?? 'الكاشير';

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
    );

    await Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          InvoicePreviewScreen(data: data, receiptMode: false),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.1),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
              child: child),
        );
      },
    ));
  }

  Future<void> _handlePrintInvoice(Sale sale) async {
    final subtotal = sale.saleItems.fold<double>(0, (s, it) => s + it.total);
    final cashierName = sale.cashierName ?? 'الكاشير';

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
    );

    await Printing.layoutPdf(
      onLayout: (format) => InvoicePdfService.buildReceipt80mm(data),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    return BlocBuilder<InvoiceCubit, InvoiceState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(isDesktop ? 32 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   FadeTransition(
                    opacity: _animationController,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, -0.2),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _animationController,
                        curve: Curves.easeOut,
                      )),
                      child: ScreenHeader(
                        title: 'الفواتير',
                        icon: Icons.receipt_long,
                        subtitle: 'عرض وطباعة الفواتير الصادرة',
                        subtitleColor: AppColors.mutedColor,
                        iconColor: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FadeTransition(
                    opacity: _animationController,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, -0.1),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _animationController,
                        curve: Curves.easeOut,
                      )),
                      child: InvoiceFilterSection(
                        isDesktop: isDesktop,
                        barcodeSearchController: _barcodeSearchController,
                        focusNode: _searchFocusNode,
                        searchQuery: state.searchQuery,
                        onSearch: _searchByBarcode,
                        onChanged: _onSearchChanged,
                        onClearSearch: () {
                          _barcodeSearchController.clear();
                          _searchByBarcode('');
                        },
                        startDate: state.startDate,
                        endDate: state.endDate,
                        onSelectDate: _selectDate,
                        onClearFilters: _clearFilters,
                        onDeleteInvoices: () =>
                            _deleteInvoices(state.startDate, state.endDate, state.searchQuery),
                        filterType: state.filterType,
                        onFilterTypeChanged: (type) =>
                            context.read<InvoiceCubit>().setFilterType(type),
                        isManager: widget.currentUser.userType == UserType.manager,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: InvoiceListSection(
                      loading: state.loading,
                      sales: state.sales,
                      startDate: state.startDate,
                      endDate: state.endDate,
                      animationController: _animationController,
                      onOpenInvoice: _openInvoice,
                      onDeleteSale: _handleDeleteSale,
                      onReturnSale: _handleReturnSale,
                      onPrintInvoice: _handlePrintInvoice,
                      isManager: widget.currentUser.userType == UserType.manager,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
