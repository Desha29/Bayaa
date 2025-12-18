// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_report_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyReportAdapter extends TypeAdapter<DailyReport> {
  @override
  final int typeId = 8;

  @override
  DailyReport read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyReport(
      id: fields[0] as String,
      sessionId: fields[1] as String,
      date: fields[2] as DateTime,
      totalSales: fields[3] as double,
      totalRefunds: fields[4] as double,
      netRevenue: fields[5] as double,
      totalTransactions: fields[6] as int,
      closedByUserName: fields[7] as String,
      topProducts: (fields[8] as List).cast<ProductPerformanceModel>(),
      refundedProducts: (fields[9] as List).cast<ProductPerformanceModel>(),
      transactions: (fields[10] as List).cast<Sale>(),
    );
  }

  @override
  void write(BinaryWriter writer, DailyReport obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.sessionId)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.totalSales)
      ..writeByte(4)
      ..write(obj.totalRefunds)
      ..writeByte(5)
      ..write(obj.netRevenue)
      ..writeByte(6)
      ..write(obj.totalTransactions)
      ..writeByte(7)
      ..write(obj.closedByUserName)
      ..writeByte(8)
      ..write(obj.topProducts)
      ..writeByte(9)
      ..write(obj.refundedProducts)
      ..writeByte(10)
      ..write(obj.transactions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyReportAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
