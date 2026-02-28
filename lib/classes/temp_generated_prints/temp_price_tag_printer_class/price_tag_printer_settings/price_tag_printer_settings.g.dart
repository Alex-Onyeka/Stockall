// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_tag_printer_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PriceTagPrinterSettingsAdapter
    extends TypeAdapter<PriceTagPrinterSettings> {
  @override
  final int typeId = 50;

  @override
  PriceTagPrinterSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PriceTagPrinterSettings(
      gapMm: fields[1] as double,
      startPriceY: fields[4] as int,
      verticalSpacing: fields[3] as int,
      labelWidth: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, PriceTagPrinterSettings obj) {
    writer
      ..writeByte(4)
      ..writeByte(1)
      ..write(obj.gapMm)
      ..writeByte(2)
      ..write(obj.labelWidth)
      ..writeByte(3)
      ..write(obj.verticalSpacing)
      ..writeByte(4)
      ..write(obj.startPriceY);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PriceTagPrinterSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
