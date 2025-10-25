import 'package:hive_flutter/adapters.dart';

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
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    
    return Product(
      name: fields[0] as String,
      barcode: fields[1] as String,
      price: fields[2] as double,
      minPrice: fields[3] as double,
      wholesalePrice: fields[4] as double? ?? 0.0, // Default value for old data
      quantity: fields[5] as int,
      minQuantity: fields[6] as int,
      category: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Product obj) {
    writer
      ..writeByte(8) // Number of fields
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.barcode)
      ..writeByte(2)
      ..write(obj.price)
      ..writeByte(3)
      ..write(obj.minPrice)
      ..writeByte(4)
      ..write(obj.wholesalePrice)
      ..writeByte(5)
      ..write(obj.quantity)
      ..writeByte(6)
      ..write(obj.minQuantity)
      ..writeByte(7)
      ..write(obj.category);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
