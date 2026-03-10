import 'package:flutter/material.dart';
import 'package:stockall/classes/subscription/subscription_class.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/classes/temp_sub_payment/temp_sub_payment_class.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/local_database/subscription/subscription_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:stockall/providers/nav_provider.dart';
import 'package:stockall/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SubscriptionProvider extends ChangeNotifier {
  static final SubscriptionProvider _instance =
      SubscriptionProvider._internal();
  factory SubscriptionProvider() => _instance;
  SubscriptionProvider._internal();

  final ConnectivityProvider connectivity =
      ConnectivityProvider();
  final SupabaseClient supabase = Supabase.instance.client;
  final NavProvider navProvider = NavProvider();
  SubscriptionClass? subscription;

  DateTime? lastPayment() {
    return subscription?.lastPayment;
  }

  DateTime? nextPayment() {
    return subscription?.nextPayment;
  }

  int? remainingDays() {
    return subscription?.nextPayment != null
        ? getDayDifference(subscription!.nextPayment!)
        : null;
  }

  bool isClicked = false;

  void toggleIsClicked(bool value) {
    isClicked = value;
    notifyListeners();
    print("Is Clicked Value: $isClicked");
  }

  void checkSubscriptionExpiryNotification() {
    if (remainingDays() != null &&
        remainingDays()! <= 7 &&
        subscription?.plan != 0) {
      isClicked = false;
      notifyListeners();
      print('Is Clicked is False');
    } else {
      isClicked = true;
      notifyListeners();
      print('Is Clicked is True');
    }
  }

  Future<TempShopClass> userShop(
    BuildContext context,
  ) async {
    var shopP = returnShopProvider();
    if (shopP.userShop() == null) {
      await shopP.getUserShops();
      return shopP.userShop()!;
    } else {
      return shopP.userShop()!;
    }
  }

  Future<SubscriptionClass?> createSubscription(
    BuildContext context,
  ) async {
    try {
      var newSub = SubscriptionClass(
        createdAt: DateTime.now().toUtc(),
        plan: 3,
        nextPayment: DateTime.now().add(Duration(days: 30)),
        lastPayment: DateTime.now().toUtc(),
        subscriptionId: uuidGen(),
        userId: AuthService().currentUser!,
        userName:
            "${returnUserProvider(context, listen: false).currentUserMain!.name} ${returnUserProvider(context, listen: false).currentUserMain!.lastName ?? ''}",
      );
      var subTemp =
          await supabase
              .from('subscription')
              .insert(newSub.toJson())
              .select()
              .maybeSingle();
      if (subTemp != null) {
        subscription = SubscriptionClass.fromJson(subTemp);
        SubscriptionFunc().createSubscription(
          SubscriptionClass.fromJson(subTemp),
        );
        notifyListeners();
        return SubscriptionClass.fromJson(subTemp);
      }
      return null;
    } catch (e) {
      print('Error Creating Online: ${e.toString()}');
      return null;
    }
    // }else {

    // }
  }

  Future<SubscriptionClass?> getSubscription(
    BuildContext context,
  ) async {
    var isOnline = await connectivity.isOnline();
    // ignore: use_build_context_synchronously
    var shop = await userShop(context);
    if (isOnline) {
      try {
        var response =
            await supabase
                .from('subscription')
                .select()
                .eq('user_id', shop.userId)
                .maybeSingle();
        if (response == null) {
          print('No Subscription Found');
          // ignore: use_build_context_synchronously
          var subs = await createSubscription(context);
          return subs;
        }
        subscription = SubscriptionClass.fromJson(response);
        SubscriptionFunc().createSubscription(
          SubscriptionClass.fromJson(response),
        );
        notifyListeners();
        return SubscriptionClass.fromJson(response);
      } catch (e) {
        print('❌❌ Get Subscription Error: ${e.toString()}');
        return null;
      }
    } else {
      try {
        print('Getting Subscription Offline');
        subscription = SubscriptionFunc().getSubscription();
        notifyListeners();
        return subscription;
      } catch (e) {
        print(
          '❌❌ Get Subscription Error Offline: ${e.toString()}',
        );
        return null;
      }
    }
  }

  List<TempSub> subs = [
    TempSub(planName: 'Free', plan: 0),
    TempSub(planName: 'Basic', plan: 1),
    TempSub(planName: 'Standard', plan: 2),
    TempSub(planName: 'Premium', plan: 3),
  ];

  int? selected;

  void select(int sub) {
    selected = sub;
    notifyListeners();
  }

  double? subscriptionAmount(int plan) {
    if (plan == 0) {
      return null;
    } else if (plan == 1) {
      return 2500;
    } else if (plan == 2) {
      return 3500;
    } else {
      return 5000;
    }
  }

  Future<int> subscribe({
    required int plan,
    required BuildContext context,
  }) async {
    var shop = await userShop(context);
    var nextPayment =
        plan == 0
            ? null
            : DateTime.now().add(Duration(days: 30));
    try {
      var res =
          await supabase
              .from('subscription')
              .update({
                'next_payment':
                    nextPayment?.toUtc().toIso8601String(),
                'last_payment':
                    DateTime.now()
                        .toUtc()
                        .toIso8601String(),
                'plan': plan,
                'amount': subscriptionAmount(plan),
              })
              .eq('user_id', shop.userId)
              .select()
              .maybeSingle();

      if (res == null) {
        print('Subcription Action Failed');
        return 0;
      }
      try {
        List<Map<String, dynamic>> res = await supabase.rpc(
          'get_this_month_subscription_payments',
        );
        if (res.isNotEmpty) {
          var tempSubPayments =
              res
                  .map(
                    (re) =>
                        TempSubPaymentClass.fromJson(re),
                  )
                  .toList();
          if (tempSubPayments
              .where(
                (subPayment) =>
                    subPayment.userId == shop.userId,
              )
              .isNotEmpty) {
            print("Store Subcription Exists");
            var tempP =
                tempSubPayments
                    .where(
                      (subPayment) =>
                          subPayment.userId == shop.userId,
                    )
                    .first;
            var nextPayment =
                plan == 0
                    ? null
                    : DateTime.now().add(
                      Duration(days: 30),
                    );
            // tempP.plan == plan;
            // tempP.amount == subscriptionAmount(plan);
            await supabase
                .from('subscription_payments')
                .update({
                  'plan': plan,
                  'amount':
                      subscriptionAmount(plan)?.toInt(),
                  'next_payment':
                      nextPayment
                          ?.toUtc()
                          .toIso8601String(),
                })
                .eq('payments_id', tempP.paymentsId!);
          } else {
            print("Store Subcription Does not Exists");
            var nextPayment =
                plan == 0
                    ? null
                    : DateTime.now().add(
                      Duration(days: 30),
                    );
            var tempP = TempSubPaymentClass(
              userId: shop.userId,
              duration: 200,
              amount: subscriptionAmount(plan)?.toInt(),
              plan: plan,
              nextPayment: nextPayment?.toUtc(),
            );
            await supabase
                .from('subscription_payments')
                .insert(tempP.toJson());
          }
        } else {
          var nextPayment =
              plan == 0
                  ? null
                  : DateTime.now().add(Duration(days: 30));
          var tempP = TempSubPaymentClass(
            userId: shop.userId,
            duration: 200,
            amount: subscriptionAmount(plan)?.toInt(),
            plan: plan,
            nextPayment: nextPayment?.toUtc(),
          );
          await supabase
              .from('subscription_payments')
              .insert(tempP.toJson());
        }
        await getSubscription(context);
      } catch (e) {
        print(
          'Subsciption Payments Creation Failed: ${e.toString()}',
        );
      }
      subscription = SubscriptionClass.fromJson(res);
      SubscriptionFunc().createSubscription(
        SubscriptionClass.fromJson(res),
      );
      notifyListeners();
      print('Subscription Success');
      return 1;
    } catch (e) {
      print('❌❌ SubScribe Error: ${e.toString()}');
      return 0;
    }
  }
}

class TempSub {
  final String planName;
  final int plan;

  TempSub({required this.planName, required this.plan});
}
