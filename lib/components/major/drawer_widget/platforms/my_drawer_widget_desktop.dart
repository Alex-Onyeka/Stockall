import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stockall/classes/temp_notification.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/major/drawer_widget/platforms/my_drawer_widget_tablet.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/calculator_page/calculator_page.dart';
import 'package:stockall/pages/customers/customers_list/customer_list.dart';
import 'package:stockall/pages/employees/employee_list/employee_list_page.dart';
import 'package:stockall/pages/expenses/expenses_page.dart';
import 'package:stockall/pages/home/home.dart';
import 'package:stockall/pages/notifications/notifications_page.dart';
import 'package:stockall/pages/report/report_page.dart';
import 'package:stockall/pages/sales/total_sales/total_sales_page.dart';
import 'package:stockall/providers/theme_provider.dart';
import 'package:stockall/services/auth_service.dart';

class MyDrawerWidgetDesktop extends StatelessWidget {
  final ThemeProvider theme;
  final Function()? action;
  final GlobalKey<ScaffoldState> globalKey;
  final List<TempNotification> notifications;
  const MyDrawerWidgetDesktop({
    super.key,
    required this.theme,
    required this.notifications,
    required this.action,
    required this.globalKey,
  });

  @override
  Widget build(BuildContext context) {
    if (screenWidth(context) <= tabletScreen) {
      return MyDrawerWidgetTablet(
        theme: theme,
        notifications: notifications,
        action: action,
        globalKey: globalKey,
      );
    } else {
      return MyDrawerWidgetDesktopMain(
        theme: theme,
        notifications: notifications,
        action: action,
        globalKey: globalKey,
      );
    }
  }
}

class MyDrawerWidgetDesktopMain extends StatefulWidget {
  final ThemeProvider theme;
  final Function()? action;
  final List<TempNotification> notifications;
  final GlobalKey<ScaffoldState> globalKey;

  const MyDrawerWidgetDesktopMain({
    super.key,
    required this.theme,
    required this.notifications,
    required this.action,
    required this.globalKey,
  });

  @override
  State<MyDrawerWidgetDesktopMain> createState() =>
      _MyDrawerWidgetDesktopMainState();
}

