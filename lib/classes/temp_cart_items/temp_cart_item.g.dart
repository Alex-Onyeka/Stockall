// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'temp_cart_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TempCartItemAdapter extends TypeAdapter<TempCartItem> {
  @override
  final int typeId = 72;

  @override
  TempCartItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TempCartItem(
      item: fields[0] as TempProductClass,
      itemUuid: fields[13] as String?,
      quantity: fields[3] as double,
      discount: fields[1] as double?,
      fixedDiscount: fields[2] as double?,
      customPrice: fields[4] as double?,
      setCustomPrice: fields[5] as bool,
      addToStock: fields[8] as bool,
      setTotalPrice: fields[7] as bool,
      useWholeSalePrice: fields[6] as bool,
      salesRecordId: fields[9] as String?,
      useGroupQuantity: fields[10] as bool?,
      qttyPerGroup: fields[11] as double?,
      isVoid: fields[12] as bool?,
      uuid: fields[14] as String?,
      remainingQuantity: fields[15] as double?,
      remainingBalance: fields[16] as double?,
      unitUuid: fields[17] as String?,
      priceUuid: fields[18] as String?,
      widthDimension: fields[19] as double?,
      heightDimension: fields[20] as double?,
      quantityType: fields[21] as int?,
      manageSalesWastage: fields[22] as bool?,
      isPercentageWastage: fields[23] as bool?,
      wastageAmount: fields[24] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, TempCartItem obj) {
    writer
      ..writeByte(25)
      ..writeByte(0)
      ..write(obj.item)
      ..writeByte(1)
      ..write(obj.discount)
      ..writeByte(2)
      ..write(obj.fixedDiscount)
      ..writeByte(3)
      ..write(obj.quantity)
      ..writeByte(4)
      ..write(obj.customPrice)
      ..writeByte(5)
      ..write(obj.setCustomPrice)
      ..writeByte(6)
      ..write(obj.useWholeSalePrice)
      ..writeByte(7)
      ..write(obj.setTotalPrice)
      ..writeByte(8)
      ..write(obj.addToStock)
      ..writeByte(9)
      ..write(obj.salesRecordId)
      ..writeByte(10)
      ..write(obj.useGroupQuantity)
      ..writeByte(11)
      ..write(obj.qttyPerGroup)
      ..writeByte(12)
      ..write(obj.isVoid)
      ..writeByte(13)
      ..write(obj.itemUuid)
      ..writeByte(14)
      ..write(obj.uuid)
      ..writeByte(15)
      ..write(obj.remainingQuantity)
      ..writeByte(16)
      ..write(obj.remainingBalance)
      ..writeByte(17)
      ..write(obj.unitUuid)
      ..writeByte(18)
      ..write(obj.priceUuid)
      ..writeByte(19)
      ..write(obj.widthDimension)
      ..writeByte(20)
      ..write(obj.heightDimension)
      ..writeByte(21)
      ..write(obj.quantityType)
      ..writeByte(22)
      ..write(obj.manageSalesWastage)
      ..writeByte(23)
      ..write(obj.isPercentageWastage)
      ..writeByte(24)
      ..write(obj.wastageAmount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TempCartItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
