import 'package:flutter/material.dart';
import 'package:stockall/classes/subscription/subscription_class.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/local_database/subscription/subscription_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:stockall/providers/nav_provider.dart';
import 'package:stockall/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SubscriptionProvider extends ChangeNotifier {
  // final ShopProvider shopProvider = ShopProvider();
  final ConnectivityProvider connectivity =
      ConnectivityProvider();
  final SupabaseClient supabase = Supabase.instance.client;
  final NavProvider navProvider = NavProvider();
  SubscriptionClass? subscription;

  Future<TempShopClass> userShop(
    BuildContext context,
  ) async {
    var shopP = returnShopProvider(context, listen: false);
    if (shopP.userShop() == null) {
      await shopP.getUserShops(AuthService().currentUser!);
      return shopP.userShop()!;
    } else {
      return shopP.userShop()!;
    }
  }

  Future<SubscriptionClass?> createSubscription(
    BuildContext context,
  ) async {
    // bool isOnline = await connectivity.isOnline();
    // if (isOnline) {
    var shop = await userShop(context);
    try {
      var newSub = SubscriptionClass(
        createdAt: DateTime.now().toUtc(),
        plan: 3,
        nextPayment: DateTime.now().add(Duration(days: 30)),
        lastPayment: DateTime.now().toUtc(),
        subscriptionId: uuidGen(),
        userId: shop.userId,
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
      }
      notifyListeners();
      return SubscriptionClass.fromJson(subTemp!);
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
                    nextPayment?..toUtc().toIso8601String(),
                'last_payment':
                    DateTime.now()
                        .toUtc()
                        .toIso8601String(),
                'plan': plan,
              })
              .eq('user_id', shop.userId)
              .select()
              .maybeSingle();

      if (res != null) {
        subscription = SubscriptionClass.fromJson(res);
        SubscriptionFunc().createSubscription(
          SubscriptionClass.fromJson(res),
        );
      }
      notifyListeners();
      print('Subscription Success');
      return 1;
    } catch (e) {
      print('❌❌ SubScribe Error: ${e.toString()}');
      return 0;
    }
  }
}
