// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deleted_invoices.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DeletedInvoicesAdapter extends TypeAdapter<DeletedInvoices> {
  @override
  final int typeId = 45;

  @override
  DeletedInvoices read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DeletedInvoices(
      invoiceUuid: fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DeletedInvoices obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.invoiceUuid);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeletedInvoicesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
