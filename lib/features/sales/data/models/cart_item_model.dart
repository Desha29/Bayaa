// lib/features/sales/data/models/cart_item_model.dart
class CartItemModel {
  final String id;
  final String name;
  final double originalPrice;
  double salePrice;
  int qty;
  final DateTime date;
  final double minPrice;

  CartItemModel({
    required this.id,
    required this.name,
    required this.originalPrice,
    required this.salePrice,
    required this.qty,
    required this.date,
    required this.minPrice,
  });

  double get total => salePrice * qty;

  bool isPriceBelowMin() => salePrice < minPrice;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': salePrice,
      'qty': qty,
      'date': date,
      'minPrice': minPrice,
      'originalPrice': originalPrice,
    };
  }
}
