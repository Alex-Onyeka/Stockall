// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'production_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductionItemAdapter extends TypeAdapter<ProductionItem> {
  @override
  final int typeId = 109;

  @override
  ProductionItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductionItem(
      name: fields[1] as String,
      barcode: fields[4] as String?,
      quantity: fields[8] as double?,
      unit: fields[5] as String,
      sizeType: fields[6] as String?,
      costPrice: fields[7] as double,
      shopId: fields[2] as int,
      createdAt: fields[3] as DateTime?,
      departmentName: fields[9] as String?,
      departmentUuid: fields[10] as String?,
      expiryDate: fields[11] as DateTime?,
      isManaged: fields[12] as bool,
      updatedAt: fields[13] as DateTime?,
      uuid: fields[0] as String?,
      groupUnit: fields[14] as String?,
      qttyPerGroup: fields[15] as double?,
      categoryUuid: fields[16] as String?,
      categories: (fields[17] as List?)?.cast<String>(),
      useGroupUnit: fields[18] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, ProductionItem obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.uuid)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.shopId)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.barcode)
      ..writeByte(5)
      ..write(obj.unit)
      ..writeByte(6)
      ..write(obj.sizeType)
      ..writeByte(7)
      ..write(obj.costPrice)
      ..writeByte(8)
      ..write(obj.quantity)
      ..writeByte(9)
      ..write(obj.departmentName)
      ..writeByte(10)
      ..write(obj.departmentUuid)
      ..writeByte(11)
      ..write(obj.expiryDate)
      ..writeByte(12)
      ..write(obj.isManaged)
      ..writeByte(13)
      ..write(obj.updatedAt)
      ..writeByte(14)
      ..write(obj.groupUnit)
      ..writeByte(15)
      ..write(obj.qttyPerGroup)
      ..writeByte(16)
      ..write(obj.categoryUuid)
      ..writeByte(17)
      ..write(obj.categories)
      ..writeByte(18)
      ..write(obj.useGroupUnit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductionItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
