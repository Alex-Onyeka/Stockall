// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deleted_orders.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DeletedOrdersAdapter
    extends TypeAdapter<DeletedOrders> {
  @override
  final int typeId = 136;

  @override
  DeletedOrders read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++)
        reader.readByte(): reader.read(),
    };
    return DeletedOrders(orderUuid: fields[0] as String);
  }

  @override
  void write(BinaryWriter writer, DeletedOrders obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.orderUuid);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeletedOrdersAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
