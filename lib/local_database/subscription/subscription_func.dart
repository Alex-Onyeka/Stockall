import 'package:hive/hive.dart';
import 'package:stockall/classes/subscription/subscription_class.dart';
import 'package:stockall/local_database/hive_box_helper.dart';
import 'package:stockall/main.dart';

class SubscriptionFunc {
  static final SubscriptionFunc instance =
      SubscriptionFunc._internal();
  factory SubscriptionFunc() => instance;
  SubscriptionFunc._internal();
  late Box<SubscriptionClass> subscriptionBox;
  final String subscriptionBoxName =
      'subscriptionBoxStockall';

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(SubscriptionClassAdapter().typeId)) {
      Hive.registerAdapter(SubscriptionClassAdapter());
    }
    subscriptionBox = await openBoxSafely<SubscriptionClass>(
      subscriptionBoxName,
    );
    await mainLocalLog('Subscription Box Initialized ✅');
  }

  SubscriptionClass? getSubscription() {
    SubscriptionClass? subscription =
        subscriptionBox.values.isNotEmpty
            ? subscriptionBox.values.first
            : null;
    return subscription;
  }

  Future<int> createSubscription(
    SubscriptionClass subscription,
  ) async {
    try {
      await clearSubscription();
      await subscriptionBox.put(
        subscription.subscriptionId!,
        subscription,
      );
      await mainLocalLog(
        'Offline Subscription inserted Successfully',
      );

      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Subscription Insertion Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearSubscription() async {
    try {
      if (subscriptionBox.values.isNotEmpty) {
        await subscriptionBox.clear();
        await mainLocalLog('Subscription Cleared');
      }
      return 1;
    } catch (e) {
      await mainLocalLog(
        '❌❌ Subscription Clear Error: ${e.toString()}',
      );
      return 0;
    }
  }
}
