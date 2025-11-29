import 'package:flutter/material.dart';
import 'package:stockall/constants/subscription/subscription_func.dart';
import 'package:stockall/main.dart';

class GeneralSettingsAuth {
  final bool addSocials;
  final bool customizeReceiptTemplate;
  final bool allowOfflineUse;

  GeneralSettingsAuth({
    required this.addSocials,
    required this.customizeReceiptTemplate,
    required this.allowOfflineUse,
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
    if (plan == 3) {
      action == null ? {} : action();
      return true;
    } else {
      if (subPlans
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
    }
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
    if (plan == 3) {
      action == null ? {} : action();
      return true;
    } else {
      if (subPlans
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
    if (plan == 3) {
      action == null ? {} : action();
      return true;
    } else {
      if (subPlans
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
  }
}
