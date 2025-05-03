import 'package:flutter/material.dart';

class NavProvider extends ChangeNotifier {
  int currentPage = 0;

  void navigate(int index) {
    currentPage = index;
    notifyListeners();
  }
}
