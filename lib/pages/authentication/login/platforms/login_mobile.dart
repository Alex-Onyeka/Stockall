import 'dart:io';

import 'package:flutter/material.dart';
// import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/base_page/base_page.dart';
import 'package:stockall/pages/authentication/components/email_text_field.dart';
import 'package:stockall/pages/authentication/forgot_password_page/forgot_password_page.dart';
import 'package:stockall/pages/authentication/translations/auth_texts_en.dart';
import 'package:stockall/pages/authentication/translations/general.dart';
import 'package:stockall/providers/theme_provider.dart';
import 'package:stockall/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginMobile extends StatefulWidget {
  final ThemeProvider theme;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const LoginMobile({
    super.key,
    required this.theme,
    required this.emailController,
    required this.passwordController,
  });

  @override
  State<LoginMobile> createState() => _LoginMobileState();
}

class _LoginMobileState extends State<LoginMobile> {
  bool issLoading = false;
  bool showwSuccess = false;

  Future<void> checkInputs() async {
    if (widget.emailController.text.isEmpty ||
        widget.passwordController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          var theme = Provider.of<ThemeProvider>(context);
          return InfoAlert(
            theme: theme,
            message:
                LoginPageTexts().pleaseFillOutAllFields,
            title: General().emptyFields,
          );
        },
      );
    } else if (!isValidEmail(widget.emailController.text)) {
      showDialog(
        context: context,
        builder: (context) {
          var theme = Provider.of<ThemeProvider>(context);
          return InfoAlert(
            theme: theme,
            message: General().emailIsBadlyFormatted,
            title: General().invalidEmail,
          );
        },
      );
    } else {
      setState(() {
        issLoading = true;
      });
      try {
        var res = await AuthService().signIn(
          widget.emailController.text,
          widget.passwordController.text,
          // context,
        );
        if (res == 1 && context.mounted) {
          setState(() {
            issLoading = false;
            showwSuccess = true;
          });

          Future.delayed(Duration(seconds: 3), () {
            Navigator.pushReplacementNamed(
              // ignore: use_build_context_synchronously
              context,
              '/',
            );
            setState(() {
              showwSuccess = false;
            });
          });
        } else {
          setState(() {
            issLoading = false;
          });
          showDialog(
            // ignore: use_build_context_synchronously
            context: context,
            builder: (context) {
              return InfoAlert(
                theme: widget.theme,
                message:
                    'Login Failed. Please check your email and password. Also check to see if your internet is properly connected',
                title: General().authenticationError,
              );
            },
          );
        }
      } on SocketException catch (_) {
        // No internet
        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (context) {
            return InfoAlert(
              theme: widget.theme,
              message: General().noInternetConnection,
              title: General().authenticationError,
            );
          },
        );
      } on AuthException catch (e) {
        setState(() {
          issLoading = false;
        });
        if (!context.mounted) return;
        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (context) {
            return InfoAlert(
              theme: widget.theme,
              message:
                  e.statusCode == '400'
                      ? General().invalidEmailOrPassword
                      : e.statusCode == '401'
                      ? General().invalidEmailOrPassword
                      : e.statusCode == '404'
                      ? '${General().userNotFound}. Please check your email and try again.'
                      : e.statusCode == '500'
                      ? General().anErrorOccuredOnTheServer
                      : e.statusCode == null
                      ? General().noInternetConnection
                      : General().anErrorOccured,
              // 'An Error occured while tryin to create your account, please check you internet and try again.',
              title: General().authenticationError,
            );
          },
        );
      } catch (e) {
        setState(() {
          issLoading = false;
        });

        if (!context.mounted) return;
        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (context) {
            return InfoAlert(
              theme: widget.theme,
              message: e.toString(),
              title: General().unexpectedError,
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: Colors.white,
            leading: GestureDetector(
              onTap: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BasePage(),
                    ),
                  );
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 0,
                ),
                child: Icon(
                  color: Colors.grey,
                  Icons.arrow_back_ios_new_rounded,
                ),
              ),
            ),
            leadingWidth: 10,
            centerTitle: true,
            title: InkWell(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Row(
                spacing: 10,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(mainLogoIcon, height: 20),
                  Text(
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 25,
                      fontWeight:
                          widget
                              .theme
                              .mobileTexts
                              .h3
                              .fontWeightBold,
                    ),
                    appName,
                  ),
                ],
              ),
            ),
            actions: [
              Opacity(
                opacity: 0.0,
                child: Padding(
                  padding: const EdgeInsets.only(
                    right: 20.0,
                  ),
                  child: Icon(Icons.clear),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 35.0,
              ),
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(
                  context,
                ).copyWith(scrollbars: false),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 60),
                      Column(
                        spacing: 8,
                        children: [
                          Row(
                            children: [
                              Text(
                                style: TextStyle(
                                  color:
                                      widget
                                          .theme
                                          .lightModeColor
                                          .shadesColorBlack,
                                  fontSize:
                                      widget
                                          .theme
                                          .mobileTexts
                                          .h3
                                          .fontSize,
                                  fontWeight:
                                      widget
                                          .theme
                                          .mobileTexts
                                          .h3
                                          .fontWeightBold,
                                ),
                                General().welcomeBack,
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  style:
                                      Provider.of<
                                            ThemeProvider
                                          >(context)
                                          .mobileTexts
                                          .b1
                                          .textStyleNormal,
                                  LoginPageTexts()
                                      .pleaseFillInTheForm,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 30),
                      EmailTextField(
                        title: General().emailAddress,
                        hint: General().enterEmail,
                        isEmail: true,
                        controller: widget.emailController,
                        theme: widget.theme,
                      ),
                      SizedBox(height: 15),
                      EmailTextField(
                        title: General().password,
                        hint: General().enterPassword,
                        isEmail: false,
                        controller:
                            widget.passwordController,
                        theme: widget.theme,
                      ),

                      // SizedBox(height: 30),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.end,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return ForgotPasswordPage();
                                  },
                                ),
                              );
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(
                                    right: 0.0,
                                    top: 15,
                                    bottom: 15,
                                    left: 20,
                                  ),
                              child: Text(
                                style: TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                  color:
                                      widget
                                          .theme
                                          .lightModeColor
                                          .secColor100,
                                ),
                                LoginPageTexts()
                                    .forgetPassword,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      MainButtonP(
                        themeProvider: widget.theme,
                        action: () {
                          checkInputs();
                        },
                        text: General().login,
                      ),
                      SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Visibility(
          visible: issLoading,
          child: returnCompProvider(
            context,
            listen: false,
          ).showLoader(message: General().loadingText),
        ),
        Visibility(
          visible: showwSuccess,
          child: returnCompProvider(
            context,
            listen: false,
          ).showSuccess(General().successfully),
        ),
      ],
    );
  }
}
