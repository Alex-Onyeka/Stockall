// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receipt_printer_class.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReceiptPrinterClassAdapter extends TypeAdapter<ReceiptPrinterClass> {
  @override
  final int typeId = 93;

  @override
  ReceiptPrinterClass read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReceiptPrinterClass(
      printerName: fields[0] as String,
      printerSize: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ReceiptPrinterClass obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.printerName)
      ..writeByte(1)
      ..write(obj.printerSize);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReceiptPrinterClassAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
