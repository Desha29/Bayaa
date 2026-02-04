import 'package:crazy_phone_pos/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import '../../data/models/daily_report_model.dart';
import '../../../sales/data/models/sale_model.dart';

class DailyReportDatasheetScreen extends StatefulWidget {
  final DailyReport report;

  const DailyReportDatasheetScreen({super.key, required this.report});

  @override
  State<DailyReportDatasheetScreen> createState() =>
      _DailyReportDatasheetScreenState();
}

class _DailyReportDatasheetScreenState extends State<DailyReportDatasheetScreen> {
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          title: const Text("جدول البيانات"),
          centerTitle: true,
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: widget.report.transactions.isEmpty
                ? const Center(child: Text('لا توجد معاملات'))
                : _buildDataTable(),
          ),
        ),
      ),
    );
  }

  Widget _buildDataTable() {
    // Sort transactions by date descending
    final transactions = List<Sale>.from(widget.report.transactions)
      ..sort((a, b) => b.date.compareTo(a.date));

    return LayoutBuilder(builder: (context, constraints) {
      return Scrollbar(
        controller: _verticalController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: _verticalController,
          scrollDirection: Axis.vertical,
          child: Scrollbar(
            controller: _horizontalController,
            thumbVisibility: true,
            trackVisibility: true,
            notificationPredicate: (notif) => notif.depth == 1,
            child: SingleChildScrollView(
              controller: _horizontalController,
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(
                      AppColors.primaryColor.withOpacity(0.05)),
                  columnSpacing: 24,
                  horizontalMargin: 24,
                  headingTextStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                    fontSize: 14,
                  ),
                  dataTextStyle: const TextStyle(
                    color: Colors.black87,
                    fontSize: 13,
                  ),
                  columns: const [
                    DataColumn(label: Text('رقم المعاملة')),
                    DataColumn(label: Text('الوقت')),
                    DataColumn(label: Text('النوع')),
                    DataColumn(label: Text('الكاشير')),
                    DataColumn(label: Text('الأصناف')), // New Column
                    DataColumn(label: Text('عدد')), 
                    DataColumn(label: Text('الإجمالي'), numeric: true),
                  ],
                  rows: transactions.map((sale) {
                    final isRefund = sale.isRefund;
                    
                    // Generate items string
                    final itemsText = sale.saleItems
                        .map((i) => '${i.name} (${i.quantity})')
                        .join('، ');

                    return DataRow(
                      cells: [
                        DataCell(Text('#${sale.id.substring(0, 8)}...')),
                        DataCell(Text(intl.DateFormat('hh:mm a').format(sale.date))),
                        DataCell(Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isRefund
                                  ? AppColors.errorColor.withOpacity(0.1)
                                  : AppColors.successColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isRefund ? 'مرتجع' : 'بيع',
                              style: TextStyle(
                                color: isRefund
                                    ? AppColors.errorColor
                                    : AppColors.successColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ))),
                        DataCell(Text(sale.cashierName ?? '-')),
                        DataCell(Container(
                          constraints: const BoxConstraints(maxWidth: 250),
                          child: Text(
                            itemsText,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: const TextStyle(fontSize: 12),
                          ),
                        )),
                        DataCell(Text('${sale.items}')), // items count
                        DataCell(Text(
                          '${isRefund ? '-' : ''}${sale.total.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isRefund ? AppColors.errorColor : null,
                          ),
                        )),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
