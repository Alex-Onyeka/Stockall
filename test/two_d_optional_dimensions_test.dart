import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';
import 'package:stockall/classes/temp_purchase/purchase_list_item/purchase_list_item.dart';
import 'package:stockall/classes/temp_item_purchase_record/temp_item_purchase_record.dart';
import 'package:stockall/classes/temp_storage_product/temp_storage_products.dart';

void main() {
  group('2D item optional dimensions tests', () {
    final areaUnit = ProductUnitsClass(
      uuid: 'unit-sqm',
      staffUuid: null,
      createdAt: DateTime.utc(2026),
      staffName: null,
      conversion: 1,
      name: 'Square Meter',
      isPrimary: true,
      productUuid: 'item-no-dims',
      dimensionType: ProductUnitsClass.areaUnit,
    );

    final sheetUnit = ProductUnitsClass(
      uuid: 'unit-sheet',
      staffUuid: null,
      createdAt: DateTime.utc(2026),
      staffName: null,
      conversion: 1,
      name: 'Sheet',
      isPrimary: false,
      productUuid: 'item-no-dims',
      dimensionType: ProductUnitsClass.sheetUnit,
    );

    TempProductClass productWithoutDimensions() {
      return TempProductClass(
        uuid: 'item-no-dims',
        name: 'Glass Sheet Area Only',
        shopId: 1,
        unit: 'Square Meter',
        quantityType: 2,
        widthDimension: null,
        heightDimension: null,
        dimensionUnit: 'm',
        dimensionUnitConversion: 1,
        quantity: 50, // 50 square meters
        isManaged: true,
        isRefundable: false,
        costPrice: 50.0,
        setCustomPrice: false,
        departmentName: 'General',
        departmentUuid: 'dept-1',
        groupUnit: 'box',
        qttyPerGroup: 1.0,
        wholeSalePrice: 60.0,
        storageUuid: 'storage-1',
        categories: [],
        useGroupUnit: false,
        pricesList: [],
        manageSalesWastage: false,
        unitsList: [areaUnit, sheetUnit],
      );
    }

    TempProductClass productWithDimensions() {
      return TempProductClass(
        uuid: 'item-with-dims',
        name: 'Standard Marble Slab',
        shopId: 1,
        unit: 'Square Meter',
        quantityType: 2,
        widthDimension: 3,
        heightDimension: 2,
        dimensionUnit: 'm',
        dimensionUnitConversion: 1,
        quantity: 60, // 60 square meters
        isManaged: true,
        isRefundable: false,
        costPrice: 50.0,
        setCustomPrice: false,
        departmentName: 'General',
        departmentUuid: 'dept-1',
        groupUnit: 'box',
        qttyPerGroup: 1.0,
        wholeSalePrice: 60.0,
        storageUuid: 'storage-1',
        categories: [],
        useGroupUnit: false,
        pricesList: [],
        manageSalesWastage: false,
        unitsList: [areaUnit, sheetUnit],
      );
    }

    test('item without dimensions has hasDimensions = false and dimensionArea = 1.0', () {
      final item = productWithoutDimensions();
      expect(item.hasDimensions, isFalse);
      expect(item.dimensionArea(), 1.0);
    });

    test('item with dimensions has hasDimensions = true and dimensionArea calculated', () {
      final item = productWithDimensions();
      expect(item.hasDimensions, isTrue);
      expect(item.dimensionArea(), 6.0); // 3 * 2 / 1 = 6.0
    });

    test('storage item without dimensions has hasDimensions = false and dimensionArea = 1.0', () {
      final storage = TempStorageProducts(
        uuid: 'storage-1',
        name: 'Storage 2D',
        shopId: 1,
        quantityType: 2,
        widthDimension: null,
        heightDimension: null,
        quantity: 100,
        costPrice: 50.0,
        sellingPrice: 60.0,
        useGroupUnit: false,
        unitsList: [],
      );
      expect(storage.hasDimensions, isFalse);
      expect(storage.dimensionArea(), 1.0);
    });

    test('operating in square meters (area unit) does not require dimensions', () {
      final item = productWithoutDimensions();

      // Calculate quantity equiv in area unit (e.g. 5 sq.m)
      final equiv = areaUnit.getQuantityEquivMultiplied(
        index: 1,
        product: item,
        newQuantity: 5,
        customWidth: null,
        customHeight: null,
      );
      expect(equiv, 5.0);

      // Area unit quantity divided
      final divided = areaUnit.getQuantityEquivDivided(
        index: 1,
        product: item,
        newQuantity: 10,
      );
      expect(divided, 10.0);
    });

    test('item with cm dimension unit (conv 10000) and meter square base unit preserves exact area quantity', () {
      // Replicates user scenario: dimensions empty, dim unit cm (conv 10000), base unit "meters square"
      final cmAreaUnit = ProductUnitsClass(
        uuid: 'unit-cm-sqm',
        staffUuid: null,
        createdAt: DateTime.utc(2026),
        staffName: null,
        conversion: 1,
        name: 'meters square',
        isPrimary: true,
        productUuid: 'item-cm-sqm',
      );

      final item = TempProductClass(
        uuid: 'item-cm-sqm',
        name: 'Marble Slab Area',
        shopId: 1,
        unit: 'meters square',
        quantityType: 2,
        widthDimension: null,
        heightDimension: null,
        dimensionUnit: 'Centimeter(s)',
        dimensionUnitConversion: 10000,
        quantity: 0,
        isManaged: true,
        isRefundable: false,
        costPrice: 50.0,
        setCustomPrice: false,
        departmentName: 'General',
        departmentUuid: 'dept-1',
        groupUnit: 'box',
        qttyPerGroup: 1.0,
        wholeSalePrice: 60.0,
        storageUuid: 'storage-1',
        categories: [],
        useGroupUnit: false,
        pricesList: [],
        manageSalesWastage: false,
        unitsList: [cmAreaUnit],
      );

      // Verify that "meters square" is recognized as an area unit
      expect(cmAreaUnit.isAreaUnit, isTrue);

      // Entering 5 in quantity without dimensions MUST return 5.0 (NOT 0.0005)
      final equiv = cmAreaUnit.getQuantityEquivMultiplied(
        index: 1,
        product: item,
        newQuantity: 5,
        customWidth: null,
        customHeight: null,
      );
      expect(equiv, 5.0);

      // 2D product with only area unit automatically makes a Sheet unit available
      final units = item.getUnitsList();
      expect(units.any((u) => u.name == 'Sheet' && !u.isAreaUnit), isTrue);
    });

    test('operating in sheet unit for item without preset dimensions uses custom dimensions', () {
      final item = productWithoutDimensions();

      // 2 sheets of custom 2.5m x 2.0m = 2 * 5.0 = 10.0 sq.m
      final equiv = sheetUnit.getQuantityEquivMultiplied(
        index: 1,
        product: item,
        newQuantity: 2,
        customWidth: 2.5,
        customHeight: 2.0,
      );
      expect(equiv, 10.0);
    });

    test('purchase item retains custom dimensions and converts to purchase record', () {
      final purchaseItem = PurchaseListItem(
        itemName: 'Glass Sheet Area Only',
        itemUuid: 'item-no-dims',
        storageItemUuid: null,
        totalPrice: 20000,
        quantity: 2,
        unit: 'Sheet',
        customPrice: null,
        originalPrice: 1000,
        isGroup: false,
        qttyPerGroup: null,
        unitsList: [areaUnit, sheetUnit],
        unitUuid: sheetUnit.uuid,
        widthDimension: 2.5,
        heightDimension: 2.0,
      );

      expect(purchaseItem.widthDimension, 2.5);
      expect(purchaseItem.heightDimension, 2.0);

      // Convert to TempItemPurchaseRecord
      final record = TempItemPurchaseRecord(
        createdAt: DateTime.now(),
        shopId: 1,
        staffId: 'staff-1',
        itemName: purchaseItem.itemName,
        itemId: purchaseItem.itemUuid,
        storageItemId: purchaseItem.storageItemUuid,
        quantity: purchaseItem.quantity,
        total: purchaseItem.totalPrice,
        unit: purchaseItem.unit,
        unitUuid: purchaseItem.unitUuid,
        unitsList: purchaseItem.unitsList,
        originalPrice: purchaseItem.originalPrice,
        customPrice: purchaseItem.customPrice,
        isGroup: purchaseItem.isGroup,
        qttyPerGroup: purchaseItem.qttyPerGroup,
        widthDimension: purchaseItem.widthDimension,
        heightDimension: purchaseItem.heightDimension,
      );

      expect(record.widthDimension, 2.5);
      expect(record.heightDimension, 2.0);

      // JSON serialization round-trip
      final json = record.toJson();
      expect(json['width_dimension'], 2.5);
      expect(json['height_dimension'], 2.0);

      final fromJson = TempItemPurchaseRecord.fromJson(json);
      expect(fromJson.widthDimension, 2.5);
      expect(fromJson.heightDimension, 2.0);
    });

    test('2D item without dimensions with Centimeters conversion (10000) does not divide by 10000 in getActualQuantity', () {
      final cmAreaUnit = ProductUnitsClass(
        uuid: 'unit-sqm-cm',
        staffUuid: null,
        createdAt: DateTime.utc(2026),
        staffName: null,
        conversion: 1,
        name: 'm²',
        isPrimary: true,
        productUuid: 'item-cm-no-dims',
        dimensionType: ProductUnitsClass.areaUnit,
      );

      final cmSlabUnit = ProductUnitsClass(
        uuid: 'unit-slabs-cm',
        staffUuid: null,
        createdAt: DateTime.utc(2026),
        staffName: null,
        conversion: 1,
        name: 'Slabs',
        isPrimary: false,
        productUuid: 'item-cm-no-dims',
        dimensionType: ProductUnitsClass.sheetUnit,
      );

      final item = TempProductClass(
        uuid: 'item-cm-no-dims',
        name: 'Marble Slab CM No Dims',
        shopId: 1,
        unit: 'm²',
        quantityType: 2,
        widthDimension: null,
        heightDimension: null,
        dimensionUnit: 'cm',
        dimensionUnitConversion: 10000, // Centimeters conversion factor!
        quantity: 5, // 5 square meters
        isManaged: true,
        isRefundable: false,
        costPrice: 50.0,
        setCustomPrice: false,
        departmentName: 'General',
        departmentUuid: 'dept-1',
        groupUnit: null,
        qttyPerGroup: null,
        wholeSalePrice: 60.0,
        storageUuid: 'storage-1',
        categories: [],
        useGroupUnit: false,
        pricesList: [],
        manageSalesWastage: false,
        unitsList: [cmAreaUnit, cmSlabUnit],
      );

      // getActualQuantity should return 5.0, NOT 5 * (1 * 1 / 10000) = 0.0005
      expect(item.getActualQuantity(), 5.0);

      // Unit conversions for display (divided):
      // Area unit displays 5.0 m²
      expect(
        cmAreaUnit.getQuantityEquivDivided(product: item, index: 1),
        5.0,
      );
      // Whole unit (Slabs) displays 0 because dimensions are not set!
      expect(
        cmSlabUnit.getQuantityEquivDivided(product: item, index: 1),
        0.0,
      );
    });

    test('isAreaUnitName recognizes all squared unit names with superscript 2', () {
      expect(ProductUnitsClass.isAreaUnitName('M²(s)'), isTrue);
      expect(ProductUnitsClass.isAreaUnitName('Cm²(s)'), isTrue);
      expect(ProductUnitsClass.isAreaUnitName('Mm²(s)'), isTrue);
      expect(ProductUnitsClass.isAreaUnitName('Km²(s)'), isTrue);
      expect(ProductUnitsClass.isAreaUnitName('Foot²(s)'), isTrue);
      expect(ProductUnitsClass.isAreaUnitName('Inch²(s)'), isTrue);
      expect(ProductUnitsClass.isAreaUnitName('Yard²(s)'), isTrue);
      expect(ProductUnitsClass.isAreaUnitName('Mile²(s)'), isTrue);
      expect(ProductUnitsClass.isAreaUnitName('m²'), isTrue);
      expect(ProductUnitsClass.isAreaUnitName('M^2'), isTrue);
      expect(ProductUnitsClass.isAreaUnitName('Square Meter'), isTrue);
      expect(ProductUnitsClass.isAreaUnitName('Slab'), isFalse);
      expect(ProductUnitsClass.isAreaUnitName('Sheet(s)'), isFalse);
    });
  });
}
