import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/auth_screens/auth_screens_page.dart';
import 'package:stockall/pages/dashboard/components/button_tab.dart';
import 'package:stockall/pages/dashboard/components/main_bottom_nav.dart';
import 'package:stockall/pages/dashboard/components/top_nav_bar.dart';
import 'package:stockall/pages/dashboard/components/total_sales_banner.dart';
import 'package:stockall/services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';

class RestrictedPage extends StatefulWidget {
  final Function()? action;
  const RestrictedPage({super.key, this.action});

  @override
  State<RestrictedPage> createState() =>
      _RestrictedPageState();
}

class _RestrictedPageState extends State<RestrictedPage> {
  Future<void> _launchUrl() async {
    final Uri url = Uri.parse(
      'https://www.stockallapp.com/#/reset-password',
    );
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          bottomNavigationBar: MainBottomNav(
            globalKey: GlobalKey(),
          ),
          body: Column(
            children: [
              SizedBox(height: 20),
              TopNavBar(
                notifications: [],
                title: 'Users Shop',
                subText: 'shop@gmail.com',
                theme: theme,
                openSideBar: () {},
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30.0,
                  ),
                  child: ListView(
                    children: [
                      DashboardTotalSalesBanner(
                        theme: theme,
                        value: 10000,
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        spacing: 20,
                        children: [
                          Expanded(
                            child: Container(
                              height: 130,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(
                                      10,
                                    ),
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 130,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(
                                      10,
                                    ),
                                color: Colors.grey,
                              ),
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
                            child: LayoutBuilder(
                              builder: (
                                context,
                                constraints,
                              ) {
                                if (constraints.maxWidth >
                                    320) {
                                  return Column(
                                    spacing: 15,
                                    children: [
                                      Row(
                                        spacing: 15,
                                        children: [
                                          ButtonTab(
                                            theme: theme,
                                            icon:
                                                productIconSvg,
                                            title: 'Items',
                                            action: () {},
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
                                            action: () {},
                                          ),
                                        ],
                                      ),
                                      Row(
                                        spacing: 15,
                                        children: [
                                          ButtonTab(
                                            theme: theme,
                                            icon:
                                                employeesIconSvg,
                                            title:
                                                'Employees',
                                            action: () {},
                                          ),
                                          ButtonTab(
                                            theme: theme,
                                            icon:
                                                expensesIconSvg,
                                            title:
                                                'Expenses',
                                            action:
                                                () async {},
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
                                    ],
                                  );
                                } else {
                                  return Column(
                                    spacing: 15,
                                    children: [
                                      Row(
                                        spacing: 15,
                                        children: [
                                          ButtonTab(
                                            theme: theme,
                                            icon:
                                                productIconSvg,
                                            title: 'Items',
                                            action: () {},
                                          ),
                                          ButtonTab(
                                            theme: theme,
                                            icon:
                                                salesIconSvg,
                                            title: 'Sales',
                                            action: () {},
                                          ),
                                        ],
                                      ),
                                      Row(
                                        spacing: 15,
                                        children: [
                                          ButtonTab(
                                            theme: theme,
                                            icon:
                                                custBookIconSvg,
                                            title:
                                                'Customers',
                                            action: () {},
                                          ),
                                          ButtonTab(
                                            theme: theme,
                                            icon:
                                                employeesIconSvg,
                                            title:
                                                'Employees',
                                            action: () {},
                                          ),
                                        ],
                                      ),
                                      Row(
                                        spacing: 15,
                                        children: [
                                          ButtonTab(
                                            theme: theme,
                                            icon:
                                                expensesIconSvg,
                                            title:
                                                'Expenses',
                                            action:
                                                () async {},
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
                                    ],
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Material(
          color: Colors.transparent,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: GestureDetector(
              onTap:
                  () =>
                      FocusManager.instance.primaryFocus
                          ?.unfocus(),
              child: Container(
                width: screenWidth(context),
                height: MediaQuery.of(context).size.height,
                color: const Color.fromARGB(
                  215,
                  255,
                  255,
                  255,
                ),
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Center(
                          child: Container(
                            width:
                                screenWidth(context) <
                                        mobileScreen
                                    ? screenWidth(context) *
                                        0.85
                                    : mobileScreen - 100,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(5),
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
                                  horizontal: 40,
                                  vertical: 20,
                                ),
                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Column(
                                  children: [
                                    SizedBox(height: 20),
                                    SizedBox(height: 30),
                                    Text(
                                      style: TextStyle(
                                        fontSize:
                                            theme
                                                .mobileTexts
                                                .h2
                                                .fontSize,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                      'Expired Subscription',
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      textAlign:
                                          TextAlign.center,
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
                                      'Your Subcription has Expired. Click on the Button to renew your subscription.',
                                    ),
                                  ],
                                ),
                                SizedBox(height: 30),
                                MainButtonP(
                                  themeProvider: theme,
                                  action: () async {
                                    await _launchUrl();
                                  },
                                  text: 'Subscribe',
                                ),
                                SizedBox(height: 15),
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () async {
                                      final safceContext =
                                          context;
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return ConfirmationAlert(
                                            theme: theme,
                                            message:
                                                'Are you sure you want to proceed to logout from your account?',
                                            title:
                                                'Are You Sure?',
                                            action: () async {
                                              Navigator.of(
                                                context,
                                              ).pop();
                                              if (safceContext
                                                  .mounted) {
                                                Navigator.pushReplacement(
                                                  safceContext,
                                                  MaterialPageRoute(
                                                    builder: (
                                                      safceContext,
                                                    ) {
                                                      return AuthScreensPage();
                                                    },
                                                  ),
                                                );
                                                returnNavProvider(
                                                  safceContext,
                                                  listen:
                                                      false,
                                                ).navigate(
                                                  0,
                                                );
                                              }
                                              if (safceContext
                                                  .mounted) {
                                                await AuthService()
                                                    .signOut(
                                                      safceContext,
                                                    );
                                              }
                                            },
                                          );
                                        },
                                      );
                                    },
                                    child: Container(
                                      padding:
                                          EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment
                                                .center,
                                        spacing: 5,
                                        children: [
                                          Icon(
                                            size: 20,
                                            color:
                                                Colors
                                                    .redAccent,
                                            Icons.logout,
                                          ),
                                          Text(
                                            style: TextStyle(
                                              color:
                                                  Colors
                                                      .grey
                                                      .shade700,
                                              fontSize: 12,
                                            ),
                                            'Logout',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Container(),
                                SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ),
                        // Container(
                        //   height:
                        //       MediaQuery.of(
                        //         context,
                        //       ).size.height *
                        //       0.4,
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
