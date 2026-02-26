// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'updated_invoices.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UpdatedInvoicesAdapter extends TypeAdapter<UpdatedInvoices> {
  @override
  final int typeId = 11;

  @override
  UpdatedInvoices read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UpdatedInvoices(
      updatedInvoice: fields[0] as TempInvoice,
    );
  }

  @override
  void write(BinaryWriter writer, UpdatedInvoices obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.updatedInvoice);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdatedInvoicesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
