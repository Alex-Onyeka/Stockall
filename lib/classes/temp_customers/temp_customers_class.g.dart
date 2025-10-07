// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'temp_customers_class.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TempCustomersClassAdapter extends TypeAdapter<TempCustomersClass> {
  @override
  final int typeId = 1;

  @override
  TempCustomersClass read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TempCustomersClass(
      country: fields[3] as String?,
      id: fields[0] as int?,
      name: fields[4] as String,
      email: fields[5] as String,
      phone: fields[6] as String,
      address: fields[7] as String?,
      city: fields[8] as String?,
      state: fields[9] as String?,
      dateAdded: fields[1] as DateTime,
      shopId: fields[2] as int,
      departmentName: fields[10] as String?,
      departmentId: fields[11] as int?,
      uuid: fields[12] as String?,
      updatedAt: fields[13] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, TempCustomersClass obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.dateAdded)
      ..writeByte(2)
      ..write(obj.shopId)
      ..writeByte(3)
      ..write(obj.country)
      ..writeByte(4)
      ..write(obj.name)
      ..writeByte(5)
      ..write(obj.email)
      ..writeByte(6)
      ..write(obj.phone)
      ..writeByte(7)
      ..write(obj.address)
      ..writeByte(8)
      ..write(obj.city)
      ..writeByte(9)
      ..write(obj.state)
      ..writeByte(10)
      ..write(obj.departmentName)
      ..writeByte(11)
      ..write(obj.departmentId)
      ..writeByte(12)
      ..write(obj.uuid)
      ..writeByte(13)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TempCustomersClassAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
