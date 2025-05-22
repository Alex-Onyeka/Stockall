import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stockitt/classes/temp_main_receipt.dart';
import 'package:stockitt/classes/temp_notification.dart';
import 'package:stockitt/classes/temp_product_sale_record.dart';
import 'package:stockitt/classes/temp_shop_class.dart';
import 'package:stockitt/classes/temp_user_class.dart';
import 'package:stockitt/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockitt/components/alert_dialogues/info_alert.dart';
import 'package:stockitt/components/buttons/main_button_p.dart';
import 'package:stockitt/components/major/empty_widget_display_only.dart';
import 'package:stockitt/components/major/my_drawer_widget.dart';
import 'package:stockitt/constants/constants_main.dart';
import 'package:stockitt/main.dart';
import 'package:stockitt/pages/authentication/auth_screens/auth_screens_page.dart';
import 'package:stockitt/pages/authentication/components/email_text_field.dart';
import 'package:stockitt/pages/customers/customers_list/customer_list.dart';
import 'package:stockitt/pages/dashboard/components/button_tab.dart';
import 'package:stockitt/pages/dashboard/components/main_bottom_nav.dart';
import 'package:stockitt/pages/dashboard/components/main_info_tab.dart';
import 'package:stockitt/pages/dashboard/components/top_nav_bar.dart';
import 'package:stockitt/pages/dashboard/components/total_sales_banner.dart';
import 'package:stockitt/pages/employees/employee_list/employee_list_page.dart';
import 'package:stockitt/pages/expenses/expenses_page.dart';
import 'package:stockitt/pages/notifications/notifications_page.dart';
import 'package:stockitt/pages/report/report_page.dart';
import 'package:stockitt/providers/nav_provider.dart';
import 'package:stockitt/services/auth_service.dart';

class DashboardMobile extends StatefulWidget {
  const DashboardMobile({super.key});

  @override
  State<DashboardMobile> createState() =>
      _DashboardMobileState();
}

class _DashboardMobileState extends State<DashboardMobile> {
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();
  late TempShopClass shop;

  Future<List<TempMainReceipt>> getMainReceipts() {
    var tempReceipts = returnReceiptProvider(
      context,
      listen: false,
    ).loadReceipts(
      returnShopProvider(
        context,
        listen: false,
      ).userShop!.shopId!,
    );

    return tempReceipts;
  }

