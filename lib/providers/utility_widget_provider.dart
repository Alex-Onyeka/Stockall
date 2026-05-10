import 'package:flutter/foundation.dart';
import 'package:stockall/local_database/floating_button_visibility_box/floating_button_visibility_box.dart';

class UtilityWidgetProvider extends ChangeNotifier {
  static final UtilityWidgetProvider _instance =
      UtilityWidgetProvider._internal();
  factory UtilityWidgetProvider() => _instance;
  UtilityWidgetProvider._internal();

  var utilityBox = FloatingButtonVisibilityBox();

  bool getVisibility() {
    return utilityBox.getDataVisibility();
  }

  Future<void> toggleVisibility() async {
    await utilityBox.toggleDataVisibility();
    notifyListeners();
  }
}
