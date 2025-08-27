import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_notification.dart';
import 'package:stockall/components/major/drawer_widget/platforms/my_drawer_widget_desktop.dart';
import 'package:stockall/components/major/drawer_widget/platforms/my_drawer_widget_mobile.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/providers/theme_provider.dart';

class MyDrawerWidget extends StatelessWidget {
  final ThemeProvider theme;
  final Function()? action;
  final List<TempNotification> notifications;
  final GlobalKey<ScaffoldState>? globalKey;
  const MyDrawerWidget({
    super.key,
    required this.theme,
    required this.notifications,
    required this.action,
    this.globalKey,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < mobileScreen) {
          return MyDrawerWidgetMobile(
            action: action,
            notifications: notifications,
            theme: theme,
          );
        } else {
          return MyDrawerWidgetDesktop(
            theme: theme,
            notifications: notifications,
            action: action,
            globalKey: globalKey!,
          );
        }
      },
    );
  }
}
