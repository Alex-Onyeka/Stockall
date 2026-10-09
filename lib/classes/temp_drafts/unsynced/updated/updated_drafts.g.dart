// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'updated_drafts.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UpdatedDraftsAdapter extends TypeAdapter<UpdatedDrafts> {
  @override
  final int typeId = 151;

  @override
  UpdatedDrafts read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UpdatedDrafts(
      draft: fields[0] as Drafts,
    );
  }

  @override
  void write(BinaryWriter writer, UpdatedDrafts obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.draft);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdatedDraftsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
