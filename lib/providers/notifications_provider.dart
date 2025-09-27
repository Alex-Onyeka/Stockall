import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_notification/temp_notification.dart';
import 'package:stockall/local_database/notification/notification_func.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationProvider with ChangeNotifier {
  final SupabaseClient supabase = Supabase.instance.client;
  final ConnectivityProvider connectivity =
      ConnectivityProvider();

  List<TempNotification> _notifications = [];

  List<TempNotification> get notifications =>
      _notifications;

  void clearNotifications() {
    _notifications.clear();
    print('Notifications Cleared');
    notifyListeners();
  }

  void deleteNotification(TempNotification notif) {
    notifications.remove(notif);
    notifyListeners();
  }

  Future<void> deleteNotificationFromSupabase(
    TempNotification notif,
  ) async {
    bool isOnline = await connectivity.isOnline();

    if (isOnline) {
      try {
        debugPrint(
          'Attempting to delete notification ID: ${notif.uuid}',
        );

        final response =
            await supabase
                .from('notifications')
                .delete()
                .eq('uuid', notif.uuid!)
                .select(); // confirm deletion

        debugPrint('Deleted rows: $response');

        if (response.isNotEmpty) {
          deleteNotification(notif);
          debugPrint(
            'Notification ${notif.uuid} deleted successfully.',
          );
        } else {
          debugPrint(
            'No matching notification found to delete.',
          );
        }
      } catch (e) {
        debugPrint('Error deleting notification: $e');
      }
    }
  }

  Future<List<TempNotification>> fetchRecentNotifications(
    int shopId,
  ) async {
    bool isOnline = await ConnectivityProvider().isOnline();
    if (isOnline) {
      final response = await supabase
          .from('notifications')
          .select()
          .eq('shop_id', shopId)
          .order('is_viewed', ascending: true)
          .order('date', ascending: false)
          .limit(10);

      _notifications =
          (response as List)
              .map(
                (item) => TempNotification.fromJson(item),
              )
              .toList();

      await NotificationFunc().insertAllNotifications(
        _notifications,
      );
    } else {
      _notifications =
          NotificationFunc().getNotifications();
    }
    notifyListeners();
    return _notifications;
  }

  Future<void> updateNotification(String notifUuid) async {
    bool isOnline = await connectivity.isOnline();

    if (isOnline) {
      try {
        print(
          'Updating notification with uuid: $notifUuid',
        );
        final response =
            await supabase
                .from('notifications')
                .update({'is_viewed': true})
                .eq('uuid', notifUuid)
                .select()
                .maybeSingle();

        if (response == null) {
          debugPrint(
            '⚠️ No notification found with uuid $notifUuid',
          );
        } else {
          debugPrint(
            '✅ Notification $notifUuid updated: $response',
          );
        }

        // Update locally
        int index = _notifications.indexWhere(
          (n) => n.uuid == notifUuid,
        );
        if (index != -1) {
          _notifications[index] = TempNotification(
            uuid: _notifications[index].uuid,
            notifId: _notifications[index].notifId,
            shopId: _notifications[index].shopId,
            productId: _notifications[index].productId,
            productUuid: _notifications[index].productUuid,
            title: _notifications[index].title,
            text: _notifications[index].text,
            date: _notifications[index].date,
            category: _notifications[index].category,
            itemName: _notifications[index].itemName,
            isViewed: true,
          );
          notifyListeners();
        }
      } catch (e) {
        debugPrint('Error updating notification: $e');
      }
    }
  }
}
