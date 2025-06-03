import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storrec/classes/temp_notification.dart';
import 'package:storrec/components/alert_dialogues/confirmation_alert.dart';
import 'package:storrec/components/major/empty_widget_display_only.dart';
import 'package:storrec/components/major/top_banner.dart';
import 'package:storrec/constants/calculations.dart';
import 'package:storrec/main.dart';
import 'package:storrec/pages/products/product_details/product_details_page.dart';
import 'package:storrec/providers/notifications_provider.dart';
import 'package:storrec/providers/theme_provider.dart';

class NotificationsMobile extends StatelessWidget {
  const NotificationsMobile({super.key});

  @override
  Widget build(BuildContext context) {
    var notificationss =
        returnNotificationProvider(context).notifications;
    var theme = returnTheme(context);
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          TopBanner(
            subTitle: 'Manage your account Notifications',
            title: 'Notifications',
            theme: theme,
            bottomSpace: 40,
            topSpace: 30,
            iconData: Icons.notifications,
            isMain: true,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15.0,
              ),
              child: Builder(
                builder: (context) {
                  if (notificationss.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          bottom: 30.0,
                        ),
                        child: EmptyWidgetDisplayOnly(
                          title: 'No New Notifications',
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
                    return ListView.builder(
                      padding: EdgeInsets.only(top: 20),
                      itemCount: notificationss.length,
                      itemBuilder: (context, index) {
                        TempNotification notif =
                            notificationss[index];
                        return Padding(
                          padding:
                              const EdgeInsets.symmetric(
                                vertical: 5.0,
                              ),
                          child: NotificatonTileMain(
                            notif: notif,
                            theme: theme,
                            action: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return ConfirmationAlert(
                                    theme: theme,
                                    message:
                                        'Are you sure you want to proceed with delete?',
                                    title:
                                        'Delete Notification?',
                                    action: () {
                                      Provider.of<
                                        NotificationProvider
                                      >(
                                        context,
                                        listen: false,
                                      ).deleteNotification(
                                        notif,
                                      );
                                      Navigator.of(
                                        context,
                                      ).pop();
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return ProductDetailsPage(
                  productId: widget.notif.productId,
                );
              },
            ),
          );
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
                                    'out_of_stock'
                                ? widget
                                    .theme
                                    .lightModeColor
                                    .errorColor200
                                : widget.notif.notifId ==
                                    'product_deleted'
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
                                'out_of_stock'
                            ? Icons.dangerous_outlined
                            : widget.notif.notifId ==
                                'product_created'
                            ? Icons.plus_one
                            : widget.notif.notifId ==
                                'product_deleted'
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
                                  // fontSize:
                                  //     theme
                                  //         .mobileTexts
                                  //         .b2
                                  //         .fontSize,
                                  fontWeight:
                                      FontWeight.bold,
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
                                      Colors.grey.shade500,
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
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
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
                                          'Product',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            spacing: 3,
                            children: [
                              Icon(
                                size: 20,
                                color: Colors.grey,
                                Icons
                                    .delete_outline_rounded,
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
