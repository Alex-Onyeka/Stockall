import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
// import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:stockall/classes/temp_notification/temp_notification.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/major/desktop_page_container.dart';
import 'package:stockall/components/major/drawer_widget/my_drawer_widget.dart';
import 'package:stockall/components/major/drawer_widget/platforms/my_drawer_widget_desktop.dart';
import 'package:stockall/components/major/right_side_bar.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/refresh_functions.dart';
import 'package:stockall/constants/subscription/sales_auth.dart';
import 'package:stockall/constants/subscription/subscription_func.dart';
import 'package:stockall/helpers/clean_up_url/clean_up_url.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/dashboard/components/button_tab.dart';
import 'package:stockall/pages/dashboard/components/expiry_sub_popup_desktop.dart';
import 'package:stockall/pages/dashboard/components/main_info_tab.dart';
import 'package:stockall/pages/dashboard/components/top_nav_bar.dart';
import 'package:stockall/pages/dashboard/components/total_sales_banner.dart';
import 'package:stockall/pages/employees/employee_list/employee_list_page.dart';
import 'package:stockall/pages/expenses/expenses_page.dart';
import 'package:stockall/pages/invoices/invoice_list/invoice_list_page.dart';
import 'package:stockall/pages/notifications/notifications_page.dart';
import 'package:stockall/pages/report/report_page.dart';
import 'package:stockall/pages/sales/make_sales/page1/make_sales_page.dart';
import 'package:stockall/services/auth_service.dart';

class DashboardDesktop extends StatefulWidget {
  final int? shopId;
  const DashboardDesktop({super.key, required this.shopId});

  @override
  State<DashboardDesktop> createState() =>
      _DashboardDesktopState();
}

