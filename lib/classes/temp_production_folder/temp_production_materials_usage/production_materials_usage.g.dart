// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'production_materials_usage.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductionMaterialsUsageAdapter
    extends TypeAdapter<ProductionMaterialsUsage> {
  @override
  final int typeId = 121;

  @override
  ProductionMaterialsUsage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductionMaterialsUsage(
      uuid: fields[0] as String,
      shopId: fields[1] as int,
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
      unit: fields[14] as String?,
      customCost: fields[15] as double?,
      updatedAt: fields[16] as DateTime?,
      customUnit: fields[18] as String?,
      groupUnit: fields[20] as String?,
      originalCostPerItem: fields[17] as double?,
      originalUseGroupQuantity: fields[19] as bool?,
      selectedCostInt: fields[21] as int?,
      isManaged: fields[22] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, ProductionMaterialsUsage obj) {
    writer
      ..writeByte(22)
      ..writeByte(0)
      ..write(obj.uuid)
      ..writeByte(1)
      ..write(obj.shopId)
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
      ..writeByte(14)
      ..write(obj.unit)
      ..writeByte(15)
      ..write(obj.customCost)
      ..writeByte(16)
      ..write(obj.updatedAt)
      ..writeByte(17)
      ..write(obj.originalCostPerItem)
      ..writeByte(18)
      ..write(obj.customUnit)
      ..writeByte(19)
      ..write(obj.originalUseGroupQuantity)
      ..writeByte(20)
      ..write(obj.groupUnit)
      ..writeByte(21)
      ..write(obj.selectedCostInt)
      ..writeByte(22)
      ..write(obj.isManaged);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductionMaterialsUsageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
