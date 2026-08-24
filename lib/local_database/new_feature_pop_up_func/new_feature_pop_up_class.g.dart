// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'new_feature_pop_up_class.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NewFeaturePopUpClassAdapter extends TypeAdapter<NewFeaturePopUpClass> {
  @override
  final int typeId = 132;

  @override
  NewFeaturePopUpClass read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NewFeaturePopUpClass(
      uuid: fields[0] as String,
      oldNewFeatureMobile: fields[1] as String,
      oldNewFeatureDesktop: fields[2] as String,
      numberViewed: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, NewFeaturePopUpClass obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.uuid)
      ..writeByte(1)
      ..write(obj.oldNewFeatureMobile)
      ..writeByte(2)
      ..write(obj.oldNewFeatureDesktop)
      ..writeByte(3)
      ..write(obj.numberViewed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NewFeaturePopUpClassAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
