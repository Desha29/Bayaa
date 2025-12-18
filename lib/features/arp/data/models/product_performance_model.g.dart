// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_performance_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductPerformanceModelAdapter
    extends TypeAdapter<ProductPerformanceModel> {
  @override
  final int typeId = 9;

  @override
  ProductPerformanceModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductPerformanceModel(
      productId: fields[0] as String,
      productName: fields[1] as String,
      quantitySold: fields[2] as int,
      revenue: fields[3] as double,
      cost: fields[4] as double,
      profit: fields[5] as double,
      profitMargin: fields[6] as double,
    );
  }

  @override
  void write(BinaryWriter writer, ProductPerformanceModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.productId)
      ..writeByte(1)
      ..write(obj.productName)
      ..writeByte(2)
      ..write(obj.quantitySold)
      ..writeByte(3)
      ..write(obj.revenue)
      ..writeByte(4)
      ..write(obj.cost)
      ..writeByte(5)
      ..write(obj.profit)
      ..writeByte(6)
      ..write(obj.profitMargin);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductPerformanceModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
