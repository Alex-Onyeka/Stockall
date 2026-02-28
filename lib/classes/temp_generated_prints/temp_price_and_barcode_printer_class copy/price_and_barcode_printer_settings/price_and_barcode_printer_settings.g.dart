// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_and_barcode_printer_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PriceAndBarcodePrinterSettingsAdapter
    extends TypeAdapter<PriceAndBarcodePrinterSettings> {
  @override
  final int typeId = 55;

  @override
  PriceAndBarcodePrinterSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PriceAndBarcodePrinterSettings(
      widthMm: fields[0] as double,
      heightMm: fields[1] as double,
      gapMm: fields[2] as double,
      startX: fields[3] as int,
      startY: fields[4] as int,
      barcodeHeight: fields[5] as int,
      barcodeScale: fields[6] as int,
      verticalSpacing: fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, PriceAndBarcodePrinterSettings obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.widthMm)
      ..writeByte(1)
      ..write(obj.heightMm)
      ..writeByte(2)
      ..write(obj.gapMm)
      ..writeByte(3)
      ..write(obj.startX)
      ..writeByte(4)
      ..write(obj.startY)
      ..writeByte(5)
      ..write(obj.barcodeHeight)
      ..writeByte(6)
      ..write(obj.barcodeScale)
      ..writeByte(7)
      ..write(obj.verticalSpacing);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PriceAndBarcodePrinterSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
