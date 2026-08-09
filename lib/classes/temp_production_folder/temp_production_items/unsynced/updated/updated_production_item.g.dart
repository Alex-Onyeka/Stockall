// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'updated_production_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UpdatedProductionItemAdapter extends TypeAdapter<UpdatedProductionItem> {
  @override
  final int typeId = 112;

  @override
  UpdatedProductionItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UpdatedProductionItem(
      productionItem: fields[0] as ProductionItem,
      includeQuantity: fields[1] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, UpdatedProductionItem obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.productionItem)
      ..writeByte(1)
      ..write(obj.includeQuantity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdatedProductionItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
