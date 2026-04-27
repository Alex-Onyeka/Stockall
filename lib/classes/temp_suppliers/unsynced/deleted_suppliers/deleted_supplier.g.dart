// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deleted_supplier.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DeletedSupplierAdapter extends TypeAdapter<DeletedSupplier> {
  @override
  final int typeId = 81;

  @override
  DeletedSupplier read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DeletedSupplier(
      supplierUuid: fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DeletedSupplier obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.supplierUuid);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeletedSupplierAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
