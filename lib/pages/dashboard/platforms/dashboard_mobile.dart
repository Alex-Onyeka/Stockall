import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
// import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stockall/classes/temp_expenses_class.dart';
import 'package:stockall/classes/temp_main_receipt.dart';
import 'package:stockall/classes/temp_notification.dart';
import 'package:stockall/classes/temp_product_class.dart';
import 'package:stockall/classes/temp_product_sale_record.dart';
import 'package:stockall/classes/temp_shop_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/components/major/my_drawer_widget.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/auth_screens/auth_screens_page.dart';
import 'package:stockall/pages/customers/customers_list/customer_list.dart';
import 'package:stockall/pages/dashboard/components/button_tab.dart';
import 'package:stockall/pages/dashboard/components/main_bottom_nav.dart';
import 'package:stockall/pages/dashboard/components/main_info_tab.dart';
import 'package:stockall/pages/dashboard/components/top_nav_bar.dart';
import 'package:stockall/pages/dashboard/components/total_sales_banner.dart';
import 'package:stockall/pages/employees/employee_list/employee_list_page.dart';
import 'package:stockall/pages/expenses/expenses_page.dart';
import 'package:stockall/pages/notifications/notifications_page.dart';
import 'package:stockall/pages/report/report_page.dart';
import 'package:stockall/providers/nav_provider.dart';
import 'package:stockall/services/auth_service.dart';

class DashboardMobile extends StatefulWidget {
  final int? shopId;
  const DashboardMobile({
    super.key,
    required this.shopId,
    // required this.stillLoading,
  });

  @override
  State<DashboardMobile> createState() =>
      _DashboardMobileState();
}

class _DashboardMobileState extends State<DashboardMobile> {
  Future<void> loadSuggestions() async {
    await returnSuggestionProvider(
      context,
      listen: false,
    ).loadSuggestions(
      returnShopProvider(
        context,
        listen: false,
      ).userShop!.shopId!,
    );
  }

  bool isFloatOpen = false;

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

  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();
  late TempShopClass shop;

  Future<List<TempMainReceipt>> getMainReceipts() {
    var tempReceipts = returnReceiptProvider(
      context,
      listen: false,
    ).loadReceipts(widget.shopId!, context);

    return tempReceipts;
  }

