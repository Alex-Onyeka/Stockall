// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'barcode_printer_local.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BarcodePrinterLocalAdapter extends TypeAdapter<BarcodePrinterLocal> {
  @override
  final int typeId = 36;

  @override
  BarcodePrinterLocal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BarcodePrinterLocal(
      printer: fields[0] as TempBarcodePrinterClass,
      settings: fields[1] as PrinterSettings,
    );
  }

  @override
  void write(BinaryWriter writer, BarcodePrinterLocal obj) {
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
      other is BarcodePrinterLocalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
