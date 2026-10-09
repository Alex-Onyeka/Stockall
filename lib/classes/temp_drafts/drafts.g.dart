// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drafts.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DraftsAdapter extends TypeAdapter<Drafts> {
  @override
  final int typeId = 149;

  @override
  Drafts read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Drafts(
      uuid: fields[0] as String?,
      createdAt: fields[1] as DateTime,
      updatedAt: fields[2] as DateTime?,
      shopId: fields[3] as int,
      staffId: fields[4] as String?,
      staffName: fields[5] as String?,
      subStaffUuid: fields[6] as String?,
      subStaffName: fields[7] as String?,
      customerUuid: fields[8] as String?,
      customerName: fields[9] as String?,
      departmentUuid: fields[10] as String?,
      departmentName: fields[11] as String?,
      cartName: fields[12] as String?,
      comment: fields[13] as String?,
      generalDiscount: fields[14] as double?,
      fixedDiscount: fields[15] as double?,
      total: fields[16] as double?,
      draftItems: (fields[17] as List).cast<DraftItems>(),
    );
  }

  @override
  void write(BinaryWriter writer, Drafts obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.uuid)
      ..writeByte(1)
      ..write(obj.createdAt)
      ..writeByte(2)
      ..write(obj.updatedAt)
      ..writeByte(3)
      ..write(obj.shopId)
      ..writeByte(4)
      ..write(obj.staffId)
      ..writeByte(5)
      ..write(obj.staffName)
      ..writeByte(6)
      ..write(obj.subStaffUuid)
      ..writeByte(7)
      ..write(obj.subStaffName)
      ..writeByte(8)
      ..write(obj.customerUuid)
      ..writeByte(9)
      ..write(obj.customerName)
      ..writeByte(10)
      ..write(obj.departmentUuid)
      ..writeByte(11)
      ..write(obj.departmentName)
      ..writeByte(12)
      ..write(obj.cartName)
      ..writeByte(13)
      ..write(obj.comment)
      ..writeByte(14)
      ..write(obj.generalDiscount)
      ..writeByte(15)
      ..write(obj.fixedDiscount)
      ..writeByte(16)
      ..write(obj.total)
      ..writeByte(17)
      ..write(obj.draftItems);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DraftsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
