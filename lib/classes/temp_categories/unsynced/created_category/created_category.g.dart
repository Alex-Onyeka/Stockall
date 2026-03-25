// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'created_category.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CreatedCategoryAdapter extends TypeAdapter<CreatedCategory> {
  @override
  final int typeId = 62;

  @override
  CreatedCategory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CreatedCategory(
      category: fields[0] as CategoryClass,
    );
  }

  @override
  void write(BinaryWriter writer, CreatedCategory obj) {
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
      other is CreatedCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
