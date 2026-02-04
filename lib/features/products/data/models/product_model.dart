
class Product {
  final String name;
  final String barcode;
  double price;
  double minPrice;
  double wholesalePrice;
  int quantity;
  final int minQuantity;
  final String category;

  Product({
    required this.name,
    required this.barcode,
    required this.price,
    required this.minPrice,
    required this.wholesalePrice,
    required this.quantity,
    required this.minQuantity,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'barcode': barcode,
      'price': price,
      'minPrice': minPrice,
      'wholesalePrice': wholesalePrice,
      'quantity': quantity,
      'minQuantity': minQuantity,
      'category': category,
    };
  }

  String get status {
    if (quantity == 0) return 'غير متوفر';
    if (quantity < minQuantity) return 'مخزون منخفض';
    return 'متوفر';
  }

  String get priority {
    if (quantity == 0) return 'عاجل جداً';
    final diff = minQuantity - quantity;
    if (diff >= 3) return 'عاجل';
    if (diff == 1 || diff == 2) return 'متوسط';
    return 'منخفض';
  }

  Product copyWith({
    String? name,
    String? barcode,
    double? price,
    double? minPrice,
    double? wholesalePrice,
    int? quantity,
    int? minQuantity,
    String? category,
  }) {
    return Product(
      name: name ?? this.name,
      barcode: barcode ?? this.barcode,
      price: price ?? this.price,
      minPrice: minPrice ?? this.minPrice,
      wholesalePrice: wholesalePrice ?? this.wholesalePrice,
      quantity: quantity ?? this.quantity,
      minQuantity: minQuantity ?? this.minQuantity,
      category: category ?? this.category,
    );
  }
}
