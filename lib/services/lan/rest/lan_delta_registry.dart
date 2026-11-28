import 'package:stockall/classes/temp_customer_account_receipts/unsynced/customer_account_update/customer_account_update.dart';
import 'package:stockall/classes/temp_product_class/unsynced/quantity_update/quantity_update.dart';
import 'package:stockall/classes/temp_production_folder/temp_material_class/unsynced/material_quantity_update/material_quantity_update.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_items/unsynced/production_item_quantity_update/production_item_quantity_update.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/local_database/customer_account_receipts/unsync_funcs/customer_account_updates/customer_account_update_func.dart';
import 'package:stockall/local_database/customers/customer_func.dart';
import 'package:stockall/local_database/lan/lan_applied_deltas_func.dart';
import 'package:stockall/local_database/lan/lan_delta_journal_func.dart';
import 'package:stockall/local_database/materials/materials_func.dart';
import 'package:stockall/local_database/materials/unsync_funcs/materials_quantity_update/materials_quantity_update_func.dart';
import 'package:stockall/local_database/production_items/production_items_func.dart';
import 'package:stockall/local_database/production_items/unsync_funcs/production_items_quantity_update/production_items_quantity_update_func.dart';
import 'package:stockall/local_database/products/products_func.dart';
import 'package:stockall/local_database/products/unsync_funcs/quantity_update/quantity_update_func.dart';
import 'package:stockall/services/lan/rest/lan_delta_rpcs.dart';

/// The tables the delta RPCs change: the ones whose deletes the server
/// remembers.
const Set<String> lanDeltaTables = {
  'products',
  'production_materials',
  'production_items',
  'customers',
};

/// Asks Supabase about an item the server doesn't hold
/// ([LanRemoteRow.unknown] when the server is offline).
typedef LanRemoteLookup =
    Future<LanRemoteRow> Function(String table, String uuid);

/// The applied-delta record, on the server's Hive.
class HiveAppliedDeltas implements LanAppliedDeltas {
  const HiveAppliedDeltas();

  @override
  bool contains(String key) => LanAppliedDeltasFunc().contains(key);

  @override
  Future<void> add(String key) => LanAppliedDeltasFunc().add(key);
}

/// The delta journal, on the server's Hive.
class HiveDeltaJournal implements LanDeltaJournal {
  const HiveDeltaJournal();

  @override
  Map<String, Map<String, dynamic>> pending() => LanDeltaJournalFunc().pending();

  @override
  Future<void> put(String id, Map<String, dynamic> record) =>
      LanDeltaJournalFunc().put(id, record);

  @override
  Future<void> remove(String id) => LanDeltaJournalFunc().remove(id);
}

/// Finishes the delta entries a crash cut off on this device, if it was a
/// LAN server (see [LanDeltaRpcs.recover]). Run once the boxes are open
/// and before anything else can change them.
Future<int> recoverLanDeltaJournal() => LanDeltaRpcs(
  rpcs: lanDeltaRpcs(shopId: () => 0),
  applied: const HiveAppliedDeltas(),
  journal: const HiveDeltaJournal(),
).recover();

