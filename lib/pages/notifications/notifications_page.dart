import 'package:flutter/material.dart';
import 'package:storrec/pages/notifications/platforms/notifications_mobile.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 550) {
          return NotificationsMobile();
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
