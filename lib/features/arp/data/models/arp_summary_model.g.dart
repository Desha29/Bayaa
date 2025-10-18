// lib/features/arp/data/models/arp_summary_model.g.dart
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'arp_summary_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ArpSummaryModelAdapter extends TypeAdapter<ArpSummaryModel> {
  @override
  final int typeId = 4;

  @override
  ArpSummaryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ArpSummaryModel(
      totalRevenue: fields[0] as double,
      totalCost: fields[1] as double,
      totalProfit: fields[2] as double,
      profitMargin: fields[3] as double,
      totalSales: fields[4] as int,
      startDate: fields[5] as DateTime,
      endDate: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ArpSummaryModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.totalRevenue)
      ..writeByte(1)
      ..write(obj.totalCost)
      ..writeByte(2)
      ..write(obj.totalProfit)
      ..writeByte(3)
      ..write(obj.profitMargin)
      ..writeByte(4)
      ..write(obj.totalSales)
      ..writeByte(5)
      ..write(obj.startDate)
      ..writeByte(6)
      ..write(obj.endDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArpSummaryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
