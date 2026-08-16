// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'production_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductionRecordAdapter extends TypeAdapter<ProductionRecord> {
  @override
  final int typeId = 100;

  @override
  ProductionRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductionRecord(
      uuid: fields[0] as String?,
      createdAt: fields[1] as DateTime?,
      shopId: fields[2] as int?,
      staffId: fields[3] as String?,
      staffName: fields[4] as String?,
      departmentId: fields[5] as String?,
      departmentName: fields[6] as String?,
      updatedAt: fields[7] as DateTime?,
      materials: (fields[8] as List).cast<ProductionRecordMaterials>(),
      itemName: fields[10] as String?,
      itemUuid: fields[11] as String?,
      salesItemUuid: fields[23] as String?,
      quantity: fields[9] as double?,
      unit: fields[14] as String?,
      qttyPerGroup: fields[13] as double?,
      totalCost: fields[15] as double?,
      customCost: fields[16] as double?,
      comment: fields[17] as String?,
      selectedCostPriceOption: fields[18] as int?,
      originalCostPerItem: fields[21] as double?,
      originalUseGroupQuantity: fields[20] as bool?,
      useGroupQuantity: fields[19] as bool?,
      groupUnit: fields[22] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ProductionRecord obj) {
    writer
      ..writeByte(23)
      ..writeByte(0)
      ..write(obj.uuid)
      ..writeByte(1)
      ..write(obj.createdAt)
      ..writeByte(2)
      ..write(obj.shopId)
      ..writeByte(3)
      ..write(obj.staffId)
      ..writeByte(4)
      ..write(obj.staffName)
      ..writeByte(5)
      ..write(obj.departmentId)
      ..writeByte(6)
      ..write(obj.departmentName)
      ..writeByte(7)
      ..write(obj.updatedAt)
      ..writeByte(8)
      ..write(obj.materials)
      ..writeByte(9)
      ..write(obj.quantity)
      ..writeByte(10)
      ..write(obj.itemName)
      ..writeByte(11)
      ..write(obj.itemUuid)
      ..writeByte(13)
      ..write(obj.qttyPerGroup)
      ..writeByte(14)
      ..write(obj.unit)
      ..writeByte(15)
      ..write(obj.totalCost)
      ..writeByte(16)
      ..write(obj.customCost)
      ..writeByte(17)
      ..write(obj.comment)
      ..writeByte(18)
      ..write(obj.selectedCostPriceOption)
      ..writeByte(19)
      ..write(obj.useGroupQuantity)
      ..writeByte(20)
      ..write(obj.originalUseGroupQuantity)
      ..writeByte(21)
      ..write(obj.originalCostPerItem)
      ..writeByte(22)
      ..write(obj.groupUnit)
      ..writeByte(23)
      ..write(obj.salesItemUuid);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductionRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
