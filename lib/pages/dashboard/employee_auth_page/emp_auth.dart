import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:stockall/classes/temp_user_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/auth_screens/auth_screens_page.dart';
import 'package:stockall/pages/authentication/components/email_text_field.dart';
import 'package:stockall/pages/authentication/forgot_password_page/forgot_password_page.dart';
import 'package:stockall/pages/dashboard/components/button_tab.dart';
import 'package:stockall/pages/dashboard/components/main_bottom_nav.dart';
import 'package:stockall/pages/dashboard/components/top_nav_bar.dart';
import 'package:stockall/pages/dashboard/components/total_sales_banner.dart';
import 'package:stockall/services/auth_service.dart';

class EmpAuth extends StatefulWidget {
  final Function()? action;
  const EmpAuth({super.key, this.action});

  @override
  State<EmpAuth> createState() => _EmpAuthState();
}

class _EmpAuthState extends State<EmpAuth> {
  TextEditingController passwordController =
      TextEditingController();
  bool isLoading = false;
  bool showSuccess = false;
  bool isPassword = false;
  String value = '0';

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
            child: Stack(
              children: [
                GestureDetector(
                  onTap:
                      () =>
                          FocusManager.instance.primaryFocus
                              ?.unfocus(),
                  child: Container(
                    width: screenWidth(context),
                    height:
                        MediaQuery.of(context).size.height,
                    color: const Color.fromARGB(
                      215,
                      255,
                      255,
                      255,
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
                                0.2,
                          ),
                          Container(
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
                                  horizontal: 20,
                                  vertical: 20,
                                ),
                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Column(
                                  children: [
                                    SizedBox(height: 20),
                                    Row(
                                      spacing: 10,
                                      mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Material(
                                            color:
                                                Colors
                                                    .transparent,
                                            child: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  isPassword =
                                                      false;
                                                });
                                              },
                                              child: Container(
                                                padding:
                                                    EdgeInsets.symmetric(
                                                      vertical:
                                                          10,
                                                    ),
                                                decoration: BoxDecoration(
                                                  border: Border(
                                                    bottom: BorderSide(
                                                      color:
                                                          !isPassword
                                                              ? theme.lightModeColor.secColor200
                                                              : Colors.grey.shade400,
                                                      width:
                                                          !isPassword
                                                              ? 2
                                                              : 1,
                                                    ),
                                                  ),
                                                  color:
                                                      !isPassword
                                                          ? const Color.fromARGB(
                                                            29,
                                                            255,
                                                            193,
                                                            7,
                                                          )
                                                          : Colors.transparent,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    style: TextStyle(
                                                      fontWeight:
                                                          !isPassword
                                                              ? FontWeight.bold
                                                              : FontWeight.normal,
                                                      color:
                                                          !isPassword
                                                              ? Colors.grey.shade800
                                                              : Colors.grey.shade600,
                                                      fontSize:
                                                          13,
                                                    ),
                                                    'Enter Pin',
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Material(
                                            color:
                                                Colors
                                                    .transparent,
                                            child: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  isPassword =
                                                      true;
                                                });
                                              },
                                              child: Container(
                                                padding:
                                                    EdgeInsets.symmetric(
                                                      vertical:
                                                          10,
                                                    ),
                                                decoration: BoxDecoration(
                                                  border: Border(
                                                    bottom: BorderSide(
                                                      color:
                                                          isPassword
                                                              ? theme.lightModeColor.secColor200
                                                              : Colors.grey.shade400,
                                                      width:
                                                          isPassword
                                                              ? 2
                                                              : 1,
                                                    ),
                                                  ),
                                                  color:
                                                      isPassword
                                                          ? const Color.fromARGB(
                                                            29,
                                                            255,
                                                            193,
                                                            7,
                                                          )
                                                          : Colors.transparent,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    style: TextStyle(
                                                      fontWeight:
                                                          isPassword
                                                              ? FontWeight.bold
                                                              : FontWeight.normal,
                                                      color:
                                                          isPassword
                                                              ? Colors.grey.shade800
                                                              : Colors.grey.shade600,
                                                      fontSize:
                                                          13,
                                                    ),
                                                    'Password',
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
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
                                      'Login',
                                    ),
                                    SizedBox(height: 10),
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
                                      'Enter your ${isPassword ? 'password' : 'PIN'} to Login.',
                                    ),
                                  ],
                                ),
                                SizedBox(height: 15),
                                Stack(
                                  children: [
                                    Visibility(
                                      visible: isPassword,
                                      child: Column(
                                        children: [
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
                                              if (passwordController
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
                                                            'Password fields must be set.',
                                                        title:
                                                            'Empty Fields',
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
                                                  AuthService()
                                                      .currentUser!
                                                      .email!,
                                                  AuthService()
                                                      .currentUser!
                                                      .id,
                                                );

                                                setState(() {
                                                  isLoading =
                                                      false;
                                                });

                                                if (user !=
                                                        null &&
                                                    context
                                                        .mounted) {
                                                  if (user.password !=
                                                      passwordController
                                                          .text
                                                          .trim()) {
                                                    if (context
                                                        .mounted) {
                                                      setState(() {
                                                        isLoading =
                                                            false;
                                                      });
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
                                                      widget
                                                          .action!();
                                                    }
                                                    passwordController
                                                        .clear();
                                                    setState(() {
                                                      showSuccess =
                                                          false;
                                                    });
                                                  }
                                                } else {
                                                  setState(() {
                                                    isLoading =
                                                        false;
                                                  });
                                                  showDialog(
                                                    // ignore: use_build_context_synchronously
                                                    context:
                                                        context,
                                                    builder: (
                                                      context,
                                                    ) {
                                                      return InfoAlert(
                                                        theme:
                                                            theme,
                                                        message:
                                                            'User is Not found. Please check your details, and network and try again.',
                                                        title:
                                                            'User not found',
                                                      );
                                                    },
                                                  );
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
                                    Visibility(
                                      visible: !isPassword,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 0,
                                            ),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    color:
                                                        Colors.grey.shade700,
                                                  ),
                                                  'Enter PIN',
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            PinCodeTextField(
                                              autoFocus:
                                                  true,
                                              appContext:
                                                  context,
                                              length: 4,
                                              onChanged: (
                                                value,
                                              ) {
                                                // print("OTP: $value");
                                              },
                                              hintCharacter:
                                                  '0',
                                              hintStyle: TextStyle(
                                                color:
                                                    Colors
                                                        .grey
                                                        .shade300,
                                              ),
                                              onCompleted: (
                                                value,
                                              ) async {
                                                setState(() {
                                                  isLoading =
                                                      true;
                                                });
                                                TempUserClass?
                                                user = await fetchUserFromDatabase(
                                                  AuthService()
                                                      .currentUser!
                                                      .email!,
                                                  AuthService()
                                                      .currentUser!
                                                      .id,
                                                );
                                                if (user !=
                                                        null &&
                                                    context
                                                        .mounted) {
                                                  if (value !=
                                                      user.pin) {
                                                    setState(() {
                                                      isLoading =
                                                          false;
                                                      value =
                                                          '';
                                                    });

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
                                                              'Pin is Incorrect. Please Try again, or try logging in with your password.',
                                                          title:
                                                              'Incorrect PIN',
                                                        );
                                                      },
                                                    );
                                                  } else {
                                                    setState(() {
                                                      isLoading =
                                                          false;
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
                                                      widget
                                                          .action!();
                                                    }

                                                    setState(() {
                                                      showSuccess =
                                                          false;
                                                    });
                                                  }
                                                } else {
                                                  showDialog(
                                                    // ignore: use_build_context_synchronously
                                                    context:
                                                        context,
                                                    builder: (
                                                      context,
                                                    ) {
                                                      return InfoAlert(
                                                        theme:
                                                            theme,
                                                        message:
                                                            'User is Not found. Please check your details, and network and try again.',
                                                        title:
                                                            'User not found',
                                                      );
                                                    },
                                                  );
                                                }
                                              },
                                              pinTheme: PinTheme(
                                                shape:
                                                    PinCodeFieldShape
                                                        .box,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      5,
                                                    ),
                                                fieldHeight:
                                                    50,
                                                fieldWidth:
                                                    40,
                                                activeFillColor:
                                                    Colors
                                                        .white,
                                                selectedFillColor:
                                                    Colors
                                                        .grey
                                                        .shade100,
                                                inactiveFillColor:
                                                    Colors
                                                        .grey
                                                        .shade100,
                                                activeColor:
                                                    theme
                                                        .lightModeColor
                                                        .secColor200,
                                                selectedColor:
                                                    theme
                                                        .lightModeColor
                                                        .prColor300,
                                                inactiveColor:
                                                    Colors
                                                        .grey,
                                              ),
                                              cursorColor:
                                                  theme
                                                      .lightModeColor
                                                      .prColor300,
                                              keyboardType:
                                                  TextInputType
                                                      .number,
                                              animationType:
                                                  AnimationType
                                                      .fade,
                                              enableActiveFill:
                                                  true,
                                            ),
                                            SizedBox(
                                              height: 15,
                                            ),
                                            MainButtonP(
                                              themeProvider:
                                                  theme,
                                              action: () {
                                                if (value
                                                        .isEmpty ||
                                                    value.length !=
                                                        4) {
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
                                                            'Invalid PIN Length. Please Ensure that the Length of PINS are 4, and try again.',
                                                        title:
                                                            'Invalid PIN',
                                                      );
                                                    },
                                                  );
                                                }
                                              },
                                              text: 'Login',
                                            ),
                                            SizedBox(
                                              height: 15,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 15),
                                Row(
                                  spacing: 5,
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .center,
                                  children: [
                                    Expanded(
                                      child: Material(
                                        color:
                                            Colors
                                                .transparent,
                                        child: InkWell(
                                          onTap: () async {
                                            var safeContext =
                                                context;
                                            showDialog(
                                              context:
                                                  safeContext,
                                              builder: (
                                                context,
                                              ) {
                                                return ConfirmationAlert(
                                                  theme:
                                                      theme,
                                                  message:
                                                      'You are about to navigate from the shop to recover your password. Are you sure you want to Proceed?',
                                                  title:
                                                      'Recover Password',
                                                  action: () async {
                                                    Navigator.of(
                                                      safeContext,
                                                    ).pop();
                                                    setState(() {
                                                      isLoading =
                                                          true;
                                                    });
                                                    //
                                                    if (safeContext
                                                        .mounted) {
                                                      // localDatabase
                                                      //     .deleteUser();
                                                      Navigator.push(
                                                        safeContext,
                                                        MaterialPageRoute(
                                                          builder: (
                                                            context,
                                                          ) {
                                                            return ForgotPasswordPage(
                                                              isMain:
                                                                  true,
                                                            );
                                                          },
                                                        ),
                                                      );
                                                      //await AuthService()
                                                      //     .signOut();
                                                      returnNavProvider(
                                                        safeContext,
                                                        listen:
                                                            false,
                                                      ).navigate(
                                                        0,
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
                                                  vertical:
                                                      5,
                                                ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .center,
                                              spacing: 5,
                                              children: [
                                                // Icon(
                                                //   size: 18,
                                                //   color:
                                                //       Colors
                                                //           .grey,
                                                //   Icons
                                                //       .question_mark,
                                                // ),
                                                Text(
                                                  style: TextStyle(
                                                    color:
                                                        Colors.grey.shade700,
                                                    fontSize:
                                                        12,
                                                  ),
                                                  'Forgot Password?',
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    Expanded(
                                      child: Material(
                                        color:
                                            Colors
                                                .transparent,
                                        child: InkWell(
                                          onTap: () async {
                                            final safceContext =
                                                context;
                                            showDialog(
                                              context:
                                                  context,
                                              builder: (
                                                context,
                                              ) {
                                                return ConfirmationAlert(
                                                  theme:
                                                      theme,
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
                                                      await AuthService().signOut(
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
                                                  vertical:
                                                      8,
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
                                                  Icons
                                                      .logout,
                                                ),
                                                Text(
                                                  style: TextStyle(
                                                    color:
                                                        Colors.grey.shade700,
                                                    fontSize:
                                                        12,
                                                  ),
                                                  'Logout',
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Container(),
                                SizedBox(height: 10),
                              ],
                            ),
                          ),
                          Container(
                            height:
                                MediaQuery.of(
                                  context,
                                ).size.height *
                                0.4,
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
