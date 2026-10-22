import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_item_history/item_history.dart';
import 'package:stockall/classes/temp_item_history/item_history_event_class.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';
import 'package:stockall/pages/report/items_report_/item_history_summary/class/item_history_summary_logic.dart';
import 'package:stockall/pages/report/items_report_/items_report_main/class/items_report_main_logic.dart';

TempProductClass cocaCola({double quantity = 5}) {
  return TempProductClass(
    uuid: 'coke',
    name: 'Coca Cola',
    unit: 'Bottle(s)',
    isRefundable: false,
    costPrice: 0,
    shopId: 1,
    setCustomPrice: false,
    departmentName: null,
    departmentUuid: null,
    isManaged: true,
    groupUnit: null,
    qttyPerGroup: null,
    wholeSalePrice: null,
    storageUuid: null,
    categories: [],
    useGroupUnit: false,
    unitsList: [
      ProductUnitsClass(
        uuid: 'bottle',
        staffUuid: null,
        createdAt: DateTime.utc(2026),
        staffName: null,
        conversion: 1,
        name: 'Bottle(s)',
        isPrimary: true,
        productUuid: 'coke',
      ),
    ],
    pricesList: null,
    widthDimension: null,
    heightDimension: null,
    manageSalesWastage: null,
    quantity: quantity,
    createdAt: DateTime(2026, 9, 1),
  );
}

ItemHistory history({
  required String uuid,
  required String title,
  required String? event,
  required DateTime createdAt,
  required String oldValue,
  required String newValue,
  required double quantityChange,
  required bool? isIncreased,
}) {
  return ItemHistory(
    uuid: uuid,
    createdAt: createdAt,
    shopId: 1,
    title: title,
    itemName: 'Coca Cola',
    itemUuid: 'coke',
    oldValue: oldValue,
    newValue: newValue,
    quantityChange: quantityChange,
    desc: null,
    isIncreased: isIncreased,
    unit: 'Bottle(s)',
    primaryUnit: 'Bottle(s)',
    event: event,
    isManaged: true,
    source: null,
  );
}

/// The 29 Sep receipt sale of 5 bottles, with or without an event.
ItemHistory sale({String? event}) => history(
  uuid: 'sale-1',
  title: 'Item Sold In Receipt',
  event: event,
  createdAt: DateTime(2026, 9, 29, 12),
  oldValue: '10.0',
  newValue: '5.0',
  quantityChange: -5,
  isIncreased: false,
);

ItemHistory bare(String title, {bool? isIncreased, String? event}) => history(
  uuid: title,
  title: title,
  event: event,
  createdAt: DateTime(2026, 9, 29, 12),
  oldValue: '0',
  newValue: '0',
  quantityChange: 0,
  isIncreased: isIncreased,
);

ItemHistorySummaryRow summaryRow(List<ItemHistory> histories) {
  return ItemHistorySummaryBuilder.buildSummaryAndRows(
    products: [cocaCola()],
    histories: histories,
    period: ItemHistoryPeriod.allTime,
    businessNow: DateTime(2026, 10, 22, 12),
    manageProductions: true,
  ).rows.single;
}

