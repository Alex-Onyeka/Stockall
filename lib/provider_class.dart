import 'package:flutter/material.dart';

class ProviderClass extends ChangeNotifier {
  int counter = 0;

  void changeCounter(String sign) {
    sign == '-' && counter > 0
        ? counter--
        : sign == '+'
        ? counter++
        : counter;
    notifyListeners();
  }
}
