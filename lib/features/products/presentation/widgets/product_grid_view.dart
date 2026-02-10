import 'package:crazy_phone_pos/features/products/data/models/product_model.dart';
import 'package:flutter/material.dart';
import '../../../../core/components/empty_state.dart';
import 'enhanced_product_card.dart';

class ProductsGridView extends StatelessWidget {
  final List<Product> products;
  final void Function(Product) onDelete;
  final void Function(Product) onEdit;
  final Color Function(int, int) statusColorFn;
  final String Function(int, int) statusTextFn;

  final ScrollController? scrollController;
  final bool isLoadingMore;
  final String? emptyTitle;
  final String? emptyMessage;

  const ProductsGridView({
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
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return EmptyState(
        variant: EmptyStateVariant.products,
        title: emptyTitle ?? 'ابدأ البحث',
        message: emptyMessage ?? 'قم بالبحث عن منتج أو اختر فئة لعرض المنتجات',
        icon: Icons.search,
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      itemCount: products.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == products.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
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
