// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'production_item_history.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductionItemHistoryAdapter extends TypeAdapter<ProductionItemHistory> {
  @override
  final int typeId = 114;

  @override
  ProductionItemHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductionItemHistory(
      uuid: fields[0] as String?,
      createdAt: fields[1] as DateTime?,
      shopId: fields[2] as int,
      title: fields[3] as String,
      itemName: fields[4] as String?,
      departmentName: fields[10] as String?,
      departmentUuid: fields[11] as String?,
      staffId: fields[8] as String?,
      staffName: fields[9] as String?,
      newValue: fields[6] as String?,
      oldValue: fields[7] as String?,
      itemUuid: fields[5] as String?,
      quantityChange: fields[12] as double?,
      desc: fields[13] as String?,
      isIncreased: fields[14] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, ProductionItemHistory obj) {
    writer
      ..writeByte(15)
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
      ..write(obj.itemUuid)
      ..writeByte(6)
      ..write(obj.newValue)
      ..writeByte(7)
      ..write(obj.oldValue)
      ..writeByte(8)
      ..write(obj.staffId)
      ..writeByte(9)
      ..write(obj.staffName)
      ..writeByte(10)
      ..write(obj.departmentName)
      ..writeByte(11)
      ..write(obj.departmentUuid)
      ..writeByte(12)
      ..write(obj.quantityChange)
      ..writeByte(13)
      ..write(obj.desc)
      ..writeByte(14)
      ..write(obj.isIncreased);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductionItemHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
