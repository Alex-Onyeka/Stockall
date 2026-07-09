// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'temp_item_purchase_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TempItemPurchaseRecordAdapter
    extends TypeAdapter<TempItemPurchaseRecord> {
  @override
  final int typeId = 77;

  @override
  TempItemPurchaseRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TempItemPurchaseRecord(
      createdAt: fields[1] as DateTime,
      shopId: fields[2] as int,
      staffId: fields[5] as String?,
      quantity: fields[7] as double?,
      uuid: fields[0] as String?,
      departmentId: fields[3] as String?,
      itemId: fields[4] as String?,
      supplierId: fields[6] as String?,
      total: fields[8] as double?,
      purchaseId: fields[9] as String?,
      itemName: fields[10] as String?,
      originalPrice: fields[11] as double?,
      customPrice: fields[12] as double?,
      storageItemId: fields[13] as String?,
      isGroup: fields[14] as bool?,
      qttyPerGroup: fields[15] as double?,
      unit: fields[16] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TempItemPurchaseRecord obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.uuid)
      ..writeByte(1)
      ..write(obj.createdAt)
      ..writeByte(2)
      ..write(obj.shopId)
      ..writeByte(3)
      ..write(obj.departmentId)
      ..writeByte(4)
      ..write(obj.itemId)
      ..writeByte(5)
      ..write(obj.staffId)
      ..writeByte(6)
      ..write(obj.supplierId)
      ..writeByte(7)
      ..write(obj.quantity)
      ..writeByte(8)
      ..write(obj.total)
      ..writeByte(9)
      ..write(obj.purchaseId)
      ..writeByte(10)
      ..write(obj.itemName)
      ..writeByte(11)
      ..write(obj.originalPrice)
      ..writeByte(12)
      ..write(obj.customPrice)
      ..writeByte(13)
      ..write(obj.storageItemId)
      ..writeByte(14)
      ..write(obj.isGroup)
      ..writeByte(15)
      ..write(obj.qttyPerGroup)
      ..writeByte(16)
      ..write(obj.unit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TempItemPurchaseRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
