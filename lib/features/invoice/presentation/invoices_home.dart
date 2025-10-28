// lib/features/invoice/presentation/invoices_home.dart
import 'dart:async';

import 'package:crazy_phone_pos/core/components/screen_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../auth/data/models/user_model.dart';
import '../../sales/data/models/sale_model.dart';
import '../../sales/domain/sales_repository.dart';

import '../data/invoice_models.dart';
import 'invoice_preview_screen.dart';

class InvoicesHome extends StatefulWidget {
  final SalesRepository repository;
  final User currentUser;

  const InvoicesHome({
    super.key,
    required this.repository,
    required this.currentUser,
  });

  @override
  State<InvoicesHome> createState() => _InvoicesHomeState();
}

class _InvoicesHomeState extends State<InvoicesHome>
    with SingleTickerProviderStateMixin {
  DateTime? _startDate;
  DateTime? _endDate;
  late Future<List<Sale>> _salesFuture;
  late AnimationController _animationController;

  final TextEditingController _barcodeSearchController =
      TextEditingController();
  final StringBuffer _hidBuffer = StringBuffer();
  Timer? _hidTimer;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadSales();
    _animationController.forward();

    RawKeyboard.instance.addListener(_onRawKey);
  }

  @override
  void dispose() {
    RawKeyboard.instance.removeListener(_onRawKey);
    _hidTimer?.cancel();
    _barcodeSearchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onRawKey(RawKeyEvent event) {
    if (event is! RawKeyDownEvent) return;

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
    if (barcode.isEmpty) return;
    setState(() {
      _searchQuery = barcode;
      _loadSales();
    });
  }

  void _loadSales() {
    setState(() {
      _salesFuture = widget.repository
          .getRecentSales(limit: 10000)
          .then((e) => e.getOrElse(() => []))
          .then((sales) => _filterSales(sales));
    });
  }

  List<Sale> _filterSales(List<Sale> sales) {
    var filtered = sales;

    if (_startDate != null || _endDate != null) {
      filtered = filtered.where((sale) {
        if (_startDate != null && sale.date.isBefore(_startDate!)) {
          return false;
        }
        if (_endDate != null) {
          final endOfDay = DateTime(
              _endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59);
          if (sale.date.isAfter(endOfDay)) {
            return false;
          }
        }
        return true;
      }).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((sale) {
        if (sale.id.contains(_searchQuery)) return true;
        return sale.saleItems.any((item) =>
            item.productId.contains(_searchQuery) ||
            item.name.toLowerCase().contains(_searchQuery.toLowerCase()));
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 32 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Current User Badge
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
                    subtitleColor: Colors.grey.shade600,
                    iconColor: AppColors.primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Filter Section
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
                  child: _buildFilterSection(isDesktop),
                ),
              ),
              const SizedBox(height: 24),

              // Invoice List
              Expanded(
                child: FutureBuilder<List<Sale>>(
                  future: _salesFuture,
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                        ),
                      );
                    }
                    if (!snap.hasData || snap.data!.isEmpty) {
                      return FadeTransition(
                        opacity: _animationController,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.receipt_long_outlined,
                                size: 80,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _startDate != null || _endDate != null
                                    ? 'لا توجد فواتير في الفترة المحددة'
                                    : 'لا توجد فواتير حديثة',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    final sales = snap.data!;
                    return ListView.separated(
                      itemCount: sales.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) =>
                          _buildAnimatedInvoiceCard(sales[i], i),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection(bool isDesktop) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: isDesktop
          ? Column(
              spacing: 20,
              children: [
                FadeTransition(
                  opacity: _animationController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.qr_code_scanner,
                              color: AppColors.primaryColor, size: 24),
                          const SizedBox(width: 12),
                          Text(
                            'بحث بالباركود',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.kDarkChip,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _barcodeSearchController,
                              decoration: InputDecoration(
                                hintText: 'امسح الباركود أو اكتب رقم الفاتورة',
                                prefixIcon: Icon(Icons.search,
                                    color: AppColors.primaryColor),
                                suffixIcon: _searchQuery.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: () {
                                          _barcodeSearchController.clear();
                                          setState(() {
                                            _searchQuery = '';
                                            _loadSales();
                                          });
                                        },
                                      )
                                    : null,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: AppColors.primaryColor, width: 2),
                                ),
                              ),
                              onSubmitted: (value) {
                                _searchByBarcode(value);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                      ),
                      if (_searchQuery.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.search,
                                  color: AppColors.primaryColor, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                'البحث عن: $_searchQuery',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                        child: _buildDateButton('من تاريخ', _startDate, true)),
                    const SizedBox(width: 16),
                    Expanded(
                        child: _buildDateButton('إلى تاريخ', _endDate, false)),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _clearFilters,
                      icon: const Icon(Icons.clear_all, size: 20),
                      label: const Text('مسح الفلاتر'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade100,
                        foregroundColor: Colors.grey.shade700,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _clearFilters,
                      icon: const Icon(Icons.clear, size: 20),
                      label: const Text('مسح الفواتير'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.grey.shade100,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            )
          : Column(
              children: [
                _buildDateButton('من تاريخ', _startDate, true),
                const SizedBox(height: 12),
                _buildDateButton('إلى تاريخ', _endDate, false),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _clearFilters,
                    icon: const Icon(Icons.clear_all, size: 20),
                    label: const Text('مسح الفلاتر'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade100,
                      foregroundColor: Colors.grey.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildDateButton(String label, DateTime? date, bool isStart) {
    return InkWell(
      onTap: () => _selectDate(isStart),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: AppColors.primaryColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date != null
                        ? DateFormat('yyyy-MM-dd').format(date)
                        : 'اختر التاريخ',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.kDarkChip,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? DateTime.now()),
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
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
      _loadSales();
    }
  }

  void _clearFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
    _loadSales();
  }

  Widget _buildAnimatedInvoiceCard(Sale sale, int index) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            (index * 0.1).clamp(0.0, 1.0),
            ((index * 0.1) + 0.3).clamp(0.0, 1.0),
            curve: Curves.easeOut,
          ),
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(
              (index * 0.1).clamp(0.0, 1.0),
              ((index * 0.1) + 0.3).clamp(0.0, 1.0),
              curve: Curves.easeOut,
            ),
          ),
        ),
        child: _buildInvoiceCard(sale),
      ),
    );
  }

  Widget _buildInvoiceCard(Sale sale) {
    final df = DateFormat('yyyy-MM-dd  HH:mm');
    final cashierName = sale.cashierName ?? 'الكاشير';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openInvoice(sale),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Receipt Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.receipt_long,
                    color: AppColors.primaryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),

                // Invoice Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Invoice Number
                      Text(
                        'فاتورة #${sale.id}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.kDarkChip,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Cashier Name and Item Count
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            cashierName,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            ' • ',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            '${sale.items} صنف',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),

                      // Date and Time
                      Text(
                        df.format(sale.date),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Price and Print Button
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${sale.total.toStringAsFixed(2)} ج.م',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.print,
                        color: AppColors.primaryColor,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openInvoice(Sale sale) async {
    final subtotal = sale.saleItems.fold<double>(0, (s, it) => s + it.total);
    final cashierName = sale.cashierName ?? 'الكاشير';

    final data = InvoiceData(
      invoiceId: sale.id,
      date: sale.date,
      storeName: 'Crazy Phone',
      storeAddress: ' الخانكة امام شارع الحجار   - القليوبية ',
      storePhone: '01002546124',
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
      logoAsset: 'assets/images/logo1.png',
    );

    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            InvoicePreviewScreen(data: data, receiptMode: false),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.1),
                end: Offset.zero,
              ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut)),
              child: child,
            ),
          );
        },
      ),
    );
  }
}
