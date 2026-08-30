// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'created_orders.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CreatedOrdersAdapter extends TypeAdapter<CreatedOrders> {
  @override
  final int typeId = 135;

  @override
  CreatedOrders read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CreatedOrders(
      order: fields[0] as Orders,
    );
  }

  @override
  void write(BinaryWriter writer, CreatedOrders obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.order);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreatedOrdersAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
