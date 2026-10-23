import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_storage_product/temp_storage_products.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_report_main/class/storage_report_main_logic.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_report_main/storage_report_main_page.dart';

TempProductClass createTestProduct({
  required String uuid,
  required String name,
  required double quantity,
  required String? storageUuid,
}) {
  return TempProductClass(
    uuid: uuid,
    name: name,
    shopId: 1,
    unit: 'Pieces',
    isRefundable: false,
    costPrice: 50,
    sellingPrice: 80,
    quantity: quantity,
    setCustomPrice: false,
    departmentName: null,
    departmentUuid: null,
    isManaged: true,
    groupUnit: null,
    qttyPerGroup: null,
    wholeSalePrice: 75,
    storageUuid: storageUuid,
    categories: [],
    useGroupUnit: false,
    unitsList: [],
    pricesList: [],
    widthDimension: null,
    heightDimension: null,
    manageSalesWastage: false,
  );
}

void main() {
  test(
    'StorageReportRowBuilder and StorageReportQuery test',
    () {
      final storageProduct = TempStorageProducts(
        uuid: 'storage_1',
        shopId: 1,
        name: 'Storage Item A',
        quantity: 100,
        costPrice: 50,
        sellingPrice: 70,
        useGroupUnit: false,
        unitsList: [],
      );

      final salesProduct1 = createTestProduct(
        uuid: 'sales_1',
        name: 'Sales Item A1',
        quantity: 20,
        storageUuid: 'storage_1',
      );

      final salesProduct2 = createTestProduct(
        uuid: 'sales_2',
        name: 'Sales Item A2',
        quantity: 30,
        storageUuid: 'storage_1',
      );

      final unlinkedSales = createTestProduct(
        uuid: 'sales_3',
        name: 'Sales Item B',
        quantity: 10,
        storageUuid: 'other_storage',
      );

      final rows = StorageReportRowBuilder.buildAll(
        storageProducts: [storageProduct],
        salesProducts: [
          salesProduct1,
          salesProduct2,
          unlinkedSales,
        ],
      );

      expect(rows.length, 1);
      final row = rows.first;
      expect(row.name, 'Storage Item A');
      expect(row.quantity, 100);
      expect(row.costPrice, 50);
      expect(row.totalCostValue, 5000);
      expect(row.salesCount, 2);
      expect(row.salesItemNames, [
        'Sales Item A1',
        'Sales Item A2',
      ]);
      expect(row.quantityInSales, 50);
      expect(row.totalQuantity, 150);

      // Test filter
      final filters = StorageReportFilters();
      expect(
        filters.matches(row, costFilterAllowed: true),
        true,
      );

      filters.search = 'A1';
      expect(
        filters.matches(row, costFilterAllowed: true),
        true,
      );

      filters.search = 'NonExistent';
      expect(
        filters.matches(row, costFilterAllowed: true),
        false,
      );
      filters.search = '';

      // Quantity range filter
      filters.quantityMin = 150;
      expect(
        filters.matches(row, costFilterAllowed: true),
        false,
      );
      filters.quantityMin = 50;
      filters.quantityMax = 120;
      expect(
        filters.matches(row, costFilterAllowed: true),
        true,
      );
      filters.quantityMin = null;
      filters.quantityMax = null;

      // Number of sales items filter
      filters.salesItemsCountMin = 3;
      expect(
        filters.matches(row, costFilterAllowed: true),
        false,
      );
      filters.salesItemsCountMin = 1;
      filters.salesItemsCountMax = 2;
      expect(
        filters.matches(row, costFilterAllowed: true),
        true,
      );
      filters.salesItemsCountMin = null;
      filters.salesItemsCountMax = null;

      // Test sorting
      final page = StorageReportQuery.paginate(rows, 1);
      expect(page.totalCount, 1);
      expect(page.totalPages, 1);
      expect(page.rows.length, 1);

      // Ensure StorageReportMainPage widget constructor works
      const pageWidget = StorageReportMainPage();
      expect(pageWidget.initialSearch, null);
    },
  );
}
