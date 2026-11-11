// Every hand-off from the shared stock pages stays on its own kind:
// Materials rows open the Materials pages, Produced Items rows the
// Produced Items pages.

import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/pages/production/materials_page/materials_details/materials_details_page.dart';
import 'package:stockall/pages/production/production_items/production_items_details/production_items_details_page.dart';
import 'package:stockall/pages/report/production_report/material_history_table/material_history_table_page.dart';
import 'package:stockall/pages/report/production_report/materials_table/materials_table_page.dart';
import 'package:stockall/pages/report/production_report/produced_item_history_table/produced_item_history_table_page.dart';
import 'package:stockall/pages/report/production_report/produced_items_table/produced_items_table_page.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/production_stock_model.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/stock_history_logic.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/stock_items_logic.dart';
import 'package:stockall/pages/report/production_report/stock_shared/components/production_stock_env.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

final day2 = ReceiptsReportPeriod.day(DateTime(2026, 10, 2));

void main() {
  test('the stock table: Materials open Materials, Produced Items theirs', () {
    final filters = ProductionStockFilters(itemKey: 'flour');
    final m = productionStockTablePage(ProductionStockKind.material, filters, day2);
    expect(m, isA<MaterialsTablePage>());
    expect((m as MaterialsTablePage).initialFilters!.itemKey, 'flour');
    expect(m.initialPeriod, day2);
    final p = productionStockTablePage(ProductionStockKind.producedItem, filters, day2);
    expect(p, isA<ProducedItemsTablePage>());
    expect((p as ProducedItemsTablePage).initialFilters!.itemKey, 'flour');
  });

  test('the history table, by kind', () {
    final filters = ProductionHistoryFilters(itemKey: 'sugar');
    final m = productionStockHistoryPage(ProductionStockKind.material, filters, day2);
    expect(m, isA<MaterialHistoryTablePage>());
    expect((m as MaterialHistoryTablePage).initialFilters!.itemKey, 'sugar');
    expect(m.initialPeriod, day2);
    expect(
      productionStockHistoryPage(ProductionStockKind.producedItem, filters, day2),
      isA<ProducedItemHistoryTablePage>(),
    );
  });

  test('the item page, by kind', () {
    final m = productionStockItemPage(ProductionStockKind.material, 'flour');
    expect(m, isA<MaterialsDetailsPage>());
    expect((m as MaterialsDetailsPage).materialUuid, 'flour');
    final p = productionStockItemPage(ProductionStockKind.producedItem, 'donut');
    expect(p, isA<ProductionItemsDetailsPage>());
    expect((p as ProductionItemsDetailsPage).productionItemUuid, 'donut');
  });
}
