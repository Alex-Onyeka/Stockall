// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'created_events_log_class.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CreatedEventsLogClassAdapter extends TypeAdapter<CreatedEventsLogClass> {
  @override
  final int typeId = 35;

  @override
  CreatedEventsLogClass read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CreatedEventsLogClass(
      eventLog: fields[0] as TempEventLogClass,
    );
  }

  @override
  void write(BinaryWriter writer, CreatedEventsLogClass obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.eventLog);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreatedEventsLogClassAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
