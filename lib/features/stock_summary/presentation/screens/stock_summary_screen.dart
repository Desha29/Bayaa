// ignore_for_file: deprecated_member_use

import 'package:bayaa_pos/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:bayaa_pos/core/constants/app_colors.dart';
import 'package:bayaa_pos/core/components/screen_header.dart';
import 'package:bayaa_pos/features/stock_summary/data/models/stock_summary_category_model.dart';
import 'package:bayaa_pos/features/stock_summary/presentation/cubit/stock_summary_cubit.dart';
import 'package:bayaa_pos/features/stock_summary/presentation/cubit/stock_summary_state.dart';
import 'package:bayaa_pos/features/stock_summary/presentation/widgets/product_details_dialog.dart';

class StockSummaryScreen extends StatefulWidget {
  const StockSummaryScreen({super.key});

  @override
  State<StockSummaryScreen> createState() => _StockSummaryScreenState();
}

class _StockSummaryScreenState extends State<StockSummaryScreen> {
  String _sortOption = 'totalValue'; // Default sort
  bool _sortAscending = false;
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: BlocBuilder<StockSummaryCubit, StockSummaryState>(
          builder: (context, state) {
            if (state is StockSummaryLoading) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
            } else if (state is StockSummaryError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.errorColor.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.alertTriangle, color: AppColors.errorColor, size: 40),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: const TextStyle(color: AppColors.errorColor, fontFamily: 'Cairo', fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            } else if (state is StockSummaryLoaded) {
              return _buildContent(context, state);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, StockSummaryLoaded state) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    // Filter & Sort logic
    List<StockSummaryCategoryModel> displayedList = List.from(state.categories);

    if (_selectedCategory != null) {
      displayedList = displayedList
          .where((e) => e.categoryName == _selectedCategory)
          .toList();
    }

    displayedList.sort((a, b) {
      int compareResult = 0;
      switch (_sortOption) {
        case 'name':
          compareResult = a.categoryName.compareTo(b.categoryName);
          break;
        case 'quantity':
          compareResult = a.totalQuantity.compareTo(b.totalQuantity);
          break;
        case 'profitMargin':
          compareResult = a.profitMarginPercent.compareTo(b.profitMarginPercent);
          break;
        case 'historicValue':
          compareResult = a.totalHistoricValue.compareTo(b.totalHistoricValue);
          break;
        case 'totalValue':
        default:
          compareResult = a.totalCurrentWholesaleValue.compareTo(b.totalCurrentWholesaleValue);
          break;
      }
      return _sortAscending ? compareResult : -compareResult;
    });

    final l10n = AppLocalizations.of(context);
    return Directionality(
      textDirection: l10n.localeName == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 32 : 16,
              vertical: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Premium Screen Header
                ScreenHeader(
                  title: l10n.stockSummaryTitle,
                  subtitle: l10n.stockSummarySubtitleLong,
                  icon: LucideIcons.pieChart,
                  iconColor: AppColors.primaryColor,
                  titleColor: AppColors.textPrimary,
                ),
                const SizedBox(height: 20),

                // Summary cards row
                // Summary cards row
                _buildSummaryCardsRow(state, context),
                const SizedBox(height: 24),

                // Premium charts for Stock Summary
                StockSummaryCharts(categories: state.categories),
                const SizedBox(height: 24),

                // Filter & sorting action bar
                _buildFilterBar(state.categories, context),
                const SizedBox(height: 16),

                // Clean data table
                _buildDataTable(displayedList, context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCardsRow(StockSummaryLoaded state, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 750;
        
        if (isDesktop) {
          return Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  title: l10n.totalHistoricValue,
                  value: "${state.totalStoreHistoricValue.toStringAsFixed(0)} ${l10n.currencyEg}",
                  icon: LucideIcons.history,
                  color: AppColors.secondaryColor,
                  tooltip: l10n.historicValueTooltip,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _SummaryCard(
                  title: l10n.currentWholesaleValue,
                  value: "${state.totalStoreCurrentValue.toStringAsFixed(0)} ${l10n.currencyEg}",
                  icon: LucideIcons.package,
                  color: AppColors.primaryColor,
                  tooltip: l10n.currentWholesaleTooltip,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _SummaryCard(
                  title: l10n.expectedProfit,
                  value: "${state.totalExpectedProfit.toStringAsFixed(0)} ${l10n.currencyEg}",
                  icon: LucideIcons.trendingUp,
                  color: AppColors.successColor,
                  tooltip: l10n.expectedProfitTooltip,
                ),
              ),
            ],
          );
        } else {
          return Column(
            children: [
              _SummaryCard(
                title: l10n.totalHistoricValue,
                value: "${state.totalStoreHistoricValue.toStringAsFixed(0)} ${l10n.currencyEg}",
                icon: LucideIcons.history,
                color: AppColors.secondaryColor,
                tooltip: l10n.historicValueTooltip,
              ),
              const SizedBox(height: 12),
              _SummaryCard(
                title: l10n.currentWholesaleValue,
                value: "${state.totalStoreCurrentValue.toStringAsFixed(0)} ${l10n.currencyEg}",
                icon: LucideIcons.package,
                color: AppColors.primaryColor,
                tooltip: l10n.currentWholesaleTooltip,
              ),
              const SizedBox(height: 12),
              _SummaryCard(
                title: l10n.expectedProfit,
                value: "${state.totalExpectedProfit.toStringAsFixed(0)} ${l10n.currencyEg}",
                icon: LucideIcons.trendingUp,
                color: AppColors.successColor,
                tooltip: l10n.expectedProfitTooltip,
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildFilterBar(List<StockSummaryCategoryModel> allCategories, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final categories = allCategories.map((e) => e.categoryName).toSet().toList();
    final sortOptions = {
      'totalValue': l10n.totalValue,
      'historicValue': l10n.historicValue,
      'profitMargin': l10n.profitMarginPercent,
      'quantity': l10n.qtySort,
      'name': l10n.nameSort,
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        
        if (isMobile) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    style: const TextStyle(fontFamily: 'Cairo', color: AppColors.textPrimary, fontSize: 13),
                    hint: Text(l10n.filterByCategory, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.mutedColor)),
                    isExpanded: true,
                    items: [
                      DropdownMenuItem(value: null, child: Text(l10n.allCategoriesFilter, style: const TextStyle(fontFamily: 'Cairo'))),
                      ...categories.map((cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(cat, style: const TextStyle(fontFamily: 'Cairo')),
                          )),
                    ],
                    onChanged: (val) {
                      setState(() => _selectedCategory = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderColor),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _sortOption,
                          style: const TextStyle(fontFamily: 'Cairo', color: AppColors.textPrimary, fontSize: 13),
                          icon: const Icon(LucideIcons.arrowUpDown, size: 16, color: AppColors.mutedColor),
                          isExpanded: true,
                          items: sortOptions.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value, style: const TextStyle(fontFamily: 'Cairo')))).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _sortOption = val);
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildSortIconButton(context),
                ],
              ),
            ],
          );
        } else {
          return Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderColor),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      style: const TextStyle(fontFamily: 'Cairo', color: AppColors.textPrimary, fontSize: 13),
                      hint: Text(l10n.filterByCategory, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.mutedColor)),
                      isExpanded: true,
                      items: [
                        DropdownMenuItem(value: null, child: Text(l10n.allCategoriesFilter, style: const TextStyle(fontFamily: 'Cairo'))),
                        ...categories.map((cat) => DropdownMenuItem(
                              value: cat,
                              child: Text(cat, style: const TextStyle(fontFamily: 'Cairo')),
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
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderColor),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _sortOption,
                      style: const TextStyle(fontFamily: 'Cairo', color: AppColors.textPrimary, fontSize: 13),
                      icon: const Icon(LucideIcons.arrowUpDown, size: 16, color: AppColors.mutedColor),
                      isExpanded: true,
                      items: sortOptions.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value, style: const TextStyle(fontFamily: 'Cairo')))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _sortOption = val);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _buildSortIconButton(context),
            ],
          );
        }
      },
    );
  }

  Widget _buildSortIconButton(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Tooltip(
      message: _sortAscending ? l10n.sortAsc : l10n.sortDesc,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _sortAscending = !_sortAscending),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryColor.withOpacity(0.12)),
            ),
            child: Icon(
              _sortAscending ? LucideIcons.arrowUp : LucideIcons.arrowDown,
              color: AppColors.primaryColor,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDataTable(List<StockSummaryCategoryModel> data, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      height: 450,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor.withOpacity(0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: DataTable2(
          showCheckboxColumn: false,
          columnSpacing: 16,
          horizontalMargin: 12,
          minWidth: 950,
          headingRowHeight: 52,
          dataRowHeight: 60,
          headingRowColor: WidgetStateProperty.all(AppColors.borderColor.withOpacity(0.24)),
          headingTextStyle: const TextStyle(
            fontFamily: 'Cairo',
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 12.5,
          ),
          dataRowColor: WidgetStateProperty.resolveWith(
            (states) {
              if (states.contains(WidgetState.hovered)) {
                return AppColors.primaryColor.withOpacity(0.03);
              }
              return null;
            },
          ),
          border: TableBorder(
            horizontalInside: BorderSide(color: AppColors.borderColor.withOpacity(0.5), width: 1),
            bottom: BorderSide(color: AppColors.borderColor.withOpacity(0.5), width: 1),
          ),
          columns: [
            DataColumn2(label: Center(child: Text(l10n.sectionColumn)), size: ColumnSize.L),
            DataColumn2(label: Center(child: Text(l10n.productsColumn)), size: ColumnSize.S, numeric: true),
            DataColumn2(label: Center(child: Text(l10n.currentStock)), size: ColumnSize.S, numeric: true),
            DataColumn2(label: Center(child: Text(l10n.outputsColumn)), size: ColumnSize.S, numeric: true),
            DataColumn2(label: Center(child: Text(l10n.historicValueColumn)), size: ColumnSize.M, numeric: true),
            DataColumn2(label: Center(child: Text(l10n.currentWholesaleColumn)), size: ColumnSize.M, numeric: true),
            DataColumn2(label: Center(child: Text(l10n.expectedSellValue)), size: ColumnSize.M, numeric: true),
            DataColumn2(label: Center(child: Text(l10n.profitMarginPercent)), size: ColumnSize.S),
          ],
          rows: data.map((item) {
            return DataRow2(
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
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (item.isDeletedCategory)
                        Tooltip(
                          message: l10n.archivedSection,
                          child: const Padding(
                            padding: EdgeInsets.only(left: 6.0),
                            child: Icon(LucideIcons.alertTriangle, size: 14, color: AppColors.warningColor),
                          ),
                        ),
                      Text(
                        item.categoryName,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (item.productDetails.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        const Icon(
                          LucideIcons.info,
                          size: 13,
                          color: AppColors.secondaryColor,
                        ),
                      ],
                    ],
                  ),
                ),
                DataCell(Center(
                  child: Text(
                    "${item.productCount}",
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textPrimary),
                  ),
                )),
                DataCell(Center(
                  child: Text(
                    "${item.totalQuantity}",
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textPrimary),
                  ),
                )),
                DataCell(Center(
                  child: Text(
                    "${item.totalSoldQuantity}",
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textPrimary),
                  ),
                )),
                DataCell(Center(
                  child: Text(
                    "${item.totalHistoricValue.toStringAsFixed(0)} ${l10n.currencyEg}",
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 12.5, color: AppColors.textSecondary),
                  ),
                )),
                DataCell(Center(
                  child: Text(
                    "${item.totalCurrentWholesaleValue.toStringAsFixed(0)} ${l10n.currencyEg}",
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 12.5, color: AppColors.primaryColor, fontWeight: FontWeight.bold),
                  ),
                )),
                DataCell(Center(
                  child: Text(
                    "${item.totalDefaultSellValue.toStringAsFixed(0)} ${l10n.currencyEg}",
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 12.5, color: AppColors.secondaryColor, fontWeight: FontWeight.bold),
                  ),
                )),
                DataCell(
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: item.profitMarginPercent > 20
                            ? AppColors.successColor.withOpacity(0.08)
                            : item.profitMarginPercent > 10
                                ? AppColors.warningColor.withOpacity(0.08)
                                : AppColors.errorColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: item.profitMarginPercent > 20
                              ? AppColors.successColor.withOpacity(0.24)
                              : item.profitMarginPercent > 10
                                  ? AppColors.warningColor.withOpacity(0.24)
                                  : AppColors.errorColor.withOpacity(0.24),
                        ),
                      ),
                      child: Text(
                        "${item.profitMarginPercent.toStringAsFixed(1)}%",
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          color: item.profitMarginPercent > 20
                              ? AppColors.successColor
                              : item.profitMarginPercent > 10
                                  ? AppColors.warningColor
                                  : AppColors.errorColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
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
        border: Border.all(color: AppColors.borderColor.withOpacity(0.8)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.015),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    color: AppColors.textSecondary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Tooltip(
                message: tooltip,
                textStyle: const TextStyle(fontFamily: 'Cairo', color: Colors.white, fontSize: 11),
                child: Icon(LucideIcons.info, size: 16, color: AppColors.mutedColor.withOpacity(0.6)),
              )
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class StockSummaryCharts extends StatefulWidget {
  final List<StockSummaryCategoryModel> categories;

  const StockSummaryCharts({super.key, required this.categories});

  @override
  State<StockSummaryCharts> createState() => _StockSummaryChartsState();
}

class _StockSummaryChartsState extends State<StockSummaryCharts> {
  int _touchedValueIndex = -1;
  int _touchedQtyIndex = -1;

  final List<Color> _colors = [
    AppColors.primaryColor,
    AppColors.secondaryColor,
    AppColors.successColor,
    AppColors.warningColor,
    const Color(0xFF8B5CF6), // Purple
    const Color(0xFF14B8A6), // Teal
    const Color(0xFFEC4899), // Pink
    const Color(0xFF6366F1), // Indigo
    const Color(0xFFF59E0B), // Amber
    const Color(0xFF64748B), // Slate for Others
  ];

  @override
  Widget build(BuildContext context) {
    if (widget.categories.isEmpty) {
      return const SizedBox.shrink();
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 850;

    final l10n = AppLocalizations.of(context);
    // 1. Process Value Data
    final valueList = List<StockSummaryCategoryModel>.from(widget.categories)
      ..sort((a, b) => b.totalCurrentWholesaleValue.compareTo(a.totalCurrentWholesaleValue));
    
    final double totalValue = valueList.fold(0, (sum, c) => sum + c.totalCurrentWholesaleValue);

    List<_ChartItem> valueItems = [];
    if (totalValue > 0) {
      if (valueList.length > 5) {
        for (int i = 0; i < 4; i++) {
          valueItems.add(_ChartItem(
            name: valueList[i].categoryName,
            value: valueList[i].totalCurrentWholesaleValue,
            percentage: (valueList[i].totalCurrentWholesaleValue / totalValue) * 100,
            color: _colors[i % _colors.length],
          ));
        }
        double remainingValue = 0;
        for (int i = 4; i < valueList.length; i++) {
          remainingValue += valueList[i].totalCurrentWholesaleValue;
        }
        if (remainingValue > 0) {
          valueItems.add(_ChartItem(
            name: l10n.otherSections,
            value: remainingValue,
            percentage: (remainingValue / totalValue) * 100,
            color: _colors.last,
          ));
        }
      } else {
        for (int i = 0; i < valueList.length; i++) {
          if (valueList[i].totalCurrentWholesaleValue > 0) {
            valueItems.add(_ChartItem(
              name: valueList[i].categoryName,
              value: valueList[i].totalCurrentWholesaleValue,
              percentage: (valueList[i].totalCurrentWholesaleValue / totalValue) * 100,
              color: _colors[i % _colors.length],
            ));
          }
        }
      }
    }

    // 2. Process Quantity Data
    final qtyList = List<StockSummaryCategoryModel>.from(widget.categories)
      ..sort((a, b) => b.totalQuantity.compareTo(a.totalQuantity));

    final double totalQty = qtyList.fold(0, (sum, c) => sum + c.totalQuantity);

    List<_ChartItem> qtyItems = [];
    if (totalQty > 0) {
      if (qtyList.length > 5) {
        for (int i = 0; i < 4; i++) {
          qtyItems.add(_ChartItem(
            name: qtyList[i].categoryName,
            value: qtyList[i].totalQuantity.toDouble(),
            percentage: (qtyList[i].totalQuantity / totalQty) * 100,
            color: _colors[i % _colors.length],
          ));
        }
        double remainingQty = 0;
        for (int i = 4; i < qtyList.length; i++) {
          remainingQty += qtyList[i].totalQuantity;
        }
        if (remainingQty > 0) {
          qtyItems.add(_ChartItem(
            name: l10n.otherSections,
            value: remainingQty,
            percentage: (remainingQty / totalQty) * 100,
            color: _colors.last,
          ));
        }
      } else {
        for (int i = 0; i < qtyList.length; i++) {
          if (qtyList[i].totalQuantity > 0) {
            qtyItems.add(_ChartItem(
              name: qtyList[i].categoryName,
              value: qtyList[i].totalQuantity.toDouble(),
              percentage: (qtyList[i].totalQuantity / totalQty) * 100,
              color: _colors[i % _colors.length],
            ));
          }
        }
      }
    }

    final chartsWidget = isDesktop
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildPieChartCard(
                  title: l10n.stockValueDistribution,
                  subtitle: l10n.capitalInGoods,
                  totalText: l10n.totalValueAmount(totalValue.toStringAsFixed(0)),
                  items: valueItems,
                  isQty: false,
                  touchedIndex: _touchedValueIndex,
                  onTouch: (index) => setState(() => _touchedValueIndex = index),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPieChartCard(
                  title: l10n.stockQtyDistribution,
                  subtitle: l10n.qtyBySection,
                  totalText: l10n.totalQtyAmount(totalQty.toStringAsFixed(0)),
                  items: qtyItems,
                  isQty: true,
                  touchedIndex: _touchedQtyIndex,
                  onTouch: (index) => setState(() => _touchedQtyIndex = index),
                ),
              ),
            ],
          )
        : Column(
            children: [
              _buildPieChartCard(
                title: l10n.stockValueDistribution,
                subtitle: l10n.capitalInGoods,
                totalText: l10n.totalValueAmount(totalValue.toStringAsFixed(0)),
                items: valueItems,
                isQty: false,
                touchedIndex: _touchedValueIndex,
                onTouch: (index) => setState(() => _touchedValueIndex = index),
              ),
              const SizedBox(height: 16),
              _buildPieChartCard(
                title: l10n.stockQtyDistribution,
                subtitle: l10n.qtyBySection,
                totalText: l10n.totalQtyAmount(totalQty.toStringAsFixed(0)),
                items: qtyItems,
                isQty: true,
                touchedIndex: _touchedQtyIndex,
                onTouch: (index) => setState(() => _touchedQtyIndex = index),
              ),
            ],
          );

    return chartsWidget;
  }

  Widget _buildPieChartCard({
    required String title,
    required String subtitle,
    required String totalText,
    required List<_ChartItem> items,
    required bool isQty,
    required int touchedIndex,
    required Function(int) onTouch,
  }) {
    final l10n = AppLocalizations.of(context);
    if (items.isEmpty) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderColor.withOpacity(0.8)),
        ),
        child: Center(
          child: Text(
            l10n.insufficientDataForChart,
            style: TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary, fontSize: 13),
          ),
        ),
      );
    }

    final sections = List.generate(items.length, (index) {
      final isTouched = index == touchedIndex;
      final radius = isTouched ? 48.0 : 40.0;
      final fontSize = isTouched ? 12.0 : 10.0;
      final item = items[index];

      return PieChartSectionData(
        color: item.color,
        value: item.value,
        title: '${item.percentage.toStringAsFixed(0)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontFamily: 'Cairo',
        ),
      );
    });

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor.withOpacity(0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 14.5, color: AppColors.textPrimary),
          ),
          Text(
            subtitle,
            style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 4,
                child: SizedBox(
                  height: 140,
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            onTouch(-1);
                            return;
                          }
                          onTouch(pieTouchResponse.touchedSection!.touchedSectionIndex);
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 2,
                      centerSpaceRadius: 30,
                      sections: sections,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: items.map((e) {
                    final isTouched = items.indexOf(e) == touchedIndex;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: e.color),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              e.name,
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 11.5,
                                color: isTouched ? AppColors.primaryColor : AppColors.textPrimary,
                                fontWeight: isTouched ? FontWeight.bold : FontWeight.normal,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isQty ? l10n.unitCount(e.value.toInt()) : "${e.value.toStringAsFixed(0)} ${l10n.currencyEg}",
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 10.5,
                              color: AppColors.textSecondary,
                              fontWeight: isTouched ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.borderColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              totalText,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartItem {
  final String name;
  final double value;
  final double percentage;
  final Color color;

  _ChartItem({
    required this.name,
    required this.value,
    required this.percentage,
    required this.color,
  });
}
