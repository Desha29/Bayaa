import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_helper.dart';
import 'empty_state.dart';
import 'enhanced_product_card.dart';


class ProductsGridView extends StatelessWidget {
  final List<Map<String, dynamic>> products;
  final void Function(Map<String, dynamic>) onDelete;
  final void Function(Map<String, dynamic>) onEdit;
  final Color Function(int, int) statusColorFn;
  final String Function(int, int) statusTextFn;

  const ProductsGridView({
    super.key,
    required this.products,
    required this.onDelete,
    required this.onEdit,
    required this.statusColorFn,
    required this.statusTextFn,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const EmptyState();

    return GridView.builder(
      padding: ResponsiveHelper.padding(context),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveHelper.gridCount(context),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: _getChildAspectRatio(context),
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final qty = product['qty'] as int;
        final min = product['min'] as int;

        return EnhancedProductCard(
          product: product,
          onDelete: () => onDelete(product),
          onEdit: () => onEdit(product),
          statusColor: statusColorFn(qty, min),
          statusText: statusTextFn(qty, min),
        );
      },
    );
  }

  double _getChildAspectRatio(BuildContext context) {
  if (ResponsiveHelper.isDesktop(context)) return 0.75;
  if (ResponsiveHelper.isTablet(context)) return 0.72;
  return 0.60; 
}

}
