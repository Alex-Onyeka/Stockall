import 'package:hive/hive.dart';
import 'package:stockall/classes/subscription/subscription_class.dart';

class SubscriptionFunc {
  static final SubscriptionFunc instance =
      SubscriptionFunc._internal();
  factory SubscriptionFunc() => instance;
  SubscriptionFunc._internal();
  late Box<SubscriptionClass> subscriptionBox;
  final String subscriptionBoxName =
      'subscriptionBoxStockall';

  Future<void> init() async {
    Hive.registerAdapter(SubscriptionClassAdapter());
    subscriptionBox = await Hive.openBox(
      subscriptionBoxName,
    );
    print('Subscription Box Initialized ✅');
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
      print('Offline Subscription inserted Successfully');

      return 1;
    } catch (e) {
      print(
        'Offline Subscription Insertion Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearSubscription() async {
    try {
      if (subscriptionBox.values.isNotEmpty) {
        await subscriptionBox.clear();
        print('Subscription Cleared');
      }
      return 1;
    } catch (e) {
      print('Error: ${e.toString()}');
      return 0;
    }
  }
}
