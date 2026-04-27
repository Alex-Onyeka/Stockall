// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'updated_purchases.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UpdatedPurchasesAdapter extends TypeAdapter<UpdatedPurchases> {
  @override
  final int typeId = 76;

  @override
  UpdatedPurchases read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UpdatedPurchases(
      purchaseUuid: fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, UpdatedPurchases obj) {
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
      other is UpdatedPurchasesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
