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

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
  }
}
