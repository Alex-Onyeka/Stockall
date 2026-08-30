// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'updated_orders.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UpdatedOrdersAdapter extends TypeAdapter<UpdatedOrders> {
  @override
  final int typeId = 137;

  @override
  UpdatedOrders read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UpdatedOrders(
      order: fields[0] as Orders,
    );
  }

  @override
  void write(BinaryWriter writer, UpdatedOrders obj) {
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
      other is UpdatedOrdersAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
