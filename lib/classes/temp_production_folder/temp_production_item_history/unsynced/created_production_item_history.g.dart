// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'created_production_item_history.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CreatedProductionItemHistoryAdapter
    extends TypeAdapter<CreatedProductionItemHistory> {
  @override
  final int typeId = 115;

  @override
  CreatedProductionItemHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CreatedProductionItemHistory(
      productionItemHistory: fields[0] as ProductionItemHistory,
    );
  }

  @override
  void write(BinaryWriter writer, CreatedProductionItemHistory obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.productionItemHistory);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreatedProductionItemHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
