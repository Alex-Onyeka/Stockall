import 'dart:convert';

import 'package:stockall/local_database/customer_account_receipts/unsync_funcs/customer_account_updates/customer_account_update_func.dart';
import 'package:stockall/local_database/customers/customer_func.dart';
import 'package:stockall/local_database/lan/sent_entries_func.dart';
import 'package:stockall/local_database/materials/materials_func.dart';
import 'package:stockall/local_database/materials/unsync_funcs/materials_quantity_update/materials_quantity_update_func.dart';
import 'package:stockall/local_database/production_items/production_items_func.dart';
import 'package:stockall/local_database/production_items/unsync_funcs/production_items_quantity_update/production_items_quantity_update_func.dart';
import 'package:stockall/local_database/products/products_func.dart';
import 'package:stockall/local_database/products/unsync_funcs/quantity_update/quantity_update_func.dart';
import 'package:stockall/services/lan/lan_constants.dart';
import 'package:stockall/services/lan/lan_handoffs.dart';

/// One stock or account change this device handed to a LAN server and
/// still holds: listed when that server was force-cleared, so
/// stock can be checked by hand. Never replayed.
class LanHeldDelta {
  const LanHeldDelta({
    required this.kind,
    required this.itemUuid,
    required this.amount,
    required this.isIncrement,
    required this.source,
    required this.handedAt,
  });

  /// Product, Material, Production item or Customer account.
  final String kind;
  final String itemUuid;

  /// Always positive; [isIncrement] gives the direction.
  final double amount;
  final bool isIncrement;

  /// The sale (a checkout's receipt) or the queued change it came from.
  final String source;
  final DateTime handedAt;
}

typedef _Rpc = ({String kind, String itemKey, String amountKey});

const Map<String, _Rpc> _rpcs = {
  'update_product_quantities': (
    kind: 'Product',
    itemKey: 'itemUuid',
    amountKey: 'quantity',
  ),
  LanConstants.stockCheckoutRpc: (
    kind: 'Product',
    itemKey: 'itemUuid',
    amountKey: 'quantity',
  ),
  'update_materials_quantities': (
    kind: 'Material',
    itemKey: 'materialItemUuid',
    amountKey: 'quantity',
  ),
  'update_production_items_quantities': (
    kind: 'Production item',
    itemKey: 'productionItemUuid',
    amountKey: 'quantity',
  ),
  'update_customer_account': (
    kind: 'Customer account',
    itemKey: 'customerUuid',
    amountKey: 'amount',
  ),
};

String _short(String id) => id.length > 8 ? id.substring(0, 8) : id;

/// The changes in the delta [handoffs], one per item update. Unreadable
/// bodies are skipped.
List<LanHeldDelta> heldDeltasOf(Iterable<LanHandoff> handoffs) {
  final out = <LanHeldDelta>[];
  for (final h in handoffs) {
    if (h.kind != LanHandoffKind.delta || !h.path.startsWith('rpc/')) {
      continue;
    }
    final name = h.path.substring('rpc/'.length);
    final rpc = _rpcs[name];
    final body = h.body;
    if (rpc == null || body == null) continue;
    try {
      final decoded = jsonDecode(body);
      if (decoded is! Map) continue;
      final receipt = decoded['receipt_uuid'];
      final updates = decoded['updates'];
      if (updates is! List) continue;
      for (final u in updates) {
        if (u is! Map) continue;
        final item = u[rpc.itemKey];
        final amount = u[rpc.amountKey];
        final up = u['isIncrement'] ?? true;
        if (item is! String || amount is! num || up is! bool) continue;
        final queued = u['hiveUuid'];
        out.add(
          LanHeldDelta(
            kind: rpc.kind,
            itemUuid: item,
            amount: amount.toDouble().abs(),
            isIncrement: amount < 0 ? !up : up,
            source: receipt is String
                ? 'Sale ${_short(receipt)}'
                : queued is String
                ? 'Change ${_short(queued)}'
                : '-',
            handedAt: h.handedAt,
          ),
        );
      }
    } catch (_) {
      continue;
    }
  }
  return out;
}

