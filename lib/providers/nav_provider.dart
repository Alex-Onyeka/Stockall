import 'package:flutter/material.dart';
import 'package:stockall/local_database/shop/shop_func.dart';
import 'package:stockall/pages/shop_setup/banner_screen/shop_banner_screen.dart';

class NavProvider extends ChangeNotifier {
  int currentPage = 0;

  bool settingNow = false;

  int currentIndex = 0;

  void setSettings() {
    settingNow = true;
    notifyListeners();
  }

  void closeDrawer() {
    settingNow = false;
    notifyListeners();
  }

  Future<void> navigate(int index) async {
    await Future.delayed(Duration(milliseconds: 5));
    settingNow = false;
    currentIndex = index;
    currentPage = index;
    notifyListeners();
  }

  // Future<void> navigateAction({required int index}) async {
  //   await Future.delayed(Duration(milliseconds: 10));
  //   navigate(index);
  // }

  int currentAuth = 0;

  void navigateAuth(int index) {
    currentAuth = index;
    notifyListeners();
  }

  bool isNotVerified = true;

  void verify() {
    isNotVerified = false;
    notifyListeners();
  }

  bool isLoadingMain = true;

  void offLoading() {
    isLoadingMain = false;
    notifyListeners();
  }

  void nullShop(BuildContext context) async {
    await ShopFunc().clearShop();
    await navigate(0);
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => ShopBannerScreen(),
        ),
        (route) => false,
      );
    }
  }
}
