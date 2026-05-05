// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deleted_waybills.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DeletedWaybillsAdapter extends TypeAdapter<DeletedWaybills> {
  @override
  final int typeId = 88;

  @override
  DeletedWaybills read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DeletedWaybills(
      waybillUuid: fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DeletedWaybills obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.waybillUuid);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeletedWaybillsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
