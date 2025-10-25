import 'package:hive_flutter/adapters.dart';

class Product {
  final String name;
  final String barcode;
  double price;
  double minPrice;
  int quantity;
  final int minQuantity;
  final String category;

  Product({
    required this.name,
    required this.barcode,
    required this.price,
    required this.minPrice,
    required this.quantity,
    required this.minQuantity,
    required this.category,
  });
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
}

class ProductAdapter extends TypeAdapter<Product> {
  @override
  final int typeId = 4;

  @override
  Product read(BinaryReader reader) {
    return Product(
      name: reader.readString(),        // 1st
      barcode: reader.readString(),     // 2nd
      price: reader.readDouble(),       // 3rd
      minPrice: reader.readDouble(),    // 4th - MOVED HERE
      quantity: reader.readInt(),       // 5th
      minQuantity: reader.readInt(),    // 6th
      category: reader.readString(),    // 7th
    );
  }

  @override
  void write(BinaryWriter writer, Product obj) {
    writer.writeString(obj.name);       // 1st
    writer.writeString(obj.barcode);    // 2nd
    writer.writeDouble(obj.price);      // 3rd
    writer.writeDouble(obj.minPrice);   // 4th
    writer.writeInt(obj.quantity);      // 5th
    writer.writeInt(obj.minQuantity);   // 6th
    writer.writeString(obj.category);   // 7th
  }
}
