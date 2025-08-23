import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
// import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:stockall/classes/temp_expenses_class.dart';
import 'package:stockall/classes/temp_main_receipt.dart';
import 'package:stockall/classes/temp_notification.dart';
import 'package:stockall/classes/temp_product_class.dart';
import 'package:stockall/classes/temp_product_sale_record.dart';
import 'package:stockall/classes/temp_shop_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/major/desktop_page_container.dart';
import 'package:stockall/components/major/my_drawer_widget.dart';
import 'package:stockall/components/major/right_side_bar.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/helpers/clean_up_url.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/auth_screens/auth_screens_page.dart';
import 'package:stockall/pages/dashboard/components/button_tab.dart';
import 'package:stockall/pages/dashboard/components/main_info_tab.dart';
import 'package:stockall/pages/dashboard/components/top_nav_bar.dart';
import 'package:stockall/pages/dashboard/components/total_sales_banner.dart';
import 'package:stockall/pages/employees/employee_list/employee_list_page.dart';
import 'package:stockall/pages/expenses/expenses_page.dart';
import 'package:stockall/pages/notifications/notifications_page.dart';
import 'package:stockall/pages/report/report_page.dart';
import 'package:stockall/pages/sales/make_sales/page1/make_sales_page.dart';
import 'package:stockall/pages/sales/total_sales/total_sales_page.dart';
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
    returnUserProvider(
      context,
      listen: false,
    ).fetchCurrentUser(context);
    getProducts();
    clearDate();
    fetchNotifications();
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
        return returnCompProvider(
          context,
          listen: false,
        ).showLoader('Loading');
      } else {
        // return Container();
        return Row(
          spacing: 15,
          children: [
            MyDrawerWidget(
              action: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return ConfirmationAlert(
                      theme: theme,
                      message: 'You are about to Logout',
                      title: 'Are you Sure?',
                      action: () async {
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
                        if (context.mounted) {
                          await AuthService().signOut(
                            context,
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
                      key: _scaffoldKey,
                      body: Stack(
                        children: [
                          Column(
                            children: [
                              FutureBuilder(
                                future: notificationsFuture,
                                builder: (
                                  context,
                                  snapshot,
                                ) {
                                  return TopNavBar(
                                    refreshAction:
                                        refreshAll,
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
                                      );
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
                                        snapshot.connectionState ==
                                                    ConnectionState
                                                        .waiting ||
                                                snapshot
                                                    .hasError
                                            ? []
                                            : snapshot
                                                .data!,
                                  );
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
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(
                                          horizontal: 15.0,
                                        ),
                                    child: ListView(
                                      children: [
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          spacing: 15,
                                          children: [
                                            Expanded(
                                              child: DashboardTotalSalesBanner(
                                                expenses:
                                                    expensesLocal,
                                                userValue: returnReceiptProvider(
                                                  context,
                                                ).getTotalRevenueForSelectedDay(
                                                  context,
                                                  returnReceiptProvider(
                                                        context,
                                                      )
                                                      .receipts
                                                      .where(
                                                        (
                                                          emp,
                                                        ) =>
                                                            emp.staffName ==
                                                            userGeneral(
                                                              context,
                                                            ).name,
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
                                                theme:
                                                    theme,
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
                                            ),
                                            Material(
                                              elevation: 2,
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
                                                      theme
                                                          .lightModeColor
                                                          .prColor300,
                                                  borderRadius:
                                                      BorderRadius.circular(
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
                                            Expanded(
                                              child: MainInfoTab(
                                                theme:
                                                    theme,
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
                                                  ).navigate(
                                                    2,
                                                  );
                                                },
                                              ),
                                            ),
                                            Visibility(
                                              visible:
                                                  screenWidth(
                                                    context,
                                                  ) >
                                                  tabletScreen,
                                              child: Expanded(
                                                child: MainInfoTab(
                                                  theme:
                                                      theme,
                                                  icon:
                                                      productIconSvg,
                                                  number:
                                                      '${returnExpensesProvider(context).returnExpensesByDayOrWeek(context, returnExpensesProvider(context).expenses).length}',
                                                  title:
                                                      'Todays Expenses',
                                                  action: () {
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
                                            ),
                                            Expanded(
                                              child: MainInfoTab(
                                                theme:
                                                    theme,
                                                icon:
                                                    productIconSvg,
                                                number:
                                                    '${returnReceiptProvider(context).receipts.where((rec) => rec.isInvoice).length}',
                                                title:
                                                    'Total Invoice',
                                                action: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (
                                                        context,
                                                      ) {
                                                        return TotalSalesPage(
                                                          isInvoice:
                                                              true,
                                                        );
                                                      },
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 20,
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
                                              height: 15,
                                            ),

                                            SizedBox(
                                              width:
                                                  double
                                                      .infinity,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .center,
                                                spacing: 15,
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
                                                          context:
                                                              context,
                                                        ),
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
                                                        visible: authorization(
                                                          authorized:
                                                              Authorizations().employeePage,
                                                          context:
                                                              context,
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
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (
                                                                context,
                                                              ) {
                                                                return TotalSalesPage(
                                                                  isInvoice:
                                                                      true,
                                                                );
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
                              context: context,
                            ),
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
                                                        Colors.white,
                                                    size:
                                                        16,
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
                                !returnShopProvider(
                                  context,
                                ).isUpdated,
                            child: Align(
                              alignment: Alignment(0, -0.8),
                              child: Material(
                                elevation: 2,
                                color: Colors.transparent,
                                child: Container(
                                  width: 320,
                                  padding:
                                      EdgeInsets.fromLTRB(
                                        15,
                                        15,
                                        15,
                                        30,
                                      ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            const Color.fromARGB(
                                              84,
                                              0,
                                              0,
                                              0,
                                            ),
                                        blurRadius: 20,
                                        spreadRadius: 10,
                                      ),
                                    ],
                                    borderRadius:
                                        BorderRadius.circular(
                                          5,
                                        ),
                                  ),
                                  child: Column(
                                    mainAxisSize:
                                        MainAxisSize.min,
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
                                            opacity: 0,
                                            child: IconButton(
                                              onPressed:
                                                  () {},
                                              icon: Icon(
                                                Icons.clear,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            style: TextStyle(
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                            ),
                                            'APP UPDATE AVAILABLE',
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              returnShopProvider(
                                                context,
                                                listen:
                                                    false,
                                              ).toggleUpdated(
                                                true,
                                              );
                                            },
                                            icon: Icon(
                                              Icons.clear,
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
                                      SizedBox(height: 10),
                                      Text(
                                        textAlign:
                                            TextAlign
                                                .center,
                                        style: TextStyle(
                                          color:
                                              theme
                                                  .lightModeColor
                                                  .secColor100,
                                          fontSize:
                                              theme
                                                  .mobileTexts
                                                  .b3
                                                  .fontSize,
                                        ),
                                        'Note: If you decide to update web, You might need to refresh more than twice before the update can relfect',
                                      ),
                                      SizedBox(height: 15),
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
                                                    TargetPlatform
                                                        .iOS,
                                            child: Expanded(
                                              child: Material(
                                                color:
                                                    Colors
                                                        .transparent,
                                                child: Ink(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          5,
                                                        ),
                                                    color:
                                                        theme.lightModeColor.prColor300,
                                                  ),
                                                  child: InkWell(
                                                    onTap: () async {
                                                      setState(() {
                                                        isUpdateLodaingWeb =
                                                            true;
                                                      });
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
                                                    Theme.of(
                                                          context,
                                                        ).platform ==
                                                        TargetPlatform.android),
                                            child: Expanded(
                                              child: Material(
                                                color:
                                                    Colors
                                                        .transparent,
                                                child: Ink(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          5,
                                                        ),
                                                    color:
                                                        theme.lightModeColor.prColor300,
                                                  ),
                                                  child: InkWell(
                                                    onTap: () async {
                                                      setState(() {
                                                        isUpdateLodaingMobile =
                                                            true;
                                                      });
                                                      downloadApkFromApp();
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
                                                                                ).platform ==
                                                                                TargetPlatform.android
                                                                        ? 'Download App'
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
                                                    Theme.of(
                                                          context,
                                                        ).platform ==
                                                        TargetPlatform.android),
                                            child: SizedBox(
                                              width: 10,
                                            ),
                                          ),
                                          Visibility(
                                            visible:
                                                kIsWeb &&
                                                Theme.of(
                                                      context,
                                                    ).platform ==
                                                    TargetPlatform
                                                        .android,
                                            child: Expanded(
                                              child: Material(
                                                color:
                                                    Colors
                                                        .transparent,
                                                child: Ink(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          5,
                                                        ),
                                                    color:
                                                        theme.lightModeColor.prColor300,
                                                  ),
                                                  child: InkWell(
                                                    onTap: () async {
                                                      setState(() {
                                                        isUpdateLodaingWeb =
                                                            true;
                                                      });
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
                ),
              ),
            ),
            RightSideBar(theme: theme),
          ],
        );
      }
    }
  }
}
