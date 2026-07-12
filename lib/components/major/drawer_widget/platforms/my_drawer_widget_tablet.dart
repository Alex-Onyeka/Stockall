import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stockall/classes/temp_notification/temp_notification.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/major/drawer_widget/platforms/my_drawer_widget_desktop.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/calculator_page/calculator_page.dart';
import 'package:stockall/pages/customers/customers_list/customer_list.dart';
import 'package:stockall/pages/employees/employee_list/employee_list_page.dart';
import 'package:stockall/pages/expenses/expenses_page.dart';
import 'package:stockall/pages/home/home.dart';
import 'package:stockall/pages/invoices/invoice_list/invoice_list_page.dart';
import 'package:stockall/pages/notifications/notifications_page.dart';
import 'package:stockall/pages/purchases/purchase_list/purchase_list.dart';
import 'package:stockall/pages/report/report_page.dart';
import 'package:stockall/pages/settings/settings_page.dart';
import 'package:stockall/pages/suppliers/supplier_list/supplier_list.dart';
import 'package:stockall/providers/theme_provider.dart';
import 'package:stockall/services/auth_service.dart';

class MyDrawerWidgetTablet extends StatefulWidget {
  final GlobalKey<ScaffoldState> globalKey;
  final ThemeProvider theme;
  final Function()? action;
  final List<TempNotification> notifications;
  const MyDrawerWidgetTablet({
    super.key,
    required this.theme,
    required this.notifications,
    required this.action,
    required this.globalKey,
  });

  @override
  State<MyDrawerWidgetTablet> createState() =>
      _MyDrawerWidgetTabletState();
}

