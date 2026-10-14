// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'temp_product_sale_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TempProductSaleRecordAdapter extends TypeAdapter<TempProductSaleRecord> {
  @override
  final int typeId = 6;

  @override
  TempProductSaleRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TempProductSaleRecord(
      productRecordId: fields[0] as int?,
      createdAt: fields[1] as DateTime,
      productId: fields[2] as int?,
      productName: fields[3] as String,
      shopId: fields[4] as int,
      staffId: fields[5] as String,
      customerId: fields[6] as int?,
      customerName: fields[7] as String?,
      staffName: fields[8] as String?,
      recepitId: fields[9] as int?,
      quantity: fields[11] as double,
      revenue: fields[12] as double,
      discountedAmount: fields[13] as double?,
      originalCost: fields[14] as double?,
      discount: fields[10] as double?,
      costPrice: fields[15] as double?,
      customPriceSet: fields[16] as bool,
      departmentName: fields[17] as String?,
      departmentUuid: fields[18] as String?,
      addToStock: fields[19] as bool?,
      uuid: fields[20] as String?,
      productUuid: fields[21] as String?,
      customerUuid: fields[22] as String?,
      receiptUuid: fields[23] as String?,
      isProductManaged: fields[24] as bool?,
      setTotalPrice: fields[25] as bool?,
      invoiceUuid: fields[26] as String?,
      fixedDiscount: fields[27] as double?,
      unit: fields[28] as String?,
      useWholeSalePrice: fields[29] as bool?,
      useGroupQuantity: fields[30] as bool?,
      qttyPerGroup: fields[31] as double?,
      isVoid: fields[32] as bool?,
      unitsList: (fields[33] as List?)?.cast<ProductUnitsClass>(),
      unitUuid: fields[34] as String?,
      pricesList: (fields[35] as List?)?.cast<ProductPricesClass>(),
      priceUuid: fields[36] as String?,
      widthDimension: fields[37] as double?,
      heightDimension: fields[38] as double?,
      quantityType: fields[39] as int?,
      manageSalesWastage: fields[40] as bool?,
      isPercentageWastage: fields[41] as bool?,
      wastageAmount: fields[42] as double?,
      wastageUnitUuid: fields[43] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TempProductSaleRecord obj) {
    writer
      ..writeByte(44)
      ..writeByte(0)
      ..write(obj.productRecordId)
      ..writeByte(1)
      ..write(obj.createdAt)
      ..writeByte(2)
      ..write(obj.productId)
      ..writeByte(3)
      ..write(obj.productName)
      ..writeByte(4)
      ..write(obj.shopId)
      ..writeByte(5)
      ..write(obj.staffId)
      ..writeByte(6)
      ..write(obj.customerId)
      ..writeByte(7)
      ..write(obj.customerName)
      ..writeByte(8)
      ..write(obj.staffName)
      ..writeByte(9)
      ..write(obj.recepitId)
      ..writeByte(10)
      ..write(obj.discount)
      ..writeByte(11)
      ..write(obj.quantity)
      ..writeByte(12)
      ..write(obj.revenue)
      ..writeByte(13)
      ..write(obj.discountedAmount)
      ..writeByte(14)
      ..write(obj.originalCost)
      ..writeByte(15)
      ..write(obj.costPrice)
      ..writeByte(16)
      ..write(obj.customPriceSet)
      ..writeByte(17)
      ..write(obj.departmentName)
      ..writeByte(18)
      ..write(obj.departmentUuid)
      ..writeByte(19)
      ..write(obj.addToStock)
      ..writeByte(20)
      ..write(obj.uuid)
      ..writeByte(21)
      ..write(obj.productUuid)
      ..writeByte(22)
      ..write(obj.customerUuid)
      ..writeByte(23)
      ..write(obj.receiptUuid)
      ..writeByte(24)
      ..write(obj.isProductManaged)
      ..writeByte(25)
      ..write(obj.setTotalPrice)
      ..writeByte(26)
      ..write(obj.invoiceUuid)
      ..writeByte(27)
      ..write(obj.fixedDiscount)
      ..writeByte(28)
      ..write(obj.unit)
      ..writeByte(29)
      ..write(obj.useWholeSalePrice)
      ..writeByte(30)
      ..write(obj.useGroupQuantity)
      ..writeByte(31)
      ..write(obj.qttyPerGroup)
      ..writeByte(32)
      ..write(obj.isVoid)
      ..writeByte(33)
      ..write(obj.unitsList)
      ..writeByte(34)
      ..write(obj.unitUuid)
      ..writeByte(35)
      ..write(obj.pricesList)
      ..writeByte(36)
      ..write(obj.priceUuid)
      ..writeByte(37)
      ..write(obj.widthDimension)
      ..writeByte(38)
      ..write(obj.heightDimension)
      ..writeByte(39)
      ..write(obj.quantityType)
      ..writeByte(40)
      ..write(obj.manageSalesWastage)
      ..writeByte(41)
      ..write(obj.isPercentageWastage)
      ..writeByte(42)
      ..write(obj.wastageAmount)
      ..writeByte(43)
      ..write(obj.wastageUnitUuid);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TempProductSaleRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
