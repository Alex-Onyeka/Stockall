import 'package:flutter/material.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

class SubPaymentProvider extends ChangeNotifier {
  static final SubPaymentProvider _instance =
      SubPaymentProvider._internal();
  factory SubPaymentProvider() => _instance;
  SubPaymentProvider._internal();
  final String tableName = 'subscription_payments';

  int currentDuration = 6;

  void selectDuration(int duration) {
    var utilProvider = returnUtilityConstantProvider();
    currentDuration = duration;
    if (duration == 6) {
      discount =
          ((utilProvider
                      .utilityConstants
                      ?.sixMonthsDiscount ??
                  0) /
              100);
    } else if (duration == 12) {
      discount =
          ((utilProvider
                      .utilityConstants
                      ?.oneYearDiscount ??
                  0) /
              100);
    } else {
      discount = null;
    }
    notifyListeners();
  }

  int currencyIndex = 0;

  void selectCurrency(int index) {
    currencyIndex = index;
    notifyListeners();
  }

  String currencySymbol() {
    if (currencyIndex == 0) {
      return "₦";
    } else {
      return "\$";
    }
  }

  // int country = 0;

  // void selectCountry(int index) {
  //   country = index;
  //   notifyListeners();
  // }

  Future<void> nonNigerianSubscription({
    required int plan,
    required int duration,
  }) async {
    if (plan == 1) {
      if (duration == 1) {
        await launchUrlMain(
          "https://flutterwave.com/pay/basic-plan-one-month",
        );
      } else if (duration == 6) {
        await launchUrlMain(
          "https://flutterwave.com/pay/basic-plan-six-months",
        );
      } else {
        await launchUrlMain(
          "https://flutterwave.com/pay/basic-plan-one-year",
        );
      }
    } else if (plan == 2) {
      if (duration == 1) {
        await launchUrlMain(
          "https://flutterwave.com/pay/standard-plan-one-month",
        );
      } else if (duration == 6) {
        await launchUrlMain(
          "https://flutterwave.com/pay/standard-plan-six-months",
        );
      } else {
        await launchUrlMain(
          "https://flutterwave.com/pay/standard-plan-one-year",
        );
      }
    } else if (plan == 3) {
      if (duration == 1) {
        await launchUrlMain(
          "https://flutterwave.com/pay/premium-plan-one-month",
        );
      } else if (duration == 6) {
        await launchUrlMain(
          "https://flutterwave.com/pay/premium-plan-six-months",
        );
      } else {
        await launchUrlMain(
          "https://flutterwave.com/pay/premium-plan-one-year",
        );
      }
    } else if (plan == 4) {
      if (duration == 1) {
        await launchUrlMain(
          "https://flutterwave.com/pay/silver-plan-one-month",
        );
      } else if (duration == 6) {
        await launchUrlMain(
          "https://flutterwave.com/pay/silver-plan-six-months",
        );
      } else {
        await launchUrlMain(
          "https://flutterwave.com/pay/silver-plan-one-year",
        );
      }
    } else if (plan == 5) {
      if (duration == 1) {
        await launchUrlMain(
          "https://flutterwave.com/pay/gold-plan-one-month",
        );
      } else if (duration == 6) {
        await launchUrlMain(
          "https://flutterwave.com/pay/gold-plan-six-months",
        );
      } else {
        await launchUrlMain(
          "https://flutterwave.com/pay/gold-plan-one-year",
        );
      }
    }
  }

  double? discount;
}
