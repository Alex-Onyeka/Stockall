import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:stockall/main.dart';

class VisibilityBox extends ChangeNotifier {
  static final VisibilityBox _instance =
      VisibilityBox._internal();

  factory VisibilityBox() => _instance;

  VisibilityBox._internal();

  static const String _visibilityBoxName =
      'visibilityBoxStockall';
  static const String _visibilityKey = 'isDataVisible';

  Box<bool>? _visibilityBox;

  /// Initialize Hive and open visibility boxes
  Future<void> init() async {
    try {
      _visibilityBox ??= await Hive.openBox<bool>(
        _visibilityBoxName,
      );

      // Set default value for visibility if not set
      if (!_visibilityBox!.containsKey(_visibilityKey)) {
        await _visibilityBox!.put(_visibilityKey, true);
      }
    } catch (e, s) {
      await mainLocalLog(
        'Error Initializing Visibility Button Box: ${e.toString()}',
        error: e,
        stackTrace: s,
      );
    }
  }

  // ------------------- Visibility Methods -------------------
  Future<void> setDataVisibility(bool value) async {
    if (_visibilityBox == null) await init();
    await _visibilityBox!.put(_visibilityKey, value);
    notifyListeners();
  }

  Future<bool> getDataVisibility() async {
    if (_visibilityBox == null) await init();
    return _visibilityBox!.get(
      _visibilityKey,
      defaultValue: true,
    )!;
  }

  Future<void> toggleDataVisibility() async {
    final current = await getDataVisibility();
    await setDataVisibility(!current);
  }
}
