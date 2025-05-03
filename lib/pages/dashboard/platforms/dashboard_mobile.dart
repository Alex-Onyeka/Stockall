import 'package:flutter/material.dart';
import 'package:stockitt/constants/constants_main.dart';
import 'package:stockitt/main.dart';
import 'package:stockitt/pages/dashboard/components/button_tab.dart';
import 'package:stockitt/pages/dashboard/components/main_bottom_nav.dart';
import 'package:stockitt/pages/dashboard/components/main_info_tab.dart';
import 'package:stockitt/pages/dashboard/components/top_nav_bar.dart';
import 'package:stockitt/pages/dashboard/components/total_sales_banner.dart';

class DashboardMobile extends StatelessWidget {
  const DashboardMobile({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Scaffold(
      body: Column(
        children: [
          TopNavBar(
            theme: theme,
            notifNumber: 2,
            subText: 'No 12 Wuse, Abuja, Nigeria',
            title: 'Alex Shop',
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
                              direction: Axis.horizontal,
                              runSpacing: 15,
                              spacing: 15,
                              crossAxisAlignment:
                                  WrapCrossAlignment.center,
                              children: [
                                ButtonTab(
                                  theme: theme,
                                  icon: productIconSvg,
                                  title: 'Products',
                                  action: () {},
                                ),
                                ButtonTab(
                                  theme: theme,
                                  icon: salesIconSvg,
                                  title: 'Sales',
                                  action: () {},
                                ),
                                ButtonTab(
                                  theme: theme,
                                  icon: custBookIconSvg,
                                  title: 'Customers',
                                  action: () {},
                                ),
                                ButtonTab(
                                  theme: theme,
                                  icon: employeesIconSvg,
                                  title: 'Employees',
                                  action: () {},
                                ),
                                ButtonTab(
                                  theme: theme,
                                  icon: expensesIconSvg,
                                  title: 'Expenses',
                                  action: () {},
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
    );
  }
}
