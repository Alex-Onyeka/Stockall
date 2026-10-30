import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_item_history/item_history.dart';
import 'package:stockall/classes/temp_storage_item_history/storage_item_history.dart';
import 'package:stockall/classes/temp_product_class/prices_class/product_prices_class.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';
import 'package:stockall/classes/temp_storage_product/temp_storage_products.dart';
import 'package:stockall/classes/temp_cart_items/temp_cart_item.dart';
import 'package:stockall/classes/temp_product_slaes_record/temp_product_sale_record.dart';
import 'package:stockall/classes/temp_orders/order_items.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/pages/products/add_product_one/platforms/components/dimension_unit_dialog.dart';
import 'package:stockall/pages/report/items_report_/item_history_report/class/item_history_report_logic.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_item_history_report/class/storage_item_history_report_logic.dart';

ProductUnitsClass dummyUnit(
  String name, {
  int? dimensionType = ProductUnitsClass.sheetUnit,
}) {
  return ProductUnitsClass(
    uuid: 'u-1',
    staffUuid: null,
    createdAt: DateTime.utc(2026),
    staffName: null,
    conversion: 1,
    name: name,
    isPrimary: true,
    productUuid: 'p-1',
    dimensionType: dimensionType,
  );
}

ProductPricesClass dummyPrice() {
  return ProductPricesClass(
    uuid: 'pr-1',
    staffUuid: null,
    createdAt: DateTime.utc(2026),
    staffName: null,
    priceValue: 150,
    name: 'Retail',
    isPrimary: true,
    itemUuid: 'p-1',
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('2D Dimension Unit Management', () {
    test(
      'TempProductClass supports dimensionUnit and dimensionUnitConversion',
      () {
        final product = TempProductClass(
          id: 1,
          name: 'Window Glass',
          unit: 'M²(s)',
          isRefundable: false,
          costPrice: 100,
          sellingPrice: 150,
          shopId: 1,
          quantity: 5,
          setCustomPrice: false,
          departmentName: null,
          departmentUuid: null,
          isManaged: true,
          groupUnit: 'None',
          qttyPerGroup: 1,
          wholeSalePrice: 120,
          storageUuid: null,
          categories: [],
          useGroupUnit: false,
          unitsList: [dummyUnit('M²(s)')],
          pricesList: [dummyPrice()],
          widthDimension: 100,
          heightDimension: 200,
          quantityType: 2,
          manageSalesWastage: false,
          dimensionUnit: 'Centimeter(s)',
          dimensionUnitConversion: 10000.0,
        );

        expect(product.dimensionUnit, 'Centimeter(s)');
        expect(product.dimensionUnitConversion, 10000.0);
        expect(product.widthDimension, 100);
        expect(product.heightDimension, 200);

        // Area conversion: 100cm * 200cm = 20,000cm^2 / 10,000 = 2.0 m^2 per sheet
        expect(product.dimensionArea(), 2.0);

        // Actual quantity: 5 sheets * 2.0 m^2 = 10.0 m^2
        expect(product.getActualQuantity(), 10.0);

        // copyWith
        final copied = product.copyWith(
          dimensionUnit: 'Meter(s)',
          dimensionUnitConversion: 1.0,
        );
        expect(copied.dimensionUnit, 'Meter(s)');
        expect(copied.dimensionUnitConversion, 1.0);
        expect(product.dimensionUnit, 'Centimeter(s)');

        // toJson / fromJson
        final json = product.toJson(
          isIncludeQuantity: true,
        );
        expect(json['dimension_unit'], 'Centimeter(s)');
        expect(json['dimension_unit_conversion'], 10000.0);

        final restored = TempProductClass.fromJson(json);
        expect(restored.dimensionUnit, 'Centimeter(s)');
        expect(restored.dimensionUnitConversion, 10000.0);
        expect(restored.dimensionArea(), 2.0);
      },
    );

    test(
      'TempStorageProducts supports dimensionUnit and dimensionUnitConversion',
      () {
        final storageProduct = TempStorageProducts(
          shopId: 1,
          name: 'Glass Sheet in Storage',
          costPrice: 50,
          sellingPrice: 80,
          quantity: 10,
          useGroupUnit: false,
          unitsList: [dummyUnit('M²(s)')],
          quantityType: 2,
          widthDimension: 100,
          heightDimension: 200,
          dimensionUnit: 'Centimeter(s)',
          dimensionUnitConversion: 10000.0,
        );

        expect(
          storageProduct.dimensionUnit,
          'Centimeter(s)',
        );
        expect(
          storageProduct.dimensionUnitConversion,
          10000.0,
        );
        // 100 * 200 / 10,000 = 2.0 m^2 per sheet
        expect(storageProduct.dimensionArea(), 2.0);
        // 10 sheets * 2.0 = 20.0 m^2
        expect(storageProduct.getActualQuantity(), 20.0);

        // copyWith
        final copied = storageProduct.copyWith(
          dimensionUnit: 'Millimeter(s)',
          dimensionUnitConversion: 1000000.0,
        );
        expect(copied.dimensionUnit, 'Millimeter(s)');
        expect(copied.dimensionUnitConversion, 1000000.0);

        // replaceWith
        final replacement = storageProduct.copyWith(
          dimensionUnit: 'Inch(es)',
          dimensionUnitConversion: 1550.0,
        );
        storageProduct.replaceWith(newItem: replacement);
        expect(storageProduct.dimensionUnit, 'Inch(es)');
        expect(
          storageProduct.dimensionUnitConversion,
          1550.0,
        );

        // toJson / fromJson
        final json = storageProduct.toJson();
        expect(json['dimension_unit'], 'Inch(es)');
        expect(json['dimension_unit_conversion'], 1550.0);

        final restored = TempStorageProducts.fromJson(json);
        expect(restored.dimensionUnit, 'Inch(es)');
        expect(restored.dimensionUnitConversion, 1550.0);
      },
    );

    test('DimensionUnitHelper presets and calculations', () {
      // Default / baseUnit = m²:
      expect(
        DimensionUnitHelper.getPresetConversion(
          'Centimeter(s)',
          baseUnit: 'm²',
        ),
        10000.0,
      );
      expect(
        DimensionUnitHelper.getPresetConversion('cm'),
        10000.0,
      );
      expect(
        DimensionUnitHelper.getPresetConversion(
          'Millimeter(s)',
          baseUnit: 'm²',
        ),
        1000000.0,
      );
      expect(
        DimensionUnitHelper.getPresetConversion('mm'),
        1000000.0,
      );
      expect(
        DimensionUnitHelper.getPresetConversion(
          'Meter(s)',
          baseUnit: 'm²',
        ),
        1.0,
      );

      // baseUnit = mm² (User sets mm² as base unit):
      // Dimensions in mm -> 1 mm * 1 mm = 1 mm², conversion factor is 1.0!
      expect(
        DimensionUnitHelper.getPresetConversion(
          'Millimeter(s)',
          baseUnit: 'mm²',
        ),
        1.0,
      );
      expect(
        DimensionUnitHelper.getPresetConversion(
          'mm',
          baseUnit: 'mm²',
        ),
        1.0,
      );
      expect(
        DimensionUnitHelper.getPresetConversion(
          'mm',
          baseUnit: 'sq mm',
        ),
        1.0,
      );
      // Dimensions in cm -> 1 cm * 1 cm = 100 mm², divisor is 0.01
      expect(
        DimensionUnitHelper.getPresetConversion(
          'cm',
          baseUnit: 'mm²',
        ),
        closeTo(0.01, 1e-9),
      );

      // baseUnit = cm²:
      // Dimensions in cm -> 1 cm * 1 cm = 1 cm², conversion factor is 1.0!
      expect(
        DimensionUnitHelper.getPresetConversion(
          'Centimeter(s)',
          baseUnit: 'cm²',
        ),
        1.0,
      );
      expect(
        DimensionUnitHelper.getPresetConversion(
          'cm',
          baseUnit: 'cm²',
        ),
        1.0,
      );
      // Dimensions in mm -> 10 mm * 10 mm = 100 mm² = 1 cm², conversion divisor is 100.0!
      expect(
        DimensionUnitHelper.getPresetConversion(
          'Millimeter(s)',
          baseUnit: 'cm²',
        ),
        100.0,
      );
      expect(
        DimensionUnitHelper.getPresetConversion(
          'mm',
          baseUnit: 'cm²',
        ),
        100.0,
      );

      // Imperial units:
      expect(
        DimensionUnitHelper.getPresetConversion(
          'Inch(es)',
          baseUnit: 'sq ft',
        ),
        144.0,
      );
      expect(
        DimensionUnitHelper.getPresetConversion(
          'Foot(s)',
          baseUnit: 'sq ft',
        ),
        1.0,
      );
      expect(
        DimensionUnitHelper.getPresetConversion(
          'in',
          baseUnit: 'in²',
        ),
        1.0,
      );

      // Sheet / Piece unit (e.g. Slab of 100 x 200 cm):
      expect(
        DimensionUnitHelper.getPresetConversion(
          'cm',
          baseUnit: 'Slab',
          maxWidth: 100,
          maxHeight: 200,
        ),
        20000.0,
      );

      // Explanations:
      expect(
        DimensionUnitHelper.getPresetExplanation(
          'mm',
          1.0,
          baseUnit: 'mm²',
        ),
        '1 mm × 1 mm = 1 mm²',
      );
      expect(
        DimensionUnitHelper.getPresetExplanation(
          'cm',
          10000.0,
          baseUnit: 'm²',
        ),
        '100 cm × 100 cm = 10000 cm² per m²',
      );
      expect(
        DimensionUnitHelper.getPresetExplanation(
          'mm',
          100.0,
          baseUnit: 'cm²',
        ),
        '10 mm × 10 mm = 100 mm² per cm²',
      );
      expect(
        DimensionUnitHelper.getPresetExplanation(
          'cm',
          20000.0,
          baseUnit: 'Slab',
          maxWidth: 100,
          maxHeight: 200,
        ),
        '1 Slab = 100 cm × 200 cm = 20000 cm²',
      );
    });

    test(
      '2D line calculation scales dimensions in cm to base unit area in m²',
      () {
        final product = TempProductClass(
          id: 1,
          name: 'Marble Slab',
          unit: 'M²(s)',
          isRefundable: false,
          costPrice: 100,
          sellingPrice: 150,
          shopId: 1,
          quantity: 10,
          setCustomPrice: false,
          departmentName: null,
          departmentUuid: null,
          isManaged: true,
          groupUnit: 'None',
          qttyPerGroup: 1,
          wholeSalePrice: 120,
          storageUuid: null,
          categories: [],
          useGroupUnit: false,
          unitsList: [
            dummyUnit('M²(s)'),
            ProductUnitsClass(
              uuid: 'u-sheet',
              staffUuid: null,
              createdAt: DateTime.utc(2026),
              staffName: null,
              conversion: 1,
              name: 'Sheet',
              isPrimary: false,
              productUuid: 'p-1',
              dimensionType: ProductUnitsClass.sheetUnit,
            ),
          ],
          pricesList: [dummyPrice()],
          widthDimension: 100,
          heightDimension: 200,
          quantityType: 2,
          manageSalesWastage: false,
          dimensionUnit: 'Centimeter(s)',
          dimensionUnitConversion: 10000.0,
        );

        final sheetUnit = product.unitsList!.firstWhere(
          (u) => u.name == 'Sheet',
        );

        // 1 full sheet (100cm × 200cm) = 20,000 cm² / 10,000 = 2.0 m²
        final fullSheetArea = sheetUnit
            .getQuantityEquivMultiplied(
              index: 1,
              product: product,
              newQuantity: 1,
            );
        expect(fullSheetArea, 2.0);

        // Custom cut: 50cm × 100cm = 5,000 cm² / 10,000 = 0.5 m²
        final customCutArea = sheetUnit
            .getQuantityEquivMultiplied(
              index: 1,
              product: product,
              newQuantity: 1,
              customWidth: 50,
              customHeight: 100,
            );
        expect(customCutArea, 0.5);

        // 3 cuts of 50cm × 100cm = 3 × 0.5 m² = 1.5 m²
        final threeCutsArea = sheetUnit
            .getQuantityEquivMultiplied(
              index: 1,
              product: product,
              newQuantity: 3,
              customWidth: 50,
              customHeight: 100,
            );
        expect(threeCutsArea, 1.5);

        // Single unit (no dimensionType) with custom dimensions
        final baseUnit = product.unitsList!.firstWhere(
          (u) => u.name == 'M²(s)',
        );
        final customBaseArea = baseUnit
            .getQuantityEquivMultiplied(
              index: 1,
              product: product,
              newQuantity: 1,
              customWidth: 50,
              customHeight: 100,
            );
        expect(customBaseArea, 0.5);
      },
    );

    test(
      'formatDimensionsLabel outputs short unit suffix everywhere',
      () {
        // cm
        expect(
          formatDimensionsLabel(
            50,
            50,
            unit: 'Centimeter(s)',
          ),
          ' (50cm x 50cm)',
        );
        expect(
          formatDimensionsLabel(
            50,
            50,
            unit: 'Centimeter(s) (cm)',
          ),
          ' (50cm x 50cm)',
        );
        expect(
          formatDimensionsLabel(50, 50, unit: 'cm'),
          ' (50cm x 50cm)',
        );

        // mm
        expect(
          formatDimensionsLabel(
            500,
            500,
            unit: 'Millimeter(s) (mm)',
          ),
          ' (500mm x 500mm)',
        );
        expect(
          formatDimensionsLabel(500, 500, unit: 'mm'),
          ' (500mm x 500mm)',
        );

        // m
        expect(
          formatDimensionsLabel(2, 3, unit: 'Meter(s) (m)'),
          ' (2m x 3m)',
        );
        expect(
          formatDimensionsLabel(2, 3, unit: 'm'),
          ' (2m x 3m)',
        );

        // in
        expect(
          formatDimensionsLabel(
            24,
            36,
            unit: 'Inch(es) (in)',
          ),
          ' (24in x 36in)',
        );
        expect(
          formatDimensionsLabel(24, 36, unit: 'in'),
          ' (24in x 36in)',
        );

        // ft
        expect(
          formatDimensionsLabel(
            4,
            8,
            unit: 'Foot/Feet (ft)',
          ),
          ' (4ft x 8ft)',
        );
        expect(
          formatDimensionsLabel(4, 8, unit: 'ft'),
          ' (4ft x 8ft)',
        );

        // null or empty unit falls back cleanly to numbers only
        expect(
          formatDimensionsLabel(50, 50, unit: null),
          ' (50 x 50)',
        );
        expect(
          formatDimensionsLabel(50, 50, unit: ''),
          ' (50 x 50)',
        );
        expect(formatDimensionsLabel(null, 50), '');
      },
    );

    test(
      'TempCartItem, TempProductSaleRecord and OrderItems display dimensions with unit suffix',
      () {
        final product = TempProductClass(
          id: 1,
          name: 'Marble Slab',
          unit: 'M²',
          isRefundable: false,
          costPrice: 500,
          sellingPrice: 1000,
          shopId: 1,
          quantity: 10,
          setCustomPrice: false,
          departmentName: null,
          departmentUuid: null,
          isManaged: true,
          groupUnit: 'None',
          qttyPerGroup: 1,
          wholeSalePrice: 800,
          storageUuid: null,
          categories: [],
          useGroupUnit: false,
          unitsList: [dummyUnit('M²')],
          pricesList: [dummyPrice()],
          widthDimension: 100,
          heightDimension: 200,
          quantityType: 2,
          manageSalesWastage: true,
          dimensionUnit: 'Centimeter(s)',
          dimensionUnitConversion: 10000.0,
        );

        final cartItem = TempCartItem(
          item: product,
          itemUuid: 'p-1',
          quantity: 1,
          discount: null,
          addToStock: false,
          setTotalPrice: false,
          useWholeSalePrice: false,
          useGroupQuantity: false,
          qttyPerGroup: null,
          isVoid: false,
          uuid: 'cart-1',
          unitUuid: 'u-1',
          priceUuid: 'pr-1',
          widthDimension: 50,
          heightDimension: 60,
          quantityType: 2,
          manageSalesWastage: true,
          isPercentageWastage: true,
          wastageAmount: 10, // 10%
        );

        // Cart item dimensionsLabel includes dimension unit
        expect(
          cartItem.dimensionsLabel(),
          ' (50cm x 60cm)',
        );

        // Live quantity in base unit (M²): 50cm × 60cm = 3,000 cm² / 10,000 = 0.3 m²
        expect(cartItem.getRealQuantity(), 0.3);

        // 10% wastage = 0.03 m²
        expect(cartItem.wastageArea(), closeTo(0.03, 1e-9));

        // Total quantity in primary unit (base unit + wastage): 0.3 + 0.03 = 0.33 m²
        expect(
          cartItem.getStockQuantity(),
          closeTo(0.33, 1e-9),
        );

        // TempProductSaleRecord retains dimensionUnit and dimensionUnitConversion
        final record = TempProductSaleRecord(
          createdAt: DateTime.utc(2026),
          productId: 1,
          productName: 'Marble Slab',
          shopId: 1,
          staffId: 'staff-1',
          staffName: 'Admin',
          recepitId: 101,
          quantity: 1,
          revenue: 330,
          discountedAmount: 0,
          originalCost: 330,
          discount: null,
          customPriceSet: false,
          departmentName: 'Sales',
          departmentUuid: 'dep-1',
          isProductManaged: true,
          useGroupQuantity: false,
          qttyPerGroup: 1,
          isVoid: false,
          unitsList: [dummyUnit('M²')],
          unitUuid: 'u-1',
          pricesList: [dummyPrice()],
          priceUuid: 'pr-1',
          widthDimension: 50,
          heightDimension: 60,
          quantityType: 2,
          manageSalesWastage: true,
          isPercentageWastage: true,
          wastageAmount: 10,
          dimensionUnit: product.dimensionUnit,
          dimensionUnitConversion:
              product.dimensionUnitConversion,
        );

        // Sale record dimensionsLabel includes dimension unit
        expect(record.dimensionsLabel(), ' (50cm x 60cm)');
        // Dimension area divided by conversion
        expect(record.dimensionArea(), 0.3);

        // OrderItems retains dimensionUnit and dimensionUnitConversion
        final orderItem = OrderItems(
          uuid: 'ord-item-1',
          orderId: '1',
          productName: 'Marble Slab',
          productUuid: 'p-1',
          createdAt: DateTime.utc(2026),
          staffName: 'Admin',
          staffId: 'staff-1',
          costPrice: 500,
          customerName: 'Customer',
          customerUuid: 'c-1',
          departmentName: 'Sales',
          departmentUuid: 'dep-1',
          qttyPerGroup: 1,
          quantity: 1,
          revenue: 330,
          unit: 'M²',
          useGroupQuantity: false,
          useWholeSalePrice: false,
          groupUnit: 'None',
          addToStock: false,
          customPriceSet: false,
          discount: null,
          discountedAmount: null,
          fixedDiscount: null,
          isProductManaged: true,
          originalCost: 330,
          setTotalPrice: false,
          remainingQuantity: 1,
          originalUseGroupQuantity: false,
          tempUseGroupQuantity: false,
          unitsList: [dummyUnit('M²')],
          unitUuid: 'u-1',
          pricesList: [dummyPrice()],
          priceUuid: 'pr-1',
          widthDimension: 50,
          heightDimension: 60,
          quantityType: 2,
          manageSalesWastage: true,
          isPercentageWastage: true,
          wastageAmount: 10,
          dimensionUnit: product.dimensionUnit,
          dimensionUnitConversion:
              product.dimensionUnitConversion,
        );

        // Order item dimensionsLabel includes dimension unit
        expect(
          orderItem.dimensionsLabel(),
          ' (50cm x 60cm)',
        );
        // Dimension area divided by conversion
        expect(orderItem.dimensionArea(), 0.3);
      },
    );

    test(
      'Custom dimension scales quantity as decimal fraction of whole slab (e.g. 1x1 of 1x2 = 0.5 slab)',
      () {
        final slabUnit = ProductUnitsClass(
          uuid: 'u-slab',
          staffUuid: null,
          createdAt: DateTime.utc(2026),
          staffName: null,
          conversion: 1,
          name: 'Slab',
          isPrimary: false,
          productUuid: 'p-slab',
          dimensionType: ProductUnitsClass.sheetUnit,
        );

        final slabProduct = TempProductClass(
          id: 2,
          name: 'Granite Slab',
          unit: 'M²',
          isRefundable: false,
          costPrice: 5000,
          sellingPrice: 10000,
          shopId: 1,
          quantity: 10,
          setCustomPrice: false,
          departmentName: null,
          departmentUuid: null,
          isManaged: true,
          groupUnit: 'None',
          qttyPerGroup: 1,
          wholeSalePrice: 8000,
          storageUuid: null,
          categories: [],
          useGroupUnit: false,
          unitsList: [dummyUnit('M²'), slabUnit],
          pricesList: [dummyPrice()],
          widthDimension: 1, // 1m
          heightDimension: 2, // 2m (whole slab = 2 m²)
          quantityType: 2,
          manageSalesWastage: true,
          dimensionUnit: 'Meter(s)',
          dimensionUnitConversion: 1.0,
        );

        // Whole slab area = 2.0 m²
        expect(slabProduct.dimensionArea(), 2.0);

        // Custom cut: 1 by 1, quantity 1
        final cutLine = TempCartItem(
          item: slabProduct,
          itemUuid: 'p-slab',
          quantity: 1,
          discount: null,
          addToStock: false,
          setTotalPrice: false,
          useWholeSalePrice: false,
          useGroupQuantity: false,
          qttyPerGroup: null,
          isVoid: false,
          uuid: 'cut-1',
          unitUuid: 'u-slab',
          priceUuid: 'pr-1',
          widthDimension: 1,
          heightDimension: 1, // 1x1 cut = 1 m²
          quantityType: 2,
          manageSalesWastage: true,
          isPercentageWastage: false,
          wastageAmount: null,
        );

        // Base cut area = 1.0 m²
        expect(cutLine.getRealQuantity(), 1.0);
        expect(cutLine.getStockQuantity(), 1.0);

        // When custom dimensions are set, display quantity is primary unit equiv (1.0 m²):
        expect(cutLine.displayQuantity(), 1.0);
        expect(cutLine.displayUnitName(), 'M²');
        expect(cutLine.historyQuantityChange(), 0.5);
        expect(cutLine.baseQuantityInSaleUnit(), 0.5);
        expect(cutLine.getSelectedUnit().name, 'Slab');
        expect(cutLine.getUnit().trim(), 'M²');
        expect(cutLine.dimensionsLabel(), ' (1m x 1m)');

        // With 10% wastage:
        final cutWithWastage = cutLine.copyWith(
          isPercentageWastage: true,
          wastageAmount: 10,
        );
        // Cut area = 1.0 m², wastage = 0.1 m², stock quantity = 1.1 m²
        expect(
          cutWithWastage.getStockQuantity(),
          closeTo(1.1, 1e-9),
        );
        // Display quantity is primary unit equiv: 1.1 m²
        expect(
          cutWithWastage.displayQuantity(),
          closeTo(1.1, 1e-9),
        );
        expect(
          cutWithWastage.historyQuantityChange(),
          closeTo(0.55, 1e-9),
        );
        expect(
          cutWithWastage.baseQuantityInSaleUnit(),
          0.5,
        );
        expect(
          cutWithWastage.wastageInSaleUnit(),
          closeTo(0.05, 1e-9),
        );
      },
    );

    test(
      'Editing cart item wastage and dimensions persists fields correctly',
      () {
        final unitSlab = ProductUnitsClass(
          uuid: 'u-slab',
          staffUuid: null,
          createdAt: DateTime.utc(2026),
          staffName: null,
          conversion: 1,
          name: 'Slab',
          isPrimary: true,
          productUuid: 'p-slab',
          dimensionType: ProductUnitsClass.sheetUnit,
        );

        final product = TempProductClass(
          id: 1,
          name: 'Marble Slab',
          unit: 'Slab',
          isRefundable: false,
          costPrice: 50,
          sellingPrice: 100,
          shopId: 1,
          quantity: 10,
          setCustomPrice: false,
          departmentName: null,
          departmentUuid: null,
          isManaged: true,
          groupUnit: 'None',
          qttyPerGroup: 1,
          wholeSalePrice: 80,
          storageUuid: null,
          categories: [],
          useGroupUnit: false,
          unitsList: [unitSlab],
          pricesList: [dummyPrice()],
          widthDimension: 100,
          heightDimension: 200, // 100cm x 200cm = 2.0 m²
          quantityType: 2,
          manageSalesWastage: true,
          dimensionUnit: 'Centimeter(s)',
          dimensionUnitConversion: 10000.0,
        );

        // Initial line: 1 Slab (100cm x 200cm), no wastage
        final initialLine = TempCartItem(
          item: product,
          itemUuid: product.uuid,
          quantity: 1,
          discount: null,
          addToStock: false,
          setTotalPrice: false,
          useWholeSalePrice: false,
          useGroupQuantity: false,
          qttyPerGroup: null,
          isVoid: false,
          uuid: 'cart-line-1',
          unitUuid: 'u-slab',
          priceUuid: 'pr-1',
          widthDimension: 100,
          heightDimension: 200,
          quantityType: 2,
          manageSalesWastage: true,
          isPercentageWastage: false,
          wastageAmount: null,
        );

        expect(initialLine.getStockQuantity(), 2.0);
        expect(initialLine.wastageArea(), 0.0);

        // Simulate previewLine during edit: user changes to 5% wastage
        final editedPreview = initialLine.previewWith(
          quantity: 1,
          unitUuid: 'u-slab',
          priceUuid: 'pr-1',
          units: [unitSlab],
          prices: [dummyPrice()],
          width: 100,
          height: 200,
          customPrice: null,
          setTotalPrice: false,
          wastageAmount: 5.0,
          isPercentageWastage: true,
          wastageUnitUuid: 'u-slab',
        );

        expect(editedPreview.wastageAmount, 5.0);
        expect(editedPreview.isPercentageWastage, true);
        // Base area = 2.0 m², 5% wastage = 0.1 m², stock quantity = 2.1 m²
        expect(editedPreview.getRealQuantity(), 2.0);
        expect(
          editedPreview.wastageArea(),
          closeTo(0.1, 1e-9),
        );
        expect(
          editedPreview.getStockQuantity(),
          closeTo(2.1, 1e-9),
        );

        // Simulate edit save: fields applied to line
        initialLine.quantity = 1;
        initialLine.widthDimension = 100;
        initialLine.heightDimension = 200;
        initialLine.wastageAmount = 5.0;
        initialLine.isPercentageWastage = true;
        initialLine.wastageUnitUuid = 'u-slab';
        initialLine.manageSalesWastage = true;

        expect(initialLine.wastageAmount, 5.0);
        expect(initialLine.isPercentageWastage, true);
        expect(
          initialLine.wastageArea(),
          closeTo(0.1, 1e-9),
        );
        expect(
          initialLine.getStockQuantity(),
          closeTo(2.1, 1e-9),
        );

        // User edits again to clear wastage:
        initialLine.wastageAmount = null;
        expect(initialLine.wastageArea(), 0.0);
        expect(initialLine.getStockQuantity(), 2.0);
      },
    );

    test(
      '1D item sales calculations, stock deductions, and ItemHistory fields',
      () {
        final unitPcs = ProductUnitsClass(
          uuid: 'u-pcs',
          staffUuid: null,
          createdAt: DateTime.utc(2026),
          staffName: null,
          conversion: 1,
          name: 'Pcs',
          isPrimary: true,
          productUuid: 'p-1d',
        );

        final price100 = ProductPricesClass(
          uuid: 'pr-100',
          staffUuid: null,
          createdAt: DateTime.utc(2026),
          staffName: null,
          priceValue: 100,
          name: 'Standard',
          isPrimary: true,
          itemUuid: 'p-1d',
        );

        final product1D = TempProductClass(
          heightDimension: null,
          widthDimension: null,
          id: 10,
          uuid: 'p-1d',
          name: 'Soap Bar',
          unit: 'Pcs',
          isRefundable: false,
          costPrice: 60,
          sellingPrice: 100,
          shopId: 1,
          quantity: 50,
          setCustomPrice: false,
          departmentName: null,
          departmentUuid: null,
          isManaged: true,
          groupUnit: 'None',
          qttyPerGroup: 1,
          wholeSalePrice: 80,
          storageUuid: null,
          categories: [],
          useGroupUnit: false,
          unitsList: [unitPcs],
          pricesList: [price100],
          quantityType: 1, // 1D item
          manageSalesWastage: false,
        );

        expect(product1D.dimensionArea(), 1.0);
        expect(product1D.getActualQuantity(), 50.0);

        // Create cart line for 5 pcs:
        final cartLine = TempCartItem(
          heightDimension: null,
          widthDimension: null,
          isPercentageWastage: null,
          wastageAmount: null,
          item: product1D,
          itemUuid: 'p-1d',
          quantity: 5,
          discount: null,
          addToStock: false,
          setTotalPrice: false,
          useWholeSalePrice: false,
          useGroupQuantity: false,
          qttyPerGroup: null,
          isVoid: false,
          uuid: 'cart-1d-1',
          unitUuid: 'u-pcs',
          priceUuid: 'pr-100',
          quantityType: 1,
          manageSalesWastage: false,
        );

        // Quantity & stock checks
        expect(cartLine.getRealQuantity(), 5.0);
        expect(cartLine.wastageArea(), 0.0);
        expect(cartLine.getStockQuantity(), 5.0);
        expect(cartLine.displayQuantity(), 5.0);
        expect(
          cartLine.dimensionsLabel(),
          '',
        ); // no dimensions for 1D

        // Pricing checks: 5 * 100 = 500
        expect(cartLine.totalCost(), 500.0);
        expect(cartLine.costPrice(), 300.0); // 5 * 60

        // Stock deduction math:
        final remainingStock = product1D
            .quantityAfterRemoving(
              cartLine.getStockQuantity(),
            );
        expect(remainingStock, 45.0);
      },
    );

    test(
      'Sale edit diff correctly handles 1D and 2D stock adjustments and ItemHistory',
      () {
        // 2D Product: 10 Slabs in stock (each slab = 100cm × 200cm = 2.0 m²)
        final slabUnit = ProductUnitsClass(
          uuid: 'u-slab',
          staffUuid: null,
          createdAt: DateTime.utc(2026),
          staffName: null,
          conversion: 1,
          name: 'Slab',
          isPrimary: true,
          productUuid: 'p-marble',
          dimensionType: ProductUnitsClass.sheetUnit,
        );

        final product = TempProductClass(
          id: 1,
          uuid: 'p-marble',
          name: 'Marble Slab',
          unit: 'Slab',
          isRefundable: false,
          costPrice: 50,
          sellingPrice: 100,
          shopId: 1,
          quantity: 10,
          setCustomPrice: false,
          departmentName: null,
          departmentUuid: null,
          isManaged: true,
          groupUnit: 'None',
          qttyPerGroup: 1,
          wholeSalePrice: 80,
          storageUuid: null,
          categories: [],
          useGroupUnit: false,
          unitsList: [slabUnit],
          pricesList: [dummyPrice()],
          widthDimension: 100,
          heightDimension: 200,
          quantityType: 2,
          manageSalesWastage: true,
          dimensionUnit: 'Centimeter(s)',
          dimensionUnitConversion: 10000.0,
        );

        expect(
          product.dimensionArea(),
          2.0,
        ); // 2.0 m² per slab
        expect(
          product.getActualQuantity(),
          20.0,
        ); // 10 slabs * 2.0 = 20.0 m²

        // Original sale: 1 cut of 100×100 (1.0 m² = 0.5 slab)
        final oldLine = TempCartItem(
          item: product,
          itemUuid: product.uuid,
          quantity: 1,
          discount: null,
          addToStock: false,
          setTotalPrice: false,
          useWholeSalePrice: false,
          useGroupQuantity: false,
          qttyPerGroup: null,
          isVoid: false,
          uuid: 'line-1',
          unitUuid: 'u-slab',
          priceUuid: 'pr-1',
          widthDimension: 100,
          heightDimension: 100, // 1 m²
          quantityType: 2,
          manageSalesWastage: true,
          isPercentageWastage: false,
          wastageAmount: null,
        );

        expect(oldLine.getStockQuantity(), 1.0);
        expect(
          oldLine.displayQuantity(),
          1.0,
        ); // primary unit equiv (1.0 m²)
        expect(
          oldLine.historyQuantityChange(),
          0.5,
        ); // 0.5 slab fraction

        // Scenario A: User EDITS sale by increasing to 1 cut of 100×200 (full slab = 2.0 m²)
        final newLineMore = oldLine.copyWith(
          widthDimension: 100,
          heightDimension: 200, // 2.0 m²
        );

        final stockDiffMore =
            newLineMore.getStockQuantity() -
            oldLine.getStockQuantity();
        expect(stockDiffMore, 1.0); // +1.0 m² more deducted
        expect(stockDiffMore > 0, true);

        // Main product stock after removing extra 1.0 m²:
        final newStockCountMore = product
            .quantityAfterRemoving(stockDiffMore);
        expect(
          newStockCountMore,
          9.5,
        ); // was 10 slabs (20 m²), -1 m² = 19 m² / 2 = 9.5 slabs!

        // Scenario B: User EDITS sale by reducing size to 50×100 (0.5 m² = 0.25 slab)
        final newLineLess = oldLine.copyWith(
          widthDimension: 50,
          heightDimension: 100, // 0.5 m²
        );

        final stockDiffLess =
            newLineLess.getStockQuantity() -
            oldLine.getStockQuantity();
        expect(
          stockDiffLess,
          -0.5,
        ); // -0.5 m² returned to stock!
        expect(stockDiffLess < 0, true);

        // Main product stock after returning 0.5 m²:
        final returnArea = stockDiffLess.abs();
        final restoredArea =
            (product.getActualQuantity() ?? 0) + returnArea;
        final newStockCountLess =
            restoredArea / product.dimensionArea();
        expect(
          newStockCountLess,
          10.25,
        ); // 20.5 m² / 2.0 = 10.25 slabs!

        // Scenario C: User EDITS sale by adding 10% wastage to the 100×100 cut:
        final newLineWithWastage = oldLine.copyWith(
          isPercentageWastage: true,
          wastageAmount: 10,
        );
        // Cut is 1.0 m², 10% wastage = 0.1 m², total stock quantity = 1.1 m²
        expect(
          newLineWithWastage.getStockQuantity(),
          closeTo(1.1, 1e-9),
        );
        final stockDiffWastage =
            newLineWithWastage.getStockQuantity() -
            oldLine.getStockQuantity();
        expect(
          stockDiffWastage,
          closeTo(0.1, 1e-9),
        ); // +0.1 m² extra deducted
      },
    );

    test(
      'OrderItems retains dimensionUnit, calculates wastageArea, and formats dimensions label',
      () {
        final orderItem = OrderItems(
          uuid: 'ord-1',
          orderId: 'order-100',
          productName: 'Window Glass',
          productUuid: 'p-glass',
          createdAt: DateTime.utc(2026),
          staffName: 'Sales Staff',
          staffId: 'staff-1',
          costPrice: 40,
          customerName: 'Customer A',
          customerUuid: 'cust-1',
          departmentName: 'Glass Dept',
          departmentUuid: 'dep-1',
          qttyPerGroup: 1,
          quantity: 2,
          revenue: 200,
          unit: 'M²',
          useGroupQuantity: false,
          useWholeSalePrice: false,
          groupUnit: 'None',
          addToStock: false,
          customPriceSet: false,
          discount: null,
          discountedAmount: null,
          fixedDiscount: null,
          isProductManaged: true,
          originalCost: 200,
          setTotalPrice: false,
          remainingQuantity: 2,
          originalUseGroupQuantity: false,
          tempUseGroupQuantity: false,
          unitsList: [dummyUnit('M²')],
          unitUuid: 'u-1',
          pricesList: [dummyPrice()],
          priceUuid: 'pr-1',
          widthDimension: 100,
          heightDimension:
              100, // 100cm x 100cm = 10,000 cm² / 10,000 = 1.0 m²
          quantityType: 2,
          manageSalesWastage: true,
          isPercentageWastage: true,
          wastageAmount: 5, // 5%
          dimensionUnit: 'Centimeter(s)',
          dimensionUnitConversion: 10000.0,
        );

        // Dimension area = 1.0 m²
        expect(orderItem.dimensionArea(), 1.0);
        expect(
          orderItem.dimensionsLabel(),
          ' (100cm x 100cm)',
        );

        // Actual quantity for 2 cuts: 2 * 1.0 * 1.0 = 2.0 m²
        expect(orderItem.getActualQuantity(), 2.0);

        // 5% wastage on 2.0 m² = 0.1 m²
        expect(orderItem.wastageArea(), closeTo(0.1, 1e-9));

        // Total stock quantity to deduct on delivery: 2.0 + 0.1 = 2.1 m²
        expect(
          orderItem.getStockQuantity(),
          closeTo(2.1, 1e-9),
        );

        // Wastage in sale unit & wastage note
        expect(
          orderItem.displayQuantity(),
          closeTo(2.1, 1e-9),
        );
        expect(orderItem.baseQuantityInSaleUnit(), 2.0);
        expect(
          orderItem.wastageInSaleUnit(),
          closeTo(0.1, 1e-9),
        );
        expect(
          orderItem.wastageNote(),
          'incl. 0.1 M² wastage',
        );
        expect(
          orderItem.historyWastageText(),
          ' (incl. 0.1 M² wastage)',
        );
      },
    );

    test(
      'Base unit resolution in multiple units picks unit where conversion is 1.0',
      () {
        final unitSlab = ProductUnitsClass(
          uuid: 'u-slab',
          staffUuid: null,
          createdAt: DateTime.utc(2026),
          staffName: null,
          conversion: 2.0, // 2 m² per slab
          name: 'Slab',
          isPrimary:
              true, // Marked primary, but conversion is 2.0
          productUuid: 'p-1',
          dimensionType: ProductUnitsClass.sheetUnit,
        );

        final unitM2 = ProductUnitsClass(
          uuid: 'u-m2',
          staffUuid: null,
          createdAt: DateTime.utc(2026),
          staffName: null,
          conversion: 1.0, // Base unit: conversion is 1.0
          name: 'm²',
          isPrimary: false,
          productUuid: 'p-1',
          dimensionType: ProductUnitsClass.areaUnit,
        );

        final unitsList = [unitSlab, unitM2];

        // Resolve base unit where conversion is 1.0:
        final resolvedBaseUnit =
            unitsList
                .where(
                  (u) => (u.conversion - 1.0).abs() < 1e-6,
                )
                .firstOrNull
                ?.name ??
            unitsList
                .where((u) => u.isPrimary)
                .firstOrNull
                ?.name ??
            'm²';

        expect(resolvedBaseUnit, 'm²');

        // Presets for dimension unit cm with resolvedBaseUnit 'm²' yields 10,000.0:
        expect(
          DimensionUnitHelper.getPresetConversion(
            'Centimeter(s)',
            baseUnit: resolvedBaseUnit,
          ),
          10000.0,
        );
      },
    );

    test(
      'Switching cart to order sale type preserves wastage on cart items',
      () {
        final product = TempProductClass(
          id: 1,
          name: 'Marble Slab',
          unit: 'M²',
          isRefundable: false,
          costPrice: 50,
          sellingPrice: 100,
          shopId: 1,
          quantity: 10,
          setCustomPrice: false,
          departmentName: null,
          departmentUuid: null,
          isManaged: true,
          groupUnit: 'None',
          qttyPerGroup: 1,
          wholeSalePrice: 80,
          storageUuid: null,
          categories: [],
          useGroupUnit: false,
          unitsList: [dummyUnit('M²')],
          pricesList: [dummyPrice()],
          widthDimension: 100,
          heightDimension: 200,
          quantityType: 2,
          manageSalesWastage: true,
          dimensionUnit: 'Centimeter(s)',
          dimensionUnitConversion: 10000.0,
        );

        final itemWithWastage = TempCartItem(
          item: product,
          itemUuid: product.uuid,
          quantity: 1,
          discount: null,
          addToStock: false,
          setTotalPrice: false,
          useWholeSalePrice: false,
          useGroupQuantity: false,
          qttyPerGroup: null,
          isVoid: false,
          uuid: 'cart-line-order',
          unitUuid: 'u-1',
          priceUuid: 'pr-1',
          widthDimension: 100,
          heightDimension: 100,
          quantityType: 2,
          manageSalesWastage: true,
          isPercentageWastage: true,
          wastageAmount: 10.0, // 10%
          wastageUnitUuid: 'u-1',
        );

        // Verify wastage is calculated:
        expect(itemWithWastage.wastageAmount, 10.0);
        expect(itemWithWastage.isPercentageWastage, true);
        expect(
          itemWithWastage.wastageArea(),
          closeTo(0.1, 1e-9),
        );
        expect(
          itemWithWastage.getStockQuantity(),
          closeTo(1.1, 1e-9),
        );

        // After switching cart type to order (cartItemTypeIndex = 3), wastage is NOT cleared:
        // (clearOrderWastage is now a no-op)
        expect(itemWithWastage.wastageAmount, isNotNull);
        expect(itemWithWastage.wastageAmount, 10.0);
      },
    );

    test(
      'formatHistoryUnit formats 1D and 2D items and respects identical units',
      () {
        // 1D item: 2 bottles of a crate item (0.2 Crates equiv)
        final unit1D = formatHistoryUnit(
          selectedUnit: 'bottles',
          primaryUnit: 'Crates',
          primaryQuantity: 0.2,
        );
        expect(unit1D, 'bottles (0.2 Crates)');

        // 1D identical units: no bracketed equivalent
        final unit1DSame = formatHistoryUnit(
          selectedUnit: 'Crates',
          primaryUnit: 'Crates',
          primaryQuantity: 2.0,
        );
        expect(unit1DSame, 'Crates');

        // 2D item: cut sold in Slabs with primary unit M²
        final unit2D = formatHistoryUnit(
          selectedUnit: 'Slabs (50 x 50)',
          primaryUnit: 'M²',
          primaryQuantity: 0.5,
        );
        expect(unit2D, 'Slabs (0.5 M²)');

        // 2D identical units: sold in M² when primary is M²
        final unit2DSame = formatHistoryUnit(
          selectedUnit: 'M²',
          primaryUnit: 'M²',
          primaryQuantity: 0.5,
        );
        expect(unit2DSame, 'M²');
      },
    );

    test(
      'returnHistoryQuantity displays quantity change and unit correctly',
      () {
        // 1D item sold: 2 bottles (0.2 Crates)
        final res1D = returnHistoryQuantity(
          quantityChange: -2,
          isIncreased: false,
          unit: 'bottles (0.2 Crates)',
        );
        expect(res1D, '-2 bottles (0.2 Crates)');

        // 2D item sold: 0.123 Slabs (0.5 M²)
        final res2D = returnHistoryQuantity(
          quantityChange: -0.123,
          isIncreased: false,
          unit: 'Slabs (0.5 M²)',
        );
        expect(res2D, '-0.123 Slabs (0.5 M²)');

        // Legacy entry with (50 x 50) is converted using oldValue and newValue
        final resLegacy = returnHistoryQuantity(
          quantityChange: -0.123,
          isIncreased: false,
          unit: 'Slabs (50 x 50)',
          primaryUnit: 'M²',
          oldValue: '10.0',
          newValue: '9.5',
        );
        expect(resLegacy, '-0.123 Slabs (0.5 M²)');
      },
    );

    test(
      'TempCartItem.historyUnit produces correct equivalent for 1D and 2D items',
      () {
        // 1D item: Crates (primary) and Bottles (conversion = 0.1)
        final unitCrate = ProductUnitsClass(
          uuid: 'u-crate',
          staffUuid: null,
          createdAt: DateTime.utc(2026),
          staffName: null,
          conversion: 1.0,
          name: 'Crates',
          isPrimary: true,
          productUuid: 'p-1d',
        );
        final unitBottle = ProductUnitsClass(
          uuid: 'u-bottle',
          staffUuid: null,
          createdAt: DateTime.utc(2026),
          staffName: null,
          conversion: 0.1,
          name: 'bottles',
          isPrimary: false,
          productUuid: 'p-1d',
        );
        final product1D = TempProductClass(
          id: 1,
          name: 'Soda Drink',
          unit: 'Crates',
          isRefundable: false,
          costPrice: 10,
          sellingPrice: 20,
          shopId: 1,
          quantity: 50,
          setCustomPrice: false,
          departmentName: null,
          departmentUuid: null,
          isManaged: true,
          groupUnit: 'None',
          qttyPerGroup: 1,
          wholeSalePrice: 15,
          storageUuid: null,
          categories: [],
          useGroupUnit: false,
          unitsList: [unitCrate, unitBottle],
          pricesList: [dummyPrice()],
          quantityType: 1,
          widthDimension: null,
          heightDimension: null,
          manageSalesWastage: false,
        );

        final cartItem1D = TempCartItem(
          item: product1D,
          itemUuid: product1D.uuid,
          quantity: 2,
          discount: null,
          addToStock: false,
          setTotalPrice: false,
          useWholeSalePrice: false,
          useGroupQuantity: false,
          qttyPerGroup: null,
          isVoid: false,
          uuid: 'cart-1d',
          unitUuid: 'u-bottle',
          priceUuid: 'pr-1',
          widthDimension: null,
          heightDimension: null,
          quantityType: 1,
          manageSalesWastage: false,
          isPercentageWastage: false,
          wastageAmount: null,
          wastageUnitUuid: null,
        );

        // Sold 2 bottles: equiv in primary unit (Crates) is 0.2 Crates
        expect(
          cartItem1D.historyUnit(),
          'bottles (0.2 Crates)',
        );

        // 2D item: Primary unit M² (conversion = 1.0, areaUnit), Secondary unit Slabs (conversion = 1.0, sheetUnit)
        final unitM2 = ProductUnitsClass(
          uuid: 'u-m2',
          staffUuid: null,
          createdAt: DateTime.utc(2026),
          staffName: null,
          conversion: 1.0,
          name: 'M²',
          isPrimary: true,
          productUuid: 'p-2d',
          dimensionType: ProductUnitsClass.areaUnit,
        );
        final unitSlab = ProductUnitsClass(
          uuid: 'u-slab',
          staffUuid: null,
          createdAt: DateTime.utc(2026),
          staffName: null,
          conversion: 1.0,
          name: 'Slabs',
          isPrimary: false,
          productUuid: 'p-2d',
          dimensionType: ProductUnitsClass.sheetUnit,
        );
        final product2D = TempProductClass(
          id: 2,
          name: 'Marble Slab',
          unit: 'M²',
          isRefundable: false,
          costPrice: 50,
          sellingPrice: 100,
          shopId: 1,
          quantity: 10,
          setCustomPrice: false,
          departmentName: null,
          departmentUuid: null,
          isManaged: true,
          groupUnit: 'None',
          qttyPerGroup: 1,
          wholeSalePrice: 80,
          storageUuid: null,
          categories: [],
          useGroupUnit: false,
          unitsList: [unitM2, unitSlab],
          pricesList: [dummyPrice()],
          widthDimension: 100,
          heightDimension: 200, // 2 m² whole slab
          quantityType: 2,
          manageSalesWastage: false,
          dimensionUnit: 'Centimeter(s)',
          dimensionUnitConversion: 10000.0,
        );

        // Custom cut: 100cm x 50cm = 0.5 m²
        final cartItem2D = TempCartItem(
          item: product2D,
          itemUuid: product2D.uuid,
          quantity: 1,
          discount: null,
          addToStock: false,
          setTotalPrice: false,
          useWholeSalePrice: false,
          useGroupQuantity: false,
          qttyPerGroup: null,
          isVoid: false,
          uuid: 'cart-2d',
          unitUuid: 'u-slab',
          priceUuid: 'pr-1',
          widthDimension: 100,
          heightDimension: 50,
          quantityType: 2,
          manageSalesWastage: false,
          isPercentageWastage: false,
          wastageAmount: null,
          wastageUnitUuid: null,
        );

        // Sold 1 cut of 100x50 = 0.25 Slabs, stock/primary area is 0.5 M²
        expect(cartItem2D.historyUnit(), 'Slabs (0.5 M²)');
        expect(cartItem2D.historyQuantityChange(), 0.25);
        expect(cartItem2D.displayQuantity(), 0.5);
        expect(cartItem2D.displayUnitName(), 'M²');
      },
    );

    test(
      'ItemHistory & Report table format unit and equivalence',
      () {
        // 1D: 2 bottles, primary unit Crates (0.2 Crates)
        final history1D = ItemHistory(
          shopId: 1,
          title: 'Sold',
          desc: 'Sale',
          event: 'sale',
          source: 'pos',
          isManaged: true,
          quantityChange: 2,
          isIncreased: true,
          unit: 'bottles',
          primaryUnit: 'Crates',
          oldValue: '10',
          newValue: '10.2',
        );
        expect(
          ItemHistoryReportQuery.quantityChangeUnit(
            history1D,
          ),
          'bottles (0.2 Crates)',
        );
        expect(
          returnHistoryQuantity(
            quantityChange: history1D.quantityChange,
            isIncreased: history1D.isIncreased,
            unit: history1D.unit,
            primaryUnit: history1D.primaryUnit,
            oldValue: history1D.oldValue,
            newValue: history1D.newValue,
          ),
          '+2 bottles (0.2 Crates)',
        );

        // 2D: Legacy format with (w x h) -> stripped and primary equiv shown
        final history2DLegacy = ItemHistory(
          shopId: 1,
          title: 'Sold',
          desc: 'Sale',
          event: 'sale',
          source: 'pos',
          isManaged: true,
          quantityChange: 0.123,
          isIncreased: false,
          unit: 'Slabs (50 x 50)',
          primaryUnit: 'M²',
          oldValue: '10',
          newValue: '9.5',
        );
        expect(
          ItemHistoryReportQuery.quantityChangeUnit(
            history2DLegacy,
          ),
          'Slabs (0.5 M²)',
        );
        expect(
          returnHistoryQuantity(
            quantityChange: history2DLegacy.quantityChange,
            isIncreased: history2DLegacy.isIncreased,
            unit: history2DLegacy.unit,
            primaryUnit: history2DLegacy.primaryUnit,
            oldValue: history2DLegacy.oldValue,
            newValue: history2DLegacy.newValue,
          ),
          '-0.123 Slabs (0.5 M²)',
        );

        // Same unit: no brackets
        final historySame = ItemHistory(
          shopId: 1,
          title: 'Sold',
          desc: 'Sale',
          event: 'sale',
          source: 'pos',
          isManaged: true,
          quantityChange: 5,
          isIncreased: true,
          unit: 'Crates',
          primaryUnit: 'Crates',
          oldValue: '10',
          newValue: '15',
        );
        expect(
          ItemHistoryReportQuery.quantityChangeUnit(
            historySame,
          ),
          'Crates',
        );
        expect(
          returnHistoryQuantity(
            quantityChange: historySame.quantityChange,
            isIncreased: historySame.isIncreased,
            unit: historySame.unit,
            primaryUnit: historySame.primaryUnit,
            oldValue: historySame.oldValue,
            newValue: historySame.newValue,
          ),
          '+5 Crates',
        );
      },
    );

    test(
      'StorageItemHistory & Storage Report table format unit and equivalence',
      () {
        // Storage item: 2 bottles, storagePrimaryUnit Crates (0.2 Crates)
        final storageHistory1D = StorageItemHistory(
          shopId: 1,
          title: 'Transfer',
          desc: 'Transfer',
          event: 'transfer',
          source: 'storage',
          quantityChange: 2,
          isIncreased: true,
          storageUnit: 'bottles',
          storagePrimaryUnit: 'Crates',
          storageItemOldValue: '10',
          storageItemNewValue: '10.2',
        );
        expect(
          StorageItemHistoryReportQuery.quantityChangeUnit(
            storageHistory1D,
          ),
          'bottles (0.2 Crates)',
        );
        expect(
          returnHistoryQuantity(
            quantityChange: storageHistory1D.quantityChange,
            isIncreased: storageHistory1D.isIncreased,
            unit: storageHistory1D.storageUnit,
            primaryUnit:
                storageHistory1D.storagePrimaryUnit,
            oldValue: storageHistory1D.storageItemOldValue,
            newValue: storageHistory1D.storageItemNewValue,
          ),
          '+2 bottles (0.2 Crates)',
        );

        // Storage 2D: Legacy format with (w x h) -> stripped and primary equiv shown
        final storageHistory2DLegacy = StorageItemHistory(
          shopId: 1,
          title: 'Transfer',
          desc: 'Transfer',
          event: 'transfer',
          source: 'storage',
          quantityChange: 0.123,
          isIncreased: false,
          storageUnit: 'Slabs (50 x 50)',
          storagePrimaryUnit: 'M²',
          storageItemOldValue: '10',
          storageItemNewValue: '9.5',
        );
        expect(
          StorageItemHistoryReportQuery.quantityChangeUnit(
            storageHistory2DLegacy,
          ),
          'Slabs (0.5 M²)',
        );
        expect(
          returnHistoryQuantity(
            quantityChange:
                storageHistory2DLegacy.quantityChange,
            isIncreased: storageHistory2DLegacy.isIncreased,
            unit: storageHistory2DLegacy.storageUnit,
            primaryUnit:
                storageHistory2DLegacy.storagePrimaryUnit,
            oldValue:
                storageHistory2DLegacy.storageItemOldValue,
            newValue:
                storageHistory2DLegacy.storageItemNewValue,
          ),
          '-0.123 Slabs (0.5 M²)',
        );

        // Storage same unit: no brackets
        final storageHistorySame = StorageItemHistory(
          shopId: 1,
          title: 'Transfer',
          desc: 'Transfer',
          event: 'transfer',
          source: 'storage',
          quantityChange: 5,
          isIncreased: true,
          storageUnit: 'Crates',
          storagePrimaryUnit: 'Crates',
          storageItemOldValue: '10',
          storageItemNewValue: '15',
        );
        expect(
          StorageItemHistoryReportQuery.quantityChangeUnit(
            storageHistorySame,
          ),
          'Crates',
        );
        expect(
          returnHistoryQuantity(
            quantityChange:
                storageHistorySame.quantityChange,
            isIncreased: storageHistorySame.isIncreased,
            unit: storageHistorySame.storageUnit,
            primaryUnit:
                storageHistorySame.storagePrimaryUnit,
            oldValue:
                storageHistorySame.storageItemOldValue,
            newValue:
                storageHistorySame.storageItemNewValue,
          ),
          '+5 Crates',
        );
      },
    );
  });
}
