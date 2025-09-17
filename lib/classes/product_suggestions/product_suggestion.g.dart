// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_suggestion.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductSuggestionAdapter extends TypeAdapter<ProductSuggestion> {
  @override
  final int typeId = 8;

  @override
  ProductSuggestion read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductSuggestion(
      id: fields[0] as int?,
      createdAt: fields[1] as DateTime,
      name: fields[2] as String?,
      costPrice: fields[3] as double?,
      shopId: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ProductSuggestion obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.createdAt)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.costPrice)
      ..writeByte(4)
      ..write(obj.shopId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductSuggestionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
