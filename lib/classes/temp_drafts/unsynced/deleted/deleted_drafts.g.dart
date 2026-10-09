// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deleted_drafts.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DeletedDraftsAdapter extends TypeAdapter<DeletedDrafts> {
  @override
  final int typeId = 152;

  @override
  DeletedDrafts read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DeletedDrafts(
      draftUuid: fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DeletedDrafts obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.draftUuid);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeletedDraftsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
