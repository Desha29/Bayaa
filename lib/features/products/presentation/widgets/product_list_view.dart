import 'package:flutter/material.dart';
import 'package:bayaa_pos/features/products/presentation/models/product_view_data.dart';
import 'package:bayaa_pos/shared/widgets/empty_state.dart';
import 'package:bayaa_pos/l10n/app_localizations.dart';
import 'catalog_product_card.dart';

class ProductListView extends StatelessWidget {
  const ProductListView(
      {super.key,
      required this.products,
      required this.onDelete,
      required this.onEdit,
      required this.statusColorFn,
      required this.statusTextFn});
  final List<ProductViewData> products;
  final ValueChanged<ProductViewData> onDelete, onEdit;
  final Color Function(int, int) statusColorFn;
  final String Function(int, int) statusTextFn;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (products.isEmpty) {
      return EmptyState(
          variant: EmptyStateVariant.products,
          title: l.noProducts,
          message: l.tryChangingFilter,
          icon: Icons.search);
    }
    return LayoutBuilder(builder: (context, size) {
      final columns =
          size.maxWidth >= 1080 ? 6 : (size.maxWidth / 200).floor().clamp(1, 6);
      final height = 290.0 +
          ((MediaQuery.textScalerOf(context).scale(1) - 1).clamp(0, 2) * 90);
      return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: products.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              mainAxisExtent: height),
          itemBuilder: (context, i) {
            final p = products[i];
            return CatalogProductCard(
                product: p,
                onDelete: () => onDelete(p),
                onEdit: () => onEdit(p),
                statusColor: statusColorFn(p.quantity, p.minQuantity),
                statusText: statusTextFn(p.quantity, p.minQuantity));
          });
    });
  }
}
