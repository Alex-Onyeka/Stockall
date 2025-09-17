// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'temp_product_class.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TempProductClassAdapter extends TypeAdapter<TempProductClass> {
  @override
  final int typeId = 5;

  @override
  TempProductClass read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TempProductClass(
      id: fields[0] as int?,
      name: fields[1] as String,
      brand: fields[3] as String?,
      category: fields[5] as String?,
      barcode: fields[6] as String?,
      unit: fields[7] as String,
      isRefundable: fields[8] as bool,
      color: fields[9] as String?,
      sizeType: fields[10] as String?,
      size: fields[11] as String?,
      costPrice: fields[12] as double,
      sellingPrice: fields[13] as double?,
      discount: fields[14] as double?,
      startDate: fields[15] as DateTime?,
      endDate: fields[16] as DateTime?,
      quantity: fields[17] as double?,
      shopId: fields[2] as int,
      createdAt: fields[4] as DateTime?,
      setCustomPrice: fields[18] as bool,
      departmentName: fields[19] as String?,
      departmentId: fields[20] as int?,
      lowQtty: fields[21] as double?,
      expiryDate: fields[22] as DateTime?,
      isManaged: fields[23] as bool,
      updatedAt: fields[24] as DateTime?,
      uuid: fields[25] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TempProductClass obj) {
    writer
      ..writeByte(26)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.shopId)
      ..writeByte(3)
      ..write(obj.brand)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.category)
      ..writeByte(6)
      ..write(obj.barcode)
      ..writeByte(7)
      ..write(obj.unit)
      ..writeByte(8)
      ..write(obj.isRefundable)
      ..writeByte(9)
      ..write(obj.color)
      ..writeByte(10)
      ..write(obj.sizeType)
      ..writeByte(11)
      ..write(obj.size)
      ..writeByte(12)
      ..write(obj.costPrice)
      ..writeByte(13)
      ..write(obj.sellingPrice)
      ..writeByte(14)
      ..write(obj.discount)
      ..writeByte(15)
      ..write(obj.startDate)
      ..writeByte(16)
      ..write(obj.endDate)
      ..writeByte(17)
      ..write(obj.quantity)
      ..writeByte(18)
      ..write(obj.setCustomPrice)
      ..writeByte(19)
      ..write(obj.departmentName)
      ..writeByte(20)
      ..write(obj.departmentId)
      ..writeByte(21)
      ..write(obj.lowQtty)
      ..writeByte(22)
      ..write(obj.expiryDate)
      ..writeByte(23)
      ..write(obj.isManaged)
      ..writeByte(24)
      ..write(obj.updatedAt)
      ..writeByte(25)
      ..write(obj.uuid);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TempProductClassAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
