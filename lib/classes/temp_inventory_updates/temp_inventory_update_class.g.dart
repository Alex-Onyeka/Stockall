// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'temp_inventory_update_class.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TempInventoryUpdateClassAdapter
    extends TypeAdapter<TempInventoryUpdateClass> {
  @override
  final int typeId = 52;

  @override
  TempInventoryUpdateClass read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TempInventoryUpdateClass(
      uuid: fields[0] as String?,
      createdAt: fields[1] as DateTime?,
      shopId: fields[2] as int,
      title: fields[3] as String,
      itemName: fields[4] as String?,
      departmentName: fields[10] as String?,
      departmentUuid: fields[9] as String?,
      staffId: fields[8] as String?,
      staffName: fields[7] as String?,
      newValue: fields[6] as String?,
      oldValue: fields[5] as String?,
      itemUuid: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TempInventoryUpdateClass obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.uuid)
      ..writeByte(1)
      ..write(obj.createdAt)
      ..writeByte(2)
      ..write(obj.shopId)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.itemName)
      ..writeByte(5)
      ..write(obj.oldValue)
      ..writeByte(6)
      ..write(obj.newValue)
      ..writeByte(7)
      ..write(obj.staffName)
      ..writeByte(8)
      ..write(obj.staffId)
      ..writeByte(9)
      ..write(obj.departmentUuid)
      ..writeByte(10)
      ..write(obj.departmentName)
      ..writeByte(11)
      ..write(obj.itemUuid);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TempInventoryUpdateClassAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
