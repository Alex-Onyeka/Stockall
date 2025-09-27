// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'temp_shop_class.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TempShopClassAdapter extends TypeAdapter<TempShopClass> {
  @override
  final int typeId = 7;

  @override
  TempShopClass read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TempShopClass(
      shopId: fields[0] as int?,
      createdAt: fields[1] as DateTime,
      userId: fields[2] as String,
      email: fields[3] as String,
      name: fields[4] as String,
      state: fields[5] as String?,
      city: fields[7] as String?,
      shopAddress: fields[8] as String?,
      categories: (fields[9] as List?)?.cast<String>(),
      colors: (fields[10] as List?)?.cast<String>(),
      country: fields[6] as String?,
      activeEmployee: fields[12] as String?,
      phoneNumber: fields[11] as String?,
      employees: (fields[13] as List?)?.cast<String>(),
      refCode: fields[14] as String?,
      currency: fields[15] as String,
      updateNumber: fields[16] as int?,
      isVerified: fields[17] as bool,
      printType: fields[18] as int?,
      language: fields[19] as String?,
      updatedAt: fields[20] as DateTime?,
      plan: fields[21] as int?,
      nextPayment: fields[22] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, TempShopClass obj) {
    writer
      ..writeByte(23)
      ..writeByte(0)
      ..write(obj.shopId)
      ..writeByte(1)
      ..write(obj.createdAt)
      ..writeByte(2)
      ..write(obj.userId)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.name)
      ..writeByte(5)
      ..write(obj.state)
      ..writeByte(6)
      ..write(obj.country)
      ..writeByte(7)
      ..write(obj.city)
      ..writeByte(8)
      ..write(obj.shopAddress)
      ..writeByte(9)
      ..write(obj.categories)
      ..writeByte(10)
      ..write(obj.colors)
      ..writeByte(11)
      ..write(obj.phoneNumber)
      ..writeByte(12)
      ..write(obj.activeEmployee)
      ..writeByte(13)
      ..write(obj.employees)
      ..writeByte(14)
      ..write(obj.refCode)
      ..writeByte(15)
      ..write(obj.currency)
      ..writeByte(16)
      ..write(obj.updateNumber)
      ..writeByte(17)
      ..write(obj.isVerified)
      ..writeByte(18)
      ..write(obj.printType)
      ..writeByte(19)
      ..write(obj.language)
      ..writeByte(20)
      ..write(obj.updatedAt)
      ..writeByte(21)
      ..write(obj.plan)
      ..writeByte(22)
      ..write(obj.nextPayment);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TempShopClassAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
