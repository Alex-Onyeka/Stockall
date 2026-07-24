import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_notification/temp_notification.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/local_database/notification/notification_func.dart';
import 'package:stockall/local_database/shop/shop_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationProvider with ChangeNotifier {
  final SupabaseClient supabase = Supabase.instance.client;
  final ConnectivityProvider connectivity =
      ConnectivityProvider();

  List<TempNotification> _notifications = [];

  // List<TempNotification> get notifications =>
  //     _notifications;
  List<TempNotification> notifications() {
    if (returnShopProvider()
            .userShop()
            ?.manageDepartments ==
        true) {
      if (!authorization(
        authorized: Authorizations().viewAllDepartments,
      )) {
        return _notifications.where((cat) {
          return cat.departmentUuid ==
              returnDepartmentProvider()
                  .currentDepartment()
                  ?.uuid;
          // }
        }).toList();
      } else {
        if (returnDepartmentProvider()
                .currentDepartment()
                ?.uuid ==
            null) {
          return _notifications;
        } else {
          return _notifications.where((cat) {
            return cat.departmentUuid ==
                returnDepartmentProvider()
                    .currentDepartment()
                    ?.uuid;
            // }
          }).toList();
        }
      }
    } else {
      return _notifications;
    }
  }

  void clearNotifications() {
    _notifications.clear();
    mainLocalLog('Notifications Cleared');
    notifyListeners();
  }

  void deleteNotification(TempNotification notif) {
    notifications().remove(notif);
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

  void refreshState() {
    notifyListeners();
  }

  Future<void> updateNotification(String notifUuid) async {
    bool isOnline = await connectivity.isOnline();

    if (isOnline) {
      var no = notifications().firstWhere(
        (noti) => noti.uuid == notifUuid,
      );
      if (!no.isViewed) {
        try {
          await mainLocalLog(
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
              departmentName:
                  _notifications[index].departmentName,
              departmentUuid:
                  _notifications[index].departmentUuid,
              uuid: _notifications[index].uuid,
              notifId: _notifications[index].notifId,
              shopId: _notifications[index].shopId,
              productId: _notifications[index].productId,
              productUuid:
                  _notifications[index].productUuid,
              title: _notifications[index].title,
              text: _notifications[index].text,
              date: _notifications[index].date,
              category: _notifications[index].category,
              itemName: _notifications[index].itemName,
              isViewed: true,
            );
            await fetchRecentNotifications(
              ShopFunc().getShops().first.shopId ?? 0,
            );
            notifyListeners();
          }
        } catch (e) {
          debugPrint('Error updating notification: $e');
        }
      }
    }
  }

  Future<void> markAllNotificationsAsRead({
    required BuildContext context,
  }) async {
    var shopId = returnShopProvider().userShop()!.shopId!;
    var isOnline = await connectivity.isOnline();
    if (isOnline) {
      await supabase.rpc(
        'mark_all_notifications_viewed',
        params: {'p_shop_id': shopId},
      );
      await fetchRecentNotifications(shopId);
    } else {
      if (!context.mounted) {
        return;
      }
      showDialog(
        context: context,
        builder: (context) {
          return InfoAlert(
            theme: returnTheme(context, listen: false),
            message:
                'This action you are trying to perform cannot be performed offline.',
            title: 'No Internet Connection.',
          );
        },
      );
    }
  }
}
