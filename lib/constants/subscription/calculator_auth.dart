import 'package:flutter/material.dart';
import 'package:stockall/constants/subscription/subscription_func.dart';
import 'package:stockall/main.dart';

class CalculatorAuth {
  final bool useCalculator;

  CalculatorAuth({required this.useCalculator});
}

class CalculatorAuthAction {
  bool useCalculatorAction({
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
          .calculatorAuth
          .useCalculator) {
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
