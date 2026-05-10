import 'package:flutter/material.dart';
import 'package:stockall/constants/subscription/subscription_func.dart';
import 'package:stockall/main.dart';

class MultipleStoresAuth {
  final bool createMultipleStores;
  final int numberOfStores;
  final bool manageShopDashboard;

  MultipleStoresAuth({
    required this.createMultipleStores,
    required this.numberOfStores,
    required this.manageShopDashboard,
  });
}

class MultipleStoresAuthAction {
  bool createMulitpleStoresAction({
    required BuildContext context,
    Function()? action,
  }) {
    var plan =
        returnSubcsription(
          context,
          listen: false,
        ).subscription?.plan;
    if (plan == null) {
      return false;
    }
    // if (plan == 3) {
    //   action == null ? {} : action();
    //   return true;
    // } else {
    if (returnSubPaymentProvider().subPlans
        .firstWhere((pl) => pl.plan == plan)
        .multipleStoresAuth
        .createMultipleStores) {
      action == null ? {} : action();
      return true;
    } else {
      if (action != null) {
        showUnauthorizedDialog(context);
      }
      return false;
    }
    // }
  }

  bool manageShopDashboardAction({
    required BuildContext context,
    Function()? action,
  }) {
    var plan =
        returnSubcsription(
          context,
          listen: false,
        ).subscription?.plan;
    if (plan == null) {
      return false;
    }
    // if (plan == 3) {
    //   action == null ? {} : action();
    //   return true;
    // } else {
    if (returnSubPaymentProvider().subPlans
        .firstWhere((pl) => pl.plan == plan)
        .multipleStoresAuth
        .manageShopDashboard) {
      action == null ? {} : action();
      return true;
    } else {
      if (action != null) {
        showUnauthorizedDialog(context);
      }
      return false;
    }
    // }
  }

  bool numberOfStoresAction({
    required BuildContext context,
    Function()? action,
  }) {
    var plan =
        returnSubcsription(
          context,
          listen: false,
        ).subscription?.plan;
    if (plan == null) {
      return false;
    }
    // if (plan == 3) {
    //   action == null ? {} : action();
    //   return true;
    // } else {
    var currentNumberofStores =
        returnShopProvider().userShops.length;
    if (currentNumberofStores <
        returnSubPaymentProvider().subPlans
            .firstWhere((pl) => pl.plan == plan)
            .multipleStoresAuth
            .numberOfStores) {
      action == null ? {} : action();
      return true;
    } else {
      if (action != null) {
        showUnauthorizedDialog(context);
      }
      return false;
    }
    // }
  }
}
