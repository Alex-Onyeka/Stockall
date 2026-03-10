import 'package:flutter/material.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/subscription/subscription_func.dart';
import 'package:stockall/main.dart';

class ExpensesAuth {
  final int numberOfDailyExpenses;
  final bool deleteAndEditExpenses;

  ExpensesAuth({
    required this.numberOfDailyExpenses,
    required this.deleteAndEditExpenses,
  });
}

class ExpensesAuthAction {
  bool numberOfDailyExpensesAction({
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
    var todaysExpenses =
        returnExpensesProvider(context, listen: false)
            .expenses
            .where(
              (exp) => exp.createdDate!.isAfter(
                startOfDay(
                  DateTime.now(),
                ).add(Duration(hours: 1)),
              ),
            )
            .length;

    if (subPlans
            .firstWhere((pl) => pl.plan == plan)
            .expensesAuth
            .numberOfDailyExpenses >
        todaysExpenses) {
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

  bool deleteAndEditExpensesAction({
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
        .expensesAuth
        .deleteAndEditExpenses) {
      action == null ? {} : action();
      return true;
    } else {
      if (action != null) {
        showUnauthorizedDialog(context);
      }
      return false;
    }
  }

  // }
}
