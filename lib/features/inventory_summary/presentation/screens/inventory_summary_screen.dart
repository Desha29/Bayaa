import 'package:bayaa_pos/l10n/app_localizations.dart';
import 'package:bayaa_pos/shared/layout/layout_tokens.dart';
import 'package:bayaa_pos/shared/theme/app_colors.dart';
import 'package:bayaa_pos/shared/widgets/empty_state.dart';
import 'package:bayaa_pos/shared/widgets/loading/skeleton.dart';
import 'package:bayaa_pos/shared/widgets/workspace/workspace_data_table.dart';
import 'package:bayaa_pos/shared/widgets/workspace/workspace_panel.dart';
import 'package:bayaa_pos/shared/widgets/charts/workspace_donut.dart';
import 'package:bayaa_pos/shared/widgets/workspace/workspace_summary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' show NumberFormat;
import '../controllers/inventory_summary_cubit.dart';
import '../controllers/inventory_summary_state.dart';
import '../models/inventory_category_view_data.dart';
import '../widgets/category_products_dialog.dart';

class InventorySummaryScreen extends StatefulWidget {
  const InventorySummaryScreen({super.key});
  @override
  State<InventorySummaryScreen> createState() => _InventorySummaryScreenState();
}

class _InventorySummaryScreenState extends State<InventorySummaryScreen> {
  String? _category;
  String _sort = 'value';
  bool _table = false;

