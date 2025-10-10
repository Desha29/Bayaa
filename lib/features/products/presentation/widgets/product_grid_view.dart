import 'package:crazy_phone_pos/features/products/data/models/product_model.dart';
import 'package:flutter/material.dart';
import '../../../../core/components/empty_state.dart';
import '../../../../core/utils/responsive_helper.dart';

import 'enhanced_product_card.dart';

class ProductsGridView extends StatelessWidget {
  final List<Product> products;
  final void Function(Product) onDelete;
  final void Function(Product) onEdit;
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
    if (products.isEmpty)
      return const EmptyState(variant: EmptyStateVariant.products);

    return LayoutBuilder(
      builder: (context, constraints) {
        final cross = ResponsiveHelper.gridCount(context);
        final gridPadding = ResponsiveHelper.padding(context);
        return GridView.builder(
          padding: gridPadding.copyWith(
            left: gridPadding.left.clamp(8.0, 24.0),
            right: gridPadding.right.clamp(8.0, 24.0),
            top: gridPadding.top.clamp(8.0, 24.0),
            bottom: gridPadding.bottom.clamp(8.0, 24.0),
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cross,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: getChildAspectRatio(
              context,
              constraints.maxWidth,
              cross,
            ),
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            final qty = product.quantity;
            final min = product.minQuantity;
            return EnhancedProductCard(
              product: product,
              onDelete: () => onDelete(product),
              onEdit: () => onEdit(product),
              statusColor: statusColorFn(qty, min),
              statusText: statusTextFn(qty, min),
            );
          },
        );
      },
    );
  }

  double getChildAspectRatio(BuildContext context, double maxWidth, int cross) {
    if (ResponsiveHelper.isDesktop(context)) return 0.80;
    if (ResponsiveHelper.isTablet(context)) return 0.68;
    return maxWidth / cross < 180 ? 0.58 : 0.64;
  }
}
