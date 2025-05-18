import 'package:flutter/material.dart';

class NavProvider extends ChangeNotifier {
  int currentPage = 0;
  bool settingNow = false;

  void setSettings() {
    settingNow = true;
    notifyListeners();
  }

  void closeDrawer() {
    settingNow = false;
    notifyListeners();
  }

  void navigate(int index) {
    settingNow = false;
    currentPage = index;
    notifyListeners();
  }

  int currentAuth = 0;

  void navigateAuth(int index) {
    currentAuth = index;
    notifyListeners();
  }
}
