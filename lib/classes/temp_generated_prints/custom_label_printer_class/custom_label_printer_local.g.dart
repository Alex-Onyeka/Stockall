// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_label_printer_local.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomLabelPrinterLocalAdapter
    extends TypeAdapter<CustomLabelPrinterLocal> {
  @override
  final int typeId = 145;

  @override
  CustomLabelPrinterLocal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomLabelPrinterLocal(
      printer: fields[0] as TempBarcodePrinterClass,
      settings: fields[1] as CustomLabelPrinterSettings,
    );
  }

  @override
  void write(BinaryWriter writer, CustomLabelPrinterLocal obj) {
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
      other is CustomLabelPrinterLocalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
