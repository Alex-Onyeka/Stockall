import 'package:flutter/material.dart';
import 'package:stockall/constants/subscription/subscription_func.dart';
import 'package:stockall/main.dart';

class ItemsAuth {
  final int numberOfItems;
  final bool useOfBarcode;
  final bool applyVariationToItems;
  final bool setexpiryDate;
  final bool allowStockallToManageInventory;
  final bool generateItemBarcode;
  final bool manageInventoryStorage;
  final bool useGroupUnit;

  ItemsAuth({
    required this.numberOfItems,
    required this.useOfBarcode,
    required this.applyVariationToItems,
    required this.setexpiryDate,
    required this.allowStockallToManageInventory,
    required this.generateItemBarcode,
    required this.manageInventoryStorage,
    required this.useGroupUnit,
  });
}

class ItemsAuthAction {
  bool numberOfItemsAction({
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
    var currentNumberOfItems =
        returnData().productList.length;
    if (subPlans
            .firstWhere((pl) => pl.plan == plan)
            .itemsAuth
            .numberOfItems >
        currentNumberOfItems) {
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

  bool manageInventoryStorageAction({
    required BuildContext context,
    Function()? action,
    Function()? failAction,
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
    if (subPlans
        .firstWhere((pl) => pl.plan == plan)
        .itemsAuth
        .manageInventoryStorage) {
      action == null ? {} : action();
      return true;
    } else {
      if (action != null) {
        showUnauthorizedDialog(context);
        if (failAction != null) {
          failAction();
        }
      }
      return false;
    }
    // }
  }

  bool useGroupUnitAction({
    required BuildContext context,
    Function()? action,
    Function()? failAction,
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
    if (subPlans
        .firstWhere((pl) => pl.plan == plan)
        .itemsAuth
        .useGroupUnit) {
      action == null ? {} : action();
      return true;
    } else {
      if (action != null) {
        showUnauthorizedDialog(context);
        if (failAction != null) {
          failAction();
        }
      }
      return false;
    }
    // }
  }

  bool useOfBArcodeAction({
    required BuildContext context,
    Function()? action,
    Function()? failAction,
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
    if (subPlans
        .firstWhere((pl) => pl.plan == plan)
        .itemsAuth
        .useOfBarcode) {
      action == null ? {} : action();
      return true;
    } else {
      if (action != null) {
        showUnauthorizedDialog(context);
        if (failAction != null) {
          failAction();
        }
      }
      return false;
    }
    // }
  }

  bool applyVariationsAction({
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
    if (subPlans
        .firstWhere((pl) => pl.plan == plan)
        .itemsAuth
        .applyVariationToItems) {
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

  bool setExpiryDateAction({
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
    if (subPlans
        .firstWhere((pl) => pl.plan == plan)
        .itemsAuth
        .setexpiryDate) {
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

  bool allowStockallToManageItemAction({
    required BuildContext context,
    Function()? action,
    Function()? failAction,
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
    if (subPlans
        .firstWhere((pl) => pl.plan == plan)
        .itemsAuth
        .allowStockallToManageInventory) {
      action == null ? {} : action();
      return true;
    } else {
      if (action != null) {
        showUnauthorizedDialog(context);
        if (failAction != null) {
          failAction();
        }
      }
      return false;
    }
    // }
  }

  bool generateBarcodeAction({
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
    if (subPlans
        .firstWhere((pl) => pl.plan == plan)
        .itemsAuth
        .generateItemBarcode) {
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
