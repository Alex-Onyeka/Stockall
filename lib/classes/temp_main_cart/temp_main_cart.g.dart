// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'temp_main_cart.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TempMainCartAdapter extends TypeAdapter<TempMainCart> {
  @override
  final int typeId = 70;

  @override
  TempMainCart read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TempMainCart(
      cartQueue: (fields[0] as List).cast<TempCart>(),
      mainCartId: fields[2] as String?,
      subStaff: fields[1] as TempSubStaff?,
    );
  }

  @override
  void write(BinaryWriter writer, TempMainCart obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.cartQueue)
      ..writeByte(1)
      ..write(obj.subStaff)
      ..writeByte(2)
      ..write(obj.mainCartId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TempMainCartAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
