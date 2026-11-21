import 'package:hive/hive.dart';
import 'package:stockall/local_database/hive_box_helper.dart';

/// Cross-platform Hive-backed log store (works on Mobile, Web, and Desktop).
/// Retains up to [maxLogs] entries in strict FIFO order: once [maxLogs] is
/// reached, each new insert removes the oldest entry.
class AppLogsFunc {
  static final AppLogsFunc instance = AppLogsFunc._internal();
  factory AppLogsFunc() => instance;
  AppLogsFunc._internal();

  static const String boxName = 'appLogsBoxStockall';
  static const int maxLogs = 3000;

  Box<String>? _box;
  final List<String> _pending = [];
  bool _initialized = false;

  Future<void> init() async {
    try {
      _box = await openBoxSafely<String>(boxName);
      _initialized = true;
      if (_pending.isNotEmpty) {
        final toFlush = List<String>.from(_pending);
        _pending.clear();
        for (final entry in toFlush) {
          await _appendEntry(entry);
        }
      }
    } catch (_) {}
  }

  Future<void> _appendEntry(String entry) async {
    final box = _box;
    if (box == null || !box.isOpen) return;
    await box.add(entry);
    while (box.length > maxLogs) {
      await box.deleteAt(0);
    }
  }

  Future<void> addLog(String entry) async {
    if (!_initialized || _box == null || !_box!.isOpen) {
      _pending.add(entry);
      if (_pending.length > maxLogs) {
        _pending.removeRange(0, _pending.length - maxLogs);
      }
      return;
    }
    try {
      await _appendEntry(entry);
    } catch (_) {}
  }

  List<String> getLogs() {
    if (_box == null || !_box!.isOpen) {
      return List<String>.from(_pending);
    }
    return _box!.values.toList();
  }

  String readLogsFormatted() {
    final logs = getLogs();
    if (logs.isEmpty) {
      return 'No logs recorded yet.';
    }
    return logs.join('\n\n');
  }

  Future<void> clearLogs() async {
    _pending.clear();
    if (_box != null && _box!.isOpen) {
      await _box!.clear();
    }
  }
}
