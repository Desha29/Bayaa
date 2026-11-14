import 'package:flutter/material.dart';
import 'package:bayaa_pos/shared/theme/app_colors.dart';
import 'package:bayaa_pos/l10n/app_localizations.dart';
import 'package:bayaa_pos/features/pos/presentation/widgets/cart_item.dart';

class CartSection extends StatelessWidget {
  const CartSection(
      {super.key,
      required this.cartItems,
      this.onRemoveItem,
      this.onIncreaseQty,
      this.onDecreaseQty,
      this.onEditPrice});
  final List<Map<String, dynamic>> cartItems;
  final ValueChanged<int>? onRemoveItem, onIncreaseQty, onDecreaseQty;
  final void Function(int, double)? onEditPrice;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ar = l10n.localeName == 'ar';
    return Container(
      decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderColor)),
      child: Column(children: [
        Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Icon(Icons.receipt_long_outlined,
                  size: 20, color: AppColors.secondaryColor),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(l10n.cartProductList,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary))),
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                      color: AppColors.secondaryColor.withValues(alpha: .08),
                      borderRadius: BorderRadius.circular(7)),
                  child: Text('${cartItems.length}',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.secondaryColor))),
            ])),
        Divider(height: 1, color: AppColors.borderColor),
        Expanded(
            child: cartItems.isEmpty
                ? Center(
                    child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.shopping_bag_outlined,
                              size: 40, color: AppColors.mutedColor),
                          const SizedBox(height: 12),
                          Text(l10n.cartEmptyTitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary)),
                          const SizedBox(height: 8),
                          Text(
                              ar
                                  ? 'اختر منتجاً لبدء فاتورة تجريبية'
                                  : 'Choose a product to start a sample order',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: AppColors.mutedColor)),
                        ])))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: cartItems.length,
                    separatorBuilder: (_, __) => Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                        color: AppColors.borderColor.withValues(alpha: .6)),
                    itemBuilder: (context, i) {
                      final item = cartItems[i];
                      return CartItemRow(
                        name: item['name'],
                        id: item['id'],
                        price: item['price'],
                        quantity: item['qty'],
                        remainingQuantity:
                            (item['quantity'] as int) - (item['qty'] as int),
                        date: item['date'],
                        minPrice: item['minPrice'] ?? 0.0,
                        onRemove: () => onRemoveItem?.call(i),
                        onIncrease: () => onIncreaseQty?.call(i),
                        onDecrease: () => onDecreaseQty?.call(i),
                        onEditPrice: (price) => onEditPrice?.call(i, price),
                      );
                    },
                  )),
      ]),
    );
  }
}