/// The four delta RPCs on the server's Hive, inferred from how the app
/// calls them and applies the same change offline (the Supabase SQL was not
/// available, so these are assumptions to check against it):
/// - the row's amount moves by the entry's signed amount, starting from 0
///   when it has none, and its `updated_at` becomes now (so other devices'
///   incremental syncs see it);
/// - an entry for an item of another store (this server's box holds it
///   under another `shop_id`, or Supabase says so when the server is
///   online) changes nothing and is not queued: the server only changes
///   its own store;
/// - an entry for an item deleted here in the last 30 days (the server's
///   record of deleted items), or that Supabase answers it has no row for
///   (then recorded as deleted), is dropped, as Supabase ignores a delta
///   for a deleted row;
/// - an entry for an item the server can't place refuses the whole batch
///   with a retryable error (`LAN06`): the client keeps it queued and sends
///   it again once the server has pulled the item;
/// - the server queues the same change in its own queue, so its
///   `syncData()` sends it to Supabase once.
List<LanDeltaRpc> lanDeltaRpcs({
  required int Function() shopId,
  LanRemoteLookup? remoteLookup,
  bool Function(String table, String uuid)? wasDeleted,
  Future<void> Function(String table, String uuid)? recordDeleted,
}) {
  DateTime now() => DateTime.now().toUtc();
  // Asked before the lock is taken: only for an item this server neither
  // holds nor deleted.
  Future<LanRemoteRow> lookup(int? localShop, String table, String uuid) async {
    if (localShop != null || (wasDeleted?.call(table, uuid) ?? false)) {
      return LanRemoteRow.unknown;
    }
    return await remoteLookup?.call(table, uuid) ?? LanRemoteRow.unknown;
  }

  Future<LanItemPlace> place(
    int? localShop,
    String table,
    String uuid,
    LanRemoteRow remote,
  ) async {
    if (localShop != null) {
      return localShop == shopId() ? LanItemPlace.here : LanItemPlace.otherStore;
    }
    if (wasDeleted?.call(table, uuid) ?? false) return LanItemPlace.deleted;
    switch (remote.answer) {
      case LanRemoteAnswer.missing:
        await recordDeleted?.call(table, uuid);
        return LanItemPlace.deleted;
      case LanRemoteAnswer.found:
        final shop = remote.shopId;
        // Supabase saying "this store" does not make a missing item local:
        // the server hasn't pulled it yet.
        return shop != null && shop != shopId()
            ? LanItemPlace.otherStore
            : LanItemPlace.unknown;
      case LanRemoteAnswer.unknown:
        return LanItemPlace.unknown;
    }
  }

  return [
    LanDeltaRpc(
      name: 'update_product_quantities',
      queueBox: 'quantityUpdateBoxStockall',
      queueEmpty: () => QuantityUpdateFunc().quantityUpdateBox.isEmpty,
      itemKey: 'itemUuid',
      amountKey: 'quantity',
      returnsEntries: true,
      lookup: (uuid) => lookup(
        ProductsFunc().productBox.get(uuid)?.shopId,
        'products',
        uuid,
      ),
      locate: (uuid, remote) => place(
        ProductsFunc().productBox.get(uuid)?.shopId,
        'products',
        uuid,
        remote,
      ),
      next: (e) {
        // No app code sends isStorage: true today and its meaning on
        // Supabase is unknown: it is only passed on to Supabase.
        if (e.raw['isStorage'] == true) return null;
        final product = ProductsFunc().productBox.get(e.itemUuid)!;
        return (product.quantity ?? 0) + e.signed;
      },
      write: (e, value) async {
        final product = ProductsFunc().productBox.get(e.itemUuid);
        if (product == null) return;
        product
          ..quantity = value
          ..updatedAt = now();
        await ProductsFunc().productBox.put(e.itemUuid, product);
      },
      queueUuid: (e) => e.hiveUuid ?? uuidGen(),
      queue: (e, uuid) => QuantityUpdateFunc().createQuantityUpdate(
        QuantityUpdate(
          uuid: uuid,
          createdAt: DateTime.now(),
          quantity: e.amount,
          productUuid: e.itemUuid,
          isIncrement: e.isIncrement,
          isStorage: e.raw['isStorage'] == true,
        ),
      ),
    ),
    LanDeltaRpc(
      name: 'update_materials_quantities',
      queueBox: 'materialsQuantityUpdateBoxStockall',
      queueEmpty: () => MaterialsQuantityUpdateFunc().materialsQuantityUpdateBox.isEmpty,
      itemKey: 'materialItemUuid',
      amountKey: 'quantity',
      // The client merges a material's entries into one.
      keyIncludesAmount: true,
      lookup: (uuid) => lookup(
        MaterialsFunc().materialBox.get(uuid)?.shopId,
        'production_materials',
        uuid,
      ),
      locate: (uuid, remote) => place(
        MaterialsFunc().materialBox.get(uuid)?.shopId,
        'production_materials',
        uuid,
        remote,
      ),
      next: (e) {
        final material = MaterialsFunc().materialBox.get(e.itemUuid)!;
        return (material.quantity ?? 0) + e.signed;
      },
      write: (e, value) async {
        final material = MaterialsFunc().materialBox.get(e.itemUuid);
        if (material == null) return;
        material
          ..quantity = value
          ..updatedAt = now();
        await MaterialsFunc().materialBox.put(e.itemUuid, material);
      },
      queueUuid: (_) => uuidGen(),
      // Put by its own key, not merged into another entry: putting it
      // again after a crash must not add the change twice.
      queue: (e, uuid) =>
          MaterialsQuantityUpdateFunc().materialsQuantityUpdateBox.put(
            uuid,
            MaterialQuantityUpdate(
              uuid: uuid,
              createdAt: DateTime.now(),
              quantity: e.amount,
              materialUuid: e.itemUuid,
              isIncrement: e.isIncrement,
            ),
          ),
    ),
    LanDeltaRpc(
      name: 'update_production_items_quantities',
      queueBox: 'productionItemsQuantityUpdateBoxStockall',
      queueEmpty: () => ProductionItemsQuantityUpdateFunc().productionItemsQuantityUpdateBox.isEmpty,
      itemKey: 'productionItemUuid',
      amountKey: 'quantity',
      // The client merges an item's entries into one.
      keyIncludesAmount: true,
      lookup: (uuid) => lookup(
        ProductionItemsFunc().productionItemsBox.get(uuid)?.shopId,
        'production_items',
        uuid,
      ),
      locate: (uuid, remote) => place(
        ProductionItemsFunc().productionItemsBox.get(uuid)?.shopId,
        'production_items',
        uuid,
        remote,
      ),
      next: (e) {
        final item = ProductionItemsFunc().productionItemsBox.get(e.itemUuid)!;
        return (item.quantity ?? 0) + e.signed;
      },
      write: (e, value) async {
        final item = ProductionItemsFunc().productionItemsBox.get(e.itemUuid);
        if (item == null) return;
        item
          ..quantity = value
          ..updatedAt = now();
        await ProductionItemsFunc().productionItemsBox.put(e.itemUuid, item);
      },
      queueUuid: (_) => uuidGen(),
      // Put by its own key, not merged (see materials).
      queue: (e, uuid) => ProductionItemsQuantityUpdateFunc()
          .productionItemsQuantityUpdateBox
          .put(
            uuid,
            ProductionItemQuantityUpdate(
              uuid: uuid,
              createdAt: DateTime.now(),
              quantity: e.amount,
              productionItemUuid: e.itemUuid,
              isIncrement: e.isIncrement,
            ),
          ),
    ),
    LanDeltaRpc(
      name: 'update_customer_account',
      queueBox: 'customerAccountUpdateBoxStockall',
      queueEmpty: () => CustomerAccountUpdateFunc().customerAccountUpdateBox.isEmpty,
      itemKey: 'customerUuid',
      amountKey: 'amount',
      lookup: (uuid) => lookup(
        CustomerFunc().customerBox.get(uuid)?.shopId,
        'customers',
        uuid,
      ),
      locate: (uuid, remote) => place(
        CustomerFunc().customerBox.get(uuid)?.shopId,
        'customers',
        uuid,
        remote,
      ),
      // isBalance: the account balance; otherwise the cash reward.
      next: (e) {
        final customer = CustomerFunc().customerBox.get(e.itemUuid)!;
        return e.raw['isBalance'] != false
            ? (customer.balance ?? 0) + e.signed
            : (customer.cashReward ?? 0) + e.signed;
      },
      write: (e, value) async {
        final customer = CustomerFunc().customerBox.get(e.itemUuid);
        if (customer == null) return;
        if (e.raw['isBalance'] != false) {
          customer.balance = value;
        } else {
          customer.cashReward = value;
        }
        customer.updatedAt = now();
        await CustomerFunc().customerBox.put(e.itemUuid, customer);
      },
      queueUuid: (e) => e.hiveUuid ?? uuidGen(),
      queue: (e, uuid) => CustomerAccountUpdateFunc().createCustomerAccountUpdate(
        CustomerAccountUpdate(
          uuid: uuid,
          createdAt: DateTime.now(),
          amount: e.amount,
          customerUuid: e.itemUuid,
          isIncrement: e.isIncrement,
          isBalance: e.raw['isBalance'] != false,
        ),
      ),
    ),
  ];
}
