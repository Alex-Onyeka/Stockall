import 'package:stockall/classes/temp_customers/temp_customers_class.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_production_folder/temp_material_class/material_class.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_items/production_item.dart';
import 'package:stockall/local_database/customer_account_receipts/unsync_funcs/customer_account_updates/customer_account_update_func.dart';
import 'package:stockall/local_database/customers/customer_func.dart';
import 'package:stockall/local_database/lan/sent_entries_func.dart';
import 'package:stockall/local_database/materials/materials_func.dart';
import 'package:stockall/local_database/materials/unsync_funcs/materials_quantity_update/materials_quantity_update_func.dart';
import 'package:stockall/local_database/production_items/production_items_func.dart';
import 'package:stockall/local_database/production_items/unsync_funcs/production_items_quantity_update/production_items_quantity_update_func.dart';
import 'package:stockall/local_database/products/products_func.dart';
import 'package:stockall/local_database/products/unsync_funcs/quantity_update/quantity_update_func.dart';
import 'package:stockall/services/lan/lan_sent_marks.dart';

/// Stock and account changes still queued on this device (not yet on
/// Supabase). A row pulled from Supabase doesn't include them, so they are
/// added back before it is stored: local stock never rolls back over a
/// sale that is still queued (the app's own pulls use it too).
///
/// The amounts follow how they were applied locally: a product's
/// `isStorage` entry never changed its `quantity` (see the LAN delta RPCs),
/// and a customer's entry changes the balance or, with `isBalance: false`,
/// the cash reward.
class PendingDeltas {
  PendingDeltas._();

  static double _signed(double amount, bool isIncrement) =>
      isIncrement ? amount : -amount;

  /// The tables whose rows carry queued deltas.
  static const Set<String> tables = {
    'products',
    'production_materials',
    'production_items',
    'customers',
  };

  /// What [table]'s delta queue holds now (its keys): a pull compares it
  /// before and after, because an entry that left the queue meanwhile may
  /// already be in the row it fetched (it would be counted twice).
  static Set<Object?> queueKeys(String table) {
    switch (table) {
      case 'products':
        return QuantityUpdateFunc().quantityUpdateBox.keys.toSet();
      case 'production_materials':
        return MaterialsQuantityUpdateFunc().materialsQuantityUpdateBox.keys
            .toSet();
      case 'production_items':
        return ProductionItemsQuantityUpdateFunc()
            .productionItemsQuantityUpdateBox
            .keys
            .toSet();
      case 'customers':
        return CustomerAccountUpdateFunc().customerAccountUpdateBox.keys
            .toSet();
    }
    return const {};
  }

  /// The box name of [table]'s delta queue, or null.
  static String? queueName(String table) {
    switch (table) {
      case 'products':
        return QuantityUpdateFunc().quantityUpdateBoxName;
      case 'production_materials':
        return MaterialsQuantityUpdateFunc().materialsQuantityUpdateBoxName;
      case 'production_items':
        return ProductionItemsQuantityUpdateFunc()
            .productionItemsQuantityUpdateBoxName;
      case 'customers':
        return CustomerAccountUpdateFunc().customerAccountUpdateBoxName;
    }
    return null;
  }

  /// Nothing that was in [table]'s delta queue at [before] has left it
  /// (been sent), and none of its entries is out now (sent, no answer
  /// yet). Otherwise rows fetched since may already include it, and adding
  /// it back would count it twice: those rows are fetched again later
  /// instead.
  static bool stillQueued(String table, Set<Object?> before) =>
      !inFlight(table) && queueKeys(table).containsAll(before);

  /// Whether an entry of [table]'s queue is out: marked as sent and not
  /// yet answered. Not those waiting for a LAN server other than the one
  /// the queues go to now: they may wait for days, so instead their items
  /// keep the stored value ([heldItems]).
  static bool inFlight(String table) {
    final queue = queueName(table);
    if (queue == null) return false;
    final sent = SentEntriesFunc();
    final to = LanSentMarks.target();
    return sent.sentKeys(queue).any((key) {
      final server = sent.serverOf(queue, key);
      return server == null || server == to;
    });
  }

  /// The items of [table] with a change sent to a LAN server other than
  /// the one the queues go to now, never answered: a pulled row may or may
  /// not include it, the stored row does.
  static Set<String> heldItems(String table) {
    final queue = queueName(table);
    if (queue == null) return const {};
    final sent = SentEntriesFunc();
    final to = LanSentMarks.target();
    final keys = {
      for (final key in sent.sentKeys(queue))
        if (sent.serverOf(queue, key) case final server?)
          if (server != to) key,
    };
    if (keys.isEmpty) return const {};
    String? itemOf(String key) {
      switch (table) {
        case 'products':
          return QuantityUpdateFunc().quantityUpdateBox.get(key)?.productUuid;
        case 'production_materials':
          return MaterialsQuantityUpdateFunc().materialsQuantityUpdateBox
              .get(key)
              ?.materialUuid;
        case 'production_items':
          return ProductionItemsQuantityUpdateFunc()
              .productionItemsQuantityUpdateBox
              .get(key)
              ?.productionItemUuid;
        case 'customers':
          return CustomerAccountUpdateFunc().customerAccountUpdateBox
              .get(key)
              ?.customerUuid;
      }
      return null;
    }

    return {
      for (final key in keys)
        if (itemOf(key) case final item?) item,
    };
  }

