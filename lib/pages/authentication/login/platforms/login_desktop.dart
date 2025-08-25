import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/buttons/main_button_transparent.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/components/email_text_field.dart';
import 'package:stockall/pages/authentication/forgot_password_page/forgot_password_page.dart';
import 'package:stockall/pages/authentication/translations/auth_texts_en.dart';
import 'package:stockall/pages/authentication/translations/general.dart';
import 'package:stockall/providers/theme_provider.dart';
import 'package:stockall/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginDesktop extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;

  final ThemeProvider theme;
  const LoginDesktop({
    super.key,
    required this.theme,
    required this.emailController,
    required this.passwordController,
  });

  @override
  State<LoginDesktop> createState() => _LoginDesktopState();
}

class _LoginDesktopState extends State<LoginDesktop> {
  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$",
    );
    return emailRegex.hasMatch(email);
  }

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
          context,
        );
        if (res.user != null && context.mounted) {
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
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(backGroundImage),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Container(
              color: const Color.fromARGB(
                201,
                255,
                255,
                255,
              ),
            ),
            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          vertical: 40,
                        ),
                        width: 550,
                        padding: EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 30,
                        ),
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(20),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(
                                46,
                                0,
                                0,
                                0,
                              ),
                              blurRadius: 10,
                              spreadRadius: 5,
                              offset: Offset(0, 0),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            SizedBox(height: 10),
                            Row(
                              spacing: 10,
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  mainLogoIcon,
                                  height: 20,
                                ),
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
                            SizedBox(height: 20),
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
                                    Text(
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
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 30),
                            EmailTextField(
                              title: General().emailAddress,
                              hint: General().enterEmail,
                              isEmail: true,
                              controller:
                                  widget.emailController,
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

                            SizedBox(height: 20),
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
                            SizedBox(height: 10),
                            MainButtonTransparent(
                              themeProvider: widget.theme,
                              constraints: BoxConstraints(),
                              text: 'Go Back',
                              action: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: issLoading,
              child: returnCompProvider(
                context,
                listen: false,
              ).showLoader(General().loadingText),
            ),
            Visibility(
              visible: showwSuccess,
              child: returnCompProvider(
                context,
                listen: false,
              ).showSuccess(General().successfully),
            ),
          ],
        ),
      ),
    );
  }
}
