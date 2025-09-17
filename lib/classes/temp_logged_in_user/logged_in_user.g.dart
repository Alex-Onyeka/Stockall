// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'logged_in_user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LoggedInUserAdapter extends TypeAdapter<LoggedInUser> {
  @override
  final int typeId = 13;

  @override
  LoggedInUser read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LoggedInUser(
      loggedInUser: fields[0] as TempUserClass?,
    );
  }

  @override
  void write(BinaryWriter writer, LoggedInUser obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.loggedInUser);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoggedInUserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
