// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'updated_customers.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UpdatedCustomersAdapter extends TypeAdapter<UpdatedCustomers> {
  @override
  final int typeId = 19;

  @override
  UpdatedCustomers read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UpdatedCustomers(
      customer: fields[0] as TempCustomersClass,
    );
  }

  @override
  void write(BinaryWriter writer, UpdatedCustomers obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.customer);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdatedCustomersAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
