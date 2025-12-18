// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SessionAdapter extends TypeAdapter<Session> {
  @override
  final int typeId = 7;

  @override
  Session read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Session(
      id: fields[0] as String,
      openTime: fields[1] as DateTime,
      closeTime: fields[2] as DateTime?,
      isOpen: fields[3] as bool,
      openedByUserId: fields[4] as String,
      closedByUserId: fields[5] as String?,
      invoiceIds: (fields[6] as List?)?.cast<String>(),
      dailyReportId: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Session obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.openTime)
      ..writeByte(2)
      ..write(obj.closeTime)
      ..writeByte(3)
      ..write(obj.isOpen)
      ..writeByte(4)
      ..write(obj.openedByUserId)
      ..writeByte(5)
      ..write(obj.closedByUserId)
      ..writeByte(6)
      ..write(obj.invoiceIds)
      ..writeByte(7)
      ..write(obj.dailyReportId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
