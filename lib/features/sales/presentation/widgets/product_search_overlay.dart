import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../products/data/models/product_model.dart';

class ProductSearchOverlay extends StatelessWidget {
  final List<Product> products;
  final List<Product>? allProducts;
  final Function(Product) onProductSelected;

  const ProductSearchOverlay({
    super.key,
    required this.products,
    required this.onProductSelected,
    this.allProducts,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: AppColors.borderColor, width: 1),
      ),
      constraints: const BoxConstraints(maxHeight: 300),
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.all(8),
        itemCount: products.length,
        separatorBuilder: (context, index) =>
            Divider(color: AppColors.borderColor, height: 1),
        itemBuilder: (context, index) {
          final product = products[index];
          // Compute similar products (category or name prefix) from allProducts when provided
          final List<Product> similar = [];
          if (allProducts != null && allProducts!.isNotEmpty) {
            final prefix = product.name.length >= 3
                ? product.name.substring(0, 3).toLowerCase()
                : product.name.toLowerCase();
            for (final other in allProducts!) {
              if (other.barcode == product.barcode) continue;
              if ((other.category ?? '').isNotEmpty &&
                  other.category == product.category) {
                similar.add(other);
                continue;
              }
              if (other.name.toLowerCase().contains(prefix)) {
                similar.add(other);
                continue;
              }
            }
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.kPrimaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.inventory_2_outlined,
                      color: AppColors.kPrimaryBlue, size: 20),
                ),
                title: Text(
                  product.name,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: product.quantity <= 0 ? Colors.grey : Colors.black,
                      decoration: product.quantity <= 0 ? TextDecoration.lineThrough : null,
                  ),
                ),
                subtitle: Text(
                  '${product.barcode} | ${product.category ?? "بدون تصنيف"}',
                  style: TextStyle(color: AppColors.mutedColor, fontSize: 12),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${product.price.toStringAsFixed(2)} ج.م',
                      style: TextStyle(
                        color: AppColors.kPrimaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'المخزون: ${product.quantity}',
                      style: TextStyle(
                        color: product.quantity <= (product.minQuantity ?? 0)
                            ? Colors.red
                            : Colors.green,
                        fontSize: 11,
                        
                      ),
                    ),
                  ],
                ),
                tileColor: product.quantity <= 0 ? Colors.grey.withOpacity(0.1) : null,
                enabled: product.quantity > 0,
                onTap: product.quantity > 0 ? () => onProductSelected(product) : null,
              ),
              if (similar.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(
                      left: 72.0, right: 8.0, bottom: 8.0),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: similar.take(4).map((sp) {
                      return ActionChip(
                        label:
                            Text('${sp.name} | ${sp.price.toStringAsFixed(2)}'),
                        onPressed: () => onProductSelected(sp),
                      );
                    }).toList(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
