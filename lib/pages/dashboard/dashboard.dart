import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:stockitt/constants/constants_main.dart';
import 'package:stockitt/pages/dashboard/components/button_tab.dart';
import 'package:stockitt/pages/dashboard/components/main_info_tab.dart';
import 'package:stockitt/pages/dashboard/components/total_sales_banner.dart';
import 'package:stockitt/providers/comp_provider.dart';
import 'package:stockitt/providers/theme_provider.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Provider.of<ThemeProvider>(context);
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 30.0,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      spacing: 10,
                      children: [
                        Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: Image.asset(
                            profileIconImage,
                          ),
                        ),
                        Column(
                          spacing: 3,
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [
                            Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.center,
                              children: [
                                Text(
                                  style: TextStyle(
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .b2
                                            .fontSize,
                                    fontWeight:
                                        theme
                                            .mobileTexts
                                            .b2
                                            .fontWeightBold,
                                    color: Colors.black,
                                  ),
                                  'Giar Shop',
                                ),
                                SizedBox(width: 5),
                                SvgPicture.asset(
                                  checkIconSvg,
                                  height: 18,
                                  width: 18,
                                  fit: BoxFit.contain,
                                ),
                              ],
                            ),
                            Text(
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b3
                                        .fontSize,
                                color:
                                    theme
                                        .lightModeColor
                                        .prColor250,
                                fontWeight: FontWeight.w500,
                              ),
                              'No 12 Wuse, Abuja, Nigeria',
                            ),
                          ],
                        ),
                      ],
                    ),
                    Stack(
                      alignment: Alignment(1.2, -1.8),
                      children: [
                        InkWell(
                          onTap: () {
                            Provider.of<CompProvider>(
                              context,
                              listen: false,
                            ).switchNotif();
                          },
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(
                                208,
                                245,
                                245,
                                245,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: SvgPicture.asset(
                              height: 25,
                              width: 25,
                              notifIconSvg,
                            ),
                          ),
                        ),
                        Visibility(
                          visible:
                              Provider.of<CompProvider>(
                                context,
                              ).newNotif,
                          child: Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient:
                                  theme
                                      .lightModeColor
                                      .secGradient,
                            ),
                            child: Center(
                              child: Text(
                                style: TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                                '2',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20),
                DashboardTotalSalesBanner(theme: theme),
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
                        number: '0.0',
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
                SizedBox(height: 20),
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
                        alignment: WrapAlignment.start,
                        runAlignment: WrapAlignment.start,
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
                          // ButtonTab(
                          //   theme: theme,
                          //   icon: expensesIconSvg,
                          //   title: 'Expenses',
                          //   action: () {},
                          // ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
