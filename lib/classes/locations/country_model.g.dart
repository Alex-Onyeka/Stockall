// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'country_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CountryModelAdapter extends TypeAdapter<CountryModel> {
  @override
  final int typeId = 91;

  @override
  CountryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CountryModel(
      country: fields[0] as String?,
      countryCode: fields[1] as String?,
      currency: fields[2] as String?,
      currencySymbol: fields[3] as String?,
      currencyName: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CountryModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.country)
      ..writeByte(1)
      ..write(obj.countryCode)
      ..writeByte(2)
      ..write(obj.currency)
      ..writeByte(3)
      ..write(obj.currencySymbol)
      ..writeByte(4)
      ..write(obj.currencyName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CountryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
