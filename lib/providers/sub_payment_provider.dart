import 'package:flutter/material.dart';
import 'package:stockall/classes/subscription_payment_model.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/services/auth_service.dart';
import 'package:stockall/services/remote/remote_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SubPaymentProvider extends ChangeNotifier {
  static final SubPaymentProvider _instance =
      SubPaymentProvider._internal();
  factory SubPaymentProvider() => _instance;
  SubPaymentProvider._internal();

  final String tableName = 'subscription_payments';
  SupabaseClient get supabase => backend();

  int currentDuration = 6;
  double? discount;
  int currencyIndex = 0;

  // Payment History State
  List<SubscriptionPaymentModel> paymentHistory = [];
  bool isLoadingHistory = false;
  DateTime? selectedDate;
  DateTime? selectedEndDate;
  String? currentUserId;

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

  /// Fetches payments where user_id equals the shop's user_id, sorted latest to oldest
  Future<void> fetchPaymentHistory({
    String? userId,
    DateTime? date,
    DateTime? endDate,
  }) async {
    isLoadingHistory = true;
    notifyListeners();

    try {
      final targetUserId =
          userId ??
          currentUserId ??
          returnShopProvider().userShop()?.userId ??
          AuthService().currentUser;

      if (targetUserId == null) {
        await mainLocalLog(
          'fetchPaymentHistory: No target user ID found',
        );
        paymentHistory = [];
        isLoadingHistory = false;
        notifyListeners();
        return;
      }

      currentUserId = targetUserId;
      selectedDate = date;
      selectedEndDate = endDate;

      var query = supabase
          .from(tableName)
          .select()
          .eq('user_id', targetUserId);

      if (date != null && endDate != null) {
        final start =
            DateTime(
              date.year,
              date.month,
              date.day,
              0,
              0,
              0,
            ).toUtc().toIso8601String();
        final end =
            DateTime(
              endDate.year,
              endDate.month,
              endDate.day,
              23,
              59,
              59,
            ).toUtc().toIso8601String();
        query = query
            .gte('created_at', start)
            .lte('created_at', end);
      } else if (date != null) {
        final start =
            DateTime(
              date.year,
              date.month,
              date.day,
              0,
              0,
              0,
            ).toUtc().toIso8601String();
        final end =
            DateTime(
              date.year,
              date.month,
              date.day,
              23,
              59,
              59,
            ).toUtc().toIso8601String();
        query = query
            .gte('created_at', start)
            .lte('created_at', end);
      }

      final response = await query.order(
        'created_at',
        ascending: false,
      );

      paymentHistory =
          response
              .map(
                (item) =>
                    SubscriptionPaymentModel.fromJson(item),
              )
              .toList();
    } catch (e) {
      await mainLocalLog(
        'fetchPaymentHistory error: ${e.toString()}',
      );
    } finally {
      isLoadingHistory = false;
      notifyListeners();
    }
  }

  void clearDateFilter() {
    selectedDate = null;
    selectedEndDate = null;
    fetchPaymentHistory(userId: currentUserId);
  }

  void setDateFilter(DateTime date, {DateTime? endDate}) {
    fetchPaymentHistory(
      userId: currentUserId,
      date: date,
      endDate: endDate,
    );
  }

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
}
