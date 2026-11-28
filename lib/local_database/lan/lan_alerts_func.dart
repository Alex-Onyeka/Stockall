import 'dart:async';
import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:stockall/local_database/hive_box_helper.dart';
import 'package:stockall/main.dart';

/// LAN server alerts for users with `Manage Local Server`: two
/// servers met, this device stopped serving, its changes reached the new
/// server, … Keyed by alert id, valued by JSON (`LanAlert.toJson`).
///
/// Also holds, under keys starting with `_`:
/// - the shop whose queue this device is pushing to the server that
///   outranked it, under [pushingKey];
/// - the epoch this device served at before that, until the new server has
///   been told its queue is all there, under [handingOverKey];
/// - on a server: the former servers that told it so, under
///   [handedOverKey].
///
/// No adapter: a plain `Box<String>`. Shop data: cleared by
/// `clearAllShopData`.
class LanAlertsFunc {
  static final LanAlertsFunc instance = LanAlertsFunc._internal();
  factory LanAlertsFunc() => instance;
  LanAlertsFunc._internal();

  late Box<String> alertsBox;
  final String alertsBoxName = 'lanAlertsBoxStockall';
  static const String pushingKey = '_pushing_after_demotion';
  static const String handingOverKey = '_handing_over_epoch';
  static const String handedOverKey = '_handed_over';

  /// How many former servers' handovers a server keeps.
  static const int keptHandovers = 50;

  bool _warned = false;

  Future<void> init() async {
    try {
      alertsBox = await openBoxSafely<String>(alertsBoxName);
      await mainLocalLog('✅ LAN Alerts Box Initialized');
    } catch (e, s) {
      await mainLocalLog(
        'Error Initializing LAN Alerts Box: ${e.toString()}',
        error: e,
        stackTrace: s,
      );
    }
  }

  bool get isOpen {
    if (Hive.isBoxOpen(alertsBoxName)) return true;
    if (!_warned) {
      _warned = true;
      unawaited(
        mainLocalLog(
          '⚠️ LAN alerts box "$alertsBoxName" is not open: server alerts '
          'are not kept.',
        ),
      );
    }
    return false;
  }

  /// Alert JSON by id (the flags left out).
  Map<String, String> alerts() {
    if (!isOpen) return const {};
    return {
      for (final e in alertsBox.toMap().entries)
        if (!'${e.key}'.startsWith('_')) '${e.key}': e.value,
    };
  }

  Future<void> put(String id, String json) async {
    if (isOpen) await alertsBox.put(id, json);
  }

  /// The shop whose queue is being pushed after a demotion, if any.
  int? pushingShop() =>
      isOpen ? int.tryParse(alertsBox.get(pushingKey) ?? '') : null;

  Future<void> setPushingShop(int? shopId) async {
    if (!isOpen) return;
    if (shopId == null) {
      await alertsBox.delete(pushingKey);
    } else {
      await alertsBox.put(pushingKey, '$shopId');
    }
  }

  /// The epoch this device served at, while the server it now follows
  /// hasn't been told its queue is all there.
  int? handingOverEpoch() =>
      isOpen ? int.tryParse(alertsBox.get(handingOverKey) ?? '') : null;

  Future<void> setHandingOverEpoch(int? epoch) async {
    if (!isOpen) return;
    if (epoch == null) {
      await alertsBox.delete(handingOverKey);
    } else {
      await alertsBox.put(handingOverKey, '$epoch');
    }
  }

  /// On a server: the former servers (device, epoch) whose queues are all
  /// here, oldest first.
  List<({String device, int epoch})> handedOver() {
    if (!isOpen) return const [];
    try {
      final raw = jsonDecode(alertsBox.get(handedOverKey) ?? '[]') as List;
      return [
        for (final e in raw)
          if (e is Map && e['device'] is String && e['epoch'] is int)
            (device: e['device'] as String, epoch: e['epoch'] as int),
      ];
    } catch (_) {
      return const [];
    }
  }

  Future<void> recordHandedOver(String device, int epoch) async {
    if (!isOpen) return;
    final list = [
      for (final h in handedOver())
        if (h.device != device || h.epoch != epoch) h,
      (device: device, epoch: epoch),
    ];
    final kept = list.length > keptHandovers
        ? list.sublist(list.length - keptHandovers)
        : list;
    await alertsBox.put(
      handedOverKey,
      jsonEncode([
        for (final h in kept) {'device': h.device, 'epoch': h.epoch},
      ]),
    );
  }

  /// True the first time it is asked for [key] (an alert raised once).
  Future<bool> once(String key) async {
    if (!isOpen) return false;
    final k = '_once:$key';
    if (alertsBox.containsKey(k)) return false;
    await alertsBox.put(k, DateTime.now().toUtc().toIso8601String());
    return true;
  }

  Future<void> clearAlerts() async {
    if (isOpen) await alertsBox.clear();
  }
}
