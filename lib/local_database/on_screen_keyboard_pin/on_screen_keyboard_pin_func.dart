import 'package:hive/hive.dart';
import 'package:stockall/classes/on_screen_keyboard_pin/on_screen_keyboard_pin_class.dart';
import 'package:stockall/main.dart';

class OnScreenKeyboardPinFunc {
  static final OnScreenKeyboardPinFunc instance =
      OnScreenKeyboardPinFunc._internal();
  factory OnScreenKeyboardPinFunc() => instance;
  OnScreenKeyboardPinFunc._internal();
  late Box<OnScreenKeyboardPinClass> onScreenKeyboardPinBox;
  final String onScreenKeyboardPinBoxName =
      'onScreenKeyboardPinBoxStockall';

  Future<void> init() async {
    try {
      Hive.registerAdapter(
        OnScreenKeyboardPinClassAdapter(),
      );

      onScreenKeyboardPinBox = await Hive.openBox(
        onScreenKeyboardPinBoxName,
      );

      // Initialize default value
      if (onScreenKeyboardPinBox.isEmpty) {
        await insertOnScreenKeyboardPin(
          OnScreenKeyboardPinClass(id: 1, isOn: false),
        );
      }

      await mainLocalLog(
        '✅App OnScreenKeyboardPin Box Initialized',
      );
    } catch (e, s) {
      await mainLocalLog(
        'Error Initializing On Screen Keyboard Box: ${e.toString()}',
        error: e,
        stackTrace: s,
      );
    }
  }

  OnScreenKeyboardPinClass? getOnScreenKeyboardPinClass() {
    return onScreenKeyboardPinBox.values.isNotEmpty
        ? onScreenKeyboardPinBox.values.first
        : null;
  }

  Future<int> insertOnScreenKeyboardPin(
    OnScreenKeyboardPinClass onScreenKeyboardPin,
  ) async {
    try {
      await onScreenKeyboardPinBox.put(
        onScreenKeyboardPin.id,
        onScreenKeyboardPin,
      );
      await mainLocalLog(
        'OnScreenKeyboardPin inserted Success',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        '❌❌ Insert OnScreenKeyboardPin Offline Error: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> toggleOnScreenKeyboard() async {
    try {
      var temp = getOnScreenKeyboardPinClass();
      if (temp != null) {
        if (temp.isOn) {
          temp.isOn = false;
        } else {
          temp.isOn = true;
        }
        await insertOnScreenKeyboardPin(temp);
        return 1;
      } else {
        return 0;
      }
    } catch (e) {
      await mainLocalLog(
        'Error Toggling On Screen Keyboard Value: ${e.toString()}',
      );
      return 0;
    }
  }

  Future clearOnScreenKeyboardPins() async {
    await onScreenKeyboardPinBox.clear();
    await mainLocalLog(
      'Offline OnScreenKeyboardPin Cleared',
    );
  }
}
