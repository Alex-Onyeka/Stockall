// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'created_purchases.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CreatedPurchasesAdapter extends TypeAdapter<CreatedPurchases> {
  @override
  final int typeId = 74;

  @override
  CreatedPurchases read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CreatedPurchases(
      purchase: fields[0] as TempPurchase,
    );
  }

  @override
  void write(BinaryWriter writer, CreatedPurchases obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.purchase);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreatedPurchasesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
