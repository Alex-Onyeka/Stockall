// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'temp_purchase.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TempPurchaseAdapter extends TypeAdapter<TempPurchase> {
  @override
  final int typeId = 73;

  @override
  TempPurchase read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TempPurchase(
      createdAt: fields[1] as DateTime,
      shopId: fields[2] as int,
      staffId: fields[3] as String?,
      staffName: fields[4] as String?,
      departmentName: fields[7] as String?,
      departmentUuid: fields[6] as String?,
      uuid: fields[0] as String?,
      total: fields[8] as double?,
      supplierId: fields[5] as String?,
      supplierName: fields[11] as String?,
      isCustomPriceSet: fields[9] as bool,
      purchasePayments: (fields[10] as List).cast<PurchasePayments>(),
      updatedAt: fields[12] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, TempPurchase obj) {
    writer
      ..writeByte(13)
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
      ..write(obj.supplierId)
      ..writeByte(6)
      ..write(obj.departmentUuid)
      ..writeByte(7)
      ..write(obj.departmentName)
      ..writeByte(8)
      ..write(obj.total)
      ..writeByte(9)
      ..write(obj.isCustomPriceSet)
      ..writeByte(10)
      ..write(obj.purchasePayments)
      ..writeByte(11)
      ..write(obj.supplierName)
      ..writeByte(12)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TempPurchaseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
