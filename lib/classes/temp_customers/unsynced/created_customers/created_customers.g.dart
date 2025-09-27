// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'created_customers.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CreatedCustomersAdapter extends TypeAdapter<CreatedCustomers> {
  @override
  final int typeId = 17;

  @override
  CreatedCustomers read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CreatedCustomers(
      customer: fields[0] as TempCustomersClass,
    );
  }

  @override
  void write(BinaryWriter writer, CreatedCustomers obj) {
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
      other is CreatedCustomersAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
