import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_notification/temp_notification.dart';
import 'package:stockall/main.dart';

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
    await mainLocalLog('Notification Box Initialized');
  }

  List<TempNotification> getNotifications() {
    List<TempNotification> notifs =
        notificationBox.values.toList();
    notifs.sort((a, b) {
      return b.date.compareTo(a.date);
    });
    return notifs;
  }

  Future<int> insertAllNotifications(
    List<TempNotification> notifications,
  ) async {
    await clearNotifications();
    try {
      for (var notif in notifications) {
        await notificationBox.put(notif.uuid, notif);
      }
      await mainLocalLog('Offline Notif Insert Success');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline notif insert failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearNotifications() async {
    try {
      await notificationBox.clear();
      await mainLocalLog('Notif Cleared Success');
      return 1;
    } catch (e) {
      await mainLocalLog(
        '❌❌ Notif Clear Error: ${e.toString()}',
      );
      return 0;
    }
  }
}
