import 'package:hive/hive.dart';
import 'package:stockall/local_database/hive_box_helper.dart';
import 'package:stockall/main.dart';

/// Where the LAN server's pulls from Supabase got to, per table:
/// - `cursor:<table>`: the largest `updated_at` (or `created_at`) Supabase
///   returned, as Supabase sent it (its clock, not this device's);
/// - `full:<table>`: when the last full pull of the table completed (whole
///   rows: the backfill, and the weekly reconcile);
/// - `reconciled:<table>`: when the last reconcile of the table completed
///   (a full pull, or the daily one by `uuid` and `updated_at`);
/// - `backfill`: when the last complete backfill finished.
///
/// No adapter: a plain `Box<String>`. Shop data: cleared by
/// `clearAllShopData`, so a new store starts with a full backfill.
class LanPullCursorsFunc {
  static final LanPullCursorsFunc instance = LanPullCursorsFunc._internal();
  factory LanPullCursorsFunc() => instance;
  LanPullCursorsFunc._internal();

  late Box<String> pullCursorsBox;
  final String pullCursorsBoxName = 'lanPullCursorsBoxStockall';

  Future<void> init() async {
    try {
      pullCursorsBox = await openBoxSafely<String>(pullCursorsBoxName);
      await mainLocalLog('✅ LAN Pull Cursors Box Initialized');
    } catch (e, s) {
      await mainLocalLog(
        'Error Initializing LAN Pull Cursors Box: ${e.toString()}',
        error: e,
        stackTrace: s,
      );
    }
  }

  String? cursor(String table) => pullCursorsBox.get('cursor:$table');

  Future<void> setCursor(String table, String value) =>
      pullCursorsBox.put('cursor:$table', value);

  DateTime? fullPullAt(String table) => _time('full:$table');

  Future<void> setFullPullAt(String table, DateTime at) =>
      pullCursorsBox.put('full:$table', at.toUtc().toIso8601String());

  DateTime? reconciledAt(String table) => _time('reconciled:$table');

  Future<void> setReconciledAt(String table, DateTime at) =>
      pullCursorsBox.put('reconciled:$table', at.toUtc().toIso8601String());

  DateTime? backfillAt() => _time('backfill');

  Future<void> setBackfillAt(DateTime at) =>
      pullCursorsBox.put('backfill', at.toUtc().toIso8601String());

  DateTime? _time(String key) {
    final value = pullCursorsBox.get(key);
    return value == null ? null : DateTime.tryParse(value);
  }

  Future<void> clearPullCursors() async {
    await pullCursorsBox.clear();
  }
}
