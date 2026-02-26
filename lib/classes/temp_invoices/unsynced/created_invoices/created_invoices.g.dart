// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'created_invoices.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CreatedInvoicesAdapter extends TypeAdapter<CreatedInvoices> {
  @override
  final int typeId = 44;

  @override
  CreatedInvoices read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CreatedInvoices(
      invoice: fields[0] as TempInvoice,
    );
  }

  @override
  void write(BinaryWriter writer, CreatedInvoices obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.invoice);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreatedInvoicesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
