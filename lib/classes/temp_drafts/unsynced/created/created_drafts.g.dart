// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'created_drafts.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CreatedDraftsAdapter extends TypeAdapter<CreatedDrafts> {
  @override
  final int typeId = 150;

  @override
  CreatedDrafts read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CreatedDrafts(
      draft: fields[0] as Drafts,
    );
  }

  @override
  void write(BinaryWriter writer, CreatedDrafts obj) {
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
      other is CreatedDraftsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
