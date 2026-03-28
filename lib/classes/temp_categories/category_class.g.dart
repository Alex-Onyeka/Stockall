// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_class.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CategoryClassAdapter extends TypeAdapter<CategoryClass> {
  @override
  final int typeId = 61;

  @override
  CategoryClass read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CategoryClass(
      name: fields[3] as String,
      shopId: fields[2] as int,
      uuid: fields[0] as String,
      createdAt: fields[1] as DateTime?,
      updatedAt: fields[4] as DateTime?,
      departmentId: fields[5] as String?,
      departmentName: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CategoryClass obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.uuid)
      ..writeByte(1)
      ..write(obj.createdAt)
      ..writeByte(2)
      ..write(obj.shopId)
      ..writeByte(3)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.updatedAt)
      ..writeByte(5)
      ..write(obj.departmentId)
      ..writeByte(6)
      ..write(obj.departmentName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryClassAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