  /// Signed quantity still queued per product uuid.
  static Map<String, double> products() {
    final out = <String, double>{};
    for (final q in QuantityUpdateFunc().getQuantitiesUpdate()) {
      if (q.isStorage == true) continue;
      out.update(
        q.productUuid,
        (v) => v + _signed(q.quantity, q.isIncrement),
        ifAbsent: () => _signed(q.quantity, q.isIncrement),
      );
    }
    return out;
  }

  static Map<String, double> materials() {
    final out = <String, double>{};
    for (final q in MaterialsQuantityUpdateFunc().getMaterialsQuantitiesUpdate()) {
      out.update(
        q.materialUuid,
        (v) => v + _signed(q.quantity, q.isIncrement),
        ifAbsent: () => _signed(q.quantity, q.isIncrement),
      );
    }
    return out;
  }

  static Map<String, double> productionItems() {
    final out = <String, double>{};
    for (final q in ProductionItemsQuantityUpdateFunc()
        .getProductionItemsQuantitiesUpdate()) {
      out.update(
        q.productionItemUuid,
        (v) => v + _signed(q.quantity, q.isIncrement),
        ifAbsent: () => _signed(q.quantity, q.isIncrement),
      );
    }
    return out;
  }

  /// Per customer uuid: (balance, cash reward) still queued.
  static Map<String, ({double balance, double reward})> customers() {
    final out = <String, ({double balance, double reward})>{};
    for (final u in CustomerAccountUpdateFunc().getQuantitiesUpdate()) {
      final amount = _signed(u.amount, u.isIncrement);
      final now = out[u.customerUuid] ?? (balance: 0.0, reward: 0.0);
      out[u.customerUuid] = u.isBalance
          ? (balance: now.balance + amount, reward: now.reward)
          : (balance: now.balance, reward: now.reward + amount);
    }
    return out;
  }

  /// Adds back what is queued for the rows of [table], in place. Rows of
  /// other tables are left as they are. Rows of [heldItems] keep the
  /// stored amount instead (when there is one).
  static void reapply(String table, Iterable<Object?> rows) {
    final held = heldItems(table);
    switch (table) {
      case 'products':
        final pending = products();
        if (pending.isEmpty) return;
        for (final p in rows.whereType<TempProductClass>()) {
          final stored = held.contains(p.uuid)
              ? ProductsFunc().productBox.get(p.uuid)
              : null;
          if (stored != null) {
            p.quantity = stored.quantity;
            continue;
          }
          final d = pending[p.uuid];
          if (d != null && d != 0) p.quantity = (p.quantity ?? 0) + d;
        }
      case 'production_materials':
        final pending = materials();
        if (pending.isEmpty) return;
        for (final m in rows.whereType<MaterialClass>()) {
          final stored = held.contains(m.uuid)
              ? MaterialsFunc().materialBox.get(m.uuid)
              : null;
          if (stored != null) {
            m.quantity = stored.quantity;
            continue;
          }
          final d = pending[m.uuid];
          if (d != null && d != 0) m.quantity = (m.quantity ?? 0) + d;
        }
      case 'production_items':
        final pending = productionItems();
        if (pending.isEmpty) return;
        for (final i in rows.whereType<ProductionItem>()) {
          final stored = held.contains(i.uuid)
              ? ProductionItemsFunc().productionItemsBox.get(i.uuid)
              : null;
          if (stored != null) {
            i.quantity = stored.quantity;
            continue;
          }
          final d = pending[i.uuid];
          if (d != null && d != 0) i.quantity = (i.quantity ?? 0) + d;
        }
      case 'customers':
        final pending = customers();
        if (pending.isEmpty) return;
        for (final c in rows.whereType<TempCustomersClass>()) {
          final stored = held.contains(c.uuid)
              ? CustomerFunc().customerBox.get(c.uuid)
              : null;
          if (stored != null) {
            c.balance = stored.balance;
            c.cashReward = stored.cashReward;
            continue;
          }
          final d = pending[c.uuid];
          if (d == null) continue;
          if (d.balance != 0) c.balance = (c.balance ?? 0) + d.balance;
          if (d.reward != 0) c.cashReward = (c.cashReward ?? 0) + d.reward;
        }
    }
  }
}
