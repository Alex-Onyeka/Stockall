// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_tag_printer_local.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PriceTagPrinterLocalAdapter extends TypeAdapter<PriceTagPrinterLocal> {
  @override
  final int typeId = 51;

  @override
  PriceTagPrinterLocal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PriceTagPrinterLocal(
      printer: fields[0] as TempBarcodePrinterClass,
      settings: fields[1] as PriceTagPrinterSettings,
    );
  }

  @override
  void write(BinaryWriter writer, PriceTagPrinterLocal obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.printer)
      ..writeByte(1)
      ..write(obj.settings);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PriceTagPrinterLocalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
