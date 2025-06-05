import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_user_class.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/components/email_text_field.dart';
import 'package:stockall/pages/dashboard/components/button_tab.dart';
import 'package:stockall/pages/dashboard/components/main_bottom_nav.dart';
import 'package:stockall/pages/dashboard/components/main_info_tab.dart';
import 'package:stockall/pages/dashboard/components/top_nav_bar.dart';
import 'package:stockall/pages/dashboard/components/total_sales_banner.dart';
import 'package:stockall/pages/home/home.dart';
import 'package:stockall/services/auth_service.dart';

class EmpAuth extends StatefulWidget {
  const EmpAuth({super.key});

  @override
  State<EmpAuth> createState() => _EmpAuthState();
}

class _EmpAuthState extends State<EmpAuth> {
  TextEditingController emailController =
      TextEditingController();
  TextEditingController passwordController =
      TextEditingController();
  bool isLoading = false;
  bool showSuccess = false;

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

  // final GlobalKey<ScaffoldState> _scaffoldKey =
  //     GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Stack(
      children: [
        Scaffold(
          // bottomNavigationBar: MainBottomNav(
          //   globalKey: _scaffoldKey,
          // ),
          // body: Column(
          //   children: [
          //     SizedBox(height: 20),
          //     TopNavBar(
          //       notifications: [],
          //       title: 'Users Shop',
          //       subText: 'shop@gmail.com',
          //       theme: theme,
          //       openSideBar: () {},
          //       role: 'Cashier',
          //     ),
          //     Expanded(
          //       child: Padding(
          //         padding: const EdgeInsets.symmetric(
          //           horizontal: 30.0,
          //         ),
          //         child: ListView(
          //           children: [
          //             DashboardTotalSalesBanner(
          //               theme: theme,
          //               value: 10000,
          //             ),
          //             SizedBox(height: 20),
          //             Row(
          //               mainAxisAlignment:
          //                   MainAxisAlignment.center,
          //               spacing: 20,
          //               children: [
          //                 Expanded(
          //                   child: MainInfoTab(
          //                     title: 'title',
          //                     number: '20',
          //                     icon: '',
          //                     theme: theme,
          //                   ),
          //                 ),
          //                 Expanded(
          //                   child: MainInfoTab(
          //                     title: 'title',
          //                     number: '20',
          //                     icon: '',
          //                     theme: theme,
          //                   ),
          //                 ),
          //               ],
          //             ),
          //             SizedBox(height: 20),
          //             Column(
          //               children: [
          //                 Row(
          //                   children: [
          //                     Text(
          //                       style: TextStyle(
          //                         fontSize:
          //                             theme
          //                                 .mobileTexts
          //                                 .b1
          //                                 .fontSize,
          //                         fontWeight:
          //                             theme
          //                                 .mobileTexts
          //                                 .b1
          //                                 .fontWeightBold,
          //                       ),
          //                       'Quick Actions',
          //                     ),
          //                   ],
          //                 ),
          //                 SizedBox(height: 20),

          //                 SizedBox(
          //                   width: double.infinity,
          //                   child: LayoutBuilder(
          //                     builder: (
          //                       context,
          //                       constraints,
          //                     ) {
          //                       if (constraints.maxWidth >
          //                           320) {
          //                         return Column(
          //                           spacing: 15,
          //                           children: [
          //                             Row(
          //                               spacing: 15,
          //                               children: [
          //                                 ButtonTab(
          //                                   theme: theme,
          //                                   icon:
          //                                       productIconSvg,
          //                                   title:
          //                                       'Products',
          //                                   action: () {},
          //                                 ),
          //                                 ButtonTab(
          //                                   theme: theme,
          //                                   icon:
          //                                       salesIconSvg,
          //                                   title: 'Sales',
          //                                   action: () {
          //                                     returnNavProvider(
          //                                       context,
          //                                       listen:
          //                                           false,
          //                                     ).navigate(2);
          //                                   },
          //                                 ),
          //                                 ButtonTab(
          //                                   theme: theme,
          //                                   icon:
          //                                       custBookIconSvg,
          //                                   title:
          //                                       'Customers',
          //                                   action: () {},
          //                                 ),
          //                               ],
          //                             ),
          //                             Row(
          //                               spacing: 15,
          //                               children: [
          //                                 ButtonTab(
          //                                   theme: theme,
          //                                   icon:
          //                                       employeesIconSvg,
          //                                   title:
          //                                       'Employees',
          //                                   action: () {},
          //                                 ),
          //                                 ButtonTab(
          //                                   theme: theme,
          //                                   icon:
          //                                       expensesIconSvg,
          //                                   title:
          //                                       'Expenses',
          //                                   action:
          //                                       () async {},
          //                                 ),
          //                                 ButtonTab(
          //                                   theme: theme,
          //                                   icon:
          //                                       reportIconSvg,
          //                                   title: 'Report',
          //                                   action: () {},
          //                                 ),
          //                               ],
          //                             ),
          //                           ],
          //                         );
          //                       } else {
          //                         return Column(
          //                           spacing: 15,
          //                           children: [
          //                             Row(
          //                               spacing: 15,
          //                               children: [
          //                                 ButtonTab(
          //                                   theme: theme,
          //                                   icon:
          //                                       productIconSvg,
          //                                   title:
          //                                       'Products',
          //                                   action: () {},
          //                                 ),
          //                                 ButtonTab(
          //                                   theme: theme,
          //                                   icon:
          //                                       salesIconSvg,
          //                                   title: 'Sales',
          //                                   action: () {},
          //                                 ),
          //                               ],
          //                             ),
          //                             Row(
          //                               spacing: 15,
          //                               children: [
          //                                 ButtonTab(
          //                                   theme: theme,
          //                                   icon:
          //                                       custBookIconSvg,
          //                                   title:
          //                                       'Customers',
          //                                   action: () {},
          //                                 ),
          //                                 ButtonTab(
          //                                   theme: theme,
          //                                   icon:
          //                                       employeesIconSvg,
          //                                   title:
          //                                       'Employees',
          //                                   action: () {},
          //                                 ),
          //                               ],
          //                             ),
          //                             Row(
          //                               spacing: 15,
          //                               children: [
          //                                 ButtonTab(
          //                                   theme: theme,
          //                                   icon:
          //                                       expensesIconSvg,
          //                                   title:
          //                                       'Expenses',
          //                                   action:
          //                                       () async {},
          //                                 ),
          //                                 ButtonTab(
          //                                   theme: theme,
          //                                   icon:
          //                                       reportIconSvg,
          //                                   title: 'Report',
          //                                   action: () {},
          //                                 ),
          //                               ],
          //                             ),
          //                           ],
          //                         );
          //                       }
          //                     },
          //                   ),
          //                 ),
          //               ],
          //             ),
          //           ],
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
        ),
        Material(
          color: const Color.fromARGB(255, 120, 206, 197),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
            child: Stack(
              children: [
                InkWell(
                  onTap:
                      () =>
                          FocusManager.instance.primaryFocus
                              ?.unfocus(),
                  child: Container(
                    width:
                        MediaQuery.of(context).size.width,
                    height:
                        MediaQuery.of(context).size.height,
                    color: const Color.fromARGB(
                      126,
                      0,
                      0,
                      0,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height:
                                MediaQuery.of(
                                  context,
                                ).size.height *
                                0.25,
                          ),
                          Container(
                            width:
                                MediaQuery.of(
                                  context,
                                ).size.width *
                                0.85,
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
                                  horizontal: 30,
                                  vertical: 20,
                                ),
                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Column(
                                  children: [
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
                                      'Login',
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
                                SizedBox(height: 15),
                                EmailTextField(
                                  controller:
                                      emailController,
                                  theme: theme,
                                  isEmail: true,
                                  hint: 'Enter Email',
                                  title: 'Email',
                                ),
                                SizedBox(height: 20),
                                EmailTextField(
                                  controller:
                                      passwordController,
                                  theme: theme,
                                  isEmail: false,
                                  hint: 'Enter Password',
                                  title: 'Password',
                                ),
                                SizedBox(height: 30),
                                MainButtonP(
                                  themeProvider: theme,
                                  action: () async {
                                    bool isValidEmail(
                                      String email,
                                    ) {
                                      final emailRegex = RegExp(
                                        r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$",
                                      );
                                      return emailRegex
                                          .hasMatch(email);
                                    }

                                    if (passwordController
                                            .text
                                            .isEmpty ||
                                        emailController
                                            .text
                                            .isEmpty) {
                                      if (context.mounted) {
                                        showDialog(
                                          context: context,
                                          builder: (
                                            context,
                                          ) {
                                            return InfoAlert(
                                              theme: theme,
                                              message:
                                                  'Email and Password fields must be set.',
                                              title:
                                                  'Empty Fields',
                                            );
                                          },
                                        );
                                      }
                                    } else if (!isValidEmail(
                                      emailController.text,
                                    )) {
                                      if (context.mounted) {
                                        showDialog(
                                          context: context,
                                          builder: (
                                            context,
                                          ) {
                                            return InfoAlert(
                                              theme: theme,
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
                                        isLoading = true;
                                      });
                                      TempUserClass? user =
                                          await fetchUserFromDatabase(
                                            emailController
                                                .text,
                                            AuthService()
                                                .currentUser!
                                                .id,
                                          );

                                      setState(() {
                                        isLoading = false;
                                      });
                                      if (user != null) {
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
                                              seconds: 2,
                                            ),
                                          );
                                          if (context
                                              .mounted) {
                                            await returnLocalDatabase(
                                              context,
                                              listen: false,
                                            ).insertUser(
                                              user,
                                            );
                                            if (context
                                                .mounted) {
                                              Navigator.pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (
                                                        context,
                                                      ) =>
                                                          Home(),
                                                ),
                                                (route) =>
                                                    false, // removes all previous routes
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
                                SizedBox(height: 20),
                              ],
                            ),
                          ),
                          Container(
                            height:
                                MediaQuery.of(
                                  context,
                                ).size.height *
                                0.5,
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
                  ).showSuccess('Logged in Succesfully'),
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
}
