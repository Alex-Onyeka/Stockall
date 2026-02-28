// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'created_inventory_updates_class.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CreatedInventoryUpdatesClassAdapter
    extends TypeAdapter<CreatedInventoryUpdatesClass> {
  @override
  final int typeId = 53;

  @override
  CreatedInventoryUpdatesClass read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CreatedInventoryUpdatesClass(
      inventoryUpdate: fields[0] as TempInventoryUpdateClass,
    );
  }

  @override
  void write(BinaryWriter writer, CreatedInventoryUpdatesClass obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.inventoryUpdate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreatedInventoryUpdatesClassAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
