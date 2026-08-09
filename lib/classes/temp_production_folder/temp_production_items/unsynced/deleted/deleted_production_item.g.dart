// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deleted_production_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DeletedProductionItemAdapter extends TypeAdapter<DeletedProductionItem> {
  @override
  final int typeId = 111;

  @override
  DeletedProductionItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DeletedProductionItem(
      productionItemUuid: fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DeletedProductionItem obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.productionItemUuid);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeletedProductionItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
