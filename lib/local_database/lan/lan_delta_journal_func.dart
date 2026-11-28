import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:stockall/local_database/hive_box_helper.dart';
import 'package:stockall/main.dart';

/// The LAN server's delta journal: each delta entry it is applying, written
/// before the row and the queue change (JSON by queue-entry uuid). Empty
/// unless a crash cut an apply off; `initHive` finishes those. No adapter:
/// a plain `Box<String>`. Device data: not cleared on logout.
class LanDeltaJournalFunc {
  static final LanDeltaJournalFunc instance = LanDeltaJournalFunc._internal();
  factory LanDeltaJournalFunc() => instance;
  LanDeltaJournalFunc._internal();

  late Box<String> journalBox;
  final String journalBoxName = 'lanDeltaJournalBoxStockall';

  Future<void> init() async {
    try {
      journalBox = await openBoxSafely<String>(journalBoxName);
      await mainLocalLog('✅ LAN Delta Journal Box Initialized');
    } catch (e, s) {
      await mainLocalLog(
        'Error Initializing LAN Delta Journal Box: ${e.toString()}',
        error: e,
        stackTrace: s,
      );
    }
  }

  Map<String, Map<String, dynamic>> pending() => {
    for (final key in journalBox.keys)
      '$key': Map<String, dynamic>.from(
        jsonDecode(journalBox.get(key)!) as Map,
      ),
  };

  Future<void> put(String id, Map<String, dynamic> record) =>
      journalBox.put(id, jsonEncode(record));

  Future<void> remove(String id) => journalBox.delete(id);
}
