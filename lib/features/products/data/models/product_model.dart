import 'package:hive_flutter/adapters.dart';

class Product {
  final String name;
  final String barcode;
  final double price;
  final int quantity;
  final int minQuantity;
  final String category;

  Product({
    required this.name,
    required this.barcode,
    required this.price,
    required this.quantity,
    required this.minQuantity,
    required this.category,
  });
}

class ProductAdapter extends TypeAdapter<Product> {
  @override
  final int typeId = 4;

  @override
  Product read(BinaryReader reader) {
    return Product(
      name: reader.readString(),
      barcode: reader.readString(),
      price: reader.readDouble(),
      quantity: reader.readInt(),
      minQuantity: reader.readInt(),
      category: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, Product obj) {
    writer.writeString(obj.name);
    writer.writeString(obj.barcode);
    writer.writeDouble(obj.price);
    writer.writeInt(obj.quantity);
    writer.writeInt(obj.minQuantity);
    writer.writeString(obj.category);
  }
}