  bool isLoading = false;
  bool showSuccess = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    notificationsFuture = fetchNotifications();
    localUserFuture = getUserEmp();
  }

  late Future<List<TempMainReceipt>> mainReceiptFuture;

  void clearDate() {
    returnReceiptProvider(
      context,
      listen: false,
    ).clearReceiptDate();
  }

  late Future<List<TempNotification>> notificationsFuture;

  Future<List<TempNotification>>
  fetchNotifications() async {
    var tempGet = await returnNotificationProvider(
      context,
      listen: false,
    ).fetchRecentNotifications(
      returnShopProvider(
        context,
        listen: false,
      ).userShop!.shopId!,
    );

    return tempGet;
  }

  late Future<List<TempProductSaleRecord>>
  getProdutRecordsFuture;
  Future<List<TempProductSaleRecord>>
  getProductSalesRecord() async {
    var tempRecords = await returnReceiptProvider(
      context,
      listen: false,
    ).loadProductSalesRecord(
      returnShopProvider(
        context,
        listen: false,
      ).userShop!.shopId!,
    );

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

  Future<TempUserClass?> getUserEmp() async {
    var emp =
        await returnLocalDatabase(
          context,
          listen: false,
        ).getUser();
    return emp;
  }

  late Future<TempUserClass?> localUserFuture;

  Future<TempUserClass?> fetchUserFromDatabase(
    String email,
    String authId,
  ) async {
    var tempUser = await returnUserProvider(
      context,
      listen: false,
    ).fetchUserByEmailAndAuthId(email, authId);

    return tempUser;
  }

  TextEditingController emailController =
      TextEditingController();
  TextEditingController passwordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    mainReceiptFuture = getMainReceipts();
    getProdutRecordsFuture = getProductSalesRecord();
    notificationsFuture = fetchNotifications();
    localUserFuture = getUserEmp();
    shop =
        returnShopProvider(
          context,
          listen: false,
        ).userShop!;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      clearDate();
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return FutureBuilder(
      future: localUserFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return Scaffold(
            body: returnCompProvider(
              context,
              listen: false,
            ).showLoader('Loading'),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: EmptyWidgetDisplayOnly(
              title: 'An Error Occured',
              subText:
                  'Please check your internet and try again',
              theme: theme,
              height: 30,
              icon: Icons.clear,
            ),
          );
        } else {
          TempUserClass? localUser = snapshot.data;
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
                drawer: FutureBuilder<
                  List<TempNotification>
                >(
                  future: notificationsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return MyDrawerWidget(
                        role: '',
                        action: () {},
                        theme: theme,
                        notifications: [],
                      );
                    } else if (snapshot.hasError) {
                      return MyDrawerWidget(
                        role: '',
                        action: () {},
                        theme: theme,
                        notifications: [],
                      );
                    } else {
                      List<TempNotification> notifications =
                          snapshot.data!;

                      return MyDrawerWidget(
                        role:
                            localUser != null
                                ? localUser.role
                                : '',
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
                                    returnLocalDatabase(
                                      context,
                                      listen: false,
                                    ).deleteUser();
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
                        height: 35,
                      );
                    } else {
                      var mainReceipts =
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
                                builder: (
                                  context,
                                  snapshot,
                                ) {
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
                                      subText:
                                          shop.shopAddress ??
                                          shop.email,
                                      title: shop.name,
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
                                      subText:
                                          shop.shopAddress ??
                                          shop.email,
                                      title: shop.name,
                                    );
                                  } else {
                                    List<TempNotification>
                                    notifications =
                                        snapshot.data!;

                                    return TopNavBar(
                                      role:
                                          localUser != null
                                              ? localUser
                                                  .role
                                              : '',
                                      action: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (
                                              context,
                                            ) {
                                              return NotificationsPage(
                                                notifications:
                                                    notifications,
                                              );
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
                                      subText:
                                          shop.shopAddress ==
                                                  null
                                              ? shop.email
                                              : shop
                                                  .shopAddress!
                                                  .isEmpty
                                              ? shop.email
                                              : shop
                                                  .shopAddress!,
                                      title: shop.name,
                                    );
                                  }
                                },
                              ),

                              Expanded(
                                child: SingleChildScrollView(
                                  child: SizedBox(
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.symmetric(
                                            horizontal:
                                                30.0,
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
                                                        1000,
                                                  ),
                                                );
                                              } else if (snapshot
                                                  .hasError) {
                                                return DashboardTotalSalesBanner(
                                                  theme:
                                                      theme,
                                                  value:
                                                      0000,
                                                );
                                              } else {
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
                                                            1000,
                                                      );
                                                    } else if (snapshot
                                                        .hasError) {
                                                      return DashboardTotalSalesBanner(
                                                        theme:
                                                            theme,
                                                        value:
                                                            0000,
                                                      );
                                                    } else {
                                                      List<
                                                        TempProductSaleRecord
                                                      >
                                                      records =
                                                          snapshot.data!;
                                                      return InkWell(
                                                        onTap: () {
                                                          print(
                                                            returnLocalDatabase(
                                                              context,
                                                              listen:
                                                                  false,
                                                            ).currentEmployee!.name,
                                                          );
                                                        },

                                                        child: DashboardTotalSalesBanner(
                                                          theme:
                                                              theme,
                                                          value: returnReceiptProvider(
                                                            context,
                                                          ).getTotalRevenueForSelectedDay(
                                                            context,
                                                            mainReceipts,
                                                            records,
                                                          ),
                                                        ),
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
                                                  future: returnData(
                                                    context,
                                                    listen:
                                                        false,
                                                  ).getProducts(
                                                    shop.shopId!,
                                                  ),
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
                                                      '${mainReceipts.length}',
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
                                                child: Wrap(
                                                  alignment:
                                                      WrapAlignment
                                                          .center,
                                                  runAlignment:
                                                      WrapAlignment
                                                          .center,
                                                  direction:
                                                      Axis.horizontal,
                                                  runSpacing:
                                                      15,
                                                  spacing:
                                                      15,
                                                  crossAxisAlignment:
                                                      WrapCrossAlignment
                                                          .center,
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
                                                    ButtonTab(
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
                                                                    localUser !=
                                                                            null
                                                                        ? localUser.userId!
                                                                        : '',
                                                                role:
                                                                    localUser !=
                                                                            null
                                                                        ? localUser.role
                                                                        : '',
                                                              );
                                                            },
                                                          ),
                                                        );
                                                      },
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
                                                              return ExpensesPage();
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
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
              snapshot.connectionState ==
                      ConnectionState.waiting
                  ? returnCompProvider(
                    context,
                    listen: false,
                  ).showLoader('Loading')
                  : Visibility(
                    visible: snapshot.data == null,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 1,
                        sigmaY: 1,
                      ),
                      child: Stack(
                        children: [
                          Scaffold(
                            backgroundColor:
                                Colors.transparent,
                            body: InkWell(
                              onTap:
                                  () =>
                                      FocusManager
                                          .instance
                                          .primaryFocus
                                          ?.unfocus(),
                              child: Container(
                                width:
                                    MediaQuery.of(
                                      context,
                                    ).size.width,
                                height:
                                    MediaQuery.of(
                                      context,
                                    ).size.height,
                                color: const Color.fromARGB(
                                  126,
                                  0,
                                  0,
                                  0,
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .center,
                                  children: [
                                    Container(
                                      width:
                                          MediaQuery.of(
                                            context,
                                          ).size.width *
                                          0.85,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(
                                              5,
                                            ),
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                const Color.fromARGB(
                                                  31,
                                                  0,
                                                  0,
                                                  0,
                                                ),
                                            blurRadius: 5,
                                          ),
                                        ],
                                      ),
                                      padding:
                                          EdgeInsetsDirectional.symmetric(
                                            horizontal: 30,
                                            vertical: 20,
                                          ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment
                                                .center,
                                        children: [
                                          Column(
                                            children: [
                                              GestureDetector(
                                                onTap:
                                                    () =>
                                                        AuthService().signOut(),
                                                child: Text(
                                                  style: TextStyle(
                                                    fontSize:
                                                        theme.mobileTexts.h2.fontSize,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                  'Login',
                                                ),
                                              ),
                                              Text(
                                                style: TextStyle(
                                                  fontSize:
                                                      theme
                                                          .mobileTexts
                                                          .b2
                                                          .fontSize,
                                                  fontWeight:
                                                      FontWeight
                                                          .normal,
                                                ),
                                                'This is your staff account Login',
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 15,
                                          ),
                                          EmailTextField(
                                            controller:
                                                emailController,
                                            theme: theme,
                                            isEmail: true,
                                            hint:
                                                'Enter Email',
                                            title: 'Email',
                                          ),

                                          SizedBox(
                                            height: 20,
                                          ),
                                          EmailTextField(
                                            controller:
                                                passwordController,
                                            theme: theme,
                                            isEmail: false,
                                            hint:
                                                'Enter Password',
                                            title:
                                                'Password',
                                          ),
                                          SizedBox(
                                            height: 30,
                                          ),
                                          MainButtonP(
                                            themeProvider:
                                                theme,
                                            action: () async {
                                              bool
                                              isValidEmail(
                                                String
                                                email,
                                              ) {
                                                final emailRegex =
                                                    RegExp(
                                                      r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$",
                                                    );
                                                return emailRegex
                                                    .hasMatch(
                                                      email,
                                                    );
                                              }

                                              if (passwordController
                                                      .text
                                                      .isEmpty ||
                                                  emailController
                                                      .text
                                                      .isEmpty) {
                                                if (context
                                                    .mounted) {
                                                  showDialog(
                                                    context:
                                                        context,
                                                    builder: (
                                                      context,
                                                    ) {
                                                      return InfoAlert(
                                                        theme:
                                                            theme,
                                                        message:
                                                            'Email and Password fields must be set.',
                                                        title:
                                                            'Empty Fields',
                                                      );
                                                    },
                                                  );
                                                }
                                              } else if (!isValidEmail(
                                                emailController
                                                    .text,
                                              )) {
                                                if (context
                                                    .mounted) {
                                                  showDialog(
                                                    context:
                                                        context,
                                                    builder: (
                                                      context,
                                                    ) {
                                                      return InfoAlert(
                                                        theme:
                                                            theme,
                                                        message:
                                                            'Your email is not valid. Please check and try again.',
                                                        title:
                                                            'Invalid email',
                                                      );
                                                    },
                                                  );
                                                }
                                              } else {
                                                setState(() {
                                                  isLoading =
                                                      true;
                                                });
                                                TempUserClass?
                                                user = await fetchUserFromDatabase(
                                                  emailController
                                                      .text,
                                                  AuthService()
                                                      .currentUser!
                                                      .id,
                                                );

                                                setState(() {
                                                  isLoading =
                                                      false;
                                                });
                                                if (user !=
                                                    null) {
                                                  if (user.password !=
                                                      passwordController
                                                          .text
                                                          .trim()) {
                                                    if (context
                                                        .mounted) {
                                                      showDialog(
                                                        context:
                                                            context,
                                                        builder: (
                                                          context,
                                                        ) {
                                                          return InfoAlert(
                                                            theme:
                                                                theme,
                                                            message:
                                                                'Your password is not correct. Check it and try again.',
                                                            title:
                                                                'Incorrect Password',
                                                          );
                                                        },
                                                      );
                                                    }
                                                  } else {
                                                    setState(() {
                                                      showSuccess =
                                                          true;
                                                    });
                                                    await Future.delayed(
                                                      Duration(
                                                        seconds:
                                                            2,
                                                      ),
                                                    );
                                                    if (context
                                                        .mounted) {
                                                      await returnLocalDatabase(
                                                        context,
                                                        listen:
                                                            false,
                                                      ).insertUser(
                                                        user,
                                                      );
                                                      if (context
                                                          .mounted) {
                                                        Navigator.popAndPushNamed(
                                                          context,
                                                          '/',
                                                        );
                                                      }
                                                    }
                                                    emailController
                                                        .clear();
                                                    passwordController
                                                        .clear();
                                                    setState(() {
                                                      showSuccess =
                                                          false;
                                                    });
                                                  }
                                                } else {
                                                  if (context
                                                      .mounted) {
                                                    showDialog(
                                                      context:
                                                          context,
                                                      builder: (
                                                        context,
                                                      ) {
                                                        return InfoAlert(
                                                          theme:
                                                              theme,
                                                          message:
                                                              'Email address not registered with shop. Check the email and try again.',
                                                          title:
                                                              'Email not found',
                                                        );
                                                      },
                                                    );
                                                  }
                                                }
                                              }
                                            },

                                            text: 'Login',
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: showSuccess,
                            child: returnCompProvider(
                              context,
                            ).showSuccess(
                              'Logged in Succesfully',
                            ),
                          ),
                          Visibility(
                            visible: isLoading,
                            child: returnCompProvider(
                              context,
                            ).showLoader('Loading'),
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          );
        }
      },
    );
  }
}
