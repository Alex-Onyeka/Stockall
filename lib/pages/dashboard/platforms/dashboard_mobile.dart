import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stockitt/classes/temp_main_receipt.dart';
import 'package:stockitt/classes/temp_product_sale_record.dart';
import 'package:stockitt/classes/temp_shop_class.dart';
import 'package:stockitt/components/major/empty_widget_display_only.dart';
import 'package:stockitt/components/major/my_drawer_widget.dart';
import 'package:stockitt/constants/constants_main.dart';
import 'package:stockitt/main.dart';
import 'package:stockitt/pages/customers/customers_list/customer_list.dart';
import 'package:stockitt/pages/dashboard/components/button_tab.dart';
import 'package:stockitt/pages/dashboard/components/main_bottom_nav.dart';
import 'package:stockitt/pages/dashboard/components/main_info_tab.dart';
import 'package:stockitt/pages/dashboard/components/top_nav_bar.dart';
import 'package:stockitt/pages/dashboard/components/total_sales_banner.dart';
import 'package:stockitt/pages/employees/employee_list/employee_list_page.dart';
import 'package:stockitt/pages/expenses/expenses_page.dart';
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

  late Future<List<TempMainReceipt>> mainReceiptFuture;

  @override
  void initState() {
    super.initState();
    mainReceiptFuture = getMainReceipts();
    getProdutRecordsFuture = getProductSalesRecord();
    shop =
        returnShopProvider(
          context,
          listen: false,
        ).userShop!;
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

  // @override
  // void initState() {
  //   super.initState();

  // }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Scaffold(
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
      drawer: MyDrawerWidget(theme: theme),
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
            var mainReceipts = returnReceiptProvider(
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
                    TopNavBar(
                      openSideBar: () {
                        _scaffoldKey.currentState
                            ?.openDrawer();
                        returnNavProvider(
                          context,
                          listen: false,
                        ).setSettings();
                      },
                      theme: theme,
                      notifNumber: 2,
                      subText:
                          shop.shopAddress ?? shop.email,
                      title: shop.name,
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        child: SizedBox(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(
                                  horizontal: 30.0,
                                ),
                            child: Column(
                              children: [
                                SizedBox(height: 20),
                                Builder(
                                  builder: (context) {
                                    if (snapshot
                                            .connectionState ==
                                        ConnectionState
                                            .waiting) {
                                      return Shimmer.fromColors(
                                        baseColor:
                                            Colors.grey,
                                        highlightColor:
                                            Colors.white,
                                        child:
                                            DashboardTotalSalesBanner(
                                              theme: theme,
                                              value: 1000,
                                            ),
                                      );
                                    } else if (snapshot
                                        .hasError) {
                                      return DashboardTotalSalesBanner(
                                        theme: theme,
                                        value: 0000,
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
                                          if (snapshot
                                                  .connectionState ==
                                              ConnectionState
                                                  .waiting) {
                                            return DashboardTotalSalesBanner(
                                              theme: theme,
                                              value: 1000,
                                            );
                                          } else if (snapshot
                                              .hasError) {
                                            return DashboardTotalSalesBanner(
                                              theme: theme,
                                              value: 0000,
                                            );
                                          } else {
                                            List<
                                              TempProductSaleRecord
                                            >
                                            records =
                                                snapshot
                                                    .data!;
                                            return DashboardTotalSalesBanner(
                                              theme: theme,
                                              value: returnReceiptProvider(
                                                context,
                                              ).getTotalRevenueForSelectedDay(
                                                context,
                                                mainReceipts,
                                                records,
                                              ),
                                            );
                                          }
                                        },
                                      );
                                    }
                                  },
                                ),
                                SizedBox(height: 20),
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
                                          listen: false,
                                        ).getProducts(
                                          shop.shopId!,
                                        ),
                                        builder: (
                                          context,
                                          snapshot,
                                        ) {
                                          if (snapshot
                                                  .connectionState ==
                                              ConnectionState
                                                  .waiting) {
                                            return Shimmer.fromColors(
                                              baseColor:
                                                  Colors
                                                      .grey
                                                      .shade300,
                                              highlightColor:
                                                  Colors
                                                      .grey
                                                      .shade200,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        10,
                                                      ),
                                                  color:
                                                      Colors
                                                          .grey
                                                          .shade400,
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
                                              theme: theme,
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
                                        theme: theme,
                                        icon:
                                            productIconSvg,
                                        number:
                                            '${mainReceipts.length}',
                                        title:
                                            'Todays Sales',
                                        action: () {
                                          returnNavProvider(
                                            context,
                                            listen: false,
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
                                    SizedBox(height: 20),

                                    SizedBox(
                                      width:
                                          double.infinity,
                                      child: Wrap(
                                        alignment:
                                            WrapAlignment
                                                .start,
                                        runAlignment:
                                            WrapAlignment
                                                .start,
                                        direction:
                                            Axis.horizontal,
                                        runSpacing: 15,
                                        spacing: 15,
                                        crossAxisAlignment:
                                            WrapCrossAlignment
                                                .center,
                                        children: [
                                          ButtonTab(
                                            theme: theme,
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
                                              ).navigate(1);
                                            },
                                          ),
                                          ButtonTab(
                                            theme: theme,
                                            icon:
                                                salesIconSvg,
                                            title: 'Sales',
                                            action: () {
                                              returnNavProvider(
                                                context,
                                                listen:
                                                    false,
                                              ).navigate(2);
                                            },
                                          ),
                                          ButtonTab(
                                            theme: theme,
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
                                            theme: theme,
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
                                                    return EmployeeListPage();
                                                  },
                                                ),
                                              );
                                            },
                                          ),
                                          ButtonTab(
                                            theme: theme,
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
                                            theme: theme,
                                            icon:
                                                reportIconSvg,
                                            title: 'Report',
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
                                SizedBox(height: 10),
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
    );
  }
}
