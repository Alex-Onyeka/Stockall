// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deleted_customers.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DeletedCustomersAdapter extends TypeAdapter<DeletedCustomers> {
  @override
  final int typeId = 18;

  @override
  DeletedCustomers read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DeletedCustomers(
      customerUuid: fields[0] as String,
      shopId: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, DeletedCustomers obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.customerUuid)
      ..writeByte(1)
      ..write(obj.shopId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeletedCustomersAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
