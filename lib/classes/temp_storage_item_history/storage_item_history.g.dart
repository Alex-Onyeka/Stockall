// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage_item_history.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StorageItemHistoryAdapter extends TypeAdapter<StorageItemHistory> {
  @override
  final int typeId = 143;

  @override
  StorageItemHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StorageItemHistory(
      uuid: fields[0] as String?,
      createdAt: fields[1] as DateTime?,
      shopId: fields[2] as int,
      title: fields[3] as String,
      storageItemName: fields[4] as String?,
      storageDepartmentName: fields[10] as String?,
      storageDepartmentUuid: fields[11] as String?,
      storageStaffId: fields[8] as String?,
      storageStaffName: fields[9] as String?,
      storageItemNewValue: fields[6] as String?,
      storageItemOldValue: fields[7] as String?,
      storageItemUuid: fields[5] as String?,
      quantityChange: fields[12] as double?,
      desc: fields[13] as String?,
      isIncreased: fields[14] as bool?,
      storageUnit: fields[15] as String?,
      storagePrimaryUnit: fields[16] as String?,
      salesUnit: fields[24] as String?,
      salesPrimaryUnit: fields[25] as String?,
      salesStaffUuid: fields[18] as String?,
      salesStaffName: fields[17] as String?,
      salesDepartmentName: fields[20] as String?,
      salesDepartmentUuid: fields[19] as String?,
      salesItemNewValue: fields[22] as String?,
      salesItemOldValue: fields[21] as String?,
      salesItemUuid: fields[23] as String?,
      salesItemName: fields[26] as String?,
      event: fields[27] as String?,
      source: fields[28] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, StorageItemHistory obj) {
    writer
      ..writeByte(29)
      ..writeByte(0)
      ..write(obj.uuid)
      ..writeByte(1)
      ..write(obj.createdAt)
      ..writeByte(2)
      ..write(obj.shopId)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.storageItemName)
      ..writeByte(5)
      ..write(obj.storageItemUuid)
      ..writeByte(6)
      ..write(obj.storageItemNewValue)
      ..writeByte(7)
      ..write(obj.storageItemOldValue)
      ..writeByte(8)
      ..write(obj.storageStaffId)
      ..writeByte(9)
      ..write(obj.storageStaffName)
      ..writeByte(10)
      ..write(obj.storageDepartmentName)
      ..writeByte(11)
      ..write(obj.storageDepartmentUuid)
      ..writeByte(12)
      ..write(obj.quantityChange)
      ..writeByte(13)
      ..write(obj.desc)
      ..writeByte(14)
      ..write(obj.isIncreased)
      ..writeByte(15)
      ..write(obj.storageUnit)
      ..writeByte(16)
      ..write(obj.storagePrimaryUnit)
      ..writeByte(17)
      ..write(obj.salesStaffName)
      ..writeByte(18)
      ..write(obj.salesStaffUuid)
      ..writeByte(19)
      ..write(obj.salesDepartmentUuid)
      ..writeByte(20)
      ..write(obj.salesDepartmentName)
      ..writeByte(21)
      ..write(obj.salesItemOldValue)
      ..writeByte(22)
      ..write(obj.salesItemNewValue)
      ..writeByte(23)
      ..write(obj.salesItemUuid)
      ..writeByte(24)
      ..write(obj.salesUnit)
      ..writeByte(25)
      ..write(obj.salesPrimaryUnit)
      ..writeByte(26)
      ..write(obj.salesItemName)
      ..writeByte(27)
      ..write(obj.event)
      ..writeByte(28)
      ..write(obj.source);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StorageItemHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
