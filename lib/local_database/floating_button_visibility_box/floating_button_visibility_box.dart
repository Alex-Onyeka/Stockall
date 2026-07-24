import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:stockall/main.dart';

class FloatingButtonVisibilityBox extends ChangeNotifier {
  static final FloatingButtonVisibilityBox _instance =
      FloatingButtonVisibilityBox._internal();

  factory FloatingButtonVisibilityBox() => _instance;

  FloatingButtonVisibilityBox._internal();

  static const String _floatingButtonVisibilityBoxName =
      'floatingButtonVisibilityBoxStockall';
  static const String _visibilityKey = 'isVisible';

  Box<bool>? _floatingButtonVisibilityBox;

  /// Initialize Hive and open visibility boxes
  Future<void> init() async {
    try {
      _floatingButtonVisibilityBox ??=
          await Hive.openBox<bool>(
            _floatingButtonVisibilityBoxName,
          );

      // Set default value for visibility if not set
      if (!_floatingButtonVisibilityBox!.containsKey(
        _visibilityKey,
      )) {
        await _floatingButtonVisibilityBox!.put(
          _visibilityKey,
          true,
        );
      }

      await mainLocalLog("✅ Visibility Box Opened");
    } catch (e, s) {
      await mainLocalLog(
        'Error Initializing Floating Utility Button Box: ${e.toString()}',
        error: e,
        stackTrace: s,
      );
    }
  }

  // ------------------- Visibility Methods -------------------
  Future<void> setDataVisibility(bool value) async {
    if (_floatingButtonVisibilityBox == null) await init();
    await _floatingButtonVisibilityBox!.put(
      _visibilityKey,
      value,
    );
    notifyListeners();
  }

  bool getDataVisibility() {
    if (_floatingButtonVisibilityBox == null) return true;
    return _floatingButtonVisibilityBox!.get(
      _visibilityKey,
      defaultValue: true,
    )!;
  }

  Future<void> toggleDataVisibility() async {
    if (_floatingButtonVisibilityBox == null) await init();
    notifyListeners();
    final current = getDataVisibility();
    await setDataVisibility(!current);
  }
}
