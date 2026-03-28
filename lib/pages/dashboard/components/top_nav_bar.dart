import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:popover/popover.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/refresh_functions.dart';
import 'package:stockall/constants/subscription/multiple_stores_auth.dart';
import 'package:stockall/constants/subscription/subscription_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/shop_setup/shop_page/shop_page.dart';
import 'package:stockall/pages/shop_setup/shop_setup_one/shop_setup_page.dart';
import 'package:stockall/providers/theme_provider.dart';

class TopNavBar extends StatefulWidget {
  final Function()? refreshAction;
  // final List<TempNotification> notifications;
  final String? title;
  final String? subText;
  final Function()? action;
  final ThemeProvider theme;

  final Function()? openSideBar;

  const TopNavBar({
    super.key,
    // required this.notifications,
    this.title,
    this.subText,
    required this.theme,
    required this.openSideBar,
    this.action,
    this.refreshAction,
  });

  @override
  State<TopNavBar> createState() => _TopNavBarState();
}

class _TopNavBarState extends State<TopNavBar> {
  bool isOpen = false;
  String? selectedValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 0,
        bottom: 10,
        left: 0,
        right: 15,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(30, 0, 0, 0),
            blurRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 5,
            children: [
              SizedBox(
                height: 70,
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.center,
                  children: [
                    SizedBox(width: 12),
                    InkWell(
                      onTap: () {
                        widget.openSideBar!();
                      },
                      child: Visibility(
                        visible:
                            screenWidth(context) <
                            mobileScreen,
                        child: Icon(
                          color: Colors.grey.shade700,
                          size: 28,
                          Icons.menu_rounded,
                        ),
                      ),
                    ),
                    SizedBox(
                      width:
                          screenWidth(context) <
                                  mobileScreen
                              ? 0
                              : 10,
                    ),
                    InkWell(
                      onTap: () async {
                        if (!authorization(
                              authorized:
                                  Authorizations()
                                      .switchStores,
                            ) &&
                            returnShopProvider()
                                    .userShops
                                    .length <
                                2) {
                          return;
                        }
                        var isOnline =
                            await returnConnectivityProvider(
                              context,
                              listen: false,
                            ).isOnline();
                        setState(() {
                          isOpen = true;
                        });
                        if (!context.mounted) return;
                        showPopover(
                          barrierColor:
                              const Color.fromARGB(
                                15,
                                0,
                                0,
                                0,
                              ),
                          context: context,
                          transitionDuration:
                              const Duration(
                                milliseconds: 150,
                              ),
                          bodyBuilder:
                              (
                                popoverContext,
                              ) => PopoverMenu(
                                parentContext: context,
                                action: () async {
                                  MultipleStoresAuthAction().numberOfStoresAction(
                                    context: context,
                                    action: () {
                                      if (isOnline) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (
                                              context,
                                            ) {
                                              return ShopSetupPage();
                                            },
                                          ),
                                        );
                                      } else {
                                        showDialog(
                                          context: context,
                                          builder: (
                                            context,
                                          ) {
                                            return InfoAlert(
                                              theme:
                                                  widget
                                                      .theme,
                                              message:
                                                  'You need to be connected to the internet before you can create a new Shop.',
                                              title:
                                                  'No Internet Connection',
                                            );
                                          },
                                        );
                                      }
                                    },
                                  );
                                },
                              ),
                          onPop: () {
                            setState(() {
                              isOpen = false;
                            });
                            print('Popover closed');
                          },
                          direction:
                              PopoverDirection.bottom,
                          contentDyOffset: -20,
                          width:
                              screenWidth(context) >
                                      tabletScreenSmall
                                  ? 300
                                  : 270,
                          height:
                              returnShopProvider()
                                          .userShops
                                          .length <
                                      2
                                  ? 190
                                  : returnShopProvider()
                                          .userShops
                                          .length >
                                      4
                                  ? 400
                                  : (returnShopProvider()
                                              .userShops
                                              .length *
                                          (68 -
                                              returnShopProvider()
                                                      .userShops
                                                      .length *
                                                  2)) +
                                      100,
                          arrowHeight: 10,
                          arrowWidth: 20,
                        );
                      },
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(3),
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              shape: BoxShape.circle,
                            ),
                            child: Image.asset(
                              shopIconImage,
                              height:
                                  screenWidth(context) <
                                          mobileScreen
                                      ? 25
                                      : 35,
                              width: 35,
                            ),
                          ),
                          SizedBox(
                            width:
                                screenWidth(context) <
                                        mobileScreen
                                    ? 2
                                    : 10,
                          ),
                          Column(
                            spacing: 1,
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .center,
                                children: [
                                  Text(
                                    style: TextStyle(
                                      fontSize:
                                          screenWidth(
                                                    context,
                                                  ) <
                                                  mobileScreen
                                              ? widget
                                                  .theme
                                                  .mobileTexts
                                                  .b3
                                                  .fontSize
                                              : widget
                                                  .theme
                                                  .mobileTexts
                                                  .b2
                                                  .fontSize,
                                      fontWeight:
                                          widget
                                              .theme
                                              .mobileTexts
                                              .b2
                                              .fontWeightBold,
                                      color: Colors.black,
                                    ),
                                    cutLongText(
                                      widget.title ??
                                          returnShopProvider(
                                                context:
                                                    context,
                                              )
                                              .userShop()
                                              ?.name ??
                                          'Name Not Set',
                                      15,
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  Visibility(
                                    visible:
                                        returnSubcsription(
                                              context,
                                            )
                                            .subscription
                                            ?.plan !=
                                        0,
                                    child: SvgPicture.asset(
                                      // ignore: deprecated_member_use
                                      color:
                                          returnSubcsription(
                                                    context,
                                                  ).subscription?.plan ==
                                                  1
                                              ? Colors.grey
                                              : returnSubcsription(
                                                    context,
                                                  ).subscription?.plan ==
                                                  2
                                              ? Colors.blue
                                              : null,
                                      checkIconSvg,
                                      height: 16,
                                      width: 16,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
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
                                          .prColor250,
                                  fontWeight:
                                      FontWeight.w500,
                                ),
                                cutLongText(
                                  widget.subText ??
                                      returnShopProvider(
                                        context: context,
                                      ).userShop()?.email ??
                                      'Email Not Set',
                                  18,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 0),
                          Visibility(
                            visible:
                                authorization(
                                  authorized:
                                      Authorizations()
                                          .switchStores,
                                ) ||
                                returnShopProvider(
                                      context: context,
                                    ).userShops.length >
                                    1,
                            child: Icon(
                              isOpen
                                  ? Icons
                                      .keyboard_arrow_up_rounded
                                  : Icons
                                      .keyboard_arrow_down_rounded,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Stack(
            children: [
              Visibility(
                visible:
                    screenWidth(context) <= mobileScreen &&
                    isStoreKeeper(),
                child: Material(
                  color: Colors.transparent,
                  child: Ink(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        5,
                      ),
                      border: Border.all(
                        color: Colors.grey.shade300,
                      ),
                      color: Colors.grey.shade100,
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(
                        5,
                      ),
                      onTap: () async {
                        if (returnData().isSynced() == 0) {
                          await returnData().syncData(
                            context,
                          );
                        } else {
                          print('Data is in sync');
                          returnData().toggleRefreshing(
                            true,
                          );
                          await RefreshFunctions(
                            context,
                          ).refreshAll(context);
                          if (context.mounted) {
                            returnData().toggleRefreshing(
                              false,
                            );
                          }
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 7,
                        ),
                        child: Row(
                          spacing: 10,
                          children: [
                            Icon(
                              size: 15,
                              color:
                                  returnConnectivityProvider(
                                    context,
                                  ).connectedColor(),
                              returnConnectivityProvider(
                                    context,
                                  ).isConnected
                                  ? Icons.wifi
                                  : Icons.wifi_off_sharp,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(
                                    2,
                                    2,
                                    2,
                                    2,
                                  ),
                              child: Stack(
                                children: [
                                  Visibility(
                                    visible:
                                        !returnData(
                                          context: context,
                                        ).isRefreshing,
                                    child: Row(
                                      // spacing: 5,
                                      children: [
                                        Stack(
                                          children: [
                                            Visibility(
                                              visible:
                                                  returnData(
                                                    context:
                                                        context,
                                                  ).isSynced() !=
                                                  2,
                                              child: Icon(
                                                color:
                                                    returnData(
                                                              context:
                                                                  context,
                                                            ).isSynced() ==
                                                            1
                                                        ? const Color.fromARGB(
                                                          255,
                                                          87,
                                                          160,
                                                          89,
                                                        )
                                                        : Colors.grey,
                                                size: 16,
                                                returnData(
                                                          context:
                                                              context,
                                                        ).isSynced() ==
                                                        1
                                                    ? Icons
                                                        .cloud_done_outlined
                                                    : Icons.cloud_off_rounded,
                                              ),
                                            ),
                                            Visibility(
                                              visible:
                                                  returnData(
                                                    context:
                                                        context,
                                                  ).isSynced() ==
                                                  2,
                                              child: Row(
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        style: TextStyle(
                                                          color:
                                                              Colors.white,
                                                          fontSize:
                                                              8,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),

                                                        'Syncing',
                                                      ),
                                                      SizedBox(
                                                        width:
                                                            5,
                                                      ),
                                                    ],
                                                  ),
                                                  Stack(
                                                    alignment:
                                                        Alignment(
                                                          0,
                                                          0,
                                                        ),
                                                    children: [
                                                      SizedBox(
                                                        height:
                                                            17,
                                                        width:
                                                            17,
                                                        child: CircularProgressIndicator(
                                                          color:
                                                              Colors.amber,
                                                          strokeWidth:
                                                              1.2,
                                                        ),
                                                      ),
                                                      Center(
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Text(
                                                              style: TextStyle(
                                                                color:
                                                                    Colors.white,
                                                                fontWeight:
                                                                    FontWeight.bold,
                                                                fontSize:
                                                                    8,
                                                              ),
                                                              returnData(
                                                                context:
                                                                    context,
                                                              ).syncProgress.toStringAsFixed(
                                                                0,
                                                              ),
                                                              // '100',
                                                            ),
                                                            Text(
                                                              style: TextStyle(
                                                                color:
                                                                    Colors.white,
                                                                fontWeight:
                                                                    FontWeight.bold,
                                                                fontSize:
                                                                    6,
                                                              ),
                                                              '%',
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Visibility(
                                    visible:
                                        returnData(
                                          context: context,
                                        ).isRefreshing,
                                    child: SizedBox(
                                      height: 14,
                                      width: 14,
                                      child:
                                          CircularProgressIndicator(
                                            color:
                                                Colors
                                                    .amber,
                                            strokeWidth:
                                                1.5,
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
                  ),
                ),
              ),
              Row(
                spacing:
                    screenWidth(context) > tabletScreen
                        ? 3
                        : 2,
                children: [
                  Visibility(
                    visible:
                        screenWidth(context) > mobileScreen,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(
                          10,
                        ),
                        onTap: () async {
                          // print(
                          //   CreatedRecordsFunc()
                          //       .getRecords()
                          //       .length,
                          // );
                          // print(
                          //   CreatedReceiptsFunc()
                          //       .getReceipts()
                          //       .length,
                          // );
                          // print(
                          //   SalesProductFunc()
                          //       .getProducts()
                          //       .first
                          //       .quantity,
                          // );
                          // await returnData(
                          //   context,
                          //   listen: false,
                          // ).clearTotalCache();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            // spacing: 5,
                            children: [
                              Visibility(
                                visible:
                                    screenWidth(context) >
                                    tabletScreen,
                                child: Row(
                                  children: [
                                    Text(
                                      style: TextStyle(
                                        fontSize:
                                            widget
                                                .theme
                                                .mobileTexts
                                                .b3
                                                .fontSize,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),

                                      returnConnectivityProvider(
                                        context,
                                      ).connectedText(),
                                    ),
                                    SizedBox(width: 5),
                                  ],
                                ),
                              ),
                              Icon(
                                size: 17,
                                color:
                                    returnConnectivityProvider(
                                      context,
                                    ).connectedColor(),
                                returnConnectivityProvider(
                                      context,
                                    ).isConnected
                                    ? Icons.wifi
                                    : Icons.wifi_off_sharp,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible:
                        screenWidth(context) > mobileScreen,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(
                          10,
                        ),
                        onTap: () async {
                          if (returnData().isSynced() ==
                              0) {
                            await returnData().syncData(
                              context,
                            );
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            // spacing: 5,
                            children: [
                              Visibility(
                                visible:
                                    screenWidth(context) >
                                    tabletScreen,
                                child: Row(
                                  children: [
                                    Text(
                                      style: TextStyle(
                                        fontSize:
                                            widget
                                                .theme
                                                .mobileTexts
                                                .b3
                                                .fontSize,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                      returnData(
                                                context:
                                                    context,
                                              ).isSynced() ==
                                              1
                                          ? 'Synced'
                                          : returnData(
                                                context:
                                                    context,
                                              ).isSynced() ==
                                              0
                                          ? 'Unsynced'
                                          : 'Syncing',
                                    ),
                                    SizedBox(width: 5),
                                  ],
                                ),
                              ),
                              Stack(
                                children: [
                                  Visibility(
                                    visible:
                                        returnData(
                                          context: context,
                                        ).isSynced() !=
                                        2,
                                    child: Icon(
                                      color:
                                          returnData(
                                                    context:
                                                        context,
                                                  ).isSynced() ==
                                                  1
                                              ? const Color.fromARGB(
                                                255,
                                                87,
                                                160,
                                                89,
                                              )
                                              : Colors.grey,
                                      size: 18,
                                      returnData(
                                                context:
                                                    context,
                                              ).isSynced() ==
                                              1
                                          ? Icons
                                              .cloud_done_outlined
                                          : Icons
                                              .cloud_off_rounded,
                                    ),
                                  ),
                                  Visibility(
                                    visible:
                                        returnData(
                                          context: context,
                                        ).isSynced() ==
                                        2,
                                    child: Stack(
                                      alignment: Alignment(
                                        0,
                                        0,
                                      ),
                                      children: [
                                        SizedBox(
                                          height: 18,
                                          width: 18,
                                          child: CircularProgressIndicator(
                                            color:
                                                Colors
                                                    .amber,
                                            strokeWidth:
                                                1.5,
                                          ),
                                        ),
                                        Center(
                                          child: Row(
                                            mainAxisSize:
                                                MainAxisSize
                                                    .min,
                                            children: [
                                              Text(
                                                style: TextStyle(
                                                  fontWeight:
                                                      FontWeight
                                                          .bold,
                                                  fontSize:
                                                      8,
                                                ),
                                                returnData(
                                                  context:
                                                      context,
                                                ).syncProgress.toStringAsFixed(
                                                  0,
                                                ),
                                              ),
                                              Text(
                                                style: TextStyle(
                                                  fontWeight:
                                                      FontWeight
                                                          .bold,
                                                  fontSize:
                                                      7,
                                                ),
                                                '%',
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // SizedBox(height: 20),
                  Visibility(
                    visible:
                        screenWidth(context) > mobileScreen,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(
                          10,
                        ),
                        onTap: widget.refreshAction,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            // spacing: 5,
                            children: [
                              Visibility(
                                visible:
                                    screenWidth(context) >
                                    tabletScreenSmall,
                                child: Row(
                                  children: [
                                    Text(
                                      style: TextStyle(
                                        fontSize:
                                            widget
                                                .theme
                                                .mobileTexts
                                                .b3
                                                .fontSize,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                      'Refresh',
                                    ),
                                    SizedBox(width: 5),
                                  ],
                                ),
                              ),
                              Stack(
                                children: [
                                  Visibility(
                                    visible:
                                        !returnData(
                                          context: context,
                                        ).isRefreshing,
                                    child: Icon(
                                      size: 18,
                                      Icons.refresh_rounded,
                                    ),
                                  ),
                                  Visibility(
                                    visible:
                                        returnData(
                                          context: context,
                                        ).isRefreshing,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(
                                            top: 2.0,
                                            left: 2,
                                          ),
                                      child: SizedBox(
                                        height: 14,
                                        width: 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color:
                                              widget
                                                  .theme
                                                  .lightModeColor
                                                  .secColor200,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // SizedBox(height: 20),
                  Stack(
                    children: [
                      Visibility(
                        visible: authorization(
                          authorized:
                              Authorizations()
                                  .notificationsPage,
                        ),
                        child: Stack(
                          alignment: Alignment(1.2, -1.8),
                          children: [
                            InkWell(
                              onTap: () {
                                widget.action!();
                              },
                              child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color:
                                      const Color.fromARGB(
                                        208,
                                        245,
                                        245,
                                        245,
                                      ),
                                  shape: BoxShape.circle,
                                ),
                                child: SvgPicture.asset(
                                  height: 25,
                                  width: 25,
                                  notifIconSvg,
                                ),
                              ),
                            ),
                            Visibility(
                              visible:
                                  returnNotificationProvider(
                                        context,
                                      )
                                      .notifications()
                                      .where(
                                        (notif) =>
                                            !notif.isViewed,
                                      )
                                      .isNotEmpty,
                              child: Container(
                                padding: EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient:
                                      widget
                                          .theme
                                          .lightModeColor
                                          .secGradient,
                                ),
                                child: Center(
                                  child: Text(
                                    style: TextStyle(
                                      fontWeight:
                                          FontWeight.bold,
                                      fontSize:
                                          returnNotificationProvider(
                                                        context,
                                                      )
                                                      .notifications()
                                                      .where(
                                                        (
                                                          notif,
                                                        ) =>
                                                            !notif.isViewed,
                                                      )
                                                      .length ==
                                                  2
                                              ? 9
                                              : 11,
                                      color: Colors.white,
                                    ),
                                    '${returnNotificationProvider(context).notifications().where((notif) => !notif.isViewed).length}',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PopoverMenu extends StatelessWidget {
  final Function()? action;
  final BuildContext parentContext;
  const PopoverMenu({
    super.key,
    required this.action,
    required this.parentContext,
  });

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context, listen: false);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            SizedBox(height: 10),
            Text(
              style: TextStyle(
                fontSize: theme.mobileTexts.b1.fontSize,
                fontWeight: FontWeight.bold,
              ),
              'SELECT SHOP',
            ),
            SizedBox(height: 10),
            Container(
              height: 3,
              width: 100,
              decoration: BoxDecoration(
                color: theme.lightModeColor.secColor200,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            SizedBox(height: 5),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children:
                    returnShopProvider().userShops
                        .map(
                          (shop) => ListTile(
                            shape: Border(
                              bottom: BorderSide(
                                color: Colors.grey.shade100,
                              ),
                            ),
                            title: Row(
                              spacing: 10,
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              style: TextStyle(
                                                fontSize:
                                                    theme
                                                        .mobileTexts
                                                        .b3
                                                        .fontSize,
                                                fontWeight:
                                                    FontWeight
                                                        .bold,
                                              ),
                                              shop.name,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Visibility(
                                        visible:
                                            shop.isHeadQuarters!,
                                        child: Row(
                                          children: [
                                            Text(
                                              style: TextStyle(
                                                color:
                                                    theme
                                                        .lightModeColor
                                                        .secColor200,
                                                fontSize: 8,
                                                // fontStyle:
                                                //     FontStyle
                                                //         .italic,
                                                fontWeight:
                                                    FontWeight
                                                        .bold,
                                              ),
                                              "(Head Quarter)",
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible:
                                      returnShopProvider()
                                          .userShop()!
                                          .shopId! ==
                                      shop.shopId!,
                                  child: Icon(
                                    size: 18,
                                    color:
                                        theme
                                            .lightModeColor
                                            .secColor200,
                                    Icons.check,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () async {
                              var safeContext =
                                  parentContext;
                              var isOnline =
                                  await returnConnectivityProvider(
                                    context,
                                    listen: false,
                                  ).isOnline();
                              if (!safeContext.mounted)
                                return;
                              if (returnShopProvider()
                                      .userShop()!
                                      .shopId! !=
                                  shop.shopId!) {
                                if (!isOnline) {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return InfoAlert(
                                        theme: theme,
                                        message:
                                            'You need to be connected to the internet before you switch to another Shop.',
                                        title:
                                            'No Internet Connection',
                                      );
                                    },
                                  );
                                  return;
                                }
                                Navigator.of(context).pop();
                                await returnShopProvider()
                                    .selectShop(
                                      safeContext,
                                      shop,
                                    );

                                // print(
                                //   returnShopProvider(
                                //     safeContext,
                                //     listen: false,
                                //   ).userShops.length,
                                // );
                              } else if (authorization(
                                authorized:
                                    Authorizations()
                                        .manageShop,
                              )) {
                                Navigator.of(context).pop();
                                Navigator.push(
                                  safeContext,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return ShopPage();
                                    },
                                  ),
                                );
                              }
                            },
                          ),
                        )
                        .toList(),
              ),
            ),
            SizedBox(height: 5),
            Visibility(
              visible: authorization(
                authorized: Authorizations().createShop,
              ),
              child: Material(
                color: Colors.white,
                child: SubWrapper(
                  isVisible:
                      !MultipleStoresAuthAction()
                          .numberOfStoresAction(
                            context: context,
                          ),
                  mainWidget: MainButtonP(
                    themeProvider: theme,
                    action: () {
                      Navigator.of(context).pop();
                      action!();
                    },
                    text: 'Create New Shop',
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
