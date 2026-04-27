// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'updated_suppliers.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UpdatedSuppliersAdapter extends TypeAdapter<UpdatedSuppliers> {
  @override
  final int typeId = 82;

  @override
  UpdatedSuppliers read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UpdatedSuppliers(
      suppliers: fields[0] as SuppliersClass,
    );
  }

  @override
  void write(BinaryWriter writer, UpdatedSuppliers obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.suppliers);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdatedSuppliersAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
