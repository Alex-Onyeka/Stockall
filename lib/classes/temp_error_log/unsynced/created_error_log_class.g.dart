// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'created_error_log_class.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CreatedErrorLogClassAdapter extends TypeAdapter<CreatedErrorLogClass> {
  @override
  final int typeId = 95;

  @override
  CreatedErrorLogClass read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CreatedErrorLogClass(
      errorLog: fields[0] as TempErrorLogClass,
    );
  }

  @override
  void write(BinaryWriter writer, CreatedErrorLogClass obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.errorLog);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreatedErrorLogClassAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
