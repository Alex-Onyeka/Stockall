import 'package:flutter/material.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/subscription/items_auth.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/production/materials_page/materials_details/materials_details_page.dart';
import 'package:stockall/pages/production/production_items/production_items_details/production_items_details_page.dart';
import 'package:stockall/pages/report/production_report/material_history_table/material_history_table_page.dart';
import 'package:stockall/pages/report/production_report/materials_table/materials_table_page.dart';
import 'package:stockall/pages/report/production_report/produced_item_history_table/produced_item_history_table_page.dart';
import 'package:stockall/pages/report/production_report/produced_items_table/produced_items_table_page.dart';
import 'package:stockall/pages/report/production_report/production_records_table/class/production_records_table_logic.dart';
import 'package:stockall/pages/report/production_report/production_records_table/components/production_records_table_view.dart';
import 'package:stockall/pages/report/production_report/shared/class/production_report_access.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/production_stock_model.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/stock_history_logic.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/stock_items_logic.dart';
import 'package:stockall/pages/report/production_report/usage_records_table/class/usage_records_table_logic.dart';
import 'package:stockall/pages/report/production_report/usage_records_table/components/usage_records_table_view.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

/// The details page of an item of [kind].
Widget productionStockItemPage(ProductionStockKind kind, String uuid) =>
    kind == ProductionStockKind.producedItem
        ? ProductionItemsDetailsPage(productionItemUuid: uuid)
        : MaterialsDetailsPage(materialUuid: uuid);

/// The stock table of [kind], opened on [filters] and [period]. Every
/// hand-off stays on its own kind: Materials rows open the Materials
/// table, Produced Items rows the Produced Items table.
Widget productionStockTablePage(
  ProductionStockKind kind,
  ProductionStockFilters filters,
  ReceiptsReportPeriod period,
) =>
    kind == ProductionStockKind.producedItem
        ? ProducedItemsTablePage(initialFilters: filters, initialPeriod: period)
        : MaterialsTablePage(initialFilters: filters, initialPeriod: period);

/// The history table of [kind], opened on [filters] and [period].
Widget productionStockHistoryPage(
  ProductionStockKind kind,
  ProductionHistoryFilters filters,
  ReceiptsReportPeriod period,
) =>
    kind == ProductionStockKind.producedItem
        ? ProducedItemHistoryTablePage(
          initialFilters: filters,
          initialPeriod: period,
        )
        : MaterialHistoryTablePage(initialFilters: filters, initialPeriod: period);

/// Everything the stock pages read from the app, for one
/// [ProductionStockKind]. [ProductionStockEnv.live] uses the providers;
/// tests pass their own.
class ProductionStockEnv {
  final ProductionStockKind kind;
  final bool Function() departmentsEnabled;
  final bool Function() canPickDate;

  /// "Manage Cost Price": cost columns, filters and cards.
  final bool Function() canSeeCost;

  /// "View Item Quantity": quantities show as "****" without it.
  final bool Function() canSeeQuantity;

  /// "View Items History" and the plan's history tracking: the
  /// movement columns and cards.
  final bool Function() historyAllowed;

  /// Items the user may see (department scope applied).
  final List<ProductionStockItem> Function() items;

  /// History records the user may see (department scope applied).
  final List<ProductionStockEntry> Function() entries;

  /// Production record rows: the cost per unit (produced items) and the
  /// use in production (materials, from the records' material lines).
  final List<ProductionRecordRow> Function() records;

  /// Usage record rows (materials): the manual use. Empty for produced
  /// items.
  final List<UsageRecordRow> Function() usages;

  /// Category uuid → name.
  final Map<String, String> Function() categoryNames;

  final Future<void> Function(
    BuildContext context, {
    required bool refreshFromStore,
  })
  load;

  final Future<void> Function(
    BuildContext context, {
    required bool refreshFromStore,
    ReceiptsReportPeriod? period,
  })?
  loadForPeriod;