class _MyDrawerWidgetTabletState
    extends State<MyDrawerWidgetTablet> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 90,
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
                        child: InkWell(
                          onTap: () {
                            widget.globalKey.currentState
                                ?.openDrawer();
                          },
                          child: Container(
                            color: Colors.white,
                            child: Row(
                              spacing: 2,
                              mainAxisAlignment:
                                  screenWidth(context) <
                                          tabletScreenSmall
                                      ? MainAxisAlignment
                                          .spaceBetween
                                      : MainAxisAlignment
                                          .start,
                              children: [
                                Image.asset(
                                  mainLogoIcon,
                                  height: 18,
                                ),
                                Icon(
                                  size: 20,
                                  color: Colors.grey,
                                  Icons
                                      .arrow_forward_ios_rounded,
                                ),
                              ],
                            ),
                          ),
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
                                  ).clearDate();
                                  returnReceiptProvider(
                                    safeContext,
                                    listen: false,
                                  ).clearDate();
                                  returnData()
                                      .clearFields();
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
                                  ).clearDate();
                                  returnReceiptProvider(
                                    safeContext,
                                    listen: false,
                                  ).clearDate();
                                  returnData()
                                      .clearFields();
                                },
                                title: 'Items',
                                icon: Icons.book,
                              ),
                              Visibility(
                                visible: !isStoreKeeper(),
                                child: NavListTileDesktopAlt(
                                  itemIndex: 2,
                                  height: 16,
                                  action: () {
                                    var safeContext =
                                        context;
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
                                          builder: (
                                            context,
                                          ) {
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
                                    ).clearDate();
                                    returnReceiptProvider(
                                      safeContext,
                                      listen: false,
                                    ).clearDate();
                                    returnData()
                                        .clearFields();
                                  },
                                  title: 'Sales',
                                  icon:
                                      Icons
                                          .menu_book_rounded,
                                ),
                              ),
                              Visibility(
                                visible: !isStoreKeeper(),
                                child: NavListTileDesktopAlt(
                                  itemIndex: 3,
                                  height: 14,
                                  action: () {
                                    checkNavigate(context);
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
                              ),
                              Visibility(
                                visible: !isStoreKeeper(),
                                child: NavListTileDesktopAlt(
                                  itemIndex: 4,
                                  height: 14,
                                  action: () {
                                    checkNavigate(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return SupplierList();
                                        },
                                      ),
                                    );
                                  },
                                  title: 'Suppliers',
                                  icon: Icons.person,
                                ),
                              ),
                              Visibility(
                                visible:
                                    !isStoreKeeper() &&
                                    authorization(
                                      authorized:
                                          Authorizations()
                                              .managePurchases,
                                    ),
                                child: NavListTileDesktopAlt(
                                  itemIndex: 5,
                                  height: 14,
                                  action: () {
                                    checkNavigate(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return PurchaseList();
                                        },
                                      ),
                                    );
                                  },
                                  title: 'Purchases',
                                  icon:
                                      Icons
                                          .account_balance_wallet_outlined,
                                ),
                              ),
                              Visibility(
                                visible: !isStoreKeeper(),
                                child: NavListTileDesktopAlt(
                                  itemIndex: 6,
                                  height: 14,
                                  action: () {
                                    checkNavigate(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return ExpensesPage(
                                            isMain: true,
                                            turnOnBackNavButton:
                                                false,
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
                              ),
                              Visibility(
                                visible: !isStoreKeeper(),
                                child: NavListTileDesktopAlt(
                                  itemIndex: 7,
                                  height: 14,
                                  action: () {
                                    checkNavigate(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return InvoiceListPage();
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
                              ),
                              NavListTileDesktopAlt(
                                itemIndex: 8,
                                height: 14,
                                action: () {
                                  checkNavigate(context);
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
                                ),
                                child: NavListTileDesktopAlt(
                                  itemIndex: 9,
                                  height: 14,
                                  action: () {
                                    checkNavigate(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return EmployeeListPage(
                                            empId:
                                                AuthService()
                                                    .currentUser!,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  title: 'Employees',
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
                              Visibility(
                                visible: !isStoreKeeper(),
                                child: InkWell(
                                  onTap: () {
                                    checkNavigate(context);
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
                                  child: Container(
                                    color:
                                        returnNavProvider(
                                                  context,
                                                ).currentIndex ==
                                                10
                                            ? const Color.fromARGB(
                                              36,
                                              255,
                                              153,
                                              0,
                                            )
                                            : Colors
                                                .transparent,
                                    height: 40,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment
                                              .start,
                                      children: [
                                        Stack(
                                          clipBehavior:
                                              Clip.none,
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                checkNavigate(
                                                  context,
                                                );
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
                                                padding:
                                                    EdgeInsets.all(
                                                      10,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color.fromARGB(
                                                        208,
                                                        245,
                                                        245,
                                                        245,
                                                      ),
                                                  shape:
                                                      BoxShape
                                                          .circle,
                                                ),
                                                child: SvgPicture.asset(
                                                  height:
                                                      23,
                                                  width: 23,
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
                                              bottom: 18,
                                              left: 26,
                                              child: Visibility(
                                                visible:
                                                    widget
                                                        .notifications
                                                        .where(
                                                          (
                                                            notif,
                                                          ) =>
                                                              !notif.isViewed,
                                                        )
                                                        .isNotEmpty,
                                                child: Container(
                                                  padding:
                                                      EdgeInsets.all(
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
                                              10,
                                          child: SizedBox(
                                            width: 15,
                                          ),
                                        ),
                                        Visibility(
                                          visible:
                                              returnNavProvider(
                                                context,
                                              ).currentIndex ==
                                              10,
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.fromLTRB(
                                                  0,
                                                  5,
                                                  3,
                                                  5,
                                                ),
                                            child: Container(
                                              width: 4,
                                              decoration: BoxDecoration(
                                                color:
                                                    widget
                                                        .theme
                                                        .lightModeColor
                                                        .secColor200,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      20,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              NavListTileDesktopAlt(
                                itemIndex: 11,
                                height: 18,
                                action: () {
                                  checkNavigate(context);
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
                              NavListTileDesktopAlt(
                                height: 18,
                                action: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return SettingsPage();
                                      },
                                    ),
                                  );
                                },
                                title: 'General Settings',
                                icon: Icons.settings,
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
                                        tabletScreenSmall,
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
                                              'You are about to download and install our official application, for better experience.',
                                          title:
                                              'Proceed to Download App',
                                          action: () async {
                                            Navigator.of(
                                              context,
                                            ).pop();
                                            await downloadApkFromApp(
                                              context:
                                                  context,
                                            );
                                          },
                                        );
                                      },
                                    );
                                  },
                                  title: 'Download App',
                                  icon:
                                      Icons
                                          .download_outlined,
                                ),
                              ),
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
                                  returnNavProvider(
                                            context,
                                          ).currentIndex ==
                                          itemIndex
                                      ? Colors.grey.shade900
                                      : color ??
                                          Colors
                                              .grey
                                              .shade600,
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
                                  returnNavProvider(
                                            context,
                                          ).currentIndex ==
                                          itemIndex
                                      ? Colors.grey.shade900
                                      : color ??
                                          Colors
                                              .grey
                                              .shade600,
                              svg ?? '',
                              height: height,
                            ),
                          ),
                        ],
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
                          theme.lightModeColor.secColor200,
                      borderRadius: BorderRadius.circular(
                        20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
