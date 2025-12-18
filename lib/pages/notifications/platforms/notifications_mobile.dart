import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockall/classes/temp_notification/temp_notification.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/components/major/top_banner.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/notifications/platforms/notifications_desktop.dart';
import 'package:stockall/providers/notifications_provider.dart';

class NotificationsMobile extends StatefulWidget {
  const NotificationsMobile({super.key});

  @override
  State<NotificationsMobile> createState() =>
      _NotificationsMobileState();
}

class _NotificationsMobileState
    extends State<NotificationsMobile> {
  bool isLoading = false;
  int index = 0;
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.grey.shade100,
          body: Column(
            children: [
              TopBanner(
                subTitle:
                    'Manage your account Notifications',
                title: 'Notifications',
                theme: theme,
                bottomSpace: 40,
                topSpace: 30,
                iconData: Icons.notifications,
                isMain: true,
                altAction: () {
                  showDialog(
                    context: context,
                    builder: (confirmDialog) {
                      return ConfirmationAlert(
                        theme: theme,
                        message:
                            'Are you sure you want to proceed to mark all notifications as Read?',
                        title: 'Are you sure?',
                        action: () async {
                          Navigator.of(confirmDialog).pop();
                          setState(() {
                            isLoading = true;
                          });
                          await returnNotificationProvider(
                            context,
                            listen: false,
                          ).markAllNotificationsAsRead(
                            context: context,
                          );
                          setState(() {
                            isLoading = false;
                          });
                        },
                      );
                    },
                  );
                },
                altText: 'Mark All As Read',
              ),
              Container(
                color: Colors.grey.shade100,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    15,
                    10,
                    0,
                    0,
                  ),
                  child: Builder(
                    builder: (context) {
                      return Row(
                        spacing: 4,
                        children: [
                          NotifSwitchTab(
                            list:
                                returnNotificationProvider(
                                      context,
                                      listen: false,
                                    ).notifications
                                    .where(
                                      (notif) =>
                                          notif.category ==
                                              'product' &&
                                          notif.isViewed ==
                                              false,
                                    )
                                    .toList(),
                            myIndex: 0,
                            currentIndex: index,
                            theme: theme,
                            title: 'Products',
                            action: () {
                              setState(() {
                                index = 0;
                              });
                            },
                          ),
                          NotifSwitchTab(
                            list:
                                returnNotificationProvider(
                                      context,
                                      listen: false,
                                    ).notifications
                                    .where(
                                      (notif) =>
                                          notif.category ==
                                              'expense' &&
                                          notif.isViewed ==
                                              false,
                                    )
                                    .toList(),
                            myIndex: 1,
                            currentIndex: index,
                            theme: theme,
                            title: 'Expenses',
                            action: () {
                              setState(() {
                                index = 1;
                              });
                            },
                          ),
                          NotifSwitchTab(
                            list:
                                returnNotificationProvider(
                                      context,
                                      listen: false,
                                    ).notifications
                                    .where(
                                      (notif) =>
                                          notif.category ==
                                              'general' &&
                                          notif.isViewed ==
                                              false,
                                    )
                                    .toList(),
                            myIndex: 2,
                            currentIndex: index,
                            theme: theme,
                            title: 'General',
                            action: () {
                              setState(() {
                                index = 2;
                              });
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15.0,
                  ),
                  child: Builder(
                    builder: (context) {
                      if (index == 0) {
                        if (returnNotificationProvider(
                              context,
                              listen: false,
                            ).notifications
                            .where(
                              (notif) =>
                                  notif.category ==
                                  'product',
                            )
                            .isNotEmpty) {
                          return RefreshIndicator(
                            onRefresh: () {
                              return returnNotificationProvider(
                                context,
                                listen: false,
                              ).fetchRecentNotifications(
                                shopId(context),
                              );
                            },
                            backgroundColor: Colors.white,
                            color:
                                theme
                                    .lightModeColor
                                    .prColor300,
                            displacement: 10,
                            child: ListView.builder(
                              padding: EdgeInsets.only(
                                top: 5,
                              ),
                              itemCount:
                                  returnNotificationProvider(
                                        context,
                                        listen: false,
                                      ).notifications
                                      .where(
                                        (notif) =>
                                            notif
                                                .category ==
                                            'product',
                                      )
                                      .toList()
                                      .length,
                              itemBuilder: (
                                context,
                                index,
                              ) {
                                TempNotification notif =
                                    returnNotificationProvider(
                                          context,
                                          listen: false,
                                        ).notifications
                                        .where(
                                          (notif) =>
                                              notif
                                                  .category ==
                                              'product',
                                        )
                                        .toList()[index];
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(
                                        vertical: 5.0,
                                      ),
                                  child: NotificatonTileMain(
                                    notif: notif,
                                    theme: theme,
                                    action: () {
                                      if (authorization(
                                        authorized:
                                            Authorizations()
                                                .deleteNotification,
                                        context: context,
                                      )) {
                                        showDialog(
                                          context: context,
                                          builder: (
                                            context,
                                          ) {
                                            return ConfirmationAlert(
                                              theme: theme,
                                              message:
                                                  'Are you sure you want to proceed with delete?',
                                              title:
                                                  'Delete Notification?',
                                              action: () async {
                                                await Provider.of<
                                                  NotificationProvider
                                                >(
                                                  context,
                                                  listen:
                                                      false,
                                                ).deleteNotificationFromSupabase(
                                                  notif,
                                                );
                                                if (context
                                                    .mounted) {
                                                  Navigator.of(
                                                    context,
                                                  ).pop();
                                                }
                                              },
                                            );
                                          },
                                        );
                                      }
                                    },
                                  ),
                                );
                              },
                            ),
                          );
                        } else {
                          return Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(
                                    bottom: 30.0,
                                  ),
                              child: EmptyWidgetDisplayOnly(
                                title:
                                    'No New Notifications',
                                subText:
                                    'Your currently don\'t have any new notification Under this Category. Check back later when you do.',
                                theme: theme,
                                height: 30,
                                icon:
                                    Icons
                                        .notifications_active_outlined,
                              ),
                            ),
                          );
                        }
                      } else if (index == 1) {
                        if (returnNotificationProvider(
                              context,
                              listen: false,
                            ).notifications
                            .where(
                              (notif) =>
                                  notif.category ==
                                  'expense',
                            )
                            .isNotEmpty) {
                          return RefreshIndicator(
                            onRefresh: () {
                              return returnNotificationProvider(
                                context,
                                listen: false,
                              ).fetchRecentNotifications(
                                shopId(context),
                              );
                            },
                            backgroundColor: Colors.white,
                            color:
                                theme
                                    .lightModeColor
                                    .prColor300,
                            displacement: 10,
                            child: ListView.builder(
                              padding: EdgeInsets.only(
                                top: 5,
                              ),
                              itemCount:
                                  returnNotificationProvider(
                                        context,
                                        listen: false,
                                      ).notifications
                                      .where(
                                        (notif) =>
                                            notif
                                                .category ==
                                            'expense',
                                      )
                                      .toList()
                                      .length,
                              itemBuilder: (
                                context,
                                index,
                              ) {
                                TempNotification notif =
                                    returnNotificationProvider(
                                          context,
                                          listen: false,
                                        ).notifications
                                        .where(
                                          (notif) =>
                                              notif
                                                  .category ==
                                              'expense',
                                        )
                                        .toList()[index];
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(
                                        vertical: 5.0,
                                      ),
                                  child: NotificatonTileMain(
                                    notif: notif,
                                    theme: theme,
                                    action: () {
                                      if (authorization(
                                        authorized:
                                            Authorizations()
                                                .deleteNotification,
                                        context: context,
                                      )) {
                                        showDialog(
                                          context: context,
                                          builder: (
                                            context,
                                          ) {
                                            return ConfirmationAlert(
                                              theme: theme,
                                              message:
                                                  'Are you sure you want to proceed with delete?',
                                              title:
                                                  'Delete Notification?',
                                              action: () async {
                                                await Provider.of<
                                                  NotificationProvider
                                                >(
                                                  context,
                                                  listen:
                                                      false,
                                                ).deleteNotificationFromSupabase(
                                                  notif,
                                                );
                                                if (context
                                                    .mounted) {
                                                  Navigator.of(
                                                    context,
                                                  ).pop();
                                                }
                                              },
                                            );
                                          },
                                        );
                                      }
                                    },
                                  ),
                                );
                              },
                            ),
                          );
                        } else {
                          return Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(
                                    bottom: 30.0,
                                  ),
                              child: EmptyWidgetDisplayOnly(
                                title:
                                    'No New Notifications',
                                subText:
                                    'Your currently don\'t have any new notification under this Category. Check back later when you do.',
                                theme: theme,
                                height: 30,
                                icon:
                                    Icons
                                        .notifications_active_outlined,
                              ),
                            ),
                          );
                        }
                      } else {
                        if (returnNotificationProvider(
                              context,
                              listen: false,
                            ).notifications
                            .where(
                              (notif) =>
                                  notif.category ==
                                  'general',
                            )
                            .isNotEmpty) {
                          return RefreshIndicator(
                            onRefresh: () {
                              return returnNotificationProvider(
                                context,
                                listen: false,
                              ).fetchRecentNotifications(
                                shopId(context),
                              );
                            },
                            backgroundColor: Colors.white,
                            color:
                                theme
                                    .lightModeColor
                                    .prColor300,
                            displacement: 10,
                            child: ListView.builder(
                              padding: EdgeInsets.only(
                                top: 5,
                              ),
                              itemCount:
                                  returnNotificationProvider(
                                        context,
                                        listen: false,
                                      ).notifications
                                      .where(
                                        (notif) =>
                                            notif
                                                .category ==
                                            'general',
                                      )
                                      .toList()
                                      .length,
                              itemBuilder: (
                                context,
                                index,
                              ) {
                                TempNotification notif =
                                    returnNotificationProvider(
                                          context,
                                          listen: false,
                                        ).notifications
                                        .where(
                                          (notif) =>
                                              notif
                                                  .category ==
                                              'general',
                                        )
                                        .toList()[index];
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(
                                        vertical: 5.0,
                                      ),
                                  child: NotificatonTileMain(
                                    notif: notif,
                                    theme: theme,
                                    action: () {
                                      if (authorization(
                                        authorized:
                                            Authorizations()
                                                .deleteNotification,
                                        context: context,
                                      )) {
                                        showDialog(
                                          context: context,
                                          builder: (
                                            context,
                                          ) {
                                            return ConfirmationAlert(
                                              theme: theme,
                                              message:
                                                  'Are you sure you want to proceed with delete?',
                                              title:
                                                  'Delete Notification?',
                                              action: () async {
                                                await Provider.of<
                                                  NotificationProvider
                                                >(
                                                  context,
                                                  listen:
                                                      false,
                                                ).deleteNotificationFromSupabase(
                                                  notif,
                                                );
                                                if (context
                                                    .mounted) {
                                                  Navigator.of(
                                                    context,
                                                  ).pop();
                                                }
                                              },
                                            );
                                          },
                                        );
                                      }
                                    },
                                  ),
                                );
                              },
                            ),
                          );
                        } else {
                          return Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(
                                    bottom: 30.0,
                                  ),
                              child: EmptyWidgetDisplayOnly(
                                title:
                                    'No New Notifications',
                                subText:
                                    'Your currently don\'t have any new notification under this Category. Check back later when you do.',
                                theme: theme,
                                height: 30,
                                icon:
                                    Icons
                                        .notifications_active_outlined,
                              ),
                            ),
                          );
                        }
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        Visibility(
          visible: isLoading,
          child: Material(
            child: returnCompProvider(
              context,
              listen: false,
            ).showLoader(message: 'Loading'),
          ),
        ),
      ],
    );
  }
}
