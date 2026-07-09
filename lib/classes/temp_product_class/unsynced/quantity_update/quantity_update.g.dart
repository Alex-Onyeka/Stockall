// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quantity_update.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuantityUpdateAdapter extends TypeAdapter<QuantityUpdate> {
  @override
  final int typeId = 96;

  @override
  QuantityUpdate read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuantityUpdate(
      uuid: fields[0] as String?,
      createdAt: fields[1] as DateTime?,
      quantity: fields[2] as double,
      productUuid: fields[3] as String,
      isIncrement: fields[4] as bool,
      isStorage: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, QuantityUpdate obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.uuid)
      ..writeByte(1)
      ..write(obj.createdAt)
      ..writeByte(2)
      ..write(obj.quantity)
      ..writeByte(3)
      ..write(obj.productUuid)
      ..writeByte(4)
      ..write(obj.isIncrement)
      ..writeByte(5)
      ..write(obj.isStorage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuantityUpdateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
