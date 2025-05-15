import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stockitt/classes/temp_shop_class.dart';
import 'package:stockitt/components/major/empty_widget_display_only.dart';
import 'package:stockitt/constants/constants_main.dart';
import 'package:stockitt/main.dart';
import 'package:stockitt/pages/customers/customers_list/customer_list.dart';
import 'package:stockitt/pages/dashboard/components/button_tab.dart';
import 'package:stockitt/pages/dashboard/components/main_bottom_nav.dart';
import 'package:stockitt/pages/dashboard/components/main_info_tab.dart';
import 'package:stockitt/pages/dashboard/components/top_nav_bar.dart';
import 'package:stockitt/pages/dashboard/components/total_sales_banner.dart';
import 'package:stockitt/pages/employees/employee_list/employee_list_page.dart';
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

  @override
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      shopFuture = getUserShop();
      setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    shopFuture = getUserShop();
  }

  late Future<TempShopClass> shopFuture;

  Future<TempShopClass> getUserShop() async {
    var tempData = await returnShopProvider(
      context,
      listen: false,
    ).getUserShop(AuthService().currentUser!.id);

    return tempData!;
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Scaffold(
      bottomNavigationBar: MainBottomNav(),
      key: _scaffoldKey,
      drawer: Drawer(),
      body: FutureBuilder(
        future: shopFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return returnCompProvider(
              context,
              listen: false,
            ).showLoader('Loading');
          } else if (snapshot.hasError) {
            return Center(
              child: EmptyWidgetDisplayOnly(
                title: 'An Error Occoured',
                subText:
                    'We Couldn\'t Load Your Data. Check Your internet',
                buttonText: 'Reload',
                icon: Icons.clear,
                theme: theme,
                height: 30,
              ),
            );
          } else {
            var shop = snapshot.data!;
            return Stack(
              children: [
                Column(
                  children: [
                    TopNavBar(
                      openSideBar: () {
                        _scaffoldKey.currentState
                            ?.openDrawer();
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
                                DashboardTotalSalesBanner(
                                  theme: theme,
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
                                                      'Total Sales',
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
                                                  'Total Sales',
                                              action: () {},
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      child: FutureBuilder(
                                        future: returnData(
                                          context,
                                          listen: false,
                                        ).getLowProducts(
                                          shopId(context),
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
                                                          .shade300,
                                                  border: Border.all(
                                                    color:
                                                        Colors.grey.shade500,
                                                  ),
                                                ),
                                                child: MainInfoTab(
                                                  theme:
                                                      theme,
                                                  icon:
                                                      customersIconSvg,
                                                  number:
                                                      '0',
                                                  title:
                                                      'Low Products',
                                                  action:
                                                      () {},
                                                ),
                                              ),
                                            );
                                          } else {
                                            return MainInfoTab(
                                              theme: theme,
                                              icon:
                                                  productIconSvg,
                                              number:
                                                  '${snapshot.data!.length}',
                                              title:
                                                  'Low Products',
                                              action: () {},
                                            );
                                          }
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
                                            action: () {
                                              AuthService()
                                                  .signOut();
                                            },
                                          ),
                                          ButtonTab(
                                            theme: theme,
                                            icon:
                                                reportIconSvg,
                                            title: 'Report',
                                            action: () {},
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
