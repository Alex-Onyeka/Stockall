// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'created_materials_item_history.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CreatedMaterialsItemHistoryAdapter
    extends TypeAdapter<CreatedMaterialsItemHistory> {
  @override
  final int typeId = 116;

  @override
  CreatedMaterialsItemHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CreatedMaterialsItemHistory(
      createdMaterialsItemHistory: fields[0] as MaterialsItemHistory,
    );
  }

  @override
  void write(BinaryWriter writer, CreatedMaterialsItemHistory obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.createdMaterialsItemHistory);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreatedMaterialsItemHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
