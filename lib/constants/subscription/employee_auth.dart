import 'package:flutter/material.dart';
import 'package:stockall/constants/subscription/subscription_func.dart';
import 'package:stockall/main.dart';

class EmployeesAuth {
  final bool addAndManageEmployees;
  final int numberOfEmployees;

  EmployeesAuth({
    required this.addAndManageEmployees,
    required this.numberOfEmployees,
  });
}

class EmployeesAuthAction {
  bool addAndManageEmployeesAction({
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
          .employeesAuth
          .addAndManageEmployees) {
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

  bool numberOfEmployeesAction({
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
      var currentNumberOfEmployees =
          returnUserProvider(
            context,
            listen: false,
          ).usersMain.length;
      if (subPlans
              .firstWhere((pl) => pl.plan == plan)
              .employeesAuth
              .numberOfEmployees >
          currentNumberOfEmployees) {
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