  void _details(InventoryCategoryViewData record) => showDialog<void>(
        context: context,
        builder: (_) => ProductDetailsDialog(
            categoryName: record.categoryName, products: record.productDetails),
      );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final ar = l.localeName == 'ar';
    String tr(String en, String arabic) => ar ? arabic : en;
    final numbers = NumberFormat.decimalPattern(l.localeName);
    String money(double amount) => '${numbers.format(amount)} ${l.currencyEg}';
    return BlocBuilder<InventorySummaryCubit, InventorySummaryState>(
      builder: (context, state) => LayoutBuilder(builder: (context, size) {
        final padding = LayoutTokens.pagePadding(size.maxWidth);
        if (state is StockSummaryError) {
          return ListView(padding: padding, children: [
            EmptyState(
                title: l.unexpectedError,
                message: state.message,
                actionText: tr('Try again', 'إعادة المحاولة'),
                onAction: context.read<InventorySummaryCubit>().loadData),
          ]);
        }
        if (state is! StockSummaryLoaded) {
          return ListView(padding: padding, children: const [SkeletonList()]);
        }
        final records = state.categories
            .where((c) => _category == null || c.categoryName == _category)
            .toList()
          ..sort((a, b) => switch (_sort) {
                'name' => a.categoryName.compareTo(b.categoryName),
                'units' => b.totalQuantity.compareTo(a.totalQuantity),
                'profit' => b.expectedProfit.compareTo(a.expectedProfit),
                _ => b.totalCurrentWholesaleValue
                    .compareTo(a.totalCurrentWholesaleValue),
              });
        final byValue = [...state.categories]..sort((a, b) => b
            .totalCurrentWholesaleValue
            .compareTo(a.totalCurrentWholesaleValue));
        final units = state.categories.fold(0, (n, c) => n + c.totalQuantity);
        final columns = <WorkspaceColumn<InventoryCategoryViewData>>[
          WorkspaceColumn(
              label: l.sectionColumn,
              cell: (c) => TextButton(
                  onPressed:
                      c.productDetails.isEmpty ? null : () => _details(c),
                  child: Text(c.categoryName))),
          WorkspaceColumn(
              label: l.productsColumn,
              numeric: true,
              cell: (c) => Text(numbers.format(c.productCount))),
          WorkspaceColumn(
              label: l.currentStock,
              numeric: true,
              cell: (c) => Text(numbers.format(c.totalQuantity))),
          WorkspaceColumn(
              label: l.outputsColumn,
              numeric: true,
              cell: (c) => Text(numbers.format(c.totalSoldQuantity))),
          WorkspaceColumn(
              label: l.historicValueColumn,
              numeric: true,
              cell: (c) => Text(money(c.totalHistoricValue))),
          WorkspaceColumn(
              label: l.currentWholesaleColumn,
              numeric: true,
              cell: (c) => Text(money(c.totalCurrentWholesaleValue))),
          WorkspaceColumn(
              label: l.expectedSellValue,
              numeric: true,
              cell: (c) => Text(money(c.totalDefaultSellValue))),
          WorkspaceColumn(
              label: l.expectedProfit,
              numeric: true,
              cell: (c) => Text(money(c.expectedProfit))),
        ];
        return ListView(padding: padding, children: [
          WorkspacePanel(
              prominent: true,
              title: l.stockSummary,
              caption: tr('Inventory valuation and category performance',
                  'تقييم المخزون وأداء الفئات'),
              icon: Icons.inventory_2_outlined,
              child: WorkspaceSummary(metrics: [
                WorkspaceMetric(tr('Units in stock', 'الوحدات في المخزون'),
                    numbers.format(units), Icons.inventory_outlined),
                WorkspaceMetric(l.historicValue,
                    money(state.totalStoreHistoricValue), Icons.history),
                WorkspaceMetric(
                    tr('Stock at cost', 'قيمة التكلفة'),
                    money(state.totalStoreCurrentValue),
                    Icons.account_balance_wallet_outlined),
                WorkspaceMetric(tr('Est. profit', 'ربح متوقع'),
                    money(state.totalExpectedProfit), Icons.insights_outlined),
              ])),
          const SizedBox(height: 16),
          AdaptiveColumns(minWidth: 330, maxColumns: 3, children: [
            WorkspacePanel(
                title: tr('Stock value by category', 'قيمة المخزون حسب الفئة'),
                caption: tr('Current wholesale value · top six categories',
                    'قيمة الجملة الحالية · أعلى ست فئات'),
                icon: Icons.bar_chart_outlined,
                child: WorkspaceRankBars(
                    values: byValue
                        .take(6)
                        .map((c) =>
                            (c.categoryName, c.totalCurrentWholesaleValue))
                        .toList(),
                    format: money,
                    empty: tr('No stock value in this branch.',
                        'لا توجد قيمة مخزون في هذا الفرع.'))),
            WorkspacePanel(
              title: tr('Stock units by category', 'وحدات المخزون حسب الفئة'),
              caption: tr('Share of the current stock count',
                  'حصة الفئة من وحدات المخزون الحالية'),
              icon: Icons.donut_large_outlined,
              child: WorkspaceDonut(
                values: state.categories
                    .map((c) => (c.categoryName, c.totalQuantity.toDouble()))
                    .toList(),
                format: numbers.format,
                empty: tr('No units in stock.', 'لا توجد وحدات في المخزون.'),
              ),
            ),
            WorkspacePanel(
              title:
                  tr('Estimated profit by category', 'الربح المتوقع حسب الفئة'),
              caption: tr('Retail value less stock cost',
                  'قيمة البيع مطروحًا منها تكلفة المخزون'),
              icon: Icons.insights_outlined,
              child: WorkspaceRankBars(
                values: (state.categories
                        .map((c) => (c.categoryName, c.expectedProfit))
                        .toList()
                      ..sort((a, b) => b.$2.compareTo(a.$2)))
                    .take(6)
                    .toList(),
                format: money,
                empty: tr('No estimated profit in this branch.',
                    'لا يوجد ربح متوقع لهذا الفرع.'),
              ),
            ),
          ]),
          const SizedBox(height: 16),
          WorkspacePanel(
              title: tr('Category breakdown', 'تفاصيل الفئات'),
              caption: tr('${records.length} categories shown',
                  'الفئات المعروضة: ${records.length}'),
              icon: Icons.category_outlined,
              child: AdaptiveColumns(
                  minWidth: 240,
                  maxColumns: 2,
                  spacing: 10,
                  children: [
                    DropdownButtonFormField<String>(
                      key: ValueKey(_category),
                      initialValue: _category ?? '',
                      isExpanded: true,
                      decoration: InputDecoration(
                          labelText: l.sectionColumn,
                          prefixIcon: const Icon(Icons.category_outlined)),
                      items: [
                        DropdownMenuItem(
                            value: '', child: Text(l.allCategoriesFilter)),
                        for (final c in state.categories)
                          DropdownMenuItem(
                              value: c.categoryName,
                              child: Text(c.categoryName,
                                  overflow: TextOverflow.ellipsis)),
                      ],
                      onChanged: (v) =>
                          setState(() => _category = v == '' ? null : v),
                    ),
                    DropdownButtonFormField<String>(
                      initialValue: _sort,
                      isExpanded: true,
                      decoration: InputDecoration(
                          labelText: tr('Sort by', 'الترتيب حسب'),
                          prefixIcon: const Icon(Icons.sort)),
                      items: [
                        for (final entry in [
                          ('value', l.currentWholesaleColumn),
                          ('units', l.currentStock),
                          ('profit', l.expectedProfit),
                          ('name', l.sectionColumn),
                        ])
                          DropdownMenuItem(
                              value: entry.$1,
                              child: Text(entry.$2,
                                  overflow: TextOverflow.ellipsis)),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _sort = v);
                      },
                    ),
                  ])),
          const SizedBox(height: 12),
          if (size.maxWidth >= 700) ...[
            Wrap(spacing: 8, children: [
              ChoiceChip(
                  label: Text(tr('Cards', 'البطاقات')),
                  selected: !_table,
                  onSelected: (_) => setState(() => _table = false)),
              ChoiceChip(
                  label: Text(tr('Table', 'الجدول')),
                  selected: _table,
                  onSelected: (_) => setState(() => _table = true)),
            ]),
            const SizedBox(height: 8),
          ],
          if (records.isEmpty)
            EmptyState(
                title: tr('No categories to show', 'لا توجد فئات للعرض'),
                variant: EmptyStateVariant.products)
          else if (_table && size.maxWidth >= 700)
            WorkspaceDataTable(
                records: records,
                columns: columns,
                showViewToggle: false,
                minimumWidth: 1120)
          else
            AdaptiveColumns(minWidth: 300, maxColumns: 3, children: [
              for (final record in records)
                WorkspacePanel(
                    title: record.categoryName,
                    caption: tr(
                        '${numbers.format(record.productCount)} products',
                        '${numbers.format(record.productCount)} منتجات'),
                    icon: Icons.inventory_2_outlined,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor
                                  .withValues(alpha: .055),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      tr('Stock at cost',
                                          'قيمة المخزون بالتكلفة'),
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.mutedColor)),
                                  Text(money(record.totalCurrentWholesaleValue),
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.primaryColor)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(spacing: 6, runSpacing: 6, children: [
                            WorkspacePill(
                              label: tr(
                                  '${numbers.format(record.totalQuantity)} in stock',
                                  '${numbers.format(record.totalQuantity)} في المخزون'),
                              icon: Icons.inventory_outlined,
                              color: AppColors.primaryColor,
                            ),
                            WorkspacePill(
                              label: tr(
                                  '${numbers.format(record.totalSoldQuantity)} sold',
                                  '${numbers.format(record.totalSoldQuantity)} مباعة'),
                              icon: Icons.shopping_bag_outlined,
                              color: AppColors.secondaryColor,
                            ),
                          ]),
                          const SizedBox(height: 10),
                          for (final fact in [
                            (
                              l.historicValueColumn,
                              money(record.totalHistoricValue)
                            ),
                            (
                              l.expectedSellValue,
                              money(record.totalDefaultSellValue)
                            ),
                            (l.expectedProfit, money(record.expectedProfit)),
                            (
                              tr('Markup on cost', 'هامش الزيادة على التكلفة'),
                              '${record.profitMarginPercent.toStringAsFixed(1)}%'
                            ),
                          ])
                            Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Wrap(
                                    alignment: WrapAlignment.spaceBetween,
                                    spacing: 8,
                                    runSpacing: 2,
                                    children: [
                                      Text(fact.$1,
                                          style: TextStyle(
                                              color: AppColors.mutedColor)),
                                      Text(fact.$2)
                                    ])),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                              onPressed: record.productDetails.isEmpty
                                  ? null
                                  : () => _details(record),
                              icon: const Icon(Icons.inventory_outlined),
                              label: Text(tr('View products', 'عرض المنتجات'))),
                        ])),
            ]),
        ]);
      }),
    );
  }
}
