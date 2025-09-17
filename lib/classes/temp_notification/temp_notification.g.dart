// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'temp_notification.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TempNotificationAdapter extends TypeAdapter<TempNotification> {
  @override
  final int typeId = 4;

  @override
  TempNotification read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TempNotification(
      id: fields[0] as int?,
      shopId: fields[2] as int,
      notifId: fields[1] as String,
      productId: fields[3] as int?,
      expenseId: fields[5] as int?,
      title: fields[6] as String,
      text: fields[7] as String,
      date: fields[8] as DateTime,
      isViewed: fields[10] as bool,
      category: fields[9] as String,
      itemName: fields[4] as String?,
      departmentName: fields[11] as String?,
      departmentId: fields[12] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, TempNotification obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.notifId)
      ..writeByte(2)
      ..write(obj.shopId)
      ..writeByte(3)
      ..write(obj.productId)
      ..writeByte(4)
      ..write(obj.itemName)
      ..writeByte(5)
      ..write(obj.expenseId)
      ..writeByte(6)
      ..write(obj.title)
      ..writeByte(7)
      ..write(obj.text)
      ..writeByte(8)
      ..write(obj.date)
      ..writeByte(9)
      ..write(obj.category)
      ..writeByte(10)
      ..write(obj.isViewed)
      ..writeByte(11)
      ..write(obj.departmentName)
      ..writeByte(12)
      ..write(obj.departmentId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TempNotificationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
