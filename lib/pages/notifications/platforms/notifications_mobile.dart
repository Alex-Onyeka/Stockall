import 'package:flutter/material.dart';
import 'package:stockitt/components/major/empty_widget_display_only.dart';
import 'package:stockitt/components/major/top_banner.dart';
import 'package:stockitt/main.dart';

class NotificationsMobile extends StatelessWidget {
  const NotificationsMobile({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Scaffold(
      body: Column(
        children: [
          TopBanner(
            subTitle: 'Manage your account messages',
            title: 'Notifications',
            theme: theme,
            bottomSpace: 40,
            topSpace: 30,
            iconData: Icons.notifications,
            isMain: true,
          ),
          Expanded(
            child: Stack(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      bottom: 30.0,
                    ),
                    child: EmptyWidgetDisplayOnly(
                      title: 'No New Notifications',
                      subText:
                          'Your currently don\'t any new notifications. Check back later when you do.',
                      theme: theme,
                      height: 30,
                      icon:
                          Icons
                              .notifications_active_outlined,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
