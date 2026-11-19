// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'utility_constants.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UtilityConstantsAdapter extends TypeAdapter<UtilityConstants> {
  @override
  final int typeId = 90;

  @override
  UtilityConstants read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UtilityConstants(
      uuid: fields[0] as String,
      dollarRate: fields[1] as double,
      basicPlan: fields[2] as double,
      standardPlan: fields[3] as double,
      premiumPlan: fields[4] as double,
      silverPlan: fields[5] as double,
      goldPlan: fields[6] as double,
      sixMonthsDiscount: fields[7] as double,
      oneYearDiscount: fields[8] as double,
      vat: fields[9] as double,
      desktopDownloadLink: fields[10] == null ? '' : fields[10] as String,
      isCompulsory: fields[11] == null ? false : fields[11] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, UtilityConstants obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.uuid)
      ..writeByte(1)
      ..write(obj.dollarRate)
      ..writeByte(2)
      ..write(obj.basicPlan)
      ..writeByte(3)
      ..write(obj.standardPlan)
      ..writeByte(4)
      ..write(obj.premiumPlan)
      ..writeByte(5)
      ..write(obj.silverPlan)
      ..writeByte(6)
      ..write(obj.goldPlan)
      ..writeByte(7)
      ..write(obj.sixMonthsDiscount)
      ..writeByte(8)
      ..write(obj.oneYearDiscount)
      ..writeByte(9)
      ..write(obj.vat)
      ..writeByte(10)
      ..write(obj.desktopDownloadLink)
      ..writeByte(11)
      ..write(obj.isCompulsory);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UtilityConstantsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
