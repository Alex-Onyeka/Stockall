// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_method.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PaymentMethodAdapter extends TypeAdapter<PaymentMethod> {
  @override
  final int typeId = 154;

  @override
  PaymentMethod read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PaymentMethod(
      uuid: fields[0] as String?,
      bankName: fields[1] as String,
      accountNumber: fields[2] as String?,
      accountName: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PaymentMethod obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.uuid)
      ..writeByte(1)
      ..write(obj.bankName)
      ..writeByte(2)
      ..write(obj.accountNumber)
      ..writeByte(3)
      ..write(obj.accountName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentMethodAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
