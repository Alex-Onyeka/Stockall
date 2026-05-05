// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_payments.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PurchasePaymentsAdapter extends TypeAdapter<PurchasePayments> {
  @override
  final int typeId = 83;

  @override
  PurchasePayments read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PurchasePayments(
      uuid: fields[0] as String,
      purchaseId: fields[1] as String,
      createdAt: fields[2] as DateTime,
      amount: fields[3] as double,
      userId: fields[4] as String,
      paymentMethod: fields[5] as String,
      staffName: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PurchasePayments obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.uuid)
      ..writeByte(1)
      ..write(obj.purchaseId)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.userId)
      ..writeByte(5)
      ..write(obj.paymentMethod)
      ..writeByte(6)
      ..write(obj.staffName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PurchasePaymentsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