void main() {
  group('ItemHistoryEventClass.eventOf', () {
    test('keeps an event that is already set', () {
      expect(
        ItemHistoryEventClass.eventOf(
          bare('Item Sold In Receipt', event: 'purchase'),
        ),
        'purchase',
      );
    });

    test('infers the event of legacy titles', () {
      final cases = <String, String?>{
        'Item Sold In Receipt': ItemHistoryEventClass.sold,
        'Item Sold In Receipt (Unmanaged)': ItemHistoryEventClass.sold,
        'Item Sold In Receipt (Updated)': ItemHistoryEventClass.sold,
        'Item Sold On Credit': ItemHistoryEventClass.sold,
        'Item Sold On Credit (Unmanaged)': ItemHistoryEventClass.sold,
        'Order Created': ItemHistoryEventClass.sold,
        'Item Returned': ItemHistoryEventClass.returnEvent,
        'Item Returned (Receipt Updated)': ItemHistoryEventClass.returnEvent,
        'Purchase Deleted': ItemHistoryEventClass.returnEvent,
        'Purchased Deleted': ItemHistoryEventClass.returnEvent,
        'Receipt Deleted (Unmanaged)': ItemHistoryEventClass.returnEvent,
        'Invoice Deleted (Unmanaged)': ItemHistoryEventClass.returnEvent,
        'Item Purchased': ItemHistoryEventClass.purchase,
        'Stock In From Purchase': ItemHistoryEventClass.purchase,
        'Transfered In': ItemHistoryEventClass.transferedIn,
        'Transfered Out': ItemHistoryEventClass.transferedOut,
        'Order Item Delivered': ItemHistoryEventClass.delivered,
        'Order Item Delivered (Unmanaged)': ItemHistoryEventClass.delivered,
        'Production Record Deleted': ItemHistoryEventClass.productionDeleted,
        'Item Produced': ItemHistoryEventClass.produced,
        'This Item was Produced': ItemHistoryEventClass.produced,
        'Item Deleted': ItemHistoryEventClass.itemDeleted,
        'Item Deleted Now': ItemHistoryEventClass.itemDeleted,
        'Item Created': ItemHistoryEventClass.itemCreated,
        'Item Created Now': ItemHistoryEventClass.itemCreated,
        'A new Item is Created': ItemHistoryEventClass.itemCreated,
        'Price Updated': null,
      };
      cases.forEach((title, expected) {
        expect(
          ItemHistoryEventClass.eventOf(bare(title)),
          expected,
          reason: title,
        );
      });
    });

    test('legacy quantity updates take their direction from isIncreased', () {
      expect(
        ItemHistoryEventClass.eventOf(
          bare('Item Quantity Updated', isIncreased: true),
        ),
        ItemHistoryEventClass.quantityUpdatedIncrease,
      );
      expect(
        ItemHistoryEventClass.eventOf(
          bare('Item Quantity Updated', isIncreased: false),
        ),
        ItemHistoryEventClass.quantityUpdatedDecrease,
      );
      expect(
        ItemHistoryEventClass.eventOf(bare('Item Quantity Updated')),
        isNull,
      );
    });
  });

  group('Item History Summary', () {
    test('a legacy sale counts the same as a tagged one', () {
      for (final event in [null, ItemHistoryEventClass.sold]) {
        final r = summaryRow([sale(event: event)]);
        expect(r.sold, 5, reason: 'event: $event');
        expect(r.soldText, '-5.0 Bottle(s)', reason: 'event: $event');
        expect(r.netQuantityChange, -5, reason: 'event: $event');
        expect(r.openingStock, 10, reason: 'event: $event');
        expect(r.closingStock, 5, reason: 'event: $event');
      }
    });

    test('legacy quantity updates count in both directions', () {
      ItemHistorySummaryRow build(String? up, String? down) => summaryRow([
        history(
          uuid: 'up',
          title: 'Item Quantity Updated',
          event: up,
          createdAt: DateTime(2026, 9, 20, 12),
          oldValue: '5.0',
          newValue: '8.0',
          quantityChange: 3,
          isIncreased: true,
        ),
        history(
          uuid: 'down',
          title: 'Item Quantity Updated',
          event: down,
          createdAt: DateTime(2026, 9, 21, 12),
          oldValue: '8.0',
          newValue: '6.0',
          quantityChange: -2,
          isIncreased: false,
        ),
      ]);

      final legacy = build(null, null);
      final tagged = build(
        ItemHistoryEventClass.quantityUpdatedIncrease,
        ItemHistoryEventClass.quantityUpdatedDecrease,
      );
      for (final r in [legacy, tagged]) {
        expect(r.quantityIncreased, 3);
        expect(r.quantityDecreased, 2);
        expect(r.netQuantityChange, 1);
        expect(r.openingStock, 5);
        expect(r.closingStock, 6);
      }
    });

    test('an unknown legacy title is still ignored', () {
      final r = summaryRow([
        history(
          uuid: 'price',
          title: 'Price Updated',
          event: null,
          createdAt: DateTime(2026, 9, 29, 12),
          oldValue: '10.0',
          newValue: '5.0',
          quantityChange: -5,
          isIncreased: false,
        ),
      ]);
      expect(r.hasAnyMovement, isFalse);
      expect(r.netQuantityChange, 0);
    });
  });

  group('Items Report stock movement', () {
    final product = cocaCola();
    final row = ItemsReportRow(
      product: product,
      name: product.name,
      primaryUnit: 'Bottle(s)',
      quantity: 5,
      sellingPrice: 0,
      costPrice: 0,
      totalSellingValue: null,
      totalCostValue: null,
      profit: null,
      margin: null,
      discount: null,
      expiryDate: null,
      isExpired: false,
      isTwoDimensional: false,
      isManaged: true,
      createdAt: product.createdAt,
      categoryUuids: const [],
      categoryNames: const [],
      departmentUuid: null,
      departmentName: null,
      stockLevel: StockLevelFilter.inStock,
    );

    test('a legacy sale is applicable and moves stock like a tagged one', () {
      for (final event in [null, ItemHistoryEventClass.sold]) {
        final h = sale(event: event);
        expect(
          StockMovementCalculator.isApplicable(h, row),
          isTrue,
          reason: 'event: $event',
        );
        final m = StockMovementCalculator.calculate(
          row: row,
          histories: [h],
          startCutoff: DateTime(2026, 9, 29, 4),
          endCutoff: DateTime(2026, 9, 30, 4),
        );
        expect(m.opening, 10, reason: 'event: $event');
        expect(m.closing, 5, reason: 'event: $event');
        expect(m.change, -5, reason: 'event: $event');
      }
    });

    test('an unknown legacy title is not applicable', () {
      expect(
        StockMovementCalculator.isApplicable(
          history(
            uuid: 'price',
            title: 'Price Updated',
            event: null,
            createdAt: DateTime(2026, 9, 29, 12),
            oldValue: '10.0',
            newValue: '5.0',
            quantityChange: -5,
            isIncreased: false,
          ),
          row,
        ),
        isFalse,
      );
    });
  });
}
