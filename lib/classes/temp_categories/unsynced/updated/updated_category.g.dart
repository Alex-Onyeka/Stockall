// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'updated_category.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UpdatedCategoryAdapter extends TypeAdapter<UpdatedCategory> {
  @override
  final int typeId = 64;

  @override
  UpdatedCategory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UpdatedCategory(
      category: fields[0] as CategoryClass,
    );
  }

  @override
  void write(BinaryWriter writer, UpdatedCategory obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.category);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdatedCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
