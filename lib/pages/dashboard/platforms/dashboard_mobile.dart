import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
// import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:stockall/classes/temp_notification/temp_notification.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/major/drawer_widget/my_drawer_widget.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/refresh_functions.dart';
import 'package:stockall/constants/subscription/sales_auth.dart';
import 'package:stockall/constants/subscription/subscription_func.dart';
import 'package:stockall/helpers/clean_up_url/clean_up_url.dart';
import 'package:stockall/local_database/new_feature_pop_up_func/new_feature_pop_up_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/auth_screens/auth_screens_page.dart';
import 'package:stockall/pages/customers/customers_list/customer_list.dart';
import 'package:stockall/pages/dashboard/components/button_tab.dart';
import 'package:stockall/pages/dashboard/components/expiry_sub_popup_desktop.dart';
import 'package:stockall/pages/dashboard/components/main_bottom_nav.dart';
import 'package:stockall/pages/dashboard/components/main_info_tab.dart';
import 'package:stockall/pages/dashboard/components/store_keeper_department_switch_widget.dart';
import 'package:stockall/pages/dashboard/components/top_nav_bar.dart';
import 'package:stockall/pages/dashboard/components/total_sales_banner.dart';
import 'package:stockall/pages/employees/employee_list/employee_list_page.dart';
import 'package:stockall/pages/expenses/expenses_page.dart';
import 'package:stockall/pages/invoices/invoice_list/invoice_list_page.dart';
import 'package:stockall/pages/notifications/notifications_page.dart';
import 'package:stockall/pages/production/production_page.dart';
import 'package:stockall/pages/report/report_page.dart';
import 'package:stockall/services/auth_service.dart';

class DashboardMobile extends StatefulWidget {
  // final int? shopId;
  const DashboardMobile({super.key});

  @override
  State<DashboardMobile> createState() =>
      _DashboardMobileState();
}

class _DashboardMobileState extends State<DashboardMobile> {
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

