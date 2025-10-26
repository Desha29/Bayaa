class CartItemModel {
  final String id;
  final String name;
  final double originalPrice;
  double salePrice;
  int qty;
  final DateTime date;
  final double minPrice;
  final double wholesalePrice;  // Added wholesalePrice field

  CartItemModel({
    required this.id,
    required this.name,
    required this.originalPrice,
    required this.salePrice,
    required this.qty,
    required this.date,
    required this.minPrice,
    required this.wholesalePrice,  // Add to constructor
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
      'wholesalePrice': wholesalePrice,  // Include wholesalePrice in map
    };
  }
}
