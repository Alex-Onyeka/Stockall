import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockall/classes/temp_notification.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/major/desktop_page_container.dart';
import 'package:stockall/components/major/drawer_widget/platforms/my_drawer_widget_desktop.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/components/major/drawer_widget/my_drawer_widget.dart';
import 'package:stockall/components/major/right_side_bar.dart';
import 'package:stockall/components/major/top_banner.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/expenses/single_expense/expense_details.dart';
import 'package:stockall/pages/products/product_details/product_details_page.dart';
import 'package:stockall/providers/notifications_provider.dart';
import 'package:stockall/providers/theme_provider.dart';
import 'package:stockall/services/auth_service.dart';

class NotificationsDesktop extends StatefulWidget {
  final bool? turnOn;
  const NotificationsDesktop({super.key, this.turnOn});

  @override
  State<NotificationsDesktop> createState() =>
      _NotificationsDesktopState();
}

class _NotificationsDesktopState
    extends State<NotificationsDesktop> {
  bool isLoading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    var notificationss =
        returnNotificationProvider(context).notifications;
    var theme = returnTheme(context);
    return Scaffold(
      key: _scaffoldKey,
      drawer: MyDrawerWidgetDesktopMain(
        action: () {
          var safeContext = context;
          showDialog(
            context: context,
            builder: (context) {
              return ConfirmationAlert(
                theme: theme,
                message: 'You are about to Logout',
                title: 'Are you Sure?',
                action: () async {
                  Navigator.of(context).pop();
                  setState(() {
                    isLoading = true;
                  });
                  if (safeContext.mounted) {
                    await AuthService().signOut(
                      safeContext,
                    );
                  }
                },
              );
            },
          );
        },
        theme: theme,
        notifications:
            returnNotificationProvider(
                  context,
                ).notifications.isEmpty
                ? []
                : returnNotificationProvider(
                  context,
                ).notifications,
        globalKey: _scaffoldKey,
      ),
      body: Stack(
        children: [
          Row(
            spacing: 15,
            children: [
              MyDrawerWidget(
                globalKey: _scaffoldKey,
                action: () {
                  var safeContext = context;
                  showDialog(
                    context: context,
                    builder: (context) {
                      return ConfirmationAlert(
                        theme: theme,
                        message: 'You are about to Logout',
                        title: 'Are you Sure?',
                        action: () async {
                          Navigator.of(context).pop();
                          setState(() {
                            isLoading = true;
                          });
                          if (safeContext.mounted) {
                            await AuthService().signOut(
                              safeContext,
                            );
                          }
                        },
                      );
                    },
                  );
                },
                theme: theme,
                notifications:
                    returnNotificationProvider(
                          context,
                        ).notifications.isEmpty
                        ? []
                        : returnNotificationProvider(
                          context,
                        ).notifications,
              ),
              Expanded(
                child: DesktopPageContainer(
                  widget: Scaffold(
                    backgroundColor: Colors.grey.shade100,
                    body: Column(
                      children: [
                        TopBanner(
                          turnOn: widget.turnOn,
                          subTitle:
                              'Manage your account Notifications',
                          title: 'Notifications',
                          theme: theme,
                          bottomSpace: 40,
                          topSpace: 30,
                          iconData: Icons.notifications,
                          isMain: true,
                        ),
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(
                                  horizontal: 15.0,
                                ),
                            child: Builder(
                              builder: (context) {
                                if (notificationss
                                    .isEmpty) {
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
                                            'Your currently don\'t have any new notification. Check back later when you do.',
                                        theme: theme,
                                        height: 30,
                                        icon:
                                            Icons
                                                .notifications_active_outlined,
                                      ),
                                    ),
                                  );
                                } else {
                                  return RefreshIndicator(
                                    onRefresh: () {
                                      return returnNotificationProvider(
                                        context,
                                        listen: false,
                                      ).fetchRecentNotifications(
                                        shopId(context),
                                      );
                                    },
                                    backgroundColor:
                                        Colors.white,
                                    color:
                                        theme
                                            .lightModeColor
                                            .prColor300,
                                    displacement: 10,
                                    child: ListView.builder(
                                      padding:
                                          EdgeInsets.only(
                                            top: 20,
                                          ),
                                      itemCount:
                                          notificationss
                                              .length,
                                      itemBuilder: (
                                        context,
                                        index,
                                      ) {
                                        TempNotification
                                        notif =
                                            notificationss[index];
                                        return Padding(
                                          padding:
                                              const EdgeInsets.symmetric(
                                                vertical:
                                                    5.0,
                                              ),
                                          child: NotificatonTileMain(
                                            notif: notif,
                                            theme: theme,
                                            action: () {
                                              if (authorization(
                                                authorized:
                                                    Authorizations()
                                                        .deleteNotification,
                                                context:
                                                    context,
                                              )) {
                                                showDialog(
                                                  context:
                                                      context,
                                                  builder: (
                                                    context,
                                                  ) {
                                                    return ConfirmationAlert(
                                                      theme:
                                                          theme,
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
                                                        if (context.mounted) {
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
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              RightSideBar(theme: theme),
            ],
          ),
          Visibility(
            visible: isLoading,
            child: returnCompProvider(
              context,
              listen: false,
            ).showLoader('Logging Out...'),
          ),
        ],
      ),
    );
  }
}

class NotificatonTileMain extends StatefulWidget {
  const NotificatonTileMain({
    super.key,
    required this.notif,
    required this.theme,
    required this.action,
  });

  final TempNotification notif;
  final ThemeProvider theme;
  final Function() action;

  @override
  State<NotificatonTileMain> createState() =>
      _NotificatonTileMainState();
}

class _NotificatonTileMainState
    extends State<NotificatonTileMain> {
  String cutLongText(String text) {
    if (text.length > 15) {
      return '${text.substring(0, 15)}...';
    } else {
      return text;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: BoxDecoration(
        color:
            widget.notif.isViewed
                ? Colors.grey.shade100
                : Colors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color:
              widget.notif.isViewed
                  ? Colors.grey.shade300
                  : Colors.white,
        ),
      ),
      child: InkWell(
        onTap: () {
          returnNotificationProvider(
            context,
            listen: false,
          ).updateNotification(widget.notif.id!);
          if (widget.notif.productId != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return ProductDetailsPage(
                    productId: widget.notif.productId ?? 0,
                  );
                },
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return ExpenseDetails(
                    expenseId: widget.notif.expenseId ?? 0,
                  );
                },
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(5),
        child: Container(
          padding: EdgeInsets.all(15),
          child: Row(
            spacing: 10,
            children: [
              Stack(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade200,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        bottom: 2.0,
                      ),
                      child: Icon(
                        color:
                            widget.notif.notifId ==
                                    'low_stock'
                                ? widget
                                    .theme
                                    .lightModeColor
                                    .secColor200
                                : widget.notif.notifId ==
                                    'item_expire'
                                ? widget
                                    .theme
                                    .lightModeColor
                                    .secColor200
                                : widget.notif.notifId ==
                                    'out_of_stock'
                                ? widget
                                    .theme
                                    .lightModeColor
                                    .errorColor200
                                : widget.notif.notifId ==
                                    'expired'
                                ? widget
                                    .theme
                                    .lightModeColor
                                    .errorColor200
                                : widget.notif.notifId ==
                                    'item_deleted'
                                ? widget
                                    .theme
                                    .lightModeColor
                                    .errorColor200
                                : widget
                                    .theme
                                    .lightModeColor
                                    .prColor250,
                        widget.notif.notifId == 'low_stock'
                            ? Icons.warning_amber_rounded
                            : widget.notif.notifId ==
                                'item_expire'
                            ? Icons.warning_amber_rounded
                            : widget.notif.notifId ==
                                'out_of_stock'
                            ? Icons.dangerous_outlined
                            : widget.notif.notifId ==
                                'expired'
                            ? Icons.dangerous_outlined
                            : widget.notif.notifId ==
                                'item_created'
                            ? Icons.plus_one
                            : widget.notif.notifId ==
                                'item_deleted'
                            ? Icons.exposure_minus_1_rounded
                            : Icons.add_chart_rounded,
                      ),
                    ),
                  ),
                  Visibility(
                    visible: !widget.notif.isViewed,
                    child: Positioned(
                      left: 30,
                      child: Container(
                        height: 13,
                        width: 13,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient:
                              widget
                                  .theme
                                  .lightModeColor
                                  .secGradient,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Flexible(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            spacing: 5,
                            children: [
                              Text(
                                style: TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                  fontSize:
                                      widget
                                          .theme
                                          .mobileTexts
                                          .b1
                                          .fontSize,
                                ),
                                widget.notif.title,
                              ),
                              Text(
                                style: TextStyle(
                                  fontSize:
                                      widget
                                          .theme
                                          .mobileTexts
                                          .b3
                                          .fontSize,
                                  fontWeight:
                                      FontWeight.normal,
                                  color:
                                      Colors.grey.shade700,
                                ),
                                widget.notif.text,
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          size: 20,
                          color: Colors.grey.shade400,
                          Icons.arrow_forward_ios_rounded,
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Divider(),
                    InkWell(
                      onTap: widget.action,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 5.0,
                          bottom: 5,
                          right: 15,
                        ),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                spacing: 5,
                                children: [
                                  Text(
                                    style: TextStyle(
                                      fontSize:
                                          widget
                                              .theme
                                              .mobileTexts
                                              .b3
                                              .fontSize,
                                      color:
                                          Colors
                                              .grey
                                              .shade600,
                                    ),
                                    'Item:',
                                  ),
                                  Flexible(
                                    child: Text(
                                      style: TextStyle(
                                        fontSize:
                                            widget
                                                .theme
                                                .mobileTexts
                                                .b3
                                                .fontSize,
                                        color:
                                            widget
                                                .theme
                                                .lightModeColor
                                                .prColor300,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                      cutLongText(
                                        widget
                                                .notif
                                                .itemName ??
                                            'Item',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              spacing: 3,
                              children: [
                                Visibility(
                                  visible: authorization(
                                    authorized:
                                        Authorizations()
                                            .deleteNotification,
                                    context: context,
                                  ),
                                  child: Icon(
                                    size: 20,
                                    color: Colors.grey,
                                    Icons
                                        .delete_outline_rounded,
                                  ),
                                ),
                                Text(
                                  style: TextStyle(
                                    fontSize:
                                        widget
                                            .theme
                                            .mobileTexts
                                            .b4
                                            .fontSize,
                                    color:
                                        widget
                                            .theme
                                            .lightModeColor
                                            .prColor300,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                  formatDateWithoutYear(
                                    widget.notif.date,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
