// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'draft_items.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DraftItemsAdapter extends TypeAdapter<DraftItems> {
  @override
  final int typeId = 148;

  @override
  DraftItems read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DraftItems(
      uuid: fields[0] as String,
      draftId: fields[1] as String,
      createdAt: fields[2] as DateTime,
      productUuid: fields[3] as String?,
      productName: fields[4] as String,
      quantity: fields[5] as double,
      customPrice: fields[6] as double?,
      setCustomPrice: fields[7] as bool,
      setTotalPrice: fields[8] as bool,
      useWholeSalePrice: fields[9] as bool,
      addToStock: fields[10] as bool,
      discount: fields[11] as double?,
      fixedDiscount: fields[12] as double?,
      useGroupQuantity: fields[13] as bool?,
      qttyPerGroup: fields[14] as double?,
      isVoid: fields[15] as bool?,
      unit: fields[16] as String?,
      groupUnit: fields[17] as String?,
      unitUuid: fields[18] as String?,
      unitsList: (fields[19] as List?)?.cast<ProductUnitsClass>(),
      priceUuid: fields[20] as String?,
      pricesList: (fields[21] as List?)?.cast<ProductPricesClass>(),
      sellingPrice: fields[22] as double?,
      costPrice: fields[23] as double?,
      isProductManaged: fields[24] as bool?,
      revenue: fields[25] as double?,
      widthDimension: fields[26] as double?,
      heightDimension: fields[27] as double?,
      quantityType: fields[28] as int?,
      manageSalesWastage: fields[29] as bool?,
      isPercentageWastage: fields[30] as bool?,
      wastageAmount: fields[31] as double?,
      wastageUnitUuid: fields[32] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DraftItems obj) {
    writer
      ..writeByte(33)
      ..writeByte(0)
      ..write(obj.uuid)
      ..writeByte(1)
      ..write(obj.draftId)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.productUuid)
      ..writeByte(4)
      ..write(obj.productName)
      ..writeByte(5)
      ..write(obj.quantity)
      ..writeByte(6)
      ..write(obj.customPrice)
      ..writeByte(7)
      ..write(obj.setCustomPrice)
      ..writeByte(8)
      ..write(obj.setTotalPrice)
      ..writeByte(9)
      ..write(obj.useWholeSalePrice)
      ..writeByte(10)
      ..write(obj.addToStock)
      ..writeByte(11)
      ..write(obj.discount)
      ..writeByte(12)
      ..write(obj.fixedDiscount)
      ..writeByte(13)
      ..write(obj.useGroupQuantity)
      ..writeByte(14)
      ..write(obj.qttyPerGroup)
      ..writeByte(15)
      ..write(obj.isVoid)
      ..writeByte(16)
      ..write(obj.unit)
      ..writeByte(17)
      ..write(obj.groupUnit)
      ..writeByte(18)
      ..write(obj.unitUuid)
      ..writeByte(19)
      ..write(obj.unitsList)
      ..writeByte(20)
      ..write(obj.priceUuid)
      ..writeByte(21)
      ..write(obj.pricesList)
      ..writeByte(22)
      ..write(obj.sellingPrice)
      ..writeByte(23)
      ..write(obj.costPrice)
      ..writeByte(24)
      ..write(obj.isProductManaged)
      ..writeByte(25)
      ..write(obj.revenue)
      ..writeByte(26)
      ..write(obj.widthDimension)
      ..writeByte(27)
      ..write(obj.heightDimension)
      ..writeByte(28)
      ..write(obj.quantityType)
      ..writeByte(29)
      ..write(obj.manageSalesWastage)
      ..writeByte(30)
      ..write(obj.isPercentageWastage)
      ..writeByte(31)
      ..write(obj.wastageAmount)
      ..writeByte(32)
      ..write(obj.wastageUnitUuid);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DraftItemsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
