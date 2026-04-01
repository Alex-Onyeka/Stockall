// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'temp_shop_class.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TempShopClassAdapter extends TypeAdapter<TempShopClass> {
  @override
  final int typeId = 7;

  @override
  TempShopClass read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TempShopClass(
      shopId: fields[0] as int?,
      createdAt: fields[1] as DateTime,
      userId: fields[2] as String,
      email: fields[3] as String?,
      name: fields[4] as String,
      state: fields[5] as String?,
      city: fields[7] as String?,
      shopAddress: fields[8] as String?,
      categories: (fields[9] as List?)?.cast<String>(),
      colors: (fields[10] as List?)?.cast<String>(),
      country: fields[6] as String?,
      activeEmployee: fields[12] as String?,
      phoneNumber: fields[11] as String?,
      employees: (fields[13] as List?)?.cast<String>(),
      refCode: fields[14] as String?,
      currency: fields[15] as String,
      updateNumber: fields[16] as int?,
      isVerified: fields[17] as bool,
      printType: fields[18] as int?,
      language: fields[19] as String?,
      updatedAt: fields[20] as DateTime?,
      instaHandle: fields[23] as String?,
      faceBookHandle: fields[24] as String?,
      showEmail: fields[25] as bool?,
      showAddress: fields[27] as bool?,
      showFacebookDown: fields[29] as bool?,
      showInstaDown: fields[28] as bool?,
      showFirst: fields[30] as bool?,
      showSecond: fields[31] as bool?,
      showThird: fields[32] as bool?,
      showPhone: fields[26] as bool?,
      showFacebookTop: fields[34] as bool?,
      showInstaTop: fields[33] as bool?,
      showShopName: fields[36] as bool?,
      bottomText: fields[35] as String?,
      logoUrl: fields[37] as String?,
      imageHeight: fields[38] as int?,
      imageWidth: fields[39] as int?,
      isHeadQuarters: fields[40] as bool?,
      percentDiscount: fields[41] as double?,
      fixedDiscount: fields[42] as double?,
      isAllowedBySubscription: fields[43] as bool?,
      applyVAT: fields[44] as bool?,
      manageInventoryStorage: fields[45] as bool?,
      bulkSale: fields[46] as bool?,
      useGroupUnit: fields[47] as bool?,
      wholeSale: fields[48] as bool?,
      manageDepartments: fields[49] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, TempShopClass obj) {
    writer
      ..writeByte(48)
      ..writeByte(0)
      ..write(obj.shopId)
      ..writeByte(1)
      ..write(obj.createdAt)
      ..writeByte(2)
      ..write(obj.userId)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.name)
      ..writeByte(5)
      ..write(obj.state)
      ..writeByte(6)
      ..write(obj.country)
      ..writeByte(7)
      ..write(obj.city)
      ..writeByte(8)
      ..write(obj.shopAddress)
      ..writeByte(9)
      ..write(obj.categories)
      ..writeByte(10)
      ..write(obj.colors)
      ..writeByte(11)
      ..write(obj.phoneNumber)
      ..writeByte(12)
      ..write(obj.activeEmployee)
      ..writeByte(13)
      ..write(obj.employees)
      ..writeByte(14)
      ..write(obj.refCode)
      ..writeByte(15)
      ..write(obj.currency)
      ..writeByte(16)
      ..write(obj.updateNumber)
      ..writeByte(17)
      ..write(obj.isVerified)
      ..writeByte(18)
      ..write(obj.printType)
      ..writeByte(19)
      ..write(obj.language)
      ..writeByte(20)
      ..write(obj.updatedAt)
      ..writeByte(23)
      ..write(obj.instaHandle)
      ..writeByte(24)
      ..write(obj.faceBookHandle)
      ..writeByte(25)
      ..write(obj.showEmail)
      ..writeByte(26)
      ..write(obj.showPhone)
      ..writeByte(27)
      ..write(obj.showAddress)
      ..writeByte(28)
      ..write(obj.showInstaDown)
      ..writeByte(29)
      ..write(obj.showFacebookDown)
      ..writeByte(30)
      ..write(obj.showFirst)
      ..writeByte(31)
      ..write(obj.showSecond)
      ..writeByte(32)
      ..write(obj.showThird)
      ..writeByte(33)
      ..write(obj.showInstaTop)
      ..writeByte(34)
      ..write(obj.showFacebookTop)
      ..writeByte(35)
      ..write(obj.bottomText)
      ..writeByte(36)
      ..write(obj.showShopName)
      ..writeByte(37)
      ..write(obj.logoUrl)
      ..writeByte(38)
      ..write(obj.imageHeight)
      ..writeByte(39)
      ..write(obj.imageWidth)
      ..writeByte(40)
      ..write(obj.isHeadQuarters)
      ..writeByte(41)
      ..write(obj.percentDiscount)
      ..writeByte(42)
      ..write(obj.fixedDiscount)
      ..writeByte(43)
      ..write(obj.isAllowedBySubscription)
      ..writeByte(44)
      ..write(obj.applyVAT)
      ..writeByte(45)
      ..write(obj.manageInventoryStorage)
      ..writeByte(46)
      ..write(obj.bulkSale)
      ..writeByte(47)
      ..write(obj.useGroupUnit)
      ..writeByte(48)
      ..write(obj.wholeSale)
      ..writeByte(49)
      ..write(obj.manageDepartments);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TempShopClassAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
