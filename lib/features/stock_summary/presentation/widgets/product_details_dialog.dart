// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/product_sales_detail.dart';

class ProductDetailsDialog extends StatelessWidget {
  final String categoryName;
  final List<ProductSalesDetail> products;

  const ProductDetailsDialog({
    super.key,
    required this.categoryName,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 750,
        constraints: const BoxConstraints(maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dialog Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primaryColor.withOpacity(0.12)),
                  ),
                  child: const Icon(LucideIcons.package, color: AppColors.primaryColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تفاصيل حركة منتجات القسم',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        categoryName,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12.5,
                          color: AppColors.mutedColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x, color: AppColors.mutedColor),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(height: 1, color: AppColors.borderColor),
            const SizedBox(height: 16),

            // Products Table List
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderColor),
                  ),
                  child: SingleChildScrollView(
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: AppColors.borderColor.withOpacity(0.6),
                      ),
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(AppColors.borderColor.withOpacity(0.15)),
                        headingTextStyle: const TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          fontSize: 12,
                        ),
                        dataTextStyle: const TextStyle(
                          fontFamily: 'Cairo',
                          color: AppColors.textSecondary,
                          fontSize: 12.5,
                        ),
                        columnSpacing: 16,
                        columns: const [
                          DataColumn(label: Text('اسم المنتج')),
                          DataColumn(label: Text('المبيعات'), numeric: true),
                          DataColumn(label: Text('المرتجعات'), numeric: true),
                          DataColumn(label: Text('صافي المباع'), numeric: true),
                        ],
                        rows: products.map((product) {
                          final isPositive = product.netSoldQuantity >= 0;

                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  product.productName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                ),
                              ),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.errorColor.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppColors.errorColor.withOpacity(0.16)),
                                  ),
                                  child: Text(
                                    '${product.soldQuantity} وحدة',
                                    style: const TextStyle(
                                      color: AppColors.errorColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.successColor.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppColors.successColor.withOpacity(0.16)),
                                  ),
                                  child: Text(
                                    '${product.refundedQuantity} وحدة',
                                    style: const TextStyle(
                                      color: AppColors.successColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  '${product.netSoldQuantity} وحدة',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: isPositive ? AppColors.primaryColor : AppColors.warningColor,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Container(height: 1, color: AppColors.borderColor),
            const SizedBox(height: 18),

            // Summary row at bottom
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryChip(
                  'إجمالي المبيعات الكلية',
                  products.fold(0, (sum, p) => sum + p.soldQuantity),
                  AppColors.errorColor,
                  LucideIcons.arrowUpRight,
                ),
                _buildSummaryChip(
                  'إجمالي المرتجعات الكلية',
                  products.fold(0, (sum, p) => sum + p.refundedQuantity),
                  AppColors.successColor,
                  LucideIcons.arrowDownLeft,
                ),
                _buildSummaryChip(
                  'صافي المبيعات الفعلية',
                  products.fold(0, (sum, p) => sum + p.netSoldQuantity),
                  AppColors.primaryColor,
                  LucideIcons.checkSquare,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryChip(String label, int value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.18)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 13, color: color),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '$value وحدة',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
