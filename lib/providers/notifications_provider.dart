import 'package:flutter/material.dart';
import 'package:stockitt/classes/temp_notification.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationProvider with ChangeNotifier {
  final SupabaseClient supabase = Supabase.instance.client;

  List<TempNotification> _notifications = [];

  List<TempNotification> get notifications =>
      _notifications;

  Future<List<TempNotification>> fetchRecentNotifications(
    int shopId,
  ) async {
    final response = await supabase
        .from('notifications')
        .select()
        .eq('shop_id', shopId)
        .order('date', ascending: false)
        .limit(10);

    _notifications =
        (response as List)
            .map((item) => TempNotification.fromJson(item))
            .toList();
    notifyListeners();
    return _notifications;
  }

  Future<void> updateNotification(int notifId) async {
    try {
      final response = await supabase
          .from('notifications')
          .update({'is_viewed': true})
          .eq(
            'id',
            notifId,
          ); // FIXED: Use 'id' not 'notif_id'

      if (response != null) {
        debugPrint('Notification $notifId updated.');
      }

      // Update locally
      int index = _notifications.indexWhere(
        (n) => n.id == notifId,
      );
      if (index != -1) {
        _notifications[index] = TempNotification(
          id: _notifications[index].id,
          notifId: _notifications[index].notifId,
          shopId: _notifications[index].shopId,
          productId: _notifications[index].productId,
          title: _notifications[index].title,
          text: _notifications[index].text,
          date: _notifications[index].date,
          category: _notifications[index].category,

          isViewed: true,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating notification: $e');
    }
  }
}
