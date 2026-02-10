import 'package:crazy_phone_pos/features/products/data/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/components/empty_state.dart';
import '../../../../core/constants/app_colors.dart';

class ProductsTableView extends StatelessWidget {
  final List<Product> products;
  final void Function(Product) onDelete;
  final void Function(Product) onEdit;
  final Color Function(int, int) statusColorFn;
  final String Function(int, int) statusTextFn;
  final ScrollController? scrollController;
  final bool isLoadingMore;
  final String? emptyTitle;
  final String? emptyMessage;
  final bool isManager;

  const ProductsTableView({
    super.key,
    required this.products,
    required this.onDelete,
    required this.onEdit,
    required this.statusColorFn,
    required this.statusTextFn,
    this.scrollController,
    this.isLoadingMore = false,
    this.emptyTitle,
    this.emptyMessage,
    this.isManager = false,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return EmptyState(
        variant: EmptyStateVariant.products,
        title: emptyTitle ?? 'لا توجد منتجات',
        message: emptyMessage ?? 'قم بإضافة منتجات جديدة لعرضها هنا',
        icon: Icons.search,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          controller: scrollController,
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.grey.withOpacity(0.2),
                ),
                child: DataTable(
                  horizontalMargin: 20,
                  columnSpacing: 20,
                  headingRowColor: MaterialStateProperty.all(
                    AppColors.primaryColor.withOpacity(0.05),
                  ),
                  dataRowColor: MaterialStateProperty.resolveWith((states) {
                    if (states.contains(MaterialState.hovered)) {
                      return AppColors.primaryColor.withOpacity(0.02);
                    }
                    return Colors.white;
                  }),
                  border: TableBorder(
                    horizontalInside: BorderSide(
                      color: Colors.grey.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  columns: [
                    const DataColumn(
                        label: Text('اسم المنتج',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataColumn(
                        label: Text('الباركود',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataColumn(
                        label: Text('الفئة',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataColumn(
                        label: Text('السعر',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    if (isManager) ...[
                      const DataColumn(
                          label: Text('سعر الجملة',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      const DataColumn(
                          label: Text('أدنى سعر',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    const DataColumn(
                        label: Text('الكمية',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataColumn(
                        label: Text('الحالة',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    if (isManager)
                      const DataColumn(
                          label: Text('إجراءات',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: [
                    ...products.map((product) {
                      final statusColor =
                          statusColorFn(product.quantity, product.minQuantity);
                      final statusText =
                          statusTextFn(product.quantity, product.minQuantity);

                      return DataRow(cells: [
                        DataCell(
                          Container(
                            constraints: const BoxConstraints(maxWidth: 200),
                            child: Text(
                              product.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(Text(product.barcode)),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(product.category),
                          ),
                        ),
                        DataCell(
                            Text('${product.price.toStringAsFixed(2)} ج.م')),
                        if (isManager) ...[
                          DataCell(Text(
                              '${product.wholesalePrice.toStringAsFixed(2)} ج.م')),
                          DataCell(Text(
                              '${product.minPrice.toStringAsFixed(2)} ج.م')),
                        ],
                        DataCell(Text('${product.quantity}')),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: statusColor.withOpacity(0.3)),
                            ),
                            child: Text(
                              statusText,
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        if (isManager)
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(LucideIcons.edit3, size: 18),
                                  color: AppColors.primaryColor,
                                  onPressed: () => onEdit(product),
                                  tooltip: 'تعديل',
                                ),
                                IconButton(
                                  icon: const Icon(LucideIcons.trash2,
                                      size: 18),
                                  color: AppColors.errorColor,
                                  onPressed: () => onDelete(product),
                                  tooltip: 'حذف',
                                ),
                              ],
                            ),
                          ),
                      ]);
                    }),
                    if (isLoadingMore)
                      const DataRow(cells: [
                        DataCell(Center(child: CircularProgressIndicator())),
                        DataCell(SizedBox()),
                        DataCell(SizedBox()),
                        DataCell(SizedBox()),
                        DataCell(SizedBox()),
                        DataCell(SizedBox()),
                        DataCell(SizedBox()),
                      ]),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
