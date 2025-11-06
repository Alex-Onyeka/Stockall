import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:popover/popover.dart';
import 'package:stockall/classes/temp_notification/temp_notification.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/auth_screens/auth_screens_page.dart';
import 'package:stockall/pages/shop_setup/shop_setup_one/shop_setup_page.dart';
import 'package:stockall/providers/theme_provider.dart';
import 'package:stockall/services/auth_service.dart';

class TopNavBar extends StatefulWidget {
  final Function()? refreshAction;
  final List<TempNotification> notifications;
  final String? title;
  final String? subText;
  final Function()? action;
  final ThemeProvider theme;

  final Function()? openSideBar;

  const TopNavBar({
    super.key,
    required this.notifications,
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
                    SizedBox(width: 15),
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
                    // Builder(
                    //   builder: (context) {
                    //     return ElevatedButton(
                    //       onPressed: () {

                    //       },
                    //       child: const Text(
                    //         'Show Popover Menu',
                    //       ),
                    //     );
                    //   },
                    // ),
                    SizedBox(width: 10),
                    InkWell(
                      onTap: () {
                        setState(() {
                          isOpen = true;
                        });
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
                              (context) => PopoverMenu(
                                action: () async {
                                  bool isOnline =
                                      await returnConnectivityProvider(
                                        context,
                                        listen: false,
                                      ).isOnline();
                                  if (isOnline) {
                                    Navigator.push(
                                      // ignore: use_build_context_synchronously
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return ShopSetupPage();
                                        },
                                      ),
                                    );
                                  } else {
                                    showDialog(
                                      // ignore: use_build_context_synchronously
                                      context: context,
                                      builder: (context) {
                                        return InfoAlert(
                                          theme:
                                              widget.theme,
                                          message:
                                              'You need to be connected to the internet before you can create a new Shop.',
                                          title:
                                              'No Internet Connection',
                                        );
                                      },
                                    );
                                  }
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
                          // contentDxOffset:
                          //     screenWidth(context) >
                          //             tabletScreen
                          //         ? -600
                          //         : 0,
                          contentDyOffset: -20,
                          width: 300,
                          height: 300,
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
                              height: 35,
                              width: 35,
                            ),
                          ),
                          SizedBox(width: 10),
                          Column(
                            spacing: 3,
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
                                          widget
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
                                                context,
                                              )
                                              .userShop()
                                              ?.name ??
                                          '',
                                      15,
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  SvgPicture.asset(
                                    checkIconSvg,
                                    height: 18,
                                    width: 18,
                                    fit: BoxFit.contain,
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
                                        context,
                                      ).userShop()?.email ??
                                      'Email Not Set',
                                  18,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 0),
                          Icon(
                            isOpen
                                ? Icons
                                    .keyboard_arrow_up_rounded
                                : Icons
                                    .keyboard_arrow_down_rounded,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            spacing:
                screenWidth(context) > tabletScreen ? 3 : 2,
            children: [
              Visibility(
                visible:
                    screenWidth(context) > mobileScreen,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
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
                    borderRadius: BorderRadius.circular(10),
                    onTap: () async {
                      if (returnData(
                            context,
                            listen: false,
                          ).isSynced() ==
                          0) {
                        await returnData(
                          context,
                          listen: false,
                        ).syncData(context);
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
                                            context,
                                          ).isSynced() ==
                                          1
                                      ? 'Synced'
                                      : returnData(
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
                                      context,
                                    ).isSynced() !=
                                    2,
                                child: Icon(
                                  color:
                                      returnData(
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
                                      context,
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
                                      child:
                                          CircularProgressIndicator(
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
                                              fontSize: 8,
                                            ),
                                            returnData(
                                                  context,
                                                )
                                                .syncProgress
                                                .toStringAsFixed(
                                                  0,
                                                ),
                                          ),
                                          Text(
                                            style: TextStyle(
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                              fontSize: 7,
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
                    borderRadius: BorderRadius.circular(10),
                    onTap: widget.refreshAction,
                    // onTap: () async {
                    //   await MainReceiptFunc()
                    //       .clearReceipts();
                    // },
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
                          Icon(
                            size: 18,
                            Icons.refresh_rounded,
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
                      context: context,
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
                              color: const Color.fromARGB(
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
                              widget.notifications
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
                                      widget.notifications
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
                                '${widget.notifications.where((notif) => !notif.isViewed).length}',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible:
                        !authorization(
                          authorized:
                              Authorizations()
                                  .notificationsPage,
                          context: context,
                        ),
                    child: Stack(
                      alignment: Alignment(1.2, -1.8),
                      children: [
                        InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (dialogContext) {
                                return ConfirmationAlert(
                                  theme: widget.theme,
                                  message:
                                      'You are about to Logout',
                                  title: 'Are you Sure?',
                                  action: () async {
                                    Navigator.of(
                                      dialogContext,
                                    ).pop();

                                    await AuthService()
                                        .signOut(context);
                                    if (context.mounted) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (
                                            context,
                                          ) {
                                            return AuthScreensPage();
                                          },
                                        ),
                                      );
                                      returnNavProvider(
                                        context,
                                        listen: false,
                                      ).navigate(0);
                                    }
                                  },
                                );
                              },
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(
                                208,
                                245,
                                245,
                                245,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.logout_rounded,
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
    );
  }
}

class PopoverMenu extends StatelessWidget {
  final Function()? action;
  const PopoverMenu({super.key, required this.action});

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
              'Select Shop',
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
                    returnShopProvider(context).userShops
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
                                  child: Text(
                                    style: TextStyle(
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b3
                                              .fontSize,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                    shop.name,
                                  ),
                                ),
                                Visibility(
                                  visible:
                                      returnShopProvider(
                                            context,
                                            listen: false,
                                          )
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
                            onTap: () {
                              if (returnShopProvider(
                                    context,
                                    listen: false,
                                  ).userShop()!.shopId! !=
                                  shop.shopId!) {
                                returnShopProvider(
                                  context,
                                  listen: false,
                                ).selectShop(context, shop);
                                Navigator.of(
                                  context,
                                ).pop(); // closes the popover
                                print(
                                  returnShopProvider(
                                    context,
                                    listen: false,
                                  ).userShops.length,
                                );
                              }
                            },
                          ),
                        )
                        .toList(),
              ),
            ),
            SizedBox(height: 5),
            Material(
              color: Colors.white,
              child: MainButtonP(
                themeProvider: theme,
                action: () {
                  Navigator.of(context).pop();
                  action!();
                },
                text: 'Create New Shop',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
