// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'temp_cart_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TempCartItemAdapter
    extends TypeAdapter<TempCartItem> {
  @override
  final int typeId = 72;

  @override
  TempCartItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++)
        reader.readByte(): reader.read(),
    };
    return TempCartItem(
      item: fields[0] as TempProductClass,
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
    );
  }

  @override
  void write(BinaryWriter writer, TempCartItem obj) {
    writer
      ..writeByte(13)
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
      ..write(obj.isVoid);
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
