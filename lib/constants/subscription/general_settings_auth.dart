import 'package:flutter/material.dart';
import 'package:stockall/constants/subscription/subscription_func.dart';
import 'package:stockall/main.dart';

class GeneralSettingsAuth {
  final bool addSocials;
  final bool customizeReceiptTemplate;
  final bool allowOfflineUse;
  final bool manageVAT;
  final bool manageDepartments;
  final int numberOfDepartments;
  final bool useCloseSale;
  final bool useFloatingButton;

  GeneralSettingsAuth({
    required this.addSocials,
    required this.customizeReceiptTemplate,
    required this.allowOfflineUse,
    required this.manageVAT,
    required this.manageDepartments,
    required this.numberOfDepartments,
    required this.useCloseSale,
    required this.useFloatingButton,
  });
}

class GeneralSettingsAuthAction {
  bool addSocialsAction({
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
    if (returnSubPaymentProvider().subPlans
        .firstWhere((pl) => pl.plan == plan)
        .generalSettingsAuth
        .addSocials) {
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

  bool useCloseSalesAction({
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
    if (returnSubPaymentProvider().subPlans
        .firstWhere((pl) => pl.plan == plan)
        .generalSettingsAuth
        .useCloseSale) {
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

  bool useFloatingButtonAction({
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
    if (returnSubPaymentProvider().subPlans
        .firstWhere((pl) => pl.plan == plan)
        .generalSettingsAuth
        .useFloatingButton) {
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

  bool customizeReceiptTemplateAction({
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
    if (returnSubPaymentProvider().subPlans
        .firstWhere((pl) => pl.plan == plan)
        .generalSettingsAuth
        .customizeReceiptTemplate) {
      action == null ? {} : action();
      return true;
    } else {
      if (action != null) {
        showUnauthorizedDialog(context);
      }
      return false;
    }
  }

  bool allowOfflineUseAction({
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
    if (returnSubPaymentProvider().subPlans
        .firstWhere((pl) => pl.plan == plan)
        .generalSettingsAuth
        .allowOfflineUse) {
      action == null ? {} : action();
      return true;
    } else {
      if (action != null) {
        showUnauthorizedDialog(context);
      }
      return false;
    }
  }

  bool manageVATAction({
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
    if (returnSubPaymentProvider().subPlans
        .firstWhere((pl) => pl.plan == plan)
        .generalSettingsAuth
        .manageVAT) {
      action == null ? {} : action();
      return true;
    } else {
      if (action != null) {
        showUnauthorizedDialog(context);
      }
      return false;
    }
  }

  bool manageDeparmtmentsAction({
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
    if (returnSubPaymentProvider().subPlans
        .firstWhere((pl) => pl.plan == plan)
        .generalSettingsAuth
        .manageDepartments) {
      action == null ? {} : action();
      return true;
    } else {
      if (action != null) {
        showUnauthorizedDialog(context);
      }
      return false;
    }
  }

  bool numberOfDepartmentsAction({
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
    var currentNumberOfItems =
        returnDepartmentProvider().departments.length;
    if (returnSubPaymentProvider().subPlans
            .firstWhere((pl) => pl.plan == plan)
            .generalSettingsAuth
            .numberOfDepartments >
        currentNumberOfItems) {
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