class _MyDrawerWidgetDesktopMainState
    extends State<MyDrawerWidgetDesktopMain> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 250,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(39, 4, 1, 41),
              blurRadius: 10,
            ),
          ],
        ),
        child: Drawer(
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
            ),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                        height:
                            MediaQuery.of(
                                      context,
                                    ).size.height <
                                    680
                                ? 20
                                : 30,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 10.0,
                        ),
                        child: Row(
                          mainAxisAlignment:
                              screenWidth(context) <=
                                      tabletScreen
                                  ? MainAxisAlignment
                                      .spaceBetween
                                  : MainAxisAlignment.start,
                          children: [
                            Row(
                              spacing: 10,
                              mainAxisAlignment:
                                  MainAxisAlignment.start,
                              children: [
                                Image.asset(
                                  mainLogoIcon,
                                  height: 22,
                                ),
                                Text(
                                  style: TextStyle(
                                    fontSize:
                                        widget
                                            .theme
                                            .mobileTexts
                                            .h3
                                            .fontSize,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                  appName,
                                ),
                              ],
                            ),
                            Visibility(
                              visible:
                                  screenWidth(context) <=
                                  tabletScreen,
                              child: InkWell(
                                onTap: () {
                                  widget
                                      .globalKey
                                      .currentState
                                      ?.closeDrawer();
                                },
                                child: Container(
                                  padding:
                                      EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                  child: Icon(
                                    size: 20,
                                    color: Colors.grey,
                                    Icons
                                        .arrow_back_ios_new_rounded,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height:
                            MediaQuery.of(
                                      context,
                                    ).size.height <
                                    680
                                ? 10
                                : 20,
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              NavListTileDesktopAlt(
                                itemIndex: 0,
                                height: 16,
                                action: () {
                                  var safeContext = context;

                                  if (Navigator.of(
                                    context,
                                  ).canPop()) {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return Home();
                                        },
                                      ),
                                      (route) {
                                        return false;
                                      },
                                    );
                                  }
                                  returnNavProvider(
                                    safeContext,
                                    listen: false,
                                  ).navigate(0);
                                  returnExpensesProvider(
                                    safeContext,
                                    listen: false,
                                  ).clearExpenseDate();
                                  returnReceiptProvider(
                                    safeContext,
                                    listen: false,
                                  ).clearReceiptDate();
                                  returnData(
                                    safeContext,
                                    listen: false,
                                  ).clearFields();
                                },
                                title: 'Dashboard',
                                icon: Icons.home_filled,
                              ),
                              NavListTileDesktopAlt(
                                itemIndex: 1,
                                height: 16,
                                action: () {
                                  var safeContext = context;
                                  returnNavProvider(
                                    safeContext,
                                    listen: false,
                                  ).navigate(1);
                                  if (Navigator.of(
                                    context,
                                  ).canPop()) {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return Home();
                                        },
                                      ),
                                      (route) {
                                        return false;
                                      },
                                    );
                                  }
                                  returnExpensesProvider(
                                    safeContext,
                                    listen: false,
                                  ).clearExpenseDate();
                                  returnReceiptProvider(
                                    safeContext,
                                    listen: false,
                                  ).clearReceiptDate();
                                  returnData(
                                    safeContext,
                                    listen: false,
                                  ).clearFields();
                                },
                                title: 'Items',
                                icon: Icons.book,
                              ),
                              NavListTileDesktopAlt(
                                itemIndex: 2,
                                height: 16,
                                action: () {
                                  var safeContext = context;
                                  returnNavProvider(
                                    safeContext,
                                    listen: false,
                                  ).navigate(2);
                                  if (Navigator.of(
                                    context,
                                  ).canPop()) {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return Home();
                                        },
                                      ),
                                      (route) {
                                        return false;
                                      },
                                    );
                                  }
                                  returnExpensesProvider(
                                    safeContext,
                                    listen: false,
                                  ).clearExpenseDate();
                                  returnReceiptProvider(
                                    safeContext,
                                    listen: false,
                                  ).clearReceiptDate();
                                  returnData(
                                    safeContext,
                                    listen: false,
                                  ).clearFields();
                                },
                                title: 'Sales',
                                icon:
                                    Icons.menu_book_rounded,
                              ),
                              // NavListTileDesktopAlt(
                              //   height: 18,
                              //   action: () {
                              //     returnNavProvider(
                              //       context,
                              //       listen: false,
                              //     ).navigate(3);
                              //     Navigator.push(
                              //       context,
                              //       MaterialPageRoute(
                              //         builder: (context) {
                              //           return ProfilePage();
                              //         },
                              //       ),
                              //     );
                              //   },
                              //   title: 'Profile',
                              //   icon: Icons.person,
                              // ),
                              // Visibility(
                              //   visible: authorization(
                              //     authorized:
                              //         Authorizations()
                              //             .manageShop,
                              //     context: context,
                              //   ),
                              //   child: NavListTileDesktopAlt(
                              //     height: 18,
                              //     action: () {
                              //       Navigator.push(
                              //         context,
                              //         MaterialPageRoute(
                              //           builder: (
                              //             context,
                              //           ) {
                              //             return ShopPage();
                              //           },
                              //         ),
                              //       );
                              //     },
                              //     title: 'Manage Shop',
                              //     icon: Icons.home_filled,
                              //   ),
                              // ),
                              // NavListTileDesktop(
                              //   thisIndex: 0,
                              //   title: 'Home',
                              //   icon: Icons.home_rounded,
                              // ),
                              // NavListTileDesktop(
                              //   thisIndex: 1,
                              //   title: 'Products',
                              //   // icon: Icons.home_rounded,
                              //   svg: productIconSvg,
                              //   height: 16,
                              // ),
                              // NavListTileDesktop(
                              //   thisIndex: 2,
                              //   title: 'Sales',
                              //   // icon: Icons.home_rounded,
                              //   svg: salesIconSvg,
                              //   height: 16,
                              // ),
                              NavListTileDesktopAlt(
                                itemIndex: 3,
                                height: 14,
                                action: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return CustomerList();
                                      },
                                    ),
                                  );
                                },
                                title: 'Customers',
                                svg: custBookIconSvg,
                              ),
                              NavListTileDesktopAlt(
                                itemIndex: 4,
                                height: 14,
                                action: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return ExpensesPage(
                                          isMain: true,
                                          turnOn: false,
                                        );
                                      },
                                    ),
                                  ).then((_) {
                                    setState(() {});
                                  });
                                },
                                title: 'Expenses',
                                svg: expensesIconSvg,
                              ),
                              NavListTileDesktopAlt(
                                itemIndex: 5,
                                height: 14,
                                action: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return TotalSalesPage(
                                          turnOff: true,
                                          isInvoice: true,
                                        );
                                      },
                                    ),
                                  ).then((_) {
                                    setState(() {});
                                  });
                                },
                                title: 'Invoices',
                                icon:
                                    Icons
                                        .all_inclusive_sharp,
                              ),
                              NavListTileDesktopAlt(
                                itemIndex: 6,
                                height: 14,
                                action: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return ReportPage();
                                      },
                                    ),
                                  );
                                },
                                title: 'Report',
                                svg: reportIconSvg,
                              ),
                              Visibility(
                                visible: authorization(
                                  authorized:
                                      Authorizations()
                                          .employeePage,
                                  context: context,
                                ),
                                child: NavListTileDesktopAlt(
                                  itemIndex: 7,
                                  height: 14,
                                  action: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return EmployeeListPage(
                                            empId:
                                                AuthService()
                                                    .currentUser!
                                                    .id,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  title: 'Empolyees',
                                  svg: employeesIconSvg,
                                ),
                              ),
                              SizedBox(height: 5),
                              Divider(
                                height:
                                    MediaQuery.of(
                                              context,
                                            ).size.height <
                                            680
                                        ? 15
                                        : 20,
                                color: Colors.grey.shade200,
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return NotificationsPage(
                                          turnOn: false,
                                        );
                                      },
                                    ),
                                  );
                                },
                                child: Visibility(
                                  visible: true,
                                  child: Container(
                                    color:
                                        returnNavProvider(
                                                  context,
                                                ).currentIndex ==
                                                8
                                            ? const Color.fromARGB(
                                              36,
                                              255,
                                              153,
                                              0,
                                            )
                                            : Colors
                                                .transparent,
                                    height: 40,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.symmetric(
                                            horizontal:
                                                10.0,
                                          ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                        children: [
                                          Row(
                                            spacing: 10,
                                            mainAxisAlignment:
                                                MainAxisAlignment
                                                    .start,
                                            children: [
                                              Stack(
                                                children: [
                                                  Icon(
                                                    color:
                                                        Colors.grey.shade400,
                                                    size:
                                                        20,
                                                    Icons
                                                        .notifications_on_outlined,
                                                  ),
                                                ],
                                              ),

                                              Text(
                                                style: TextStyle(
                                                  color:
                                                      Colors
                                                          .grey
                                                          .shade900,
                                                  fontSize:
                                                      returnTheme(
                                                        context,
                                                        listen:
                                                            false,
                                                      ).mobileTexts.b2.fontSize,
                                                  fontWeight:
                                                      returnNavProvider(context).currentIndex ==
                                                              8
                                                          ? FontWeight.bold
                                                          : FontWeight.normal,
                                                ),
                                                'Notifications',
                                              ),
                                            ],
                                          ),
                                          Row(
                                            spacing: 15,
                                            children: [
                                              Stack(
                                                clipBehavior:
                                                    Clip.none,
                                                children: [
                                                  InkWell(
                                                    onTap: () {
                                                      Navigator.of(
                                                        context,
                                                      ).pop();
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (
                                                            context,
                                                          ) {
                                                            return NotificationsPage();
                                                          },
                                                        ),
                                                      );
                                                    },
                                                    child: Container(
                                                      padding: EdgeInsets.all(
                                                        10,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: const Color.fromARGB(
                                                          208,
                                                          245,
                                                          245,
                                                          245,
                                                        ),
                                                        shape:
                                                            BoxShape.circle,
                                                      ),
                                                      child: SvgPicture.asset(
                                                        height:
                                                            23,
                                                        width:
                                                            23,
                                                        notifIconSvg,
                                                        color:
                                                            widget.notifications
                                                                    .where(
                                                                      (
                                                                        notif,
                                                                      ) =>
                                                                          !notif.isViewed,
                                                                    )
                                                                    .isNotEmpty
                                                                ? null
                                                                : Colors.grey.shade500,
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    bottom:
                                                        18,
                                                    left:
                                                        26,
                                                    child: Visibility(
                                                      visible:
                                                          widget.notifications
                                                              .where(
                                                                (
                                                                  notif,
                                                                ) =>
                                                                    !notif.isViewed,
                                                              )
                                                              .isNotEmpty,
                                                      child: Container(
                                                        padding: EdgeInsets.all(
                                                          6,
                                                        ),
                                                        decoration: BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          gradient:
                                                              widget.theme.lightModeColor.secGradient,
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight.bold,
                                                              fontSize:
                                                                  12,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            '${widget.notifications.where((notif) => !notif.isViewed).length}',
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Visibility(
                                                visible:
                                                    returnNavProvider(
                                                      context,
                                                    ).currentIndex ==
                                                    8,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                        0,
                                                        5,
                                                        3,
                                                        5,
                                                      ),
                                                  child: Container(
                                                    width:
                                                        4,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          widget.theme.lightModeColor.secColor200,
                                                      borderRadius: BorderRadius.circular(
                                                        20,
                                                      ),
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
                              Visibility(
                                visible: authorization(
                                  authorized:
                                      Authorizations()
                                          .contactStockall,
                                  context: context,
                                ),
                                child:
                                    NavListTileDesktopAlt(
                                      height: 18,
                                      action: () async {
                                        phoneCall();
                                      },
                                      title: 'Contact Us',
                                      icon: Icons.phone,
                                    ),
                              ),
                              Visibility(
                                visible: authorization(
                                  authorized:
                                      Authorizations()
                                          .contactStockall,
                                  context: context,
                                ),
                                child:
                                    NavListTileDesktopAlt(
                                      height: 14,
                                      action: () async {
                                        openWhatsApp();
                                      },
                                      title: 'Chat With Us',
                                      svg: whatsappIconSvg,
                                    ),
                              ),
                              Visibility(
                                visible: false,
                                child: NavListTileDesktopAlt(
                                  height: 18,
                                  action: () {},
                                  title:
                                      'Privacy P. & Terms/C.',
                                  icon:
                                      Icons
                                          .menu_book_rounded,
                                ),
                              ),
                              NavListTileDesktopAlt(
                                itemIndex: 9,
                                height: 18,
                                action: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return CalculatorPage();
                                      },
                                    ),
                                  );
                                },
                                title: 'Open Calculator',
                                icon:
                                    Icons
                                        .calculate_outlined,
                              ),
                              Visibility(
                                visible:
                                    kIsWeb &&
                                        Theme.of(
                                              context,
                                            ).platform ==
                                            TargetPlatform
                                                .android ||
                                    screenWidth(context) >
                                        tabletScreen,
                                child: NavListTileDesktopAlt(
                                  height: 18,
                                  action: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return ConfirmationAlert(
                                          theme:
                                              widget.theme,
                                          message:
                                              'You are about to download and install our official mobile application, for better experience.',
                                          title:
                                              'Proceed to Download Mobile App',
                                          action: () async {
                                            Navigator.of(
                                              context,
                                            ).pop();
                                            await downloadApkFromApp();
                                          },
                                        );
                                      },
                                    );
                                  },
                                  title:
                                      'Download Mobile App',
                                  icon:
                                      Icons
                                          .download_outlined,
                                ),
                              ),
                              // NavListTileDesktopAlt(
                              //   height: 20,
                              //   action: () {
                              //     Navigator.push(
                              //       context,
                              //       MaterialPageRoute(
                              //         builder: (context) {
                              //           return Referrals();
                              //         },
                              //       ),
                              //     );
                              //   },
                              //   title: 'Referrals',
                              //   icon:
                              //       Icons
                              //           .card_giftcard_rounded,
                              // ),
                              SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Column(
                  children: [
                    Visibility(
                      child: Padding(
                        padding:
                            MediaQuery.of(
                                      context,
                                    ).size.height <
                                    680
                                ? const EdgeInsets.only(
                                  bottom: 15.0,
                                )
                                : const EdgeInsets.only(
                                  bottom: 20.0,
                                ),
                        child: NavListTileDesktopAlt(
                          height: 18,
                          action: widget.action,
                          title: 'Logout',
                          // svg: reportIconSvg,
                          icon: Icons.logout_rounded,
                          color: Colors.redAccent,
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
    );
  }
}

class NavListTileDesktopAlt extends StatelessWidget {
  final String title;
  final int? itemIndex;
  final IconData? icon;
  final String? svg;
  final Function()? action;
  final double height;
  final Color? color;
  const NavListTileDesktopAlt({
    super.key,
    required this.title,
    this.icon,
    required this.action,
    this.svg,
    required this.height,
    this.color,
    this.itemIndex,
  });

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return InkWell(
      onTap: () {
        action!();
      },
      child: Container(
        color:
            returnNavProvider(context).currentIndex ==
                    itemIndex
                ? const Color.fromARGB(36, 255, 153, 0)
                : Colors.transparent,
        height: 38,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10.0,
          ),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Row(
                spacing: 10,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 20,
                    child: Center(
                      child: Stack(
                        children: [
                          Visibility(
                            visible: icon != null,
                            child: Icon(
                              color:
                                  color ??
                                  Colors.grey.shade600,
                              size: height,
                              icon ??
                                  Icons
                                      .arrow_forward_ios_rounded,
                            ),
                          ),
                          Visibility(
                            visible: svg != null,
                            child: SvgPicture.asset(
                              color:
                                  color ??
                                  Colors.grey.shade600,
                              svg ?? '',
                              height: height,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Text(
                    style: TextStyle(
                      color: color ?? Colors.grey.shade900,
                      fontSize:
                          theme.mobileTexts.b2.fontSize,
                      fontWeight:
                          returnNavProvider(
                                    context,
                                  ).currentIndex ==
                                  itemIndex
                              ? FontWeight.bold
                              : FontWeight.normal,
                    ),
                    title,
                  ),
                ],
              ),
              Stack(
                children: [
                  Visibility(
                    visible:
                        returnNavProvider(
                          context,
                        ).currentIndex !=
                        itemIndex,
                    child: Icon(
                      color: Colors.grey.shade600,
                      size: 12,
                      Icons.arrow_forward_ios_rounded,
                    ),
                  ),
                  Visibility(
                    visible:
                        returnNavProvider(
                          context,
                        ).currentIndex ==
                        itemIndex,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        0,
                        5,
                        3,
                        5,
                      ),
                      child: Container(
                        width: 4,
                        decoration: BoxDecoration(
                          color:
                              theme
                                  .lightModeColor
                                  .secColor200,
                          borderRadius:
                              BorderRadius.circular(20),
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
    );
  }
}
