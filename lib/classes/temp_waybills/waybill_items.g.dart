// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'waybill_items.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WaybillItemsAdapter extends TypeAdapter<WaybillItems> {
  @override
  final int typeId = 86;

  @override
  WaybillItems read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WaybillItems(
      uuid: fields[0] as String,
      waybillId: fields[1] as String?,
      quantity: fields[3] as double,
      amount: fields[2] as double,
      itemName: fields[5] as String,
      itemUuid: fields[4] as String,
      isGroup: fields[6] as bool?,
      qttyPerGroup: fields[7] as double?,
      customPrice: fields[8] as double?,
      originalCost: fields[9] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, WaybillItems obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.uuid)
      ..writeByte(1)
      ..write(obj.waybillId)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.quantity)
      ..writeByte(4)
      ..write(obj.itemUuid)
      ..writeByte(5)
      ..write(obj.itemName)
      ..writeByte(6)
      ..write(obj.isGroup)
      ..writeByte(7)
      ..write(obj.qttyPerGroup)
      ..writeByte(8)
      ..write(obj.customPrice)
      ..writeByte(9)
      ..write(obj.originalCost);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WaybillItemsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
