import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stockall/classes/temp_notification/temp_notification.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/expenses/single_expense/expense_details.dart';
import 'package:stockall/pages/notifications/notifications_page.dart';
import 'package:stockall/pages/products/product_details/product_details_page.dart';
import 'package:stockall/pages/profile/profile_page.dart';
import 'package:stockall/pages/sales/make_sales/page1/make_sales_page.dart';
import 'package:stockall/providers/theme_provider.dart';

class RightSideBar extends StatelessWidget {
  const RightSideBar({
    super.key,
    required this.theme,
    // required this.receiptsLocal,
  });

  final ThemeProvider theme;
  // final List<TempMainReceipt> receiptsLocal;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        width:
            screenWidth(context) > tabletScreenSmall
                ? 230
                : 90,
        padding: EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 10,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10),
            topLeft: Radius.circular(10),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(39, 4, 1, 41),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return ProfilePage();
                      },
                    ),
                  );
                },
                child: SizedBox(
                  child: Column(
                    children: [
                      SizedBox(height: 60),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: Image.asset(
                          profileIconImage,
                          height:
                              screenWidth(context) >
                                      tabletScreenSmall
                                  ? 70
                                  : 50,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize:
                              screenWidth(context) >
                                      tabletScreenSmall
                                  ? theme
                                      .mobileTexts
                                      .b2
                                      .fontSize
                                  : theme
                                      .mobileTexts
                                      .b4
                                      .fontSize,
                        ),
                        userGeneral(context).name,
                      ),
                      Visibility(
                        visible:
                            screenWidth(context) >
                            tabletScreenSmall,
                        child: Text(
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color:
                                theme
                                    .lightModeColor
                                    .secColor200,
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b3
                                    .fontSize,
                          ),
                          userGeneral(context).email,
                        ),
                      ),
                      SizedBox(height: 5),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(
                            32,
                            255,
                            193,
                            7,
                          ),
                          borderRadius:
                              BorderRadius.circular(5),
                          border: Border.all(
                            color:
                                theme
                                    .lightModeColor
                                    .secColor200,
                          ),
                        ),
                        child: Text(
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            // color:
                            //     theme
                            //         .lightModeColor
                            //         .secColor200,
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b4
                                    .fontSize,
                          ),
                          userGeneral(context).role,
                        ),
                      ),
                      Visibility(
                        visible:
                            screenWidth(context) <=
                            tabletScreenSmall,
                        child: SizedBox(height: 30),
                      ),
                      Visibility(
                        visible:
                            screenWidth(context) >
                            tabletScreenSmall,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            0,
                            5,
                            20,
                            20,
                          ),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.end,
                            children: [
                              Icon(
                                size: 15,
                                color: Colors.grey,
                                Icons
                                    .arrow_forward_ios_rounded,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Divider(
              color: Colors.grey.shade300,
              height: 50,
            ),
            Visibility(
              visible: !isStoreKeeper(),
              child: Expanded(
                child: SizedBox(
                  child: Column(
                    spacing: 10,
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return NotificationsPage();
                                },
                              ),
                            );
                          },
                          child: Padding(
                            padding:
                                const EdgeInsets.fromLTRB(
                                  0,
                                  10,
                                  0,
                                  10,
                                ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,
                              children: [
                                Text(
                                  style: TextStyle(
                                    fontSize:
                                        screenWidth(
                                                  context,
                                                ) >
                                                tabletScreenSmall
                                            ? theme
                                                .mobileTexts
                                                .b2
                                                .fontSize
                                            : theme
                                                .mobileTexts
                                                .b4
                                                .fontSize,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                  screenWidth(context) <
                                          tabletScreenSmall
                                      ? 'Notif'
                                      : 'Notifications',
                                ),
                                Icon(
                                  size:
                                      screenWidth(
                                                context,
                                              ) <=
                                              tabletScreenSmall
                                          ? 13
                                          : 15,
                                  color: Colors.grey,
                                  Icons
                                      .arrow_forward_ios_rounded,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // SizedBox(height: 10),
                      Visibility(
                        visible:
                            screenWidth(context) >
                            tabletScreenSmall,
                        child: Builder(
                          builder: (context) {
                            if (returnNotificationProvider(
                                  context,
                                )
                                .notifications()
                                .where(
                                  (notif) =>
                                      !notif.isViewed,
                                )
                                .isEmpty) {
                              return Expanded(
                                child: Material(
                                  color: Colors.transparent,
                                  child: Center(
                                    child: Column(
                                      spacing: 10,
                                      mainAxisAlignment:
                                          MainAxisAlignment
                                              .center,
                                      children: [
                                        Icon(
                                          size: 20,
                                          color:
                                              Colors.grey,
                                          Icons
                                              .notifications_active_outlined,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment
                                                  .center,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                style: TextStyle(
                                                  fontSize:
                                                      theme
                                                          .mobileTexts
                                                          .b3
                                                          .fontSize,
                                                ),
                                                'No New Notifications',
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return Expanded(
                                child: ListView.builder(
                                  itemCount:
                                      returnNotificationProvider(
                                            context,
                                          )
                                          .notifications()
                                          .where(
                                            (notif) =>
                                                !notif
                                                    .isViewed,
                                          )
                                          .length,
                                  itemBuilder: (
                                    context,
                                    index,
                                  ) {
                                    var notif =
                                        returnNotificationProvider(
                                              context,
                                            )
                                            .notifications()
                                            .where(
                                              (notif) =>
                                                  !notif
                                                      .isViewed,
                                            )
                                            .toList();
                                    notif.sort(
                                      (a, b) =>
                                          b.date.compareTo(
                                            a.date,
                                          ),
                                    );
                                    TempNotification?
                                    notification =
                                        notif[index];
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(
                                            bottom: 2,
                                          ),
                                      child: Material(
                                        color:
                                            Colors
                                                .transparent,
                                        child: InkWell(
                                          onTap: () {
                                            if (context
                                                    .mounted &&
                                                notification
                                                        .productUuid !=
                                                    null) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (
                                                    context,
                                                  ) {
                                                    return ProductDetailsPage(
                                                      notifId:
                                                          notification.uuid,
                                                      productUuid:
                                                          notification.productUuid!,
                                                    );
                                                  },
                                                ),
                                              ).then((_) {
                                                returnNotificationProvider(
                                                  context,
                                                  listen:
                                                      false,
                                                ).refreshState();
                                              });
                                            } else if (context
                                                    .mounted &&
                                                notification
                                                        .expensesUuid !=
                                                    null) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (
                                                    context,
                                                  ) {
                                                    return ExpenseDetails(
                                                      notifId:
                                                          notification.uuid,
                                                      expenseUuid:
                                                          notification.expensesUuid ??
                                                          '0',
                                                    );
                                                  },
                                                ),
                                              ).then((_) {
                                                returnNotificationProvider(
                                                  context,
                                                  listen:
                                                      false,
                                                ).refreshState();
                                              });
                                            } else if (notification
                                                        .expensesUuid ==
                                                    null &&
                                                notification
                                                        .productUuid ==
                                                    null) {
                                              if (!notification
                                                  .isViewed) {
                                                showDialog(
                                                  context:
                                                      context,
                                                  builder: (
                                                    confirmDialog,
                                                  ) {
                                                    return ConfirmationAlert(
                                                      theme:
                                                          theme,
                                                      message:
                                                          'Are you sure you want to mark this notification as read?',
                                                      title:
                                                          'Mark As Read?',
                                                      action: () async {
                                                        Navigator.of(
                                                          confirmDialog,
                                                        ).pop();
                                                        await returnNotificationProvider(
                                                          context,
                                                          listen:
                                                              false,
                                                        ).updateNotification(
                                                          notification.uuid!,
                                                        );
                                                      },
                                                    );
                                                  },
                                                );
                                              }
                                            }
                                          },
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                  horizontal:
                                                      5,
                                                  vertical:
                                                      11,
                                                ),
                                            child: Row(
                                              spacing: 10,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  flex: 7,
                                                  child: Row(
                                                    spacing:
                                                        10,
                                                    children: [
                                                      SvgPicture.asset(
                                                        notifIconSvg,
                                                        color:
                                                            Colors.grey,
                                                        height:
                                                            13,
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          style: TextStyle(
                                                            fontSize:
                                                                theme.mobileTexts.b4.fontSize,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                          cutLongText(
                                                            notification.title,
                                                            30,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Icon(
                                                  size: 15,
                                                  color:
                                                      Colors
                                                          .grey,
                                                  Icons
                                                      .arrow_forward_ios_rounded,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Visibility(
              visible:
                  screenWidth(context) >
                      tabletScreenSmall &&
                  !isStoreKeeper(),
              child: MainButtonP(
                themeProvider: theme,
                action: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return MakeSalesPage();
                      },
                    ),
                  ).then((_) {
                    // returnData().startBarcodeTimer();
                  });
                },
                text: 'Make New Sale',
              ),
            ),
            Visibility(
              visible:
                  screenWidth(context) <=
                      tabletScreenSmall &&
                  !isStoreKeeper() &&
                  authorization(
                    authorized: Authorizations().makeSale,
                  ),
              child: Material(
                color: Colors.transparent,
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return MakeSalesPage();
                          },
                        ),
                      ).then((_) {
                        // returnData().startBarcodeTimer();
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 5,
                      ),
                      child: Column(
                        spacing: 4,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            height: 50,
                            makeSalesIconSvg,
                          ),
                          Text(
                            style: TextStyle(
                              color: const Color.fromARGB(
                                255,
                                4,
                                49,
                                199,
                              ),
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b4
                                      .fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                            'Make Sale',
                          ),
                          SizedBox(height: 5),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
