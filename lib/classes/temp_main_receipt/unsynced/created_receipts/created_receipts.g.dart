// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'created_receipts.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CreatedReceiptsAdapter extends TypeAdapter<CreatedReceipts> {
  @override
  final int typeId = 23;

  @override
  CreatedReceipts read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CreatedReceipts(
      receipt: fields[0] as TempMainReceipt,
    );
  }

  @override
  void write(BinaryWriter writer, CreatedReceipts obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.receipt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreatedReceiptsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