  bool isLoading = false;
  bool showSuccess = false;

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
    ).fetchRecentNotifications(
      returnShopProvider().userShop()?.shopId ?? 1,
    );

    return tempGet;
  }

  TextEditingController emailController =
      TextEditingController();
  TextEditingController passwordController =
      TextEditingController();
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      NewFeaturePopUpFunc().checkIfIsNew(context: context);
      if (!returnReceiptProvider(
        context,
        listen: false,
      ).isLoaded) {
        await RefreshFunctions(context).refreshAll(context);
        returnReceiptProvider(
          context,
          listen: false,
        ).load(true);
        await mainLocalLog('Data Loaded');
      }
    });
    // loadSuggestions();
    notificationsFuture = fetchNotifications();
  }

  late Future<List<TempUserClass>> employeesFuture;
  Future<List<TempUserClass>> getEmployees() {
    var users =
        returnUserProvider(
          context,
          listen: false,
        ).fetchUsersByShop();

    return users;
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    var productsLocal = returnData().productList();
    if (returnShopProvider().userShop() == null) {
      return Scaffold(
        body: returnCompProvider(
          context,
          listen: false,
        ).showLoader(message: 'Loading User Data'),
      );
    } else {
      if (!returnReceiptProvider(context).isLoaded) {
        return returnCompProvider(
          context,
          listen: false,
        ).showLoader(message: 'Loading Shop Data');
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
              drawer: MyDrawerWidget(
                action: () {
                  showDialog(
                    context: context,
                    builder: (confirmContext) {
                      return ConfirmationAlert(
                        theme: theme,
                        message: 'You are about to Logout',
                        title: 'Are you Sure?',
                        action: () async {
                          var res = await AuthService()
                              .signOut(
                                context: context,
                                allowLogout: false,
                              );
                          if (res == 1) {
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
                        ).notifications().isEmpty
                        ? []
                        : returnNotificationProvider(
                          context,
                        ).notifications(),
              ),
              body: Stack(
                children: [
                  Column(
                    children: [
                      FutureBuilder(
                        future: notificationsFuture,
                        builder: (context, snapshot) {
                          return TopNavBar(
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
                          );
                        },
                      ),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            return await RefreshFunctions(
                              context,
                            ).refreshAll(context);
                          },
                          backgroundColor: Colors.white,
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
                                SizedBox(height: 10),
                                Visibility(
                                  visible: !isStoreKeeper(),
                                  child: DashboardTotalSalesBanner(
                                    userValue:
                                        returnReceiptProvider(
                                          context,
                                        ).getTotalRevenueForSelectedDayAll(
                                          staffId:
                                              userGeneral(
                                                context,
                                              ).userId,
                                        ),
                                    theme: theme,
                                    value:
                                        returnReceiptProvider(
                                          context,
                                        ).getTotalRevenueForSelectedDay(),
                                  ),
                                ),
                                SizedBox(height: 20),
                                StoreKeeperDepartmentSwitchWidget(),
                                Row(
                                  // spacing: 10,
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .center,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: MainInfoTab(
                                              theme: theme,
                                              icon:
                                                  productIconSvg,
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
                                          SizedBox(
                                            width: 10,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Visibility(
                                      visible:
                                          isStoreKeeper(),
                                      child: Expanded(
                                        child: Row(
                                          children: [
                                            ButtonTab(
                                              theme: theme,
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
                                          ],
                                        ),
                                      ),
                                    ),
                                    Visibility(
                                      visible:
                                          !isStoreKeeper(),
                                      child: Expanded(
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: MainInfoTab(
                                                theme:
                                                    theme,
                                                icon:
                                                    salesIconSvg,
                                                number:
                                                    '${returnReceiptProvider(context).returnOwnReceiptsByDayOrWeek().length}',
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
                                                      mobileScreenSmall &&
                                                  !isStoreKeeper(),
                                              child:
                                                  SizedBox(
                                                    width:
                                                        10,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Visibility(
                                      visible:
                                          screenWidth(
                                                context,
                                              ) >
                                              mobileScreenSmall &&
                                          !isStoreKeeper(),
                                      child: Expanded(
                                        child: SubWrapper(
                                          isVisible:
                                              !SalesAuthAction()
                                                  .invoiceManagementAction(
                                                    context:
                                                        context,
                                                  ),
                                          mainWidget: MainInfoTab(
                                            theme: theme,
                                            icon:
                                                custBookIconSvg,
                                            number:
                                                '${returnInvoicesProvider(context: context).returnUnpaidInvoices().length}',
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
                                SizedBox(height: 20),
                                Visibility(
                                  visible: !isStoreKeeper(),
                                  child: Column(
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
                                      SizedBox(height: 15),

                                      SizedBox(
                                        width:
                                            double.infinity,
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
                                                spacing: 10,
                                                children: [
                                                  Row(
                                                    spacing:
                                                        10,
                                                    children: [
                                                      Builder(
                                                        builder: (
                                                          context,
                                                        ) {
                                                          if (authorization(
                                                                authorized:
                                                                    Authorizations().viewProductions,
                                                              ) &&
                                                              returnShopProvider().userShop()?.manageProductions ==
                                                                  true) {
                                                            return ButtonTab(
                                                              theme:
                                                                  theme,
                                                              iconWidget: Icon(
                                                                color:
                                                                    theme.lightModeColor.secColor200,
                                                                size:
                                                                    21,
                                                                Icons.view_in_ar_rounded,
                                                              ),
                                                              title:
                                                                  'Production',
                                                              action: () {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder: (
                                                                      context,
                                                                    ) {
                                                                      return ProductionPage();
                                                                    },
                                                                  ),
                                                                );
                                                              },
                                                            );
                                                          } else {
                                                            return ButtonTab(
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
                                                            );
                                                          }
                                                        },
                                                      ),
                                                      ButtonTab(
                                                        theme:
                                                            theme,
                                                        iconWidget: Icon(
                                                          size:
                                                              23,
                                                          color:
                                                              theme.lightModeColor.prColor250,
                                                          Icons.people_alt_outlined,
                                                        ),
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
                                                          iconColor:
                                                              theme.lightModeColor.prColor250,
                                                          title:
                                                              'Staffs',
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
                                                        ),
                                                        child: SizedBox(
                                                          width:
                                                              10,
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
                                                            10,
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
                                              );
                                            } else {
                                              return Column(
                                                spacing: 10,
                                                children: [
                                                  Row(
                                                    spacing:
                                                        10,
                                                    children: [
                                                      Builder(
                                                        builder: (
                                                          context,
                                                        ) {
                                                          if (authorization(
                                                                authorized:
                                                                    Authorizations().viewProductions,
                                                              ) &&
                                                              returnShopProvider().userShop()?.manageProductions ==
                                                                  true) {
                                                            return ButtonTab(
                                                              theme:
                                                                  theme,
                                                              iconWidget: Icon(
                                                                color:
                                                                    theme.lightModeColor.secColor200,
                                                                size:
                                                                    21,
                                                                Icons.view_in_ar_rounded,
                                                              ),
                                                              title:
                                                                  'Production',
                                                              action: () {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder: (
                                                                      context,
                                                                    ) {
                                                                      return ProductionPage();
                                                                    },
                                                                  ),
                                                                );
                                                              },
                                                            );
                                                          } else {
                                                            return ButtonTab(
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
                                                            );
                                                          }
                                                        },
                                                      ),
                                                      ButtonTab(
                                                        theme:
                                                            theme,
                                                        iconWidget: Icon(
                                                          size:
                                                              23,
                                                          color:
                                                              theme.lightModeColor.prColor250,
                                                          Icons.people_alt_outlined,
                                                        ),
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
                                                  Row(
                                                    children: [
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
                                                            10,
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
                                                  Row(
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
                                                              'Staffs',
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
                                                ],
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 30),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Visibility(
                    visible:
                        appVersionMobile !=
                            returnAppVersionProvider(
                              context,
                            ).appVersion?.mobileVersion &&
                        returnAppVersionProvider(
                              context,
                            ).isUpdated ==
                            false,
                    child: Align(
                      alignment: Alignment(0, -0.8),
                      child: Material(
                        elevation: 2,
                        color: Colors.transparent,
                        child: Container(
                          width: 450,
                          padding: EdgeInsets.fromLTRB(
                            15,
                            15,
                            15,
                            30,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(
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
                                BorderRadius.circular(5),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                spacing: 10,
                                mainAxisSize:
                                    MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
                                children: [
                                  Opacity(
                                    opacity: 0,
                                    child: IconButton(
                                      mouseCursor:
                                          SystemMouseCursors
                                              .click,
                                      onPressed: () {},
                                      icon: Icon(
                                        Icons.clear,
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
                                    mouseCursor:
                                        SystemMouseCursors
                                            .click,
                                    onPressed: () {
                                      returnAppVersionProvider(
                                        context,
                                        listen: false,
                                      ).toggleUpdated(true);
                                    },
                                    icon: Icon(Icons.clear),
                                  ),
                                ],
                              ),
                              Text(
                                textAlign: TextAlign.center,
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
                                visible: kIsWeb,
                                child: Column(
                                  children: [
                                    SizedBox(height: 10),
                                    Text(
                                      textAlign:
                                          TextAlign.center,
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
                                  ],
                                ),
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
                                                theme
                                                    .lightModeColor
                                                    .prColor300,
                                          ),
                                          child: InkWell(
                                            mouseCursor:
                                                SystemMouseCursors
                                                    .click,
                                            onTap: () async {
                                              setState(() {
                                                isUpdateLodaingWeb =
                                                    true;
                                              });
                                              performRestart();
                                            },
                                            child: Container(
                                              padding:
                                                  EdgeInsets.symmetric(
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
                                                ).platform !=
                                                TargetPlatform
                                                    .iOS),
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
                                                theme
                                                    .lightModeColor
                                                    .prColor300,
                                          ),
                                          child: InkWell(
                                            mouseCursor:
                                                SystemMouseCursors
                                                    .click,
                                            onTap: () async {
                                              setState(() {
                                                isUpdateLodaingMobile =
                                                    true;
                                              });
                                              downloadApkFromApp(
                                                context:
                                                    context,
                                              );
                                              setState(() {
                                                isUpdateLodaingMobile =
                                                    false;
                                              });
                                            },
                                            child: Container(
                                              padding:
                                                  EdgeInsets.symmetric(
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
                                            Theme.of(
                                                  context,
                                                ).platform !=
                                                TargetPlatform
                                                    .iOS),
                                    child: SizedBox(
                                      width: 10,
                                    ),
                                  ),
                                  Visibility(
                                    visible:
                                        kIsWeb &&
                                        Theme.of(
                                              context,
                                            ).platform !=
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
                                                theme
                                                    .lightModeColor
                                                    .prColor300,
                                          ),
                                          child: InkWell(
                                            mouseCursor:
                                                SystemMouseCursors
                                                    .click,
                                            onTap: () async {
                                              setState(() {
                                                isUpdateLodaingWeb =
                                                    true;
                                              });
                                              performRestart();
                                            },
                                            child: Container(
                                              padding:
                                                  EdgeInsets.symmetric(
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
                  ExpirySubPopUpDesktop(),
                  Visibility(
                    visible: authorization(
                      authorized:
                          Authorizations().contactStockall,
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
                                            mouseCursor:
                                                SystemMouseCursors
                                                    .click,
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
                                            mouseCursor:
                                                SystemMouseCursors
                                                    .click,
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
                        appVersionDesktop !=
                            returnAppVersionProvider(
                              context,
                            ).appVersion?.desktopVersion &&
                        returnAppVersionProvider(
                              context,
                            ).isUpdated ==
                            false,
                    child: Align(
                      alignment: Alignment(0, -0.8),
                      child: Material(
                        elevation: 2,
                        color: Colors.transparent,
                        child: Container(
                          width: 320,
                          padding: EdgeInsets.fromLTRB(
                            15,
                            15,
                            15,
                            30,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(
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
                                BorderRadius.circular(5),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                spacing: 10,
                                mainAxisSize:
                                    MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
                                children: [
                                  Opacity(
                                    opacity: 0,
                                    child: IconButton(
                                      mouseCursor:
                                          SystemMouseCursors
                                              .click,
                                      onPressed: () {},
                                      icon: Icon(
                                        Icons.clear,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    style: TextStyle(
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                    'APP UPDATE AVAILABLE',
                                  ),
                                  IconButton(
                                    mouseCursor:
                                        SystemMouseCursors
                                            .click,
                                    onPressed: () {
                                      returnAppVersionProvider(
                                        context,
                                        listen: false,
                                      ).toggleUpdated(true);
                                    },
                                    icon: Icon(Icons.clear),
                                  ),
                                ],
                              ),
                              Text(
                                textAlign: TextAlign.center,
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
                                visible: kIsWeb,
                                child: Column(
                                  children: [
                                    SizedBox(height: 10),
                                    Text(
                                      textAlign:
                                          TextAlign.center,
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
                                  ],
                                ),
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
                                                theme
                                                    .lightModeColor
                                                    .prColor300,
                                          ),
                                          child: InkWell(
                                            mouseCursor:
                                                SystemMouseCursors
                                                    .click,
                                            onTap: () async {
                                              setState(() {
                                                isUpdateLodaingWeb =
                                                    true;
                                              });
                                              performRestart();
                                            },
                                            child: Container(
                                              padding:
                                                  EdgeInsets.symmetric(
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
                                                TargetPlatform
                                                    .android),
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
                                                theme
                                                    .lightModeColor
                                                    .prColor300,
                                          ),
                                          child: InkWell(
                                            mouseCursor:
                                                SystemMouseCursors
                                                    .click,
                                            onTap: () async {
                                              setState(() {
                                                isUpdateLodaingMobile =
                                                    true;
                                              });
                                              downloadApkFromApp(
                                                context:
                                                    context,
                                              );
                                              setState(() {
                                                isUpdateLodaingMobile =
                                                    false;
                                              });
                                            },
                                            child: Container(
                                              padding:
                                                  EdgeInsets.symmetric(
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
                                                TargetPlatform
                                                    .android),
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
                                                theme
                                                    .lightModeColor
                                                    .prColor300,
                                          ),
                                          child: InkWell(
                                            mouseCursor:
                                                SystemMouseCursors
                                                    .click,
                                            onTap: () async {
                                              setState(() {
                                                isUpdateLodaingWeb =
                                                    true;
                                              });
                                              performRestart();
                                            },
                                            child: Container(
                                              padding:
                                                  EdgeInsets.symmetric(
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
                    ).showLoader(message: 'Loading'),
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
