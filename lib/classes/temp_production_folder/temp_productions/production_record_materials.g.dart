// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'production_record_materials.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductionRecordMaterialsAdapter
    extends TypeAdapter<ProductionRecordMaterials> {
  @override
  final int typeId = 99;

  @override
  ProductionRecordMaterials read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductionRecordMaterials(
      uuid: fields[0] as String,
      productionRecordId: fields[1] as String?,
      quantity: fields[2] as double,
      materialName: fields[4] as String,
      materialUuid: fields[3] as String,
      isGroup: fields[5] as bool?,
      qttyPerGroup: fields[6] as double?,
      totalCost: fields[7] as double?,
      createdAt: fields[8] as DateTime?,
      departmentName: fields[12] as String?,
      departmentUuid: fields[11] as String?,
      staffName: fields[10] as String?,
      staffUuid: fields[9] as String?,
      productionRecordName: fields[13] as String?,
      unit: fields[14] as String?,
      customCost: fields[15] as double?,
      customUnit: fields[17] as String?,
      groupUnit: fields[19] as String?,
      originalCostPerItem: fields[16] as double?,
      originalUseGroupQuantity: fields[18] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, ProductionRecordMaterials obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.uuid)
      ..writeByte(1)
      ..write(obj.productionRecordId)
      ..writeByte(2)
      ..write(obj.quantity)
      ..writeByte(3)
      ..write(obj.materialUuid)
      ..writeByte(4)
      ..write(obj.materialName)
      ..writeByte(5)
      ..write(obj.isGroup)
      ..writeByte(6)
      ..write(obj.qttyPerGroup)
      ..writeByte(7)
      ..write(obj.totalCost)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.staffUuid)
      ..writeByte(10)
      ..write(obj.staffName)
      ..writeByte(11)
      ..write(obj.departmentUuid)
      ..writeByte(12)
      ..write(obj.departmentName)
      ..writeByte(13)
      ..write(obj.productionRecordName)
      ..writeByte(14)
      ..write(obj.unit)
      ..writeByte(15)
      ..write(obj.customCost)
      ..writeByte(16)
      ..write(obj.originalCostPerItem)
      ..writeByte(17)
      ..write(obj.customUnit)
      ..writeByte(18)
      ..write(obj.originalUseGroupQuantity)
      ..writeByte(19)
      ..write(obj.groupUnit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductionRecordMaterialsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
