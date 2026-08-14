// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'productions_cart.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductionsCartAdapter extends TypeAdapter<ProductionsCart> {
  @override
  final int typeId = 119;

  @override
  ProductionsCart read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductionsCart(
      productionsCartItem: fields[0] as ProductionsCartItem?,
      uuid: fields[1] as String?,
      isEdit: fields[2] as bool,
      selectCostPriceToUse: fields[5] as int,
      createdDate: fields[4] as DateTime?,
      staffName: fields[6] as String?,
      staffId: fields[7] as String?,
      departmentName: fields[9] as String?,
      departmentUuid: fields[8] as String?,
      customDate: fields[10] as DateTime?,
      timeOfDay: fields[11] as TimeOfDay?,
      comment: fields[12] as String?,
      customPrice: fields[13] as double?,
      productionUuidEdit: fields[3] as String?,
      materialsCartItems:
          (fields[14] as List).cast<ProductionMaterialCartItem>(),
      originalCostPerItem: fields[15] as double?,
      originalUseGroupQuantity: fields[16] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, ProductionsCart obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.productionsCartItem)
      ..writeByte(1)
      ..write(obj.uuid)
      ..writeByte(2)
      ..write(obj.isEdit)
      ..writeByte(3)
      ..write(obj.productionUuidEdit)
      ..writeByte(4)
      ..write(obj.createdDate)
      ..writeByte(5)
      ..write(obj.selectCostPriceToUse)
      ..writeByte(6)
      ..write(obj.staffName)
      ..writeByte(7)
      ..write(obj.staffId)
      ..writeByte(8)
      ..write(obj.departmentUuid)
      ..writeByte(9)
      ..write(obj.departmentName)
      ..writeByte(10)
      ..write(obj.customDate)
      ..writeByte(11)
      ..write(obj.timeOfDay)
      ..writeByte(12)
      ..write(obj.comment)
      ..writeByte(13)
      ..write(obj.customPrice)
      ..writeByte(14)
      ..write(obj.materialsCartItems)
      ..writeByte(15)
      ..write(obj.originalCostPerItem)
      ..writeByte(16)
      ..write(obj.originalUseGroupQuantity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductionsCartAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
