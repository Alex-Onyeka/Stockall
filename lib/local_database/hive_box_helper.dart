import 'package:hive/hive.dart';
import 'package:stockall/main.dart';

/// Safely registers an adapter if not already registered.
void safeRegisterAdapter<T>(TypeAdapter<T> adapter) {
  if (!Hive.isAdapterRegistered(adapter.typeId)) {
    try {
      Hive.registerAdapter<T>(adapter);
    } catch (_) {}
  }
}

/// Safely opens a Hive box. If opening fails due to file corruption,
/// unknown typeId, or schema migration mismatch, or if any entries cannot
/// be deserialized without error, it automatically closes, deletes the
/// corrupted local file from disk, and reopens a clean box.
Future<Box<T>> openBoxSafely<T>(String boxName) async {
  Box<T>? box;
  try {
    if (Hive.isBoxOpen(boxName)) {
      box = Hive.box<T>(boxName);
    } else {
      box = await Hive.openBox<T>(boxName);
    }
    // Deep test: Verify all values can be read/deserialized without throwing HiveError / unknown typeId
    for (final _ in box.values) {}
    return box;
  } catch (e, s) {
    await mainLocalLog(
      '⚠️ Hive box "$boxName" failed to open or contains corrupted/incompatible entries ($e). Purging corrupted box from disk and resetting...',
      error: e,
      stackTrace: s,
    );
    try {
      if (box != null && box.isOpen) {
        await box.close();
      } else if (Hive.isBoxOpen(boxName)) {
        await Hive.box(boxName).close();
      }
      await Hive.deleteBoxFromDisk(boxName);
      await mainLocalLog(
        '🧹 Deleted corrupted/incompatible box "$boxName" from disk.',
      );
      final recoveredBox = await Hive.openBox<T>(boxName);
      await mainLocalLog(
        '✅ Reinitialized clean box "$boxName".',
      );
      return recoveredBox;
    } catch (innerError, innerS) {
      await mainLocalLog(
        '❌ Fatal error reinitializing box "$boxName": $innerError',
        error: innerError,
        stackTrace: innerS,
      );
      rethrow;
    }
  }
}

