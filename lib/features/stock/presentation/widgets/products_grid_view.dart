import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../products/data/models/product_model.dart';
import 'product_card.dart';


class ProductsGridView extends StatelessWidget {
  final List<Product> products;
  final Function(int) onRestock;

  const ProductsGridView({
    super.key,
    required this.products,
    required this.onRestock,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;
        double aspectRatio;

        if (ResponsiveHelper.isDesktop(context)) {
          crossAxisCount = 3;
          aspectRatio = 1.4;
        } else if (ResponsiveHelper.isTablet(context)) {
          crossAxisCount = 3;
          aspectRatio = 1.2;
        } else {
          crossAxisCount = 2;
          aspectRatio = 1;
        }

        return GridView.builder(
          padding: EdgeInsets.all(ResponsiveHelper.isMobile(context) ? 6 : 12),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: aspectRatio,
            crossAxisSpacing: ResponsiveHelper.isMobile(context) ? 6 : 12,
            mainAxisSpacing: ResponsiveHelper.isMobile(context) ? 6 : 12,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ProductCard(
              product: product,
              onRestock: () => onRestock(index),
            );
          },
        );
      },
    );
  }
}
