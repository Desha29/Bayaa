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
    // Determine responsive width constraints if needed, but for a vertical list 
    // we typically want it to fill the width (with some max constraint on very large screens).
    
    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.isMobile(context) ? 8 : 12, 
        vertical: 10
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: ProductCard(
            product: product,
            onRestock: () => onRestock(index),
          ),
        );
      },
    );
  }
}
