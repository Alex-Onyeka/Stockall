import 'dart:async';
import 'dart:convert';

import 'package:stockall/classes/temp_event_log/temp_event_log_class.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/local_database/lan/lan_alerts_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/events_log_provider.dart';

/// What happened to the shop's LAN server.
enum LanAlertKind {
  /// Two servers of the shop met; this one outranks the other.
  conflict,

  /// This device stopped serving: another server outranks it.
  demoted,

  /// This device's queue reached the server that outranked it.
  merged,

  /// A user on this device cleared a server that stopped answering.
  forceCleared,

  /// This desktop is the store server for a store other than the one
  /// signed in to (shown after the sign-in, not kept).
  otherStoreServed,
}

class LanAlert {
  const LanAlert({
    required this.id,
    required this.shopId,
    required this.kind,
    required this.title,
    required this.message,
    required this.createdAt,
    this.shown = false,
    this.columns = const [],
    this.rows = const [],
  });

  factory LanAlert.fromJson(Map<String, dynamic> json) => LanAlert(
    id: json['id'] as String,
    shopId: json['shop_id'] as int,
    kind: LanAlertKind.values.byName(json['kind'] as String),
    title: json['title'] as String,
    message: json['message'] as String,
    createdAt: DateTime.parse(json['created_at'] as String),
    shown: json['shown'] == true,
    columns: [
      for (final c in json['columns'] as List? ?? const []) '$c',
    ],
    rows: [
      for (final r in json['rows'] as List? ?? const [])
        if (r is List) [for (final c in r) '$c'],
    ],
  );

  final String id;
  final int shopId;
  final LanAlertKind kind;
  final String title;
  final String message;
  final DateTime createdAt;

  /// Shown once to a user with `Manage Local Server` (the pop-up).
  final bool shown;

  /// A table under the message: its headings, and one list of cells
  /// per row (stock below zero, stock changes still held, …).
  final List<String> columns;
  final List<List<String>> rows;

  LanAlert asShown() => LanAlert(
    id: id,
    shopId: shopId,
    kind: kind,
    title: title,
    message: message,
    createdAt: createdAt,
    shown: true,
    columns: columns,
    rows: rows,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'shop_id': shopId,
    'kind': kind.name,
    'title': title,
    'message': message,
    'created_at': createdAt.toUtc().toIso8601String(),
    'shown': shown,
    if (columns.isNotEmpty) 'columns': columns,
    if (rows.isNotEmpty) 'rows': rows,
  };
}

/// Raises LAN server alerts: kept on this device for the in-app pop-up,
/// and written to the events log (`table_name: local_server`).
class LanAlerts {
  static final LanAlerts _instance = LanAlerts._internal();
  factory LanAlerts() => _instance;
  LanAlerts._internal();

  final StreamController<LanAlert> _raised = StreamController.broadcast();

  /// Each alert as it is raised (the pop-up presenter listens).
  Stream<LanAlert> get raised => _raised.stream;

  Future<LanAlert> raise({
    required int shopId,
    required LanAlertKind kind,
    required String title,
    required String message,
    List<String> columns = const [],
    List<List<String>> rows = const [],
  }) async {
    final alert = LanAlert(
      id: uuidGen(),
      shopId: shopId,
      kind: kind,
      title: title,
      message: message,
      createdAt: DateTime.now().toUtc(),
      columns: columns,
      rows: rows,
    );
    await mainLocalLog('LAN alert (${kind.name}): $title. $message');
    try {
      await LanAlertsFunc().put(alert.id, jsonEncode(alert.toJson()));
    } catch (e) {
      await mainLocalLog('LAN alert not kept: $e');
    }
    try {
      await EventsLogProvider().createLog(
        TempEventLogClass(
          uuid: uuidGen(),
          createdAt: DateTime.now(),
          shopId: shopId,
          tableName: 'local_server',
          title: title,
          event: kind.name,
          message: message,
          staffName: currentUser().name,
          departmentUuid: null,
          departmentName: null,
        ),
      );
    } catch (e) {
      await mainLocalLog('LAN alert not logged: $e');
    }
    _raised.add(alert);
    return alert;
  }

  /// [alert] was shown: not shown again.
  Future<void> markShown(LanAlert alert) async {
    try {
      await LanAlertsFunc().put(alert.id, jsonEncode(alert.asShown().toJson()));
    } catch (e) {
      await mainLocalLog('LAN alert not marked shown: $e');
    }
  }

  /// The alerts of [shopId] not shown yet, oldest first.
  List<LanAlert> unshown(int shopId) => [
    for (final a in all().reversed)
      if (a.shopId == shopId && !a.shown) a,
  ];

  /// Every alert kept on this device, newest first.
  List<LanAlert> all() {
    final out = <LanAlert>[];
    for (final json in LanAlertsFunc().alerts().values) {
      try {
        out.add(LanAlert.fromJson(jsonDecode(json) as Map<String, dynamic>));
      } catch (_) {}
    }
    out.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return out;
  }
}
