import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:bayaa_pos/l10n/app_localizations.dart';
import 'package:bayaa_pos/shared/theme/app_colors.dart';
import '../models/product_sales_view_data.dart';

class ProductDetailsDialog extends StatelessWidget {
  const ProductDetailsDialog(
      {super.key, required this.categoryName, required this.products});
  final String categoryName;
  final List<ProductSalesViewData> products;

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final size = MediaQuery.sizeOf(context);
    return Dialog(
      insetPadding: EdgeInsets.all(size.width < 600 ? 12 : 24),
      backgroundColor: AppColors.surfaceColor,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
          constraints: BoxConstraints(
              maxWidth: 750,
              maxHeight: math.min(
                  600,
                  math.max(
                      100,
                      size.height -
                          MediaQuery.viewInsetsOf(context).bottom -
                          48))),
          child: SingleChildScrollView(
              padding: EdgeInsets.all(size.width < 600 ? 16 : 24),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(children: [
                      Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color:
                                  AppColors.primaryColor.withValues(alpha: .08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: AppColors.primaryColor
                                      .withValues(alpha: .12))),
                          child: Icon(LucideIcons.package,
                              color: AppColors.primaryColor, size: 22)),
                      const SizedBox(width: 14),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(l10n.categoryDetails,
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary)),
                            const SizedBox(height: 2),
                            Text(categoryName,
                                style: TextStyle(
                                    fontSize: 12.5,
                                    color: AppColors.mutedColor,
                                    fontWeight: FontWeight.bold)),
                          ])),
                      IconButton(
                          tooltip: MaterialLocalizations.of(context)
                              .closeButtonTooltip,
                          icon:
                              Icon(LucideIcons.x, color: AppColors.mutedColor),
                          onPressed: () => Navigator.pop(context)),
                    ]),
                    const SizedBox(height: 18),
                    Divider(color: AppColors.borderColor, height: 1),
                    const SizedBox(height: 16),
                    Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderColor)),
                        clipBehavior: Clip.antiAlias,
                        child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(minWidth: 620),
                                child: DataTable(
                                  headingRowColor: WidgetStatePropertyAll(
                                      AppColors.primaryColor),
                                  headingTextStyle: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryForeground),
                                  dataTextStyle: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Cairo',
                                      color: AppColors.textSecondary,
                                      fontSize: 12.5),
                                  columnSpacing: 20,
                                  columns: [
                                    DataColumn(
                                        label: Text(l10n.productNameColumn)),
                                    DataColumn(
                                        label: Text(l10n.salesColumn),
                                        numeric: true),
                                    DataColumn(
                                        label: Text(l10n.refundsColumn),
                                        numeric: true),
                                    DataColumn(
                                        label: Text(l10n.netSoldColumn),
                                        numeric: true),
                                  ],
                                  rows: products
                                      .map((product) => DataRow(cells: [
                                            DataCell(SizedBox(
                                                width: 180,
                                                child: Text(product.productName,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: AppColors
                                                            .textPrimary)))),
                                            DataCell(Text(
                                                l10n.unitCount(
                                                    product.soldQuantity),
                                                style: TextStyle(
                                                    color: AppColors.errorColor,
                                                    fontWeight:
                                                        FontWeight.w700))),
                                            DataCell(Text(
                                                l10n.unitCount(
                                                    product.refundedQuantity),
                                                style: TextStyle(
                                                    color:
                                                        AppColors.successColor,
                                                    fontWeight:
                                                        FontWeight.w700))),
                                            DataCell(Text(
                                                l10n.unitCount(
                                                    product.netSoldQuantity),
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w800,
                                                    color: product
                                                                .netSoldQuantity >=
                                                            0
                                                        ? AppColors.primaryColor
                                                        : AppColors
                                                            .warningColor))),
                                          ]))
                                      .toList(),
                                )))),
                    const SizedBox(height: 18),
                    Divider(color: AppColors.borderColor, height: 1),
                    const SizedBox(height: 18),
                    LayoutBuilder(builder: (context, constraints) {
                      final stacked = constraints.maxWidth < 560 ||
                          MediaQuery.textScalerOf(context).scale(1) > 1.3;
                      final width = stacked
                          ? constraints.maxWidth
                          : (constraints.maxWidth - 16) / 3;
                      return Wrap(spacing: 8, runSpacing: 8, children: [
                        SizedBox(
                            width: width,
                            child: _summary(
                                context,
                                l10n.totalSalesOverall,
                                products.fold(
                                    0, (sum, p) => sum + p.soldQuantity),
                                AppColors.errorColor,
                                LucideIcons.arrowUpRight)),
                        SizedBox(
                            width: width,
                            child: _summary(
                                context,
                                l10n.totalRefundsOverall,
                                products.fold(
                                    0, (sum, p) => sum + p.refundedQuantity),
                                AppColors.successColor,
                                LucideIcons.arrowDownLeft)),
                        SizedBox(
                            width: width,
                            child: _summary(
                                context,
                                l10n.netActualSales,
                                products.fold(
                                    0, (sum, p) => sum + p.netSoldQuantity),
                                AppColors.primaryColor,
                                LucideIcons.checkSquare)),
                      ]);
                    }),
                  ]))),
    );
  }

  Widget _summary(BuildContext context, String label, int value, Color color,
          IconData icon) =>
      Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
              color: color.withValues(alpha: .06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: .18))),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 6),
              Flexible(
                  child: Text(label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: color))),
            ]),
            const SizedBox(height: 6),
            Text(AppLocalizations.of(context).unitCount(value),
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w800, color: color)),
          ]));
}
