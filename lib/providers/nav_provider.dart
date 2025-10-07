import 'package:flutter/material.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/local_database/shop/shop_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/restricted_page/restricted_page.dart';
import 'package:stockall/pages/shop_setup/banner_screen/shop_banner_screen.dart';
import 'package:stockall/services/auth_service.dart';

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

  Future<void> validate(BuildContext context) async {
    var dataProvider = returnData(context, listen: false);
    final userProvider = returnUserProvider(
      context,
      listen: false,
    );
    bool isOnline =
        await returnConnectivityProvider(
          context,
          listen: false,
        ).isOnline();
    final shopProvider = returnShopProvider(
      // ignore: use_build_context_synchronously
      context,
      listen: false,
    );

    final userShop = await shopProvider.getUserShop(
      AuthService().currentUser!,
    );

    if (isOnline) {
      var userOffline = AuthService().currentUserOffline;
      var userAuth = AuthService().currentUserAuth;
      if (userAuth == null && userOffline != null) {
        await AuthService().signIn(
          userOffline.email,
          userOffline.password,
        );
      } else if (userAuth != null &&
          userOffline != null &&
          userAuth.id != userOffline.userId) {
        await AuthService().signIn(
          userOffline.email,
          userOffline.password,
        );
      }
    }

    if (!context.mounted) {
      return;
    }

    if (userShop == null) {
      // ignore: use_build_context_synchronously
      NavProvider().nullShop(
        logoutAction: () {
          navPush(context);
        },
      );
      return;
    } else if (userShop.nextPayment == null) {
      await shopProvider.makePayment(
        DateTime.now().add(Duration(days: 30)),
        3,
      );
    } else if (userShop.plan != 0 &&
        (userShop.nextPayment != null &&
            (DateTime.now().isAfter(
                  userShop.nextPayment!,
                ) ||
                DateTime.now().isAtSameMomentAs(
                  userShop.nextPayment!,
                )))) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => RestrictedPage(),
        ),
        (route) => false,
      );
      return;
    } else {
      await userProvider.fetchCurrentUser(context);
      if (dataProvider.isSynced() == 0 && isOnline) {
        if (!dataProvider.isSyncing) {
          showDialog(
            context: context,
            builder: (context) {
              return InfoAlert(
                theme: returnTheme(context, listen: false),
                title: 'Data Synchronization Ongoing',
                message:
                    'You have Unsynced Data. Data synchronization is currently going on in the background.',
                // action: () {},
              );
            },
          );
          if (context.mounted) {
            print('Context is Mounted');
            await dataProvider.syncData(context);
          } else {
            print('Context is not mounted');
          }
        }
      }
    }
  }

  void nullShop({Function()? logoutAction}) async {
    await ShopFunc().clearShop();
    await navigate(0);
    logoutAction != null ? logoutAction() : {};
  }

  void navPush(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => ShopBannerScreen(),
      ),
      (route) => false,
    );
  }
}
