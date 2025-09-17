import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_notification/temp_notification.dart';

class NotificationFunc {
  static final NotificationFunc instance =
      NotificationFunc._internal();
  factory NotificationFunc() => instance;
  NotificationFunc._internal();
  late Box<TempNotification> notificationBox;
  final String notificationBoxName =
      'notificationBoxStockall';

  Future<void> init() async {
    Hive.registerAdapter(TempNotificationAdapter());
    notificationBox = await Hive.openBox(
      notificationBoxName,
    );
    print('Notification Box Initialized');
  }

  List<TempNotification> getNotifications() {
    return notificationBox.values.toList();
  }

  Future<int> insertAllNotifications(
    List<TempNotification> notifications,
  ) async {
    await clearNotifications();
    try {
      for (var notif in notifications) {
        await notificationBox.put(notif.id, notif);
      }
      print('Offline Notif Insert Success');
      return 1;
    } catch (e) {
      print('Offline notif insert failed: ${e.toString()}');
      return 0;
    }
  }

  Future<int> clearNotifications() async {
    try {
      await notificationBox.clear();
      print('Notif Cleared Success');
      return 1;
    } catch (e) {
      print('Notif Clear Error: ${e.toString()}');
      return 0;
    }
  }
}
