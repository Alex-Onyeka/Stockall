// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'created_suppliers.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CreatedSuppliersAdapter extends TypeAdapter<CreatedSuppliers> {
  @override
  final int typeId = 80;

  @override
  CreatedSuppliers read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CreatedSuppliers(
      supplier: fields[0] as SuppliersClass,
    );
  }

  @override
  void write(BinaryWriter writer, CreatedSuppliers obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.supplier);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreatedSuppliersAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
