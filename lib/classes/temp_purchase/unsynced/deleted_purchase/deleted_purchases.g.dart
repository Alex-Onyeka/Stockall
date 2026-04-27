// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deleted_purchases.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DeletedPurchasesAdapter extends TypeAdapter<DeletedPurchases> {
  @override
  final int typeId = 75;

  @override
  DeletedPurchases read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DeletedPurchases(
      purchaseUuid: fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DeletedPurchases obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.purchaseUuid);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeletedPurchasesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
