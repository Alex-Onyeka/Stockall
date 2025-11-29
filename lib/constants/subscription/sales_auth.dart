import 'package:flutter/material.dart';
import 'package:stockall/constants/subscription/subscription_func.dart';
import 'package:stockall/main.dart';

class SalesAuth {
  final bool useOfBarcode;
  final int numberOfCarts;
  final bool applyDiscount;
  // final bool useOfCalculator;
  final bool invoiceManagement;
  final bool paymentMethodSelection;
  final bool addCustomerToSell;
  final bool downloadReceipt;
  final bool editReceipt;
  final bool printReceipt;
  final int salesRecordTimeLimit;
  final bool addItemToStockAfterCustomSale;
  final bool addCustomItemToCart;
  final bool addStockallNameOnReceipt;

  SalesAuth({
    required this.useOfBarcode,
    required this.numberOfCarts,
    required this.applyDiscount,
    // required this.useOfCalculator,
    required this.invoiceManagement,
    required this.paymentMethodSelection,
    required this.addCustomerToSell,
    required this.downloadReceipt,
    required this.editReceipt,
    required this.printReceipt,
    required this.salesRecordTimeLimit,
    required this.addItemToStockAfterCustomSale,
    required this.addCustomItemToCart,
    required this.addStockallNameOnReceipt,
  });
}

class SalesAuthAction {
  bool useBarcodeAction({
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
    if (plan == 3) {
      action == null ? {} : action();
      return true;
    } else {
      if (subPlans
          .firstWhere((pl) => pl.plan == plan)
          .salesAuth
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
    }
  }

  bool numberOfCartsAction({
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
    if (plan == 3) {
      action == null ? {} : action();
      return true;
    } else {
      var cartsNum =
          returnSalesProvider(
            context,
            listen: false,
          ).cartQueue.length;
      if (cartsNum <
          subPlans
              .firstWhere((pl) => pl.plan == plan)
              .salesAuth
              .numberOfCarts) {
        print(
          subPlans
              .firstWhere((pl) => pl.plan == plan)
              .salesAuth
              .numberOfCarts,
        );
        action == null ? {} : action();
        return true;
      } else {
        if (action != null) {
          print(
            subPlans
                .firstWhere((pl) => pl.plan == plan)
                .salesAuth
                .numberOfCarts,
          );
          showUnauthorizedDialog(context);
        }
        return false;
      }
    }
  }

  bool applyDiscountAction({
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
    if (plan == 3) {
      action == null ? {} : action();
      return true;
    } else {
      if (subPlans
          .firstWhere((pl) => pl.plan == plan)
          .salesAuth
          .applyDiscount) {
        action == null ? {} : action();
        return true;
      } else {
        if (action != null) {
          showUnauthorizedDialog(context);
        }
        return false;
      }
    }
  }

  bool invoiceManagementAction({
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
    if (plan == 3) {
      action == null ? {} : action();
      return true;
    } else {
      if (subPlans
          .firstWhere((pl) => pl.plan == plan)
          .salesAuth
          .invoiceManagement) {
        action == null ? {} : action();
        return true;
      } else {
        if (action != null) {
          showUnauthorizedDialog(context);
        }
        return false;
      }
    }
  }

  bool paymentMethodSelectionAction({
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
    if (plan == 3) {
      action == null ? {} : action();
      return true;
    } else {
      if (subPlans
          .firstWhere((pl) => pl.plan == plan)
          .salesAuth
          .paymentMethodSelection) {
        action == null ? {} : action();
        return true;
      } else {
        if (action != null) {
          showUnauthorizedDialog(context);
        }
        return false;
      }
    }
  }

  bool addCustomerToSaleAction({
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
    if (plan == 3) {
      action == null ? {} : action();
      return true;
    } else {
      if (subPlans
          .firstWhere((pl) => pl.plan == plan)
          .salesAuth
          .addCustomerToSell) {
        action == null ? {} : action();
        return true;
      } else {
        if (action != null) {
          showUnauthorizedDialog(context);
        }
        return false;
      }
    }
  }

  bool downloadReceiptAction({
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
    if (plan == 3) {
      action == null ? {} : action();
      return true;
    } else {
      if (subPlans
          .firstWhere((pl) => pl.plan == plan)
          .salesAuth
          .downloadReceipt) {
        action == null ? {} : action();
        return true;
      } else {
        if (action != null) {
          showUnauthorizedDialog(context);
        }
        return false;
      }
    }
  }

  bool editReceiptAction({
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
    if (plan == 3) {
      action == null ? {} : action();
      return true;
    } else {
      if (subPlans
          .firstWhere((pl) => pl.plan == plan)
          .salesAuth
          .editReceipt) {
        action == null ? {} : action();
        return true;
      } else {
        if (action != null) {
          showUnauthorizedDialog(context);
        }
        return false;
      }
    }
  }

  bool printReceiptAction({
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
    if (plan == 3) {
      action == null ? {} : action();
      return true;
    } else {
      if (subPlans
          .firstWhere((pl) => pl.plan == plan)
          .salesAuth
          .printReceipt) {
        action == null ? {} : action();
        return true;
      } else {
        if (action != null) {
          showUnauthorizedDialog(context);
        }
        return false;
      }
    }
  }

  bool addItemToStockAfterSaleAction({
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
    if (plan == 3) {
      action == null ? {} : action();
      return true;
    } else {
      if (subPlans
          .firstWhere((pl) => pl.plan == plan)
          .salesAuth
          .addItemToStockAfterCustomSale) {
        action == null ? {} : action();
        return true;
      } else {
        if (action != null) {
          showUnauthorizedDialog(context);
        }
        return false;
      }
    }
  }

  bool addCustomItemToCartAction({
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
    if (plan == 3) {
      action == null ? {} : action();
      return true;
    } else {
      if (subPlans
          .firstWhere((pl) => pl.plan == plan)
          .salesAuth
          .addCustomItemToCart) {
        action == null ? {} : action();
        return true;
      } else {
        if (action != null) {
          showUnauthorizedDialog(context);
        }
        return false;
      }
    }
  }

  bool addStockallNameOnReceiptAction({
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
    if (plan == 3) {
      action == null ? {} : action();
      return true;
    } else {
      if (subPlans
          .firstWhere((pl) => pl.plan == plan)
          .salesAuth
          .addStockallNameOnReceipt) {
        action == null ? {} : action();
        return true;
      } else {
        if (action != null) {
          showUnauthorizedDialog(context);
        }
        return false;
      }
    }
  }
}