  bool isLoading = false;
  bool showSuccess = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   // clearDate();
    // });
  }

  void clearDate() {
    returnReportProvider(
      context,
      listen: false,
    ).clearDate(context);
  }

  late Future<List<TempProductClass>> productsFuture;
  Future<List<TempProductClass>> getProducts() async {
    var tempP = await returnData(
      context,
      listen: false,
    ).getProducts(widget.shopId!);
    return tempP;
  }

  late Future<List<TempMainReceipt>> mainReceiptFuture;

  late Future<List<TempNotification>> notificationsFuture;

  Future<List<TempNotification>>
  fetchNotifications() async {
    var tempGet = await returnNotificationProvider(
      context,
      listen: false,
    ).fetchRecentNotifications(widget.shopId!);

    return tempGet;
  }

  late Future<List<TempProductSaleRecord>>
  getProdutRecordsFuture;
  Future<List<TempProductSaleRecord>>
  getProductSalesRecord() async {
    var tempRecords = await returnReceiptProvider(
      context,
      listen: false,
    ).loadProductSalesRecord(widget.shopId!);

    return tempRecords
        .where(
          (beans) =>
              beans.shopId ==
              returnShopProvider(
                context,
                listen: false,
              ).userShop!.shopId!,
        )
        .toList();
  }

  late Future<List<TempExpensesClass>> expensesFuture;

  Future<List<TempExpensesClass>> getExpenses() {
    var tempExp = returnExpensesProvider(
      context,
      listen: false,
    ).getExpenses(widget.shopId ?? 0);

    return tempExp;
  }

  TextEditingController emailController =
      TextEditingController();
  TextEditingController passwordController =
      TextEditingController();
  @override
  void initState() {
    super.initState(); // Always call this first

    if (!returnReceiptProvider(
      context,
      listen: false,
    ).isLoaded) {
      mainReceiptFuture = getMainReceipts();
      getProdutRecordsFuture = getProductSalesRecord();
      expensesFuture = getExpenses();
      productsFuture = getProducts();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        returnReceiptProvider(
          context,
          listen: false,
        ).load();
        print('Data Loaded');
      });
    }
    loadSuggestions();
    notificationsFuture = fetchNotifications();
  }

  Future<void> refreshAll() async {
    getMainReceipts();
    getProductSalesRecord();
    getExpenses();
    getProducts();
    clearDate();
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    var receiptsLocal =
        returnReceiptProvider(context).receipts;
    var expensesLocal =
        returnExpensesProvider(context).expenses;
    var productsLocal = returnData(context).productList;
    if (widget.shopId == null) {
      return Scaffold(
        body: returnCompProvider(
          context,
          listen: false,
        ).showLoader('Loading'),
      );
    } else {
      if (!returnReceiptProvider(
        context,
        listen: false,
      ).isLoaded) {
        return Stack(
          children: [
            Scaffold(
              bottomNavigationBar: MainBottomNav(
                globalKey: _scaffoldKey,
              ),
              key: _scaffoldKey,
              onDrawerChanged: (isOpened) {
                if (!isOpened) {
                  returnNavProvider(
                    context,
                    listen: false,
                  ).closeDrawer();
                }
              },
              drawer: FutureBuilder<List<TempNotification>>(
                future: notificationsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return MyDrawerWidget(
                      action: () {},
                      theme: theme,
                      notifications: [],
                    );
                  } else if (snapshot.hasError) {
                    return MyDrawerWidget(
                      action: () {},
                      theme: theme,
                      notifications: [],
                    );
                  } else {
                    List<TempNotification> notifications =
                        snapshot.data!;
                    return MyDrawerWidget(
                      action: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return ConfirmationAlert(
                              theme: theme,
                              message:
                                  'You are about to Logout',
                              title: 'Are you Sure?',
                              action: () async {
                                await AuthService()
                                    .signOut();

                                if (context.mounted) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
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
                      theme: theme,
                      notifications: notifications,
                    );
                  }
                },
              ),
              body: FutureBuilder(
                future: mainReceiptFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return returnCompProvider(
                      context,
                      listen: false,
                    ).showLoader('Loading');
                  } else if (snapshot.hasError) {
                    return EmptyWidgetDisplayOnly(
                      title: 'An Error Occured',
                      subText:
                          'Check you device Internet connection and try again',
                      theme: theme,
                      height: 30,
                      icon: Icons.clear,
                    );
                  } else {
                    var mainReceiptss =
                        returnReceiptProvider(
                          context,
                          listen: false,
                        ).returnOwnReceiptsByDayOrWeek(
                          context,
                          snapshot.data!,
                        );
                    return Stack(
                      children: [
                        Column(
                          children: [
                            FutureBuilder(
                              future: notificationsFuture,
                              builder: (context, snapshot) {
                                if (snapshot
                                        .connectionState ==
                                    ConnectionState
                                        .waiting) {
                                  return TopNavBar(
                                    role: '',
                                    openSideBar: () {
                                      _scaffoldKey
                                          .currentState
                                          ?.openDrawer();
                                      returnNavProvider(
                                        context,
                                        listen: false,
                                      ).setSettings();
                                    },
                                    theme: theme,
                                    notifications: [],
                                  );
                                } else if (snapshot
                                    .hasError) {
                                  return TopNavBar(
                                    role: '',
                                    action: () {},
                                    openSideBar: () {
                                      _scaffoldKey
                                          .currentState
                                          ?.openDrawer();
                                      returnNavProvider(
                                        context,
                                        listen: false,
                                      ).setSettings();
                                    },
                                    theme: theme,
                                    notifications: [],
                                  );
                                } else {
                                  List<TempNotification>
                                  notifications =
                                      snapshot.data!;

                                  return TopNavBar(
                                    role:
                                        userGeneral(
                                          context,
                                        ).role,
                                    action: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (
                                            context,
                                          ) {
                                            return NotificationsPage();
                                          },
                                        ),
                                      ).then((_) {
                                        setState(() {
                                          notificationsFuture =
                                              fetchNotifications();
                                        });
                                      });
                                    },
                                    openSideBar: () {
                                      _scaffoldKey
                                          .currentState
                                          ?.openDrawer();
                                      returnNavProvider(
                                        context,
                                        listen: false,
                                      ).setSettings();
                                    },
                                    theme: theme,
                                    notifications:
                                        notifications,
                                  );
                                }
                              },
                            ),
                            Expanded(
                              child: RefreshIndicator(
                                onRefresh: () {
                                  return refreshAll();
                                },
                                backgroundColor:
                                    Colors.white,
                                color:
                                    theme
                                        .lightModeColor
                                        .prColor300,
                                displacement: 10,
                                child: SingleChildScrollView(
                                  child: SizedBox(
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.symmetric(
                                            horizontal:
                                                15.0,
                                          ),
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Builder(
                                            builder: (
                                              context,
                                            ) {
                                              if (snapshot
                                                      .connectionState ==
                                                  ConnectionState
                                                      .waiting) {
                                                return Shimmer.fromColors(
                                                  baseColor:
                                                      Colors
                                                          .grey,
                                                  highlightColor:
                                                      Colors
                                                          .white,
                                                  child: DashboardTotalSalesBanner(
                                                    theme:
                                                        theme,
                                                    value:
                                                        0,
                                                  ),
                                                );
                                              } else if (snapshot
                                                  .hasError) {
                                                return DashboardTotalSalesBanner(
                                                  theme:
                                                      theme,
                                                  value: 0,
                                                );
                                              } else {
                                                // return Container();
                                                return FutureBuilder<
                                                  List<
                                                    TempProductSaleRecord
                                                  >
                                                >(
                                                  future:
                                                      getProdutRecordsFuture,
                                                  builder: (
                                                    context,
                                                    snapshot,
                                                  ) {
                                                    if (snapshot.connectionState ==
                                                        ConnectionState.waiting) {
                                                      return DashboardTotalSalesBanner(
                                                        theme:
                                                            theme,
                                                        value:
                                                            0,
                                                      );
                                                    } else if (snapshot
                                                        .hasError) {
                                                      return DashboardTotalSalesBanner(
                                                        theme:
                                                            theme,
                                                        value:
                                                            0,
                                                      );
                                                    } else {
                                                      List<
                                                        TempProductSaleRecord
                                                      >
                                                      records =
                                                          snapshot.data!;
                                                      return Column(
                                                        children: [
                                                          FutureBuilder(
                                                            future:
                                                                expensesFuture,
                                                            builder: (
                                                              context,
                                                              snapshot,
                                                            ) {
                                                              return DashboardTotalSalesBanner(
                                                                expenses:
                                                                    snapshot.connectionState ==
                                                                            ConnectionState.waiting
                                                                        ? []
                                                                        : snapshot.hasError
                                                                        ? []
                                                                        : snapshot.data,
                                                                userValue: returnReceiptProvider(
                                                                  context,
                                                                ).getTotalRevenueForSelectedDay(
                                                                  context,
                                                                  mainReceiptss
                                                                      .where(
                                                                        (
                                                                          emp,
                                                                        ) =>
                                                                            emp.staffName ==
                                                                            userGeneral(
                                                                              context,
                                                                            ).name,
                                                                        // localUser?.name,
                                                                      )
                                                                      .toList(),
                                                                  records,
                                                                ),
                                                                currentUser: userGeneral(
                                                                  context,
                                                                ),
                                                                // returnLocalDatabase(
                                                                //   context,
                                                                // ).currentEmployee,
                                                                theme:
                                                                    theme,
                                                                value: returnReceiptProvider(
                                                                  context,
                                                                ).getTotalRevenueForSelectedDay(
                                                                  context,
                                                                  mainReceiptss,
                                                                  records,
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                          // SizedBox(
                                                          //   height:
                                                          //       10,
                                                          // ),

                                                          // Container(
                                                          //   decoration:
                                                          //       BoxDecoration(),
                                                          //   child: Row(
                                                          //     children: [
                                                          //       Column(
                                                          //         crossAxisAlignment:
                                                          //             CrossAxisAlignment.start,
                                                          //         children: [
                                                          //           Text(
                                                          //             'Todays Sales by You',
                                                          //           ),
                                                          //           Text(
                                                          //             '${localUser != null ? returnReceiptProvider(context).getTotalRevenueForSelectedDay(context, mainReceipts.where((emp) => emp.staffName == localUser.name).toList(), records) : 0}',
                                                          //           ),
                                                          //         ],
                                                          //       ),
                                                          //     ],
                                                          //   ),
                                                          // ),
                                                        ],
                                                      );
                                                    }
                                                  },
                                                );
                                              }
                                            },
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
                                                child: FutureBuilder(
                                                  future:
                                                      productsFuture,
                                                  builder: (
                                                    context,
                                                    snapshot,
                                                  ) {
                                                    if (snapshot.connectionState ==
                                                        ConnectionState.waiting) {
                                                      return Shimmer.fromColors(
                                                        baseColor:
                                                            Colors.grey.shade300,
                                                        highlightColor:
                                                            Colors.grey.shade200,
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(
                                                              10,
                                                            ),
                                                            color:
                                                                Colors.grey.shade400,
                                                            border: Border.all(
                                                              color:
                                                                  Colors.grey.shade700,
                                                            ),
                                                          ),

                                                          child: MainInfoTab(
                                                            theme:
                                                                theme,
                                                            icon:
                                                                pulseIconSvg,
                                                            number:
                                                                '0',
                                                            title:
                                                                'All Products',
                                                            action:
                                                                () {},
                                                          ),
                                                        ),
                                                      );
                                                    } else if (snapshot
                                                        .hasError) {
                                                      return MainInfoTab(
                                                        theme:
                                                            theme,
                                                        icon:
                                                            pulseIconSvg,
                                                        number:
                                                            '0',
                                                        title:
                                                            'All Products',
                                                        action:
                                                            () {},
                                                      );
                                                    } else {
                                                      return MainInfoTab(
                                                        theme:
                                                            theme,
                                                        icon:
                                                            pulseIconSvg,
                                                        number:
                                                            '${snapshot.data!.length}',
                                                        title:
                                                            'All Products',
                                                        action: () {
                                                          returnNavProvider(
                                                            context,
                                                            listen:
                                                                false,
                                                          ).navigate(
                                                            1,
                                                          );
                                                        },
                                                      );
                                                    }
                                                  },
                                                ),
                                              ),
                                              Expanded(
                                                child: MainInfoTab(
                                                  theme:
                                                      theme,
                                                  icon:
                                                      productIconSvg,
                                                  number:
                                                      '${mainReceiptss.length}',
                                                  title:
                                                      'Todays Sales',
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
                                            ],
                                          ),
                                          SizedBox(
                                            height: 30,
                                          ),
                                          Column(
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
                                                height: 20,
                                              ),

                                              SizedBox(
                                                width:
                                                    double
                                                        .infinity,
                                                child: LayoutBuilder(
                                                  builder: (
                                                    context,
                                                    constraints,
                                                  ) {
                                                    if (constraints.maxWidth >
                                                        320) {
                                                      return Column(
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
                                                                    'Products',
                                                                action: () {
                                                                  Provider.of<
                                                                    NavProvider
                                                                  >(
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
                                                                          // clearDate();
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
                                                                visible:
                                                                    userGeneral(
                                                                      context,
                                                                    ).role ==
                                                                    'Owner',
                                                                // returnLocalDatabase(
                                                                //   context,
                                                                //   listen:
                                                                //       false,
                                                                // ).currentEmployee?.role ==
                                                                // 'Owner',
                                                                child: ButtonTab(
                                                                  theme:
                                                                      theme,
                                                                  icon:
                                                                      employeesIconSvg,
                                                                  title:
                                                                      'Employees',
                                                                  action: () {
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
                                                                visible:
                                                                    userGeneral(
                                                                      context,
                                                                    ).role ==
                                                                    'Owner',
                                                                // returnLocalDatabase(
                                                                //   context,
                                                                //   listen:
                                                                //       false,
                                                                // ).currentEmployee?.role ==
                                                                // 'Owner',
                                                                child: SizedBox(
                                                                  width:
                                                                      15,
                                                                ),
                                                              ),
                                                              ButtonTab(
                                                                theme:
                                                                    theme,
                                                                icon:
                                                                    expensesIconSvg,
                                                                title:
                                                                    'Expenses',
                                                                action: () async {
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
                                                                          expensesFuture =
                                                                              getExpenses();
                                                                          // clearDate();
                                                                        },
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
                                                                    custBookIconSvg,
                                                                title:
                                                                    'Customers',
                                                                action: () {
                                                                  Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder: (
                                                                        context,
                                                                      ) {
                                                                        return CustomerList();
                                                                      },
                                                                    ),
                                                                  );
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      );
                                                    } else {
                                                      return Column(
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
                                                                    'Products',
                                                                action: () {
                                                                  Provider.of<
                                                                    NavProvider
                                                                  >(
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
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              ButtonTab(
                                                                theme:
                                                                    theme,
                                                                icon:
                                                                    custBookIconSvg,
                                                                title:
                                                                    'Customers',
                                                                action: () {
                                                                  Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder: (
                                                                        context,
                                                                      ) {
                                                                        return CustomerList();
                                                                      },
                                                                    ),
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
                                                                      _,
                                                                    ) {
                                                                      setState(
                                                                        () {
                                                                          mainReceiptFuture =
                                                                              getMainReceipts();
                                                                        },
                                                                      );
                                                                    },
                                                                  );
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              Visibility(
                                                                visible:
                                                                    userGeneral(
                                                                      context,
                                                                    ).role ==
                                                                    'Owner',
                                                                // returnLocalDatabase(
                                                                //   context,
                                                                //   listen:
                                                                //       false,
                                                                // ).currentEmployee!.role ==
                                                                // 'Owner',
                                                                child: ButtonTab(
                                                                  theme:
                                                                      theme,
                                                                  icon:
                                                                      employeesIconSvg,
                                                                  title:
                                                                      'Employees',
                                                                  action: () {
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
                                                                                ).role,
                                                                          );
                                                                        },
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                              Visibility(
                                                                visible:
                                                                    userGeneral(
                                                                      context,
                                                                    ).role ==
                                                                    'Owner',
                                                                // returnLocalDatabase(
                                                                //   context,
                                                                //   listen:
                                                                //       false,
                                                                // ).currentEmployee!.role ==
                                                                // 'Owner',
                                                                child: SizedBox(
                                                                  width:
                                                                      15,
                                                                ),
                                                              ),
                                                              ButtonTab(
                                                                theme:
                                                                    theme,
                                                                icon:
                                                                    reportIconSvg,
                                                                title:
                                                                    'Report',
                                                                action: () {
                                                                  Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder: (
                                                                        context,
                                                                      ) {
                                                                        return ReportPage();
                                                                      },
                                                                    ),
                                                                  );
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      );
                                                    }
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 30,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Visibility(
                          visible:
                              userGeneral(context).role ==
                              'Owner',
                          child: Align(
                            alignment: Alignment(
                              1,
                              isFloatOpen ? 1 : 0.94,
                            ),
                            child: Material(
                              elevation: 2,
                              color: Colors.transparent,
                              child: GestureDetector(
                                onTap: () {
                                  if (isFloatOpen) {
                                    setState(() {
                                      isFloatOpen = false;
                                    });
                                  } else {
                                    setState(() {
                                      isFloatOpen = true;
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
                                                  MainAxisSize
                                                      .min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .center,
                                              children: [
                                                Icon(
                                                  color:
                                                      Colors
                                                          .white,
                                                  size: 16,
                                                  Icons
                                                      .arrow_forward_ios_rounded,
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Column(
                                              mainAxisSize:
                                                  MainAxisSize
                                                      .min,
                                              spacing: 15,
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
                                                MainAxisSize
                                                    .min,
                                            mainAxisAlignment:
                                                MainAxisAlignment
                                                    .center,
                                            children: [
                                              Icon(
                                                size: 16,
                                                color:
                                                    Colors
                                                        .white,
                                                Icons
                                                    .arrow_back_ios_new_rounded,
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
                              context
                                  .watch<AuthService>()
                                  .isLoading,
                          child: returnCompProvider(
                            context,
                          ).showSuccess('Loading'),
                        ),
                        Visibility(
                          visible:
                              context
                                  .watch<AuthService>()
                                  .isLoading,
                          child: returnCompProvider(
                            context,
                          ).showLoader('Loading'),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ],
        );
      } else {
        // return Container();
        return Stack(
          children: [
            Scaffold(
              bottomNavigationBar: MainBottomNav(
                globalKey: _scaffoldKey,
              ),
              key: _scaffoldKey,
              onDrawerChanged: (isOpened) {
                if (!isOpened) {
                  returnNavProvider(
                    context,
                    listen: false,
                  ).closeDrawer();
                }
              },
              drawer: FutureBuilder(
                future: notificationsFuture,
                builder: (context, snapshot) {
                  return MyDrawerWidget(
                    action: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return ConfirmationAlert(
                            theme: theme,
                            message:
                                'You are about to Logout',
                            title: 'Are you Sure?',
                            action: () async {
                              await AuthService().signOut();

                              if (context.mounted) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
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
                    theme: theme,
                    notifications:
                        snapshot.connectionState ==
                                    ConnectionState
                                        .waiting ||
                                snapshot.hasError
                            ? []
                            : snapshot.data!,
                  );
                },
              ),
              body: Stack(
                children: [
                  Column(
                    children: [
                      FutureBuilder(
                        future: notificationsFuture,
                        builder: (context, snapshot) {
                          return TopNavBar(
                            role: userGeneral(context).role,
                            action: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return NotificationsPage();
                                  },
                                ),
                              );
                            },
                            openSideBar: () {
                              _scaffoldKey.currentState
                                  ?.openDrawer();
                              returnNavProvider(
                                context,
                                listen: false,
                              ).setSettings();
                            },
                            theme: theme,
                            notifications:
                                snapshot.connectionState ==
                                            ConnectionState
                                                .waiting ||
                                        snapshot.hasError
                                    ? []
                                    : snapshot.data!,
                          );
                        },
                      ),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () {
                            return refreshAll();
                          },
                          backgroundColor: Colors.white,
                          color:
                              theme
                                  .lightModeColor
                                  .prColor300,
                          displacement: 10,
                          child: SingleChildScrollView(
                            child: SizedBox(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(
                                      horizontal: 15.0,
                                    ),
                                child: Column(
                                  children: [
                                    SizedBox(height: 20),

                                    Column(
                                      children: [
                                        DashboardTotalSalesBanner(
                                          expenses:
                                              expensesLocal,
                                          userValue: returnReceiptProvider(
                                            context,
                                          ).getTotalRevenueForSelectedDay(
                                            context,
                                            returnReceiptProvider(
                                                  context,
                                                ).receipts
                                                .where(
                                                  (emp) =>
                                                      emp.staffName ==
                                                      userGeneral(
                                                        context,
                                                      ).name,
                                                  // localUser?.name,
                                                )
                                                .toList(),
                                            returnReceiptProvider(
                                              context,
                                            ).returnproductsRecordByDayOrWeek(
                                              context,
                                              returnReceiptProvider(
                                                context,
                                              ).produtRecordSalesMain,
                                            ),
                                          ),
                                          currentUser:
                                              userGeneral(
                                                context,
                                              ),
                                          theme: theme,
                                          value: returnReceiptProvider(
                                            context,
                                          ).getTotalRevenueForSelectedDay(
                                            context,
                                            returnReceiptProvider(
                                              context,
                                            ).receipts,
                                            returnReceiptProvider(
                                              context,
                                            ).produtRecordSalesMain,
                                          ),
                                        ),
                                        // SizedBox(
                                        //   height:
                                        //       10,
                                        // ),

                                        // Container(
                                        //   decoration:
                                        //       BoxDecoration(),
                                        //   child: Row(
                                        //     children: [
                                        //       Column(
                                        //         crossAxisAlignment:
                                        //             CrossAxisAlignment.start,
                                        //         children: [
                                        //           Text(
                                        //             'Todays Sales by You',
                                        //           ),
                                        //           Text(
                                        //             '${localUser != null ? returnReceiptProvider(context).getTotalRevenueForSelectedDay(context, mainReceipts.where((emp) => emp.staffName == localUser.name).toList(), records) : 0}',
                                        //           ),
                                        //         ],
                                        //       ),
                                        //     ],
                                        //   ),
                                        // ),
                                      ],
                                    ),

                                    SizedBox(height: 20),
                                    Row(
                                      spacing: 10,
                                      mainAxisAlignment:
                                          MainAxisAlignment
                                              .center,
                                      children: [
                                        Expanded(
                                          child: MainInfoTab(
                                            theme: theme,
                                            icon:
                                                pulseIconSvg,
                                            number:
                                                '${productsLocal.length}',
                                            title:
                                                'All Products',
                                            action: () {
                                              returnNavProvider(
                                                context,
                                                listen:
                                                    false,
                                              ).navigate(1);
                                            },
                                          ),
                                        ),
                                        Expanded(
                                          child: MainInfoTab(
                                            theme: theme,
                                            icon:
                                                productIconSvg,
                                            number:
                                                '${returnReceiptProvider(context).returnOwnReceiptsByDayOrWeek(context, receiptsLocal).length}',
                                            title:
                                                'Todays Sales',
                                            action: () {
                                              returnNavProvider(
                                                context,
                                                listen:
                                                    false,
                                              ).navigate(2);
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 30),
                                    Column(
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              style: TextStyle(
                                                fontSize:
                                                    theme
                                                        .mobileTexts
                                                        .b1
                                                        .fontSize,
                                                fontWeight:
                                                    theme
                                                        .mobileTexts
                                                        .b1
                                                        .fontWeightBold,
                                              ),
                                              'Quick Actions',
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),

                                        SizedBox(
                                          width:
                                              double
                                                  .infinity,
                                          child: LayoutBuilder(
                                            builder: (
                                              context,
                                              constraints,
                                            ) {
                                              if (constraints
                                                      .maxWidth >
                                                  320) {
                                                return Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .center,
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
                                                              'Products',
                                                          action: () {
                                                            Provider.of<
                                                              NavProvider
                                                            >(
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
                                                                    // clearDate();
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
                                                          visible:
                                                              userGeneral(
                                                                context,
                                                              ).role ==
                                                              'Owner',
                                                          // returnLocalDatabase(
                                                          //   context,
                                                          //   listen:
                                                          //       false,
                                                          // ).currentEmployee?.role ==
                                                          // 'Owner',
                                                          child: ButtonTab(
                                                            theme:
                                                                theme,
                                                            icon:
                                                                employeesIconSvg,
                                                            title:
                                                                'Employees',
                                                            action: () {
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
                                                          visible:
                                                              userGeneral(
                                                                context,
                                                              ).role ==
                                                              'Owner',
                                                          // returnLocalDatabase(
                                                          //   context,
                                                          //   listen:
                                                          //       false,
                                                          // ).currentEmployee?.role ==
                                                          // 'Owner',
                                                          child: SizedBox(
                                                            width:
                                                                15,
                                                          ),
                                                        ),
                                                        ButtonTab(
                                                          theme:
                                                              theme,
                                                          icon:
                                                              expensesIconSvg,
                                                          title:
                                                              'Expenses',
                                                          action: () async {
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
                                                                    // expensesFuture =
                                                                    //     getExpenses();
                                                                    // clearDate();
                                                                  },
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
                                                              custBookIconSvg,
                                                          title:
                                                              'Customers',
                                                          action: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (
                                                                  context,
                                                                ) {
                                                                  return CustomerList();
                                                                },
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                );
                                              } else {
                                                return Column(
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
                                                              'Products',
                                                          action: () {
                                                            Provider.of<
                                                              NavProvider
                                                            >(
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
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        ButtonTab(
                                                          theme:
                                                              theme,
                                                          icon:
                                                              custBookIconSvg,
                                                          title:
                                                              'Customers',
                                                          action: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (
                                                                  context,
                                                                ) {
                                                                  return CustomerList();
                                                                },
                                                              ),
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
                                                                _,
                                                              ) {
                                                                setState(
                                                                  () {
                                                                    // mainReceiptFuture =
                                                                    //     getMainReceipts();
                                                                  },
                                                                );
                                                              },
                                                            );
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Visibility(
                                                          visible:
                                                              userGeneral(
                                                                context,
                                                              ).role ==
                                                              'Owner',
                                                          // returnLocalDatabase(
                                                          //   context,
                                                          //   listen:
                                                          //       false,
                                                          // ).currentEmployee!.role ==
                                                          // 'Owner',
                                                          child: ButtonTab(
                                                            theme:
                                                                theme,
                                                            icon:
                                                                employeesIconSvg,
                                                            title:
                                                                'Employees',
                                                            action: () {
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
                                                                          ).role,
                                                                    );
                                                                  },
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                        Visibility(
                                                          visible:
                                                              userGeneral(
                                                                context,
                                                              ).role ==
                                                              'Owner',
                                                          // returnLocalDatabase(
                                                          //   context,
                                                          //   listen:
                                                          //       false,
                                                          // ).currentEmployee!.role ==
                                                          // 'Owner',
                                                          child: SizedBox(
                                                            width:
                                                                15,
                                                          ),
                                                        ),
                                                        ButtonTab(
                                                          theme:
                                                              theme,
                                                          icon:
                                                              reportIconSvg,
                                                          title:
                                                              'Report',
                                                          action: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (
                                                                  context,
                                                                ) {
                                                                  return ReportPage();
                                                                },
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 30),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Visibility(
                    visible:
                        // returnLocalDatabase(
                        //           context,
                        //         ).currentEmployee !=
                        //         null
                        //     ? returnLocalDatabase(
                        //               context,
                        //             )
                        //             .currentEmployee!
                        //             .role ==
                        //         'Owner'
                        //     :
                        userGeneral(context).role ==
                        'Owner',
                    child: Align(
                      alignment: Alignment(
                        1,
                        isFloatOpen ? 1 : 0.94,
                      ),
                      child: Material(
                        elevation: 2,
                        color: Colors.transparent,
                        child: GestureDetector(
                          onTap: () {
                            if (isFloatOpen) {
                              setState(() {
                                isFloatOpen = false;
                              });
                            } else {
                              setState(() {
                                isFloatOpen = true;
                              });
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.fromLTRB(
                              10,
                              15,
                              isFloatOpen ? 30 : 10,
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
                                        Radius.circular(5),
                                    bottomLeft:
                                        Radius.circular(5),
                                  ),
                            ),
                            child: Stack(
                              children: [
                                Visibility(
                                  visible: isFloatOpen,
                                  child: Row(
                                    mainAxisSize:
                                        MainAxisSize.min,
                                    children: [
                                      Column(
                                        mainAxisSize:
                                            MainAxisSize
                                                .min,
                                        mainAxisAlignment:
                                            MainAxisAlignment
                                                .center,
                                        children: [
                                          Icon(
                                            color:
                                                Colors
                                                    .white,
                                            size: 16,
                                            Icons
                                                .arrow_forward_ios_rounded,
                                          ),
                                        ],
                                      ),
                                      SizedBox(width: 10),
                                      Column(
                                        mainAxisSize:
                                            MainAxisSize
                                                .min,
                                        spacing: 15,
                                        children: [
                                          InkWell(
                                            onTap: () async {
                                              openWhatsApp();
                                            },

                                            child: Column(
                                              spacing: 3,
                                              mainAxisSize:
                                                  MainAxisSize
                                                      .min,
                                              children: [
                                                SvgPicture.asset(
                                                  whatsappIconSvg,
                                                  color:
                                                      Colors
                                                          .white,
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
                                              spacing: 3,
                                              mainAxisSize:
                                                  MainAxisSize
                                                      .min,
                                              children: [
                                                Icon(
                                                  size: 17,
                                                  color:
                                                      Colors
                                                          .white,
                                                  Icons
                                                      .phone,
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
                                  visible: !isFloatOpen,
                                  child: GestureDetector(
                                    onTap: () {
                                      openFloat();
                                    },
                                    child: Column(
                                      mainAxisSize:
                                          MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment
                                              .center,
                                      children: [
                                        Icon(
                                          size: 16,
                                          color:
                                              Colors.white,
                                          Icons
                                              .arrow_back_ios_new_rounded,
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
                        context
                            .watch<AuthService>()
                            .isLoading,
                    child: returnCompProvider(
                      context,
                    ).showSuccess('Loading'),
                  ),
                  Visibility(
                    visible:
                        context
                            .watch<AuthService>()
                            .isLoading,
                    child: returnCompProvider(
                      context,
                    ).showLoader('Loading'),
                  ),
                ],
              ),
            ),
          ],
        );
      }
    }
  }
}