  Future<void> loadWithPeriod(
    BuildContext context, {
    required bool refreshFromStore,
    required ReceiptsReportPeriod period,
  }) =>
      loadForPeriod != null
          ? loadForPeriod!(
              context,
              refreshFromStore: refreshFromStore,
              period: period,
            )
          : load(context, refreshFromStore: refreshFromStore);

  /// Changes whenever the source data or the user's scope does.
  final String Function() signature;
  final void Function(BuildContext context) listen;
  final String Function(BuildContext context, num amount) money;

  /// Opens an item's details page.
  final Future<void> Function(BuildContext context, String itemUuid) openItem;

  /// Opens the stock table on [filters] and [period] (from the
  /// analysis).
  final Future<void> Function(
    BuildContext context,
    ProductionStockFilters filters,
    ReceiptsReportPeriod period,
  )
  openTable;

  /// Opens the history table on [filters] and [period] (from the
  /// history summary).
  final Future<void> Function(
    BuildContext context,
    ProductionHistoryFilters filters,
    ReceiptsReportPeriod period,
  )
  openHistory;

  const ProductionStockEnv({
    required this.kind,
    required this.departmentsEnabled,
    required this.canPickDate,
    required this.canSeeCost,
    required this.canSeeQuantity,
    required this.historyAllowed,
    required this.items,
    required this.entries,
    required this.records,
    this.usages = _noUsages,
    required this.categoryNames,
    required this.load,
    this.loadForPeriod,
    required this.signature,
    required this.listen,
    required this.money,
    required this.openItem,
    required this.openTable,
    required this.openHistory,
  });

  static List<UsageRecordRow> _noUsages() => const [];

