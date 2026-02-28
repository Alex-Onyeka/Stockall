// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_and_barcode_printer_local.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PriceAndBarcodePrinterLocalAdapter
    extends TypeAdapter<PriceAndBarcodePrinterLocal> {
  @override
  final int typeId = 54;

  @override
  PriceAndBarcodePrinterLocal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PriceAndBarcodePrinterLocal(
      printer: fields[0] as TempBarcodePrinterClass,
      settings: fields[1] as PriceAndBarcodePrinterSettings,
    );
  }

  @override
  void write(BinaryWriter writer, PriceAndBarcodePrinterLocal obj) {
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
      other is PriceAndBarcodePrinterLocalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
