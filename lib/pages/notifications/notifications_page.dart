import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/notifications/platforms/notifications_desktop.dart';
import 'package:stockall/pages/notifications/platforms/notifications_mobile.dart';

class NotificationsPage extends StatefulWidget {
  final bool? turnOn;
  const NotificationsPage({super.key, this.turnOn});

  @override
  State<NotificationsPage> createState() =>
      _NotificationsPageState();
}

class _NotificationsPageState
    extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    returnNavProvider(context, listen: false).navigate(8);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await returnNavProvider(
        context,
        listen: false,
      ).validate(context);
      setState(() {
        // stillLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < mobileScreen) {
          return NotificationsMobile();
        } else {
          return NotificationsDesktop(
            turnOn: widget.turnOn,
          );
        }
      },
    );
  }
}
