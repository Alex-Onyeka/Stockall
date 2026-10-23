// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'temp_storage_products.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TempStorageProductsAdapter
    extends TypeAdapter<TempStorageProducts> {
  @override
  final int typeId = 66;

  @override
  TempStorageProducts read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++)
        reader.readByte(): reader.read(),
    };
    return TempStorageProducts(
      uuid: fields[0] as String?,
      createdAt: fields[1] as DateTime?,
      shopId: fields[2] as int,
      name: fields[3] as String,
      desc: fields[4] as String?,
      quantity: fields[5] as double?,
      unit: fields[6] as String?,
      groupUnit: fields[7] as String?,
      updatedAt: fields[8] as DateTime?,
      qttyPerGroup: fields[9] as double?,
      costPrice: fields[10] as double?,
      sellingPrice: fields[11] as double?,
      useGroupUnit: fields[12] as bool?,
      unitsList:
          (fields[13] as List?)?.cast<ProductUnitsClass>(),
      quantityType: fields[14] as int?,
      widthDimension: fields[15] as double?,
      heightDimension: fields[16] as double?,
      dimensionUnit: fields[17] as String?,
      dimensionUnitConversion: fields[18] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, TempStorageProducts obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.uuid)
      ..writeByte(1)
      ..write(obj.createdAt)
      ..writeByte(2)
      ..write(obj.shopId)
      ..writeByte(3)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.desc)
      ..writeByte(5)
      ..write(obj.quantity)
      ..writeByte(6)
      ..write(obj.unit)
      ..writeByte(7)
      ..write(obj.groupUnit)
      ..writeByte(8)
      ..write(obj.updatedAt)
      ..writeByte(9)
      ..write(obj.qttyPerGroup)
      ..writeByte(10)
      ..write(obj.costPrice)
      ..writeByte(11)
      ..write(obj.sellingPrice)
      ..writeByte(12)
      ..write(obj.useGroupUnit)
      ..writeByte(13)
      ..write(obj.unitsList)
      ..writeByte(14)
      ..write(obj.quantityType)
      ..writeByte(15)
      ..write(obj.widthDimension)
      ..writeByte(16)
      ..write(obj.heightDimension)
      ..writeByte(17)
      ..write(obj.dimensionUnit)
      ..writeByte(18)
      ..write(obj.dimensionUnitConversion);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TempStorageProductsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