class _DashboardDesktopState
    extends State<DashboardDesktop> {
  bool isFloatOpen = false;
  bool isUpdateLodaingWeb = false;
  bool isUpdateLodaingMobile = false;

  void openFloat() {
    setState(() {
      isFloatOpen = true;
    });

    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          isFloatOpen = false;
        });
      }
    });
  }

  bool isLoading = false;
  void clearDate() {
    returnReportProvider(
      context,
      listen: false,
    ).clearDate(context);
  }

  late Future<List<TempNotification>> notificationsFuture;

  Future<List<TempNotification>>
  fetchNotifications() async {
    var tempGet = await returnNotificationProvider(
      context,
      listen: false,
    ).fetchRecentNotifications(widget.shopId!);

    return tempGet;
  }

  TextEditingController emailController =
      TextEditingController();
  TextEditingController passwordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    if (!returnReceiptProvider(
      context,
      listen: false,
    ).isLoaded) {
      WidgetsBinding.instance.addPostFrameCallback((
        _,
      ) async {
        await RefreshFunctions(context).refreshAll(context);
        returnReceiptProvider(
          context,
          listen: false,
        ).load(true);
        print('Data Loaded');
      });
    }
    // loadSuggestions();
    notificationsFuture = fetchNotifications();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();

  //
  //
  //

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    var receiptsLocal =
        returnReceiptProvider(context).receipts;
    var expensesLocal =
        returnExpensesProvider(context).expenses;
    var productsLocal = returnData().productList;
    if (widget.shopId == null) {
      return Scaffold(
        body: returnCompProvider(
          context,
          listen: false,
        ).showLoader(message: 'Loading'),
      );
    } else {
      if (!returnReceiptProvider(
        context,
        listen: false,
      ).isLoaded) {
        return returnCompProvider(
          context,
          listen: false,
        ).showLoader(message: 'Loading');
      } else {
        // return Container();
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
                            message:
                                'You are about to Logout',
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
                      widget: Stack(
                        children: [
                          Scaffold(
                            body: Stack(
                              children: [
                                Column(
                                  children: [
                                    FutureBuilder(
                                      future:
                                          notificationsFuture,
                                      builder: (
                                        context,
                                        snapshot,
                                      ) {
                                        return TopNavBar(
                                          refreshAction: () async {
                                            await RefreshFunctions(
                                              context,
                                            ).refreshAll(
                                              context,
                                            );
                                            // setState(() {});
                                          },
                                          action: () {
                                            returnNavProvider(
                                              context,
                                              listen: false,
                                            ).navigate(8);
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
                                          openSideBar:
                                              () {},
                                          theme: theme,
                                        );
                                      },
                                    ),
                                    Expanded(
                                      child: RefreshIndicator(
                                        onRefresh: () async {
                                          return await RefreshFunctions(
                                            context,
                                          ).refreshAll(
                                            context,
                                          );
                                        },
                                        backgroundColor:
                                            Colors.white,
                                        color:
                                            theme
                                                .lightModeColor
                                                .prColor300,
                                        displacement: 10,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.symmetric(
                                                horizontal:
                                                    15.0,
                                              ),
                                          child: ListView(
                                            children: [
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Visibility(
                                                visible:
                                                    !isStoreKeeper(),
                                                child: Row(
                                                  spacing:
                                                      15,
                                                  children: [
                                                    Expanded(
                                                      child: DashboardTotalSalesBanner(
                                                        expenses:
                                                            expensesLocal,
                                                        userValue: returnReceiptProvider(
                                                          context,
                                                        ).getTotalRevenueForSelectedDay(
                                                          returnReceiptProvider(
                                                                context,
                                                              ).receipts
                                                              .where(
                                                                (
                                                                  rec,
                                                                ) =>
                                                                    rec.staffId ==
                                                                    userGeneral(
                                                                      context,
                                                                    ).userId,
                                                              )
                                                              .toList(),
                                                        ),
                                                        currentUser: userGeneral(
                                                          context,
                                                        ),
                                                        theme:
                                                            theme,
                                                        value: returnReceiptProvider(
                                                          context,
                                                        ).getTotalRevenueForSelectedDay(
                                                          returnReceiptProvider(
                                                            context,
                                                          ).receipts,
                                                        ),
                                                      ),
                                                    ),
                                                    Material(
                                                      elevation:
                                                          2,
                                                      child: Ink(
                                                        decoration: BoxDecoration(
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: const Color.fromARGB(
                                                                24,
                                                                0,
                                                                0,
                                                                0,
                                                              ),
                                                              blurRadius:
                                                                  10,
                                                            ),
                                                          ],
                                                          color:
                                                              theme.lightModeColor.prColor300,
                                                          borderRadius: BorderRadius.circular(
                                                            10,
                                                          ),
                                                        ),
                                                        child: InkWell(
                                                          onTap: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (
                                                                  context,
                                                                ) {
                                                                  return MakeSalesPage();
                                                                },
                                                              ),
                                                            );
                                                          },
                                                          child: Container(
                                                            padding: EdgeInsets.symmetric(
                                                              horizontal:
                                                                  30,
                                                              vertical:
                                                                  48,
                                                            ),
                                                            child: Column(
                                                              spacing:
                                                                  5,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment.center,
                                                              children: [
                                                                SvgPicture.asset(
                                                                  plusIconSvg,
                                                                  color:
                                                                      theme.lightModeColor.secColor200,
                                                                  height:
                                                                      20,
                                                                ),
                                                                Text(
                                                                  style: TextStyle(
                                                                    color:
                                                                        Colors.white,
                                                                    fontWeight:
                                                                        FontWeight.bold,
                                                                    fontSize:
                                                                        theme.mobileTexts.b3.fontSize,
                                                                  ),
                                                                  'Make Sale',
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              SizedBox(
                                                height: 20,
                                              ),
                                              Row(
                                                spacing: 10,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .center,
                                                children: [
                                                  Expanded(
                                                    child: MainInfoTab(
                                                      theme:
                                                          theme,
                                                      icon:
                                                          pulseIconSvg,
                                                      number:
                                                          '${productsLocal.length}',
                                                      title:
                                                          'All Items',
                                                      action: () {
                                                        returnNavProvider(
                                                          context,
                                                          listen:
                                                              false,
                                                        ).navigate(
                                                          1,
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                  Visibility(
                                                    visible:
                                                        !isStoreKeeper(),
                                                    child: Expanded(
                                                      child: MainInfoTab(
                                                        theme:
                                                            theme,
                                                        icon:
                                                            productIconSvg,
                                                        number:
                                                            '${returnReceiptProvider(context).returnOwnReceiptsByDayOrWeek(receiptsLocal).length}',
                                                        title:
                                                            'Sales',
                                                        action: () {
                                                          returnNavProvider(
                                                            context,
                                                            listen:
                                                                false,
                                                          ).navigate(
                                                            2,
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                  Visibility(
                                                    visible:
                                                        isStoreKeeper(),
                                                    child: ButtonTab(
                                                      theme:
                                                          theme,
                                                      icon:
                                                          reportIconSvg,
                                                      title:
                                                          'Report',
                                                      action: () {
                                                        returnNavProvider(
                                                          context,
                                                          listen:
                                                              false,
                                                        ).navigate(
                                                          6,
                                                        );
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (
                                                              context,
                                                            ) {
                                                              return ReportPage();
                                                            },
                                                          ),
                                                        ).then((
                                                          context,
                                                        ) {
                                                          setState(
                                                            () {
                                                              clearDate();
                                                            },
                                                          );
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                  Visibility(
                                                    visible:
                                                        screenWidth(
                                                              context,
                                                            ) >
                                                            tabletScreen &&
                                                        !isStoreKeeper(),
                                                    child: Expanded(
                                                      child: MainInfoTab(
                                                        theme:
                                                            theme,
                                                        icon:
                                                            productIconSvg,
                                                        number:
                                                            '${returnExpensesProvider(context).returnExpensesByDayOrWeek(context, returnExpensesProvider(context).expenses).length}',
                                                        title:
                                                            'Expenses',
                                                        action: () {
                                                          returnNavProvider(
                                                            context,
                                                            listen:
                                                                false,
                                                          ).navigate(
                                                            4,
                                                          );
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (
                                                                context,
                                                              ) {
                                                                return ExpensesPage(
                                                                  isMain:
                                                                      true,
                                                                );
                                                              },
                                                            ),
                                                          ).then(
                                                            (
                                                              context,
                                                            ) {
                                                              setState(
                                                                () {
                                                                  clearDate();
                                                                },
                                                              );
                                                            },
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                  Visibility(
                                                    visible:
                                                        !isStoreKeeper(),
                                                    child: Expanded(
                                                      child: SubWrapper(
                                                        isVisible:
                                                            !SalesAuthAction().invoiceManagementAction(
                                                              context:
                                                                  context,
                                                            ),
                                                        mainWidget: MainInfoTab(
                                                          theme:
                                                              theme,
                                                          icon:
                                                              productIconSvg,
                                                          number:
                                                              '${returnInvoicesProvider(context: context).returnInvoicesByDayOrWeekAll().length}',
                                                          title:
                                                              'Invoices',
                                                          action: () {
                                                            SalesAuthAction().invoiceManagementAction(
                                                              context:
                                                                  context,
                                                              action: () {
                                                                returnNavProvider(
                                                                  context,
                                                                  listen:
                                                                      false,
                                                                ).navigate(
                                                                  5,
                                                                );

                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder: (
                                                                      context,
                                                                    ) {
                                                                      return InvoiceListPage();
                                                                    },
                                                                  ),
                                                                );
                                                              },
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 20,
                                              ),
                                              Visibility(
                                                visible:
                                                    !isStoreKeeper(),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text(
                                                          style: TextStyle(
                                                            fontSize:
                                                                theme.mobileTexts.b1.fontSize,
                                                            fontWeight:
                                                                theme.mobileTexts.b1.fontWeightBold,
                                                          ),
                                                          'Quick Actions',
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height:
                                                          15,
                                                    ),

                                                    SizedBox(
                                                      width:
                                                          double.infinity,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment.center,
                                                        spacing:
                                                            15,
                                                        children: [
                                                          Row(
                                                            spacing:
                                                                15,
                                                            children: [
                                                              ButtonTab(
                                                                theme:
                                                                    theme,
                                                                icon:
                                                                    productIconSvg,
                                                                title:
                                                                    'Items',
                                                                action: () {
                                                                  returnNavProvider(
                                                                    context,
                                                                    listen:
                                                                        false,
                                                                  ).navigate(
                                                                    1,
                                                                  );
                                                                },
                                                              ),
                                                              ButtonTab(
                                                                theme:
                                                                    theme,
                                                                icon:
                                                                    salesIconSvg,
                                                                title:
                                                                    'Sales',
                                                                action: () {
                                                                  returnNavProvider(
                                                                    context,
                                                                    listen:
                                                                        false,
                                                                  ).navigate(
                                                                    2,
                                                                  );
                                                                },
                                                              ),
                                                              ButtonTab(
                                                                theme:
                                                                    theme,
                                                                icon:
                                                                    reportIconSvg,
                                                                title:
                                                                    'Report',
                                                                action: () {
                                                                  returnNavProvider(
                                                                    context,
                                                                    listen:
                                                                        false,
                                                                  ).navigate(
                                                                    6,
                                                                  );
                                                                  Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder: (
                                                                        context,
                                                                      ) {
                                                                        return ReportPage();
                                                                      },
                                                                    ),
                                                                  ).then(
                                                                    (
                                                                      context,
                                                                    ) {
                                                                      setState(
                                                                        () {
                                                                          clearDate();
                                                                        },
                                                                      );
                                                                    },
                                                                  );
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment.start,
                                                            // spacing:
                                                            //     15,
                                                            children: [
                                                              Visibility(
                                                                visible: authorization(
                                                                  authorized:
                                                                      Authorizations().employeePage,
                                                                ),
                                                                child: ButtonTab(
                                                                  theme:
                                                                      theme,
                                                                  icon:
                                                                      employeesIconSvg,
                                                                  title:
                                                                      'Employees',
                                                                  action: () {
                                                                    returnNavProvider(
                                                                      context,
                                                                      listen:
                                                                          false,
                                                                    ).navigate(
                                                                      7,
                                                                    );
                                                                    Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                        builder: (
                                                                          context,
                                                                        ) {
                                                                          return EmployeeListPage(
                                                                            empId:
                                                                                userGeneral(
                                                                                  context,
                                                                                ).userId!,
                                                                          );
                                                                        },
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                              Visibility(
                                                                visible: authorization(
                                                                  authorized:
                                                                      Authorizations().employeePage,
                                                                ),
                                                                child: SizedBox(
                                                                  width:
                                                                      15,
                                                                ),
                                                              ),

                                                              ButtonTab(
                                                                theme:
                                                                    theme,
                                                                icon:
                                                                    custBookIconSvg,
                                                                title:
                                                                    'Invoices',
                                                                action: () {
                                                                  SalesAuthAction().invoiceManagementAction(
                                                                    context:
                                                                        context,
                                                                    action: () {
                                                                      returnNavProvider(
                                                                        context,
                                                                        listen:
                                                                            false,
                                                                      ).navigate(
                                                                        5,
                                                                      );
                                                                      Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                          builder: (
                                                                            context,
                                                                          ) {
                                                                            return InvoiceListPage();
                                                                          },
                                                                        ),
                                                                      );
                                                                    },
                                                                  );
                                                                },
                                                              ),
                                                              SizedBox(
                                                                width:
                                                                    15,
                                                              ),
                                                              ButtonTab(
                                                                theme:
                                                                    theme,
                                                                icon:
                                                                    expensesIconSvg,
                                                                title:
                                                                    'Expenses',
                                                                action: () async {
                                                                  returnNavProvider(
                                                                    context,
                                                                    listen:
                                                                        false,
                                                                  ).navigate(
                                                                    4,
                                                                  );
                                                                  Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder: (
                                                                        context,
                                                                      ) {
                                                                        return ExpensesPage(
                                                                          isMain:
                                                                              true,
                                                                        );
                                                                      },
                                                                    ),
                                                                  ).then(
                                                                    (
                                                                      context,
                                                                    ) {
                                                                      setState(
                                                                        () {
                                                                          clearDate();
                                                                        },
                                                                      );
                                                                    },
                                                                  );
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                height: 30,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Visibility(
                                  visible: authorization(
                                    authorized:
                                        Authorizations()
                                            .contactStockall,
                                  ),
                                  child: Align(
                                    alignment: Alignment(
                                      1,
                                      isFloatOpen
                                          ? 1
                                          : 0.94,
                                    ),
                                    child: Material(
                                      elevation: 2,
                                      color:
                                          Colors
                                              .transparent,
                                      child: GestureDetector(
                                        onTap: () {
                                          if (isFloatOpen) {
                                            setState(() {
                                              isFloatOpen =
                                                  false;
                                            });
                                          } else {
                                            setState(() {
                                              isFloatOpen =
                                                  true;
                                            });
                                          }
                                        },
                                        child: Container(
                                          padding:
                                              EdgeInsets.fromLTRB(
                                                10,
                                                15,
                                                isFloatOpen
                                                    ? 30
                                                    : 10,
                                                15,
                                              ),
                                          decoration: BoxDecoration(
                                            color:
                                                theme
                                                    .lightModeColor
                                                    .secColor100,
                                            borderRadius:
                                                BorderRadius.only(
                                                  topLeft:
                                                      Radius.circular(
                                                        5,
                                                      ),
                                                  bottomLeft:
                                                      Radius.circular(
                                                        5,
                                                      ),
                                                ),
                                          ),
                                          child: Stack(
                                            children: [
                                              Visibility(
                                                visible:
                                                    isFloatOpen,
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize
                                                          .min,
                                                  children: [
                                                    Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.center,
                                                      children: [
                                                        Icon(
                                                          color:
                                                              Colors.white,
                                                          size:
                                                              16,
                                                          Icons.arrow_forward_ios_rounded,
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      width:
                                                          10,
                                                    ),
                                                    Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      spacing:
                                                          15,
                                                      children: [
                                                        InkWell(
                                                          onTap: () async {
                                                            openWhatsApp();
                                                          },

                                                          child: Column(
                                                            spacing:
                                                                3,
                                                            mainAxisSize:
                                                                MainAxisSize.min,
                                                            children: [
                                                              SvgPicture.asset(
                                                                whatsappIconSvg,
                                                                color:
                                                                    Colors.white,
                                                                height:
                                                                    16,
                                                              ),
                                                              Text(
                                                                style: TextStyle(
                                                                  color:
                                                                      Colors.white,
                                                                  fontWeight:
                                                                      FontWeight.bold,
                                                                ),
                                                                'Chat Us',
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        InkWell(
                                                          onTap: () async {
                                                            phoneCall();
                                                          },
                                                          child: Column(
                                                            spacing:
                                                                3,
                                                            mainAxisSize:
                                                                MainAxisSize.min,
                                                            children: [
                                                              Icon(
                                                                size:
                                                                    17,
                                                                color:
                                                                    Colors.white,
                                                                Icons.phone,
                                                              ),
                                                              Text(
                                                                style: TextStyle(
                                                                  color:
                                                                      Colors.white,
                                                                  fontWeight:
                                                                      FontWeight.bold,
                                                                ),
                                                                'Call Us',
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
                                                    !isFloatOpen,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    openFloat();
                                                  },
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.center,
                                                    children: [
                                                      Icon(
                                                        size:
                                                            16,
                                                        color:
                                                            Colors.white,
                                                        Icons.arrow_back_ios_new_rounded,
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
                                  ),
                                ),
                                Visibility(
                                  visible:
                                      appVersionDesktop !=
                                          returnAppVersionProvider(
                                                context,
                                              )
                                              .appVersion
                                              ?.desktopVersion &&
                                      returnAppVersionProvider(
                                            context,
                                          ).isUpdated ==
                                          false,
                                  child: Align(
                                    alignment: Alignment(
                                      0,
                                      -0.8,
                                    ),
                                    child: Material(
                                      elevation: 2,
                                      color:
                                          Colors
                                              .transparent,
                                      child: Container(
                                        width: 450,
                                        padding:
                                            EdgeInsets.fromLTRB(
                                              15,
                                              15,
                                              15,
                                              30,
                                            ),
                                        decoration: BoxDecoration(
                                          color:
                                              Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  const Color.fromARGB(
                                                    84,
                                                    0,
                                                    0,
                                                    0,
                                                  ),
                                              blurRadius:
                                                  20,
                                              spreadRadius:
                                                  10,
                                            ),
                                          ],
                                          borderRadius:
                                              BorderRadius.circular(
                                                5,
                                              ),
                                        ),
                                        child: Column(
                                          mainAxisSize:
                                              MainAxisSize
                                                  .min,
                                          children: [
                                            Row(
                                              spacing: 10,
                                              mainAxisSize:
                                                  MainAxisSize
                                                      .max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Opacity(
                                                  opacity:
                                                      0,
                                                  child: IconButton(
                                                    onPressed:
                                                        () {},
                                                    icon: Icon(
                                                      Icons
                                                          .clear,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                  'NEW UPDATE AVAILABLE',
                                                ),
                                                IconButton(
                                                  onPressed: () {
                                                    returnAppVersionProvider(
                                                      context,
                                                      listen:
                                                          false,
                                                    ).toggleUpdated(
                                                      true,
                                                    );
                                                  },
                                                  icon: Icon(
                                                    Icons
                                                        .clear,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              textAlign:
                                                  TextAlign
                                                      .center,
                                              style: TextStyle(
                                                fontSize:
                                                    theme
                                                        .mobileTexts
                                                        .b2
                                                        .fontSize,
                                              ),
                                              'New Update is Available. Please Click the button below to download the updated version.',
                                            ),
                                            Visibility(
                                              visible:
                                                  kIsWeb,
                                              child: Column(
                                                children: [
                                                  SizedBox(
                                                    height:
                                                        10,
                                                  ),
                                                  Text(
                                                    textAlign:
                                                        TextAlign.center,
                                                    style: TextStyle(
                                                      color:
                                                          theme.lightModeColor.secColor100,
                                                      fontSize:
                                                          theme.mobileTexts.b3.fontSize,
                                                    ),
                                                    'Note: If you decide to update web, You might need to refresh more than twice before the update can relfect',
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              height: 15,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .center,
                                              children: [
                                                Visibility(
                                                  visible:
                                                      kIsWeb &&
                                                      Theme.of(
                                                            context,
                                                          ).platform ==
                                                          TargetPlatform.iOS,
                                                  child: Expanded(
                                                    child: Material(
                                                      color:
                                                          Colors.transparent,
                                                      child: Ink(
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(
                                                            5,
                                                          ),
                                                          color:
                                                              theme.lightModeColor.prColor300,
                                                        ),
                                                        child: InkWell(
                                                          onTap: () async {
                                                            setState(
                                                              () {
                                                                isUpdateLodaingWeb =
                                                                    true;
                                                              },
                                                            );
                                                            performRestart();
                                                          },
                                                          child: Container(
                                                            padding: EdgeInsets.symmetric(
                                                              vertical:
                                                                  10,
                                                              horizontal:
                                                                  15,
                                                            ),
                                                            child: Center(
                                                              child: Padding(
                                                                padding: const EdgeInsets.only(
                                                                  bottom:
                                                                      3.0,
                                                                ),
                                                                child:
                                                                    isUpdateLodaingWeb
                                                                        ? CircularProgressIndicator(
                                                                          color:
                                                                              Colors.white,
                                                                        )
                                                                        : Text(
                                                                          style: TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontSize:
                                                                                theme.mobileTexts.b3.fontSize,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                          ),
                                                                          'Install Update',
                                                                        ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Visibility(
                                                  visible:
                                                      !kIsWeb ||
                                                      (kIsWeb &&
                                                          Theme.of(context).platform !=
                                                              TargetPlatform.iOS),
                                                  child: Expanded(
                                                    child: Material(
                                                      color:
                                                          Colors.transparent,
                                                      child: Ink(
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(
                                                            5,
                                                          ),
                                                          color:
                                                              theme.lightModeColor.prColor300,
                                                        ),
                                                        child: InkWell(
                                                          onTap: () async {
                                                            setState(
                                                              () {
                                                                isUpdateLodaingMobile =
                                                                    true;
                                                              },
                                                            );
                                                            downloadApkFromApp(
                                                              context:
                                                                  context,
                                                            );
                                                            setState(
                                                              () {
                                                                isUpdateLodaingMobile =
                                                                    false;
                                                              },
                                                            );
                                                          },
                                                          child: Container(
                                                            padding: EdgeInsets.symmetric(
                                                              vertical:
                                                                  10,
                                                              horizontal:
                                                                  15,
                                                            ),
                                                            child: Center(
                                                              child: Padding(
                                                                padding: const EdgeInsets.only(
                                                                  bottom:
                                                                      3.0,
                                                                ),
                                                                child:
                                                                    isUpdateLodaingMobile
                                                                        ? CircularProgressIndicator(
                                                                          color:
                                                                              Colors.white,
                                                                        )
                                                                        : Text(
                                                                          style: TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontSize:
                                                                                theme.mobileTexts.b3.fontSize,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                          ),
                                                                          !kIsWeb
                                                                              ? 'Install Update'
                                                                              : kIsWeb &&
                                                                                  Theme.of(
                                                                                        context,
                                                                                      ).platform !=
                                                                                      TargetPlatform.iOS
                                                                              ? 'Download ${screenWidth(context) > tabletScreenSmall ? 'Desktop' : ''} App'
                                                                              : '',
                                                                        ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Visibility(
                                                  visible:
                                                      (kIsWeb &&
                                                          Theme.of(context).platform !=
                                                              TargetPlatform.iOS),
                                                  child: SizedBox(
                                                    width:
                                                        10,
                                                  ),
                                                ),
                                                Visibility(
                                                  visible:
                                                      kIsWeb &&
                                                      Theme.of(
                                                            context,
                                                          ).platform !=
                                                          TargetPlatform.iOS,
                                                  child: Expanded(
                                                    child: Material(
                                                      color:
                                                          Colors.transparent,
                                                      child: Ink(
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(
                                                            5,
                                                          ),
                                                          color:
                                                              theme.lightModeColor.prColor300,
                                                        ),
                                                        child: InkWell(
                                                          onTap: () async {
                                                            setState(
                                                              () {
                                                                isUpdateLodaingWeb =
                                                                    true;
                                                              },
                                                            );
                                                            performRestart();
                                                          },
                                                          child: Container(
                                                            padding: EdgeInsets.symmetric(
                                                              vertical:
                                                                  10,
                                                              horizontal:
                                                                  15,
                                                            ),
                                                            child: Center(
                                                              child: Padding(
                                                                padding: const EdgeInsets.only(
                                                                  bottom:
                                                                      3.0,
                                                                ),
                                                                child:
                                                                    isUpdateLodaingWeb
                                                                        ? CircularProgressIndicator(
                                                                          color:
                                                                              Colors.white,
                                                                        )
                                                                        : Text(
                                                                          style: TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontSize:
                                                                                theme.mobileTexts.b3.fontSize,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                          ),
                                                                          'Install Update',
                                                                        ),
                                                              ),
                                                            ),
                                                          ),
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
                                // DesktopFocusBarcodeWidget(
                                //   theme: theme,
                                // ),
                                ExpirySubPopUpDesktop(),
                                Visibility(
                                  visible:
                                      context
                                          .watch<
                                            AuthService
                                          >()
                                          .isLoading,
                                  child: returnCompProvider(
                                    context,
                                  ).showSuccess('Loading'),
                                ),
                                Visibility(
                                  visible:
                                      context
                                          .watch<
                                            AuthService
                                          >()
                                          .isLoading,
                                  child: returnCompProvider(
                                    context,
                                  ).showLoader(
                                    message: 'Loading',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
                ).showLoader(message: 'Logging Out'),
              ),
            ],
          ),
        );
      }
    }
  }
}

// class DesktopFocusBarcodeWidget extends StatefulWidget {
//   const DesktopFocusBarcodeWidget({
//     super.key,
//     required this.theme,
//   });

//   final ThemeProvider theme;

//   @override
//   State<DesktopFocusBarcodeWidget> createState() =>
//       _DesktopFocusBarcodeWidgetState();
// }

// class _DesktopFocusBarcodeWidgetState
//     extends State<DesktopFocusBarcodeWidget> {
//   @override
//   void initState() {
//     super.initState();
//     returnData().keepNodeFocus();
//     returnData().startBarcodeTimer();
//     print('❌❌✅✅ Barcode Timer Created');
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     returnData().keepNodeFocus();
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     print('❌❌✅✅Disposed');
//     returnData().cancelBarcodeTimer();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 60,
//       width: 500,
//       child: GeneralTextField(
//         title: 'title',
//         hint: 'hint',
//         controller: returnData().barcodeController,
//         lines: 1,
//         theme: widget.theme,
//         focusNode: returnData().barcodeNode,
//         onChanged: (value) {
//           if (returnData().barcodeController.text.length >
//               20) {
//             returnData().clearBarcodeTextField();
//           } else {
//             if (value.isNotEmpty) {
//               var items = returnData().productList.where(
//                 (product) =>
//                     product.barcode?.toLowerCase() ==
//                         value.toLowerCase() ||
//                     product.name.toLowerCase() ==
//                         value.toLowerCase(),
//               );
//               if (items.isNotEmpty) {
//                 returnSalesProvider().addItemToCart(
//                   context: context,
//                   newItem: TempCartItem(
//                     setCustomPrice: false,
//                     item: items.first,
//                     quantity: 1,
//                     discount: null,
//                     addToStock: false,
//                     setTotalPrice: false,
//                   ),
//                   isCustomEdit: false,
//                 );
//                 // returnData().clearBarcodeTextField();
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) {
//                       return MakeSalesPage();
//                     },
//                   ),
//                 );
//                 // await playBeep();
//                 // setState(() {});
//                 // barcodeNode.requestFocus();
//               }
//             }
//           }
//           print("Barcode Value: $value");
//         },
//       ),
//     );
//   }
// }
