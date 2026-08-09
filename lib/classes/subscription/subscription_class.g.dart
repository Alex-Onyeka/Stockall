// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_class.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SubscriptionClassAdapter extends TypeAdapter<SubscriptionClass> {
  @override
  final int typeId = 31;

  @override
  SubscriptionClass read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SubscriptionClass(
      subscriptionId: fields[0] as String?,
      createdAt: fields[1] as DateTime?,
      userId: fields[2] as String?,
      nextPayment: fields[3] as DateTime?,
      plan: fields[4] as int?,
      lastPayment: fields[5] as DateTime?,
      userName: fields[6] as String?,
      amount: fields[7] as double?,
      email: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SubscriptionClass obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.subscriptionId)
      ..writeByte(1)
      ..write(obj.createdAt)
      ..writeByte(2)
      ..write(obj.userId)
      ..writeByte(3)
      ..write(obj.nextPayment)
      ..writeByte(4)
      ..write(obj.plan)
      ..writeByte(5)
      ..write(obj.lastPayment)
      ..writeByte(6)
      ..write(obj.userName)
      ..writeByte(7)
      ..write(obj.amount)
      ..writeByte(8)
      ..write(obj.email);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionClassAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
