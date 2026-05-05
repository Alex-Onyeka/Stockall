// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deleted_purchase_payments.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DeletedPurchasePaymentsAdapter
    extends TypeAdapter<DeletedPurchasePayments> {
  @override
  final int typeId = 85;

  @override
  DeletedPurchasePayments read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DeletedPurchasePayments(
      purchasePaymentUuid: fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DeletedPurchasePayments obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.purchasePaymentUuid);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeletedPurchasePaymentsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
