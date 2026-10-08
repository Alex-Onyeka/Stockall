// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PaymentEntryAdapter extends TypeAdapter<PaymentEntry> {
  @override
  final int typeId = 153;

  @override
  PaymentEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PaymentEntry(
      method: fields[0] as String,
      amount: fields[1] as double,
    );
  }

  @override
  void write(BinaryWriter writer, PaymentEntry obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.method)
      ..writeByte(1)
      ..write(obj.amount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
