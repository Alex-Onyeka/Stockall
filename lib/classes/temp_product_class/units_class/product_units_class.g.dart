// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_units_class.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductUnitsClassAdapter extends TypeAdapter<ProductUnitsClass> {
  @override
  final int typeId = 139;

  @override
  ProductUnitsClass read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductUnitsClass(
      uuid: fields[0] as String,
      staffUuid: fields[3] as String?,
      createdAt: fields[1] as DateTime,
      staffName: fields[2] as String?,
      conversion: fields[4] as double,
      name: fields[5] as String,
      isPrimary: fields[6] as bool,
      productUuid: fields[7] as String,
      dimensionType: fields[8] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, ProductUnitsClass obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.uuid)
      ..writeByte(1)
      ..write(obj.createdAt)
      ..writeByte(2)
      ..write(obj.staffName)
      ..writeByte(3)
      ..write(obj.staffUuid)
      ..writeByte(4)
      ..write(obj.conversion)
      ..writeByte(5)
      ..write(obj.name)
      ..writeByte(6)
      ..write(obj.isPrimary)
      ..writeByte(7)
      ..write(obj.productUuid)
      ..writeByte(8)
      ..write(obj.dimensionType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductUnitsClassAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