  factory ProductionStockEnv.live(ProductionStockKind kind) {
    final production = ProductionRecordsEnv.live();
    final usage = UsageRecordsEnv.live();
    final produced = kind == ProductionStockKind.producedItem;
    bool departmentsEnabled() => shopSingle()?.manageDepartments == true;
    bool historyAllowed() =>
        authorization(authorized: Authorizations().viewItemsHistory) &&
        ItemsAuthAction().trackItemHistoryAction(context: null);
    List<T> scope<T>(List<T> list, String? Function(T) departmentOf) =>
        ProductionReportAccess.scopeStock<T>(
          records: list,
          departmentOf: departmentOf,
          departmentsEnabled: departmentsEnabled(),
          canViewAllDepartments: authorization(
            authorized: Authorizations().viewAllDepartments,
          ),
          currentDepartmentUuid:
              returnDepartmentProvider().currentDepartment()?.uuid,
        );
    List<ProductionStockItem> items() => scope(
      produced
          ? [
            for (final p in returnProductionItemsProvider().productionItemListMain)
              ProductionStockItem.fromProducedItem(p),
          ]
          : [
            for (final m in returnMaterialsProvider().materialListMain)
              ProductionStockItem.fromMaterial(m),
          ],
      (i) => i.departmentUuid,
    );
    List<ProductionStockEntry> entries() {
      if (!historyAllowed()) return const [];
      final sid = shopSingle()?.shopId;
      return scope(
        [
          if (produced)
            for (final h in returnProductionItemHistoryProvider().productionItemHistories)
              ProductionStockEntry.fromProducedHistory(h)
          else
            for (final h in returnMaterialsItemHistoryProvider().materialsItemHistories)
              ProductionStockEntry.fromMaterialHistory(h),
        ].where((e) => sid == null || e.shopId == sid).toList(),
        (e) => e.departmentUuid,
      );
    }

    Future<void> loadPeriod(
      BuildContext context, {
      required bool refreshFromStore,
      ReceiptsReportPeriod? period,
    }) async {
      final sid = shopSingle()?.shopId;
      if (sid == null) return;
      if (produced) {
        final p = returnProductionItemsProvider();
        if (refreshFromStore) {
          await p.getProductionItems();
        } else if (p.productionItemListMain.isEmpty) {
          await p.getProductionItemsOffline(sid);
        }
        if (historyAllowed()) {
          final h = returnProductionItemHistoryProvider();
          if (refreshFromStore) {
            await h.getProductionItemHistories();
          } else if (h.productionItemHistories.isEmpty) {
            await h.getProductionItemHistoriesOffline();
          }
        }
        if (context.mounted) {
          if (period != null) {
            await production.loadWithPeriod(
              context,
              refreshFromStore: refreshFromStore,
              period: period,
            );
          } else {
            await production.load(context, refreshFromStore: refreshFromStore);
          }
        }
      } else {
        final m = returnMaterialsProvider();
        if (refreshFromStore) {
          await m.getMaterials();
        } else if (m.materialListMain.isEmpty) {
          await m.getMaterialsOffline(sid);
        }
        if (historyAllowed()) {
          final h = returnMaterialsItemHistoryProvider();
          if (refreshFromStore) {
            await h.getMaterialsItemHistories();
          } else if (h.materialsItemHistories.isEmpty) {
            await h.getMaterialsItemHistoriesOffline();
          }
        }
        // Usage records and the production records behind them.
        if (context.mounted) {
          if (period != null) {
            await usage.loadWithPeriod(
              context,
              refreshFromStore: refreshFromStore,
              period: period,
            );
          } else {
            await usage.load(context, refreshFromStore: refreshFromStore);
          }
        }
      }
    }

    return ProductionStockEnv(
      kind: kind,
      departmentsEnabled: departmentsEnabled,
      canPickDate: production.canPickDate,
      canSeeCost: production.canSeeCost,
      canSeeQuantity: production.canSeeQuantity,
      historyAllowed: historyAllowed,
      items: items,
      entries: entries,
      records:
          () => ProductionRecordRowBuilder.buildAll(
            records: production.records(),
            manageProductionItems: production.manageProductionItems(),
            pendingDeletedUuids: production.pendingDeletedUuids(),
          ),
      usages:
          () =>
              produced
                  ? const []
                  : UsageRecordRowBuilder.buildAll(
                    usages: usage.usages(),
                    pendingDeletedUuids: usage.pendingDeletedUuids(),
                  ),
      categoryNames:
          () => {
            for (final c in returnCategoriesProvider().categoriesMain)
              c.uuid: c.name,
          },
      load: (context, {required refreshFromStore}) async {
        await loadPeriod(
          context,
          refreshFromStore: refreshFromStore,
        );
      },
      loadForPeriod: (
        context, {
        required refreshFromStore,
        period,
      }) async {
        await loadPeriod(
          context,
          refreshFromStore: refreshFromStore,
          period: period,
        );
      },
      signature: () {
        final list = items();
        final hist = entries();
        int latest = 0;
        double total = 0;
        for (final i in list) {
          total += (i.quantity ?? 0) + i.costPrice;
        }
        for (final e in hist) {
          final t = e.createdAt?.millisecondsSinceEpoch ?? 0;
          if (t > latest) latest = t;
        }
        return '${list.length}|$total|${hist.length}|$latest|'
            '${returnCategoriesProvider().categoriesMain.length}|'
            '${produced ? production.signature() : usage.signature()}|'
            '${historyAllowed()}';
      },
      listen: (context) {
        if (produced) {
          returnProductionItemsProvider(context: context);
          returnProductionItemHistoryProvider(context: context);
          production.listen(context);
        } else {
          returnMaterialsProvider(context: context);
          returnMaterialsItemHistoryProvider(context: context);
          usage.listen(context);
        }
        shop(context);
      },
      money: (context, amount) => formatMoneyBig(amount: amount, context: context),
      openItem:
          (context, uuid) => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => productionStockItemPage(kind, uuid),
            ),
          ),
      openTable:
          (context, filters, period) => Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => productionStockTablePage(kind, filters, period),
            ),
          ),
      openHistory:
          (context, filters, period) => Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      productionStockHistoryPage(kind, filters, period),
            ),
          ),
    );
  }
}
