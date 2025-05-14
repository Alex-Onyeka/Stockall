import 'package:flutter/material.dart';

class NavProvider extends ChangeNotifier {
  int currentPage = 0;

  void navigate(int index) {
    currentPage = index;
    notifyListeners();
  }

  int currentAuth = 0;

  void navigateAuth(int index) {
    currentAuth = index;
    notifyListeners();
  }
}
