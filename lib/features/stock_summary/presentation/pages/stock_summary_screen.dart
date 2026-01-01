// ignore_for_file: deprecated_member_use

import 'package:crazy_phone_pos/core/constants/app_colors.dart';
import 'package:crazy_phone_pos/features/stock_summary/data/models/stock_summary_category_model.dart';
import 'package:crazy_phone_pos/features/stock_summary/presentation/cubit/stock_summary_cubit.dart';
import 'package:crazy_phone_pos/features/stock_summary/presentation/cubit/stock_summary_state.dart';
import 'package:crazy_phone_pos/features/stock_summary/presentation/widgets/product_details_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

class StockSummaryScreen extends StatefulWidget {
  const StockSummaryScreen({super.key});

  @override
  State<StockSummaryScreen> createState() => _StockSummaryScreenState();
}

class _StockSummaryScreenState extends State<StockSummaryScreen> {
  String _sortOption = 'القيمة الإجمالية'; // Default sort
  bool _sortAscending = false;
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: BlocBuilder<StockSummaryCubit, StockSummaryState>(
        builder: (context, state) {
          if (state is StockSummaryLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is StockSummaryError) {
            return Center(
                child: Text(state.message,
                    style: const TextStyle(color: AppColors.errorColor)));
          } else if (state is StockSummaryLoaded) {
            return _buildContent(context, state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, StockSummaryLoaded state) {
    // 1. Filter & Sort
    List<StockSummaryCategoryModel> displayedList =
        List.from(state.categories);

    if (_selectedCategory != null) {
      displayedList = displayedList
          .where((e) => e.categoryName == _selectedCategory)
          .toList();
    }

    displayedList.sort((a, b) {
      int compareResult = 0;
      switch (_sortOption) {
        case 'الاسم':
          compareResult = a.categoryName.compareTo(b.categoryName);
          break;
        case 'الكمية':
          compareResult = a.totalQuantity.compareTo(b.totalQuantity);
          break;
        case 'هامش الربح %':
          compareResult = a.profitMarginPercent.compareTo(b.profitMarginPercent);
          break;
        case 'القيمة التاريخية':
           compareResult = a.totalHistoricValue.compareTo(b.totalHistoricValue);
           break;
        case 'القيمة الإجمالية':
        default:
          compareResult =
              a.totalCurrentWholesaleValue.compareTo(b.totalCurrentWholesaleValue);
          break;
      }
      return _sortAscending ? compareResult : -compareResult;
    });

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            const Text(
              "ملخص المخزون",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "عرض تفاصيل المخزون، القيم التاريخية والحالية، وهوامش الربح المتوقعة",
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),

            // Summary Cards
            _buildSummaryCardsRow(state),

            const SizedBox(height: 32),

            // Filter Bar
            _buildFilterBar(state.categories),

            const SizedBox(height: 16),

            // Data Table
            _buildDataTable(displayedList),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCardsRow(StockSummaryLoaded state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 900;
        final isTablet = constraints.maxWidth > 600 && constraints.maxWidth <= 900;
        
        if (isDesktop) {
          // Desktop: 3 cards in a row
          return Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  title: "القيمة التاريخية",
                  value: "${state.totalStoreHistoricValue.toStringAsFixed(2)} ج.م",
                  icon: LucideIcons.history,
                  color: Colors.blue,
                  tooltip: "إجمالي تكلفة البضائع المضافة منذ البداية",
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _SummaryCard(
                  title: "القيمة الحالية (جملة)",
                  value: "${state.totalStoreCurrentValue.toStringAsFixed(2)} ج.م",
                  icon: LucideIcons.package,
                  color: AppColors.primaryColor,
                  tooltip: "قيمة المخزون الحالي بسعر الجملة",
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _SummaryCard(
                  title: "الربح المتوقع",
                  value: "${state.totalExpectedProfit.toStringAsFixed(2)} ج.م",
                  icon: LucideIcons.trendingUp,
                  color: AppColors.successColor,
                  tooltip: "الفرق بين سعر البيع الافتراضي وسعر الجملة للمخزون الحالي",
                ),
              ),
            ],
          );
        } else {
          // Mobile/Tablet: Stacked cards
          return Column(
            children: [
              _SummaryCard(
                title: "القيمة التاريخية",
                value: "${state.totalStoreHistoricValue.toStringAsFixed(2)} ج.م",
                icon: LucideIcons.history,
                color: Colors.blue,
                tooltip: "إجمالي تكلفة البضائع المضافة منذ البداية",
              ),
              const SizedBox(height: 16),
              _SummaryCard(
                title: "القيمة الحالية (جملة)",
                value: "${state.totalStoreCurrentValue.toStringAsFixed(2)} ج.م",
                icon: LucideIcons.package,
                color: AppColors.primaryColor,
                tooltip: "قيمة المخزون الحالي بسعر الجملة",
              ),
              const SizedBox(height: 16),
              _SummaryCard(
                title: "الربح المتوقع",
                value: "${state.totalExpectedProfit.toStringAsFixed(2)} ج.م",
                icon: LucideIcons.trendingUp,
                color: AppColors.successColor,
                tooltip: "الفرق بين سعر البيع الافتراضي وسعر الجملة للمخزون الحالي",
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildFilterBar(List<StockSummaryCategoryModel> allCategories) {
    final categories = allCategories.map((e) => e.categoryName).toSet().toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        
        if (isMobile) {
          // Mobile: Stack vertically
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    hint: const Text("تصفية حسب القسم"),
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem(value: null, child: Text("الكل")),
                      ...categories.map((cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(cat),
                          )),
                    ],
                    onChanged: (val) {
                      setState(() => _selectedCategory = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.borderColor),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _sortOption,
                          icon: const Icon(LucideIcons.arrowUpDown, size: 16),
                          isExpanded: true,
                          items: [
                            'القيمة الإجمالية',
                            'القيمة التاريخية',
                            'هامش الربح %',
                            'الكمية',
                            'الاسم'
                          ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _sortOption = val);
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => setState(() => _sortAscending = !_sortAscending),
                    icon: Icon(
                      _sortAscending ? LucideIcons.arrowUp : LucideIcons.arrowDown,
                      color: AppColors.textSecondary,
                    ),
                    tooltip: _sortAscending ? "تصاعدي" : "تنازلي",
                  ),
                ],
              ),
            ],
          );
        } else {
          // Desktop/Tablet: Horizontal
          return Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderColor),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      hint: const Text("تصفية حسب القسم"),
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem(value: null, child: Text("الكل")),
                        ...categories.map((cat) => DropdownMenuItem(
                              value: cat,
                              child: Text(cat),
                            )),
                      ],
                      onChanged: (val) {
                        setState(() => _selectedCategory = val);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderColor),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _sortOption,
                      icon: const Icon(LucideIcons.arrowUpDown, size: 16),
                      isExpanded: true,
                      items: [
                        'القيمة الإجمالية',
                        'القيمة التاريخية',
                        'هامش الربح %',
                        'الكمية',
                        'الاسم'
                      ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _sortOption = val);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => setState(() => _sortAscending = !_sortAscending),
                icon: Icon(
                  _sortAscending ? LucideIcons.arrowUp : LucideIcons.arrowDown,
                  color: AppColors.textSecondary,
                ),
                tooltip: _sortAscending ? "تصاعدي" : "تنازلي",
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildDataTable(List<StockSummaryCategoryModel> data) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppColors.borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(AppColors.backgroundColor),
                  columnSpacing: 24,
                  columns: const [
                    DataColumn(label: Text("القسم")),
                    DataColumn(label: Text("المنتجات"), numeric: true),
                    DataColumn(label: Text("الكمية"), numeric: true),
                    DataColumn(label: Text("المخرجات"), numeric: true), // NEW: Outputs
                    DataColumn(label: Text("ق. تاريخية")),
                    DataColumn(label: Text("ق. حالية (جملة)")),
                    DataColumn(label: Text("ق. بيع (متوقع)")),
                    DataColumn(label: Text("هامش %")),
                  ],
                  rows: data.map((item) {
                    return DataRow(
                      onSelectChanged: item.productDetails.isNotEmpty
                          ? (_) {
                              showDialog(
                                context: context,
                                builder: (context) => ProductDetailsDialog(
                                  categoryName: item.categoryName,
                                  products: item.productDetails,
                                ),
                              );
                            }
                          : null,
                      cells: [
                        DataCell(Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (item.isDeletedCategory)
                              const Tooltip(
                                message: "منتجات محذوفة ولكن لها سجل مبيعات",
                                child: Padding(
                                  padding: EdgeInsets.only(left: 8.0),
                                  child: Icon(LucideIcons.alertTriangle,
                                      size: 16, color: AppColors.warningColor),
                                ),
                              ),
                            Text(
                              item.categoryName,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            if (item.productDetails.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              const Tooltip(
                                message: "اضغط لعرض تفاصيل المنتجات",
                                child: Icon(
                                  LucideIcons.info,
                                  size: 14,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ],
                          ],
                        )),
                        DataCell(Text("${item.productCount}")),
                        DataCell(Text("${item.totalQuantity}")),
                        DataCell(Text("${item.totalSoldQuantity}")), 
                        DataCell(Text(item.totalHistoricValue.toStringAsFixed(0))),
                        DataCell(Text(item.totalCurrentWholesaleValue.toStringAsFixed(0))),
                        DataCell(Text(item.totalDefaultSellValue.toStringAsFixed(0))),
                        DataCell(
                          Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: item.profitMarginPercent > 20
                                  ? AppColors.successColor.withOpacity(0.1)
                                  : item.profitMarginPercent > 10
                                      ? AppColors.warningColor.withOpacity(0.1)
                                      : AppColors.errorColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              "${item.profitMarginPercent.toStringAsFixed(1)}%",
                              style: TextStyle(
                                color: item.profitMarginPercent > 20
                                    ? Colors.green[800]
                                    : item.profitMarginPercent > 10
                                        ? Colors.orange[800]
                                        : Colors.red[800],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String tooltip;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(title,
                  style:
                      const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
              const Spacer(),
              Tooltip(
                message: tooltip,
                child: const Icon(LucideIcons.info,
                    size: 16, color: AppColors.mutedColor),
              )
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}