/// The queued stock and account changes sent to [serverDeviceId] that it
/// never answered for (see `LanSentMarks`): listed with the delta
/// handoffs when that server is cleared. They stay queued for it.
List<LanHeldDelta> heldQueuedFor(String serverDeviceId) {
  final sent = SentEntriesFunc();
  final held = sent.heldFor(serverDeviceId);
  if (held.isEmpty) return const [];
  final out = <LanHeldDelta>[];
  void add(
    String queue,
    String key,
    String kind,
    String? item,
    double? amount,
    bool? up,
  ) {
    if (item == null || amount == null || up == null) return;
    out.add(
      LanHeldDelta(
        kind: kind,
        itemUuid: item,
        amount: amount.abs(),
        isIncrement: amount < 0 ? !up : up,
        source: 'Not confirmed',
        handedAt: sent.sentAt(queue, key) ?? DateTime.now(),
      ),
    );
  }

  try {
    final products = QuantityUpdateFunc();
    for (final key
        in held[products.quantityUpdateBoxName] ?? const <String>{}) {
      final q = products.quantityUpdateBox.get(key);
      add(
        products.quantityUpdateBoxName,
        key,
        'Product',
        q?.productUuid,
        q?.quantity,
        q?.isIncrement,
      );
    }
    final materials = MaterialsQuantityUpdateFunc();
    for (final key
        in held[materials.materialsQuantityUpdateBoxName] ?? const <String>{}) {
      final q = materials.materialsQuantityUpdateBox.get(key);
      add(
        materials.materialsQuantityUpdateBoxName,
        key,
        'Material',
        q?.materialUuid,
        q?.quantity,
        q?.isIncrement,
      );
    }
    final items = ProductionItemsQuantityUpdateFunc();
    for (final key in held[items.productionItemsQuantityUpdateBoxName] ??
        const <String>{}) {
      final q = items.productionItemsQuantityUpdateBox.get(key);
      add(
        items.productionItemsQuantityUpdateBoxName,
        key,
        'Production item',
        q?.productionItemUuid,
        q?.quantity,
        q?.isIncrement,
      );
    }
    final accounts = CustomerAccountUpdateFunc();
    for (final key
        in held[accounts.customerAccountUpdateBoxName] ?? const <String>{}) {
      final u = accounts.customerAccountUpdateBox.get(key);
      add(
        accounts.customerAccountUpdateBoxName,
        key,
        'Customer account',
        u?.customerUuid,
        u?.amount,
        u?.isIncrement,
      );
    }
  } catch (_) {
    // A queue box that isn't open: what could be read is listed.
  }
  return out;
}

/// The item's name on this device, if it has it.
String? heldDeltaItemName(LanHeldDelta d) {
  try {
    switch (d.kind) {
      case 'Product':
        return ProductsFunc().productBox.get(d.itemUuid)?.name;
      case 'Material':
        return MaterialsFunc().materialBox.get(d.itemUuid)?.name;
      case 'Production item':
        return ProductionItemsFunc().productionItemsBox.get(d.itemUuid)?.name;
      case 'Customer account':
        return CustomerFunc().customerBox.get(d.itemUuid)?.name;
    }
  } catch (_) {
    // A box that isn't open: the uuid is shown instead.
  }
  return null;
}

String _amount(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : '$v';

/// The alert table for [deltas]: item, change, where it came from, when.
const List<String> heldDeltaColumns = ['Item', 'Change', 'From', 'Sent'];

List<List<String>> heldDeltaRows(
  List<LanHeldDelta> deltas, {
  String? Function(LanHeldDelta d) nameOf = heldDeltaItemName,
}) => [
  for (final d in deltas)
    [
      '${nameOf(d) ?? _short(d.itemUuid)} (${d.kind})',
      '${d.isIncrement ? '+' : '-'}${_amount(d.amount)}',
      d.source,
      d.handedAt.toLocal().toIso8601String().substring(0, 16).replaceAll(
        'T',
        ' ',
      ),
    ],
];
