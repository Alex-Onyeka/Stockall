import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_item_purchase_record/temp_item_purchase_record.dart';
import 'package:stockall/classes/temp_purchase/temp_purchase.dart';
import 'package:stockall/pages/report/purchase_report/purchase_item_analysis/class/purchase_item_analysis_logic.dart';
import 'package:stockall/pages/report/purchase_report/purchase_item_report/class/purchase_item_report_logic.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/class/purchase_report_table_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

import 'purchase_report_fixtures.dart';

void main() {
  group('Custom payment channel classification & labels', () {
    test('custom bank channel like Opay classifies as bank and keeps label', () {
      final payments = [
        payment(5000, method: 'Opay', uuid: 'pay-1'),
      ];

      expect(PurchaseReportClassifier.channel(payments), PurchaseChannel.bank);
      expect(PurchaseReportClassifier.channelLabel(payments), 'Opay');
    });

    test('cash and mixed channels resolve properly', () {
      final cash = [
        payment(1000, method: 'Cash', uuid: 'pay-1'),
      ];
      final split = [
        ...cash,
        payment(2000, method: 'Moniepoint', uuid: 'pay-2'),
      ];

      expect(PurchaseReportClassifier.channel(cash), PurchaseChannel.cash);
      expect(PurchaseReportClassifier.channelLabel(cash), 'Cash');
      expect(PurchaseReportClassifier.channel(split), PurchaseChannel.split);
      expect(PurchaseReportClassifier.channelLabel(split), 'Split');
    });
  });

  group('PurchaseItemRowBuilder & PurchaseItemAnalysisBuilder', () {
    final now = DateTime(2026, 5, 10, 15, 30);

    TempPurchase makePurchase() {
      return purchase(
        uuid: 'pur-1',
        createdAt: now,
        total: 3500,
        staffId: 'staff-1',
        staffName: 'Alice',
        supplierId: 'sup-global',
        payments: [
          payment(3500, method: 'Opay', uuid: 'pay-1'),
        ],
        items: [
          TempItemPurchaseRecord(
            uuid: 'line-1',
            createdAt: now,
            shopId: 1,
            staffId: 'staff-1',
            itemId: 'prod-1',
            storageItemId: null,
            purchaseId: 'pur-1',
            itemName: 'Bottled Water',
            quantity: 10,
            total: 1500,
            originalPrice: 150,
            customPrice: null,
            isGroup: false,
            qttyPerGroup: null,
            unit: 'piece',
            unitsList: [pieceUnit],
            unitUuid: 'piece',
            globalSupplierId: 'sup-global',
            globalSupplierName: 'Global Foods',
            globalTrackingNumber: 'TRK-GLOBAL-1',
            supplierId: null,
            supplierName: null,
            trackingNumber: null,
          ),
          TempItemPurchaseRecord(
            uuid: 'line-2',
            createdAt: now,
            shopId: 1,
            staffId: 'staff-1',
            itemId: null,
            storageItemId: 'stor-1',
            purchaseId: 'pur-1',
            itemName: 'Packing Box',
            quantity: 4,
            total: 2000,
            originalPrice: 500,
            customPrice: null,
            isGroup: false,
            qttyPerGroup: null,
            unit: 'piece',
            unitsList: [pieceUnit],
            unitUuid: 'piece',
            globalSupplierId: 'sup-global',
            globalSupplierName: 'Global Foods',
            globalTrackingNumber: 'TRK-GLOBAL-1',
            supplierId: 'sup-item',
            supplierName: 'Box Co',
            trackingNumber: 'TRK-ITEM-99',
          ),
        ],
      );
    }

    test('builds global and item-specific supplier/tracking and item types', () {
      final rows = PurchaseItemRowBuilder.buildAll(
        purchases: [makePurchase()],
        supplierNames: {'sup-global': 'Global Foods', 'sup-item': 'Box Co'},
      );

      expect(rows.length, 2);

      final salesRow = rows[0];
      expect(salesRow.isStorageItem, isFalse);
      expect(salesRow.globalSupplierLabel, 'Global Foods');
      expect(salesRow.itemSupplierLabel, '—');
      expect(salesRow.effectiveSupplierLabel, 'Global Foods');
      expect(salesRow.globalTrackingLabel, 'TRK-GLOBAL-1');
      expect(salesRow.itemTrackingLabel, '—');
      expect(salesRow.effectiveTrackingLabel, 'TRK-GLOBAL-1');
      expect(salesRow.channelLabel, 'Opay');

      final storageRow = rows[1];
      expect(storageRow.isStorageItem, isTrue);
      expect(storageRow.globalSupplierLabel, 'Global Foods');
      expect(storageRow.itemSupplierLabel, 'Box Co');
      expect(storageRow.effectiveSupplierLabel, 'Box Co');
      expect(storageRow.globalTrackingLabel, 'TRK-GLOBAL-1');
      expect(storageRow.itemTrackingLabel, 'TRK-ITEM-99');
      expect(storageRow.effectiveTrackingLabel, 'TRK-ITEM-99');
    });

    test('filters by itemType and search tracking number', () {
      final rows = PurchaseItemRowBuilder.buildAll(
        purchases: [makePurchase()],
        supplierNames: {'sup-global': 'Global Foods', 'sup-item': 'Box Co'},
      );

      final storageOnly = PurchaseItemFilterBuilder.filter(
        rows,
        PurchaseItemFilters(itemType: PurchaseItemTypeFilter.storage),
        departmentsEnabled: false,
      );
      expect(storageOnly.length, 1);
      expect(storageOnly.first.itemName, 'Packing Box');

      final byTracking = PurchaseItemFilterBuilder.filter(
        rows,
        PurchaseItemFilters(search: 'TRK-ITEM-99'),
        departmentsEnabled: false,
      );
      expect(byTracking.length, 1);
      expect(byTracking.first.itemName, 'Packing Box');
    });

    test('computes PurchaseItemAnalysisBuilder stats and breakdowns', () {
      final rows = PurchaseItemRowBuilder.buildAll(
        purchases: [makePurchase()],
        supplierNames: {'sup-global': 'Global Foods', 'sup-item': 'Box Co'},
      );

      final analysis = PurchaseItemAnalysisBuilder.build(
        allRows: rows,
        period: const ReceiptsReportPeriod.allTime(),
        departmentsEnabled: false,
      );

      expect(analysis.stats.lineCount, 2);
      expect(analysis.stats.distinctItems, 2);
      expect(analysis.stats.purchaseCount, 1);
      expect(analysis.stats.totalQuantity, 14);
      expect(analysis.stats.totalSpend, 3500);
      expect(analysis.stats.salesItemLines, 1);
      expect(analysis.stats.salesItemSpend, 1500);
      expect(analysis.stats.storageItemLines, 1);
      expect(analysis.stats.storageItemSpend, 2000);
      expect(analysis.channels.length, 1);
      expect(analysis.channels.first.label, 'Opay');
    });

    test('ReceiptsReportPeriod.today() includes items recorded today and builds hourly trend', () {
      final rows = PurchaseItemRowBuilder.buildAll(
        purchases: [makePurchase()],
        supplierNames: {'sup-global': 'Global Foods', 'sup-item': 'Box Co'},
      );
      final todayPeriod = ReceiptsReportPeriod.day(now);

      final inToday = PurchaseItemFilterBuilder.inPeriod(rows, todayPeriod);
      expect(inToday.length, 2);

      final analysisToday = PurchaseItemAnalysisBuilder.build(
        allRows: rows,
        period: todayPeriod,
        departmentsEnabled: false,
      );
      expect(analysisToday.stats.lineCount, 2);
      expect(analysisToday.stats.totalSpend, 3500);
      expect(analysisToday.trend.length, 24);
      expect(
        analysisToday.trend.fold<double>(0, (s, p) => s + p.spend),
        3500,
      );

      final grouped = PurchaseItemGrouping.build(inToday);
      expect(grouped.length, 2);
    });
  });
}
