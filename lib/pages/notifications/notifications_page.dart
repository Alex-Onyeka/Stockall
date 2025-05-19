import 'package:flutter/material.dart';
import 'package:stockitt/classes/temp_notification.dart';
import 'package:stockitt/pages/notifications/platforms/notifications_mobile.dart';

class NotificationsPage extends StatelessWidget {
  final List<TempNotification> notifications;
  const NotificationsPage({
    super.key,
    required this.notifications,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 550) {
          return NotificationsMobile(
            notifications: notifications,
          );
        } else if (constraints.maxWidth > 550 &&
            constraints.maxWidth < 1000) {
          return Scaffold();
        } else {
          return Scaffold();
        }
      },
    );
  }
}
