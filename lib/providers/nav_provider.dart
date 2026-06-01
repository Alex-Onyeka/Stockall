import 'package:flutter/material.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/restricted_page/restricted_page.dart';
import 'package:stockall/services/auth_service.dart';

class NavProvider extends ChangeNotifier {
  static final NavProvider _instance =
      NavProvider._internal();
  factory NavProvider() => _instance;
  NavProvider._internal();
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

  void checkSubExp(BuildContext context) {
    if (context.mounted) {
      returnSubcsription(
        context,
        listen: false,
      ).checkSubscriptionExpiryNotification();
    }
  }

  Future<void> validate(BuildContext context) async {
    if (context.mounted) {
      checkSubExp(context);
    }
    var dataProvider = returnData();
    final userProvider = returnUserProvider(
      context,
      listen: false,
    );
    bool isOnline =
        returnConnectivityProvider().isConnected;
    if (!context.mounted) {
      return;
    }
    final shopProvider = returnShopProvider();

    final subPro = returnSubcsription(
      context,
      listen: false,
    );

    final appVersionP = returnAppVersionProvider(
      context,
      listen: false,
    );

    final utilityConstants =
        returnUtilityConstantProvider();

    await shopProvider.getUserShops();
    if (!context.mounted) {
      return;
    }
    final subsription = await subPro.getSubscription(
      context,
    );
    if (!context.mounted) {
      return;
    }
    await appVersionP.getAppVersion(context);
    await utilityConstants.getUtilityConstants();

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

    // if (userShop.isEmpty) {
    //   NavProvider().nullShop(
    //     logoutAction: () {
    //       navPush(context);
    //     },
    //   );
    //   return;
    // }
    if (returnDepartmentProvider().currentDepartment() ==
            null &&
        !authorization(
          authorized: Authorizations().viewAllDepartments,
        )) {
      returnDepartmentProvider().selectDepartment(
        departmentClass:
            returnDepartmentProvider()
                    .departments
                    .isNotEmpty
                ? returnDepartmentProvider()
                    .departments
                    .first
                : null,
      );
    }

    if (subsription != null &&
        subsription.plan != 0 &&
        (subsription.nextPayment != null &&
            (DateTime.now().isAfter(
                  subsription.nextPayment!,
                ) ||
                DateTime.now().isAtSameMomentAs(
                  subsription.nextPayment!,
                )))) {
      // returnShopProvider( ).clearDiscountsCache();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => RestrictedPage(),
        ),
        (route) => false,
      );
      return;
    } else {
      dataProvider.setAllowedRange(
        plan: subsription?.plan,
        context: context,
      );
      await userProvider.fetchCurrentUser(context);
      if (dataProvider.isSynced() == 0 && isOnline) {
        if (!dataProvider.isSyncing) {
          if (!context.mounted) {
            return;
          }
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
            await dataProvider.syncData();
          } else {
            print('Context is not mounted');
          }
        }
      }
    }
    if (context.mounted) {
      checkSubExp(context);
    }
  }

  void nullShop({Function()? logoutAction}) async {
    // await ShopFunc().clearShop();
    // await navigate(0);
    // logoutAction != null ? logoutAction() : {};
  }

  void navPush(BuildContext context) {
    // Navigator.pushAndRemoveUntil(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => ShopBannerScreen(),
    //   ),
    //   (route) => false,
    // );
  }
}
