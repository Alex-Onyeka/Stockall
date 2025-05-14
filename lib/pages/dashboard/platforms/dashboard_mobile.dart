import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

class DashboardMobile extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();

  DashboardMobile({super.key});

  @override
  Widget build(BuildContext context) {
    var currentUser = returnUserProvider(
      context,
    ).currentUser('user_001');
    var shop = returnShopProvider(
      context,
    ).returnShop(currentUser.userId!);
    var theme = returnTheme(context);
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(),
      body: Stack(
        children: [
          Column(
            children: [
              TopNavBar(
                openSideBar: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
                theme: theme,
                notifNumber: 2,
                subText: shop.shopAddress ?? shop.email,
                title: shop.name,
              ),

              Expanded(
                child: SingleChildScrollView(
                  child: SizedBox(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
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
                                MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: MainInfoTab(
                                  theme: theme,
                                  icon: pulseIconSvg,
                                  number: '9',
                                  title: 'Total Revenue',
                                  action: () {},
                                ),
                              ),
                              Expanded(
                                child: MainInfoTab(
                                  theme: theme,
                                  icon: customersIconSvg,
                                  number: '10',
                                  title: 'Customers',
                                  action: () {},
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
                                width: double.infinity,
                                child: Wrap(
                                  alignment:
                                      WrapAlignment.start,
                                  runAlignment:
                                      WrapAlignment.start,
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
                                      icon: productIconSvg,
                                      title: 'Products',
                                      action: () {
                                        Provider.of<
                                          NavProvider
                                        >(
                                          context,
                                          listen: false,
                                        ).navigate(1);
                                      },
                                    ),
                                    ButtonTab(
                                      theme: theme,
                                      icon: salesIconSvg,
                                      title: 'Sales',
                                      action: () {
                                        returnNavProvider(
                                          context,
                                          listen: false,
                                        ).navigate(2);
                                      },
                                    ),
                                    ButtonTab(
                                      theme: theme,
                                      icon: custBookIconSvg,
                                      title: 'Customers',
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
                                      title: 'Employees',
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
                                      icon: expensesIconSvg,
                                      title: 'Expenses',
                                      action: () {
                                        AuthService()
                                            .signOut();
                                      },
                                    ),
                                    ButtonTab(
                                      theme: theme,
                                      icon: reportIconSvg,
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
              MainBottomNav(),
            ],
          ),
          Visibility(
            visible: context.watch<AuthService>().isLoading,
            child: returnCompProvider(
              context,
            ).showSuccess('Loading'),
          ),
          Visibility(
            visible: context.watch<AuthService>().isLoading,
            child: returnCompProvider(
              context,
            ).showLoader('Loading'),
          ),
        ],
      ),
    );
  }
}
