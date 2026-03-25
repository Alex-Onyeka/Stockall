// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deleted_category.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DeletedCategoryAdapter extends TypeAdapter<DeletedCategory> {
  @override
  final int typeId = 63;

  @override
  DeletedCategory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DeletedCategory(
      categoryUuid: fields[0] as String,
      shopId: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, DeletedCategory obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.categoryUuid)
      ..writeByte(1)
      ..write(obj.shopId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeletedCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
