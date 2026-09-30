// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_label_printer_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomLabelPrinterSettingsAdapter
    extends TypeAdapter<CustomLabelPrinterSettings> {
  @override
  final int typeId = 146;

  @override
  CustomLabelPrinterSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomLabelPrinterSettings(
      widthMm: fields[0] as double,
      heightMm: fields[1] as double,
      startX: fields[2] as int,
      startY: fields[3] as int,
      labelHeight: fields[4] as int,
      labelScale: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CustomLabelPrinterSettings obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.widthMm)
      ..writeByte(1)
      ..write(obj.heightMm)
      ..writeByte(2)
      ..write(obj.startX)
      ..writeByte(3)
      ..write(obj.startY)
      ..writeByte(4)
      ..write(obj.labelHeight)
      ..writeByte(5)
      ..write(obj.labelScale);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomLabelPrinterSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
