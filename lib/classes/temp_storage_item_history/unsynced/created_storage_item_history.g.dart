// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'created_storage_item_history.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CreatedStorageItemHistoryAdapter
    extends TypeAdapter<CreatedStorageItemHistory> {
  @override
  final int typeId = 144;

  @override
  CreatedStorageItemHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CreatedStorageItemHistory(
      storageItemHistory: fields[0] as StorageItemHistory,
    );
  }

  @override
  void write(BinaryWriter writer, CreatedStorageItemHistory obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.storageItemHistory);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreatedStorageItemHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
