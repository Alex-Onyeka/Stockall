import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/buttons/main_button_transparent.dart';
import 'package:stockall/components/major/desktop_center_container.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/components/email_text_field.dart';
import 'package:stockall/pages/authentication/explore_page/platforms/explore_desktop.dart';
import 'package:stockall/pages/authentication/forgot_password_page/forgot_password_page.dart';
import 'package:stockall/pages/authentication/translations/auth_texts_en.dart';
import 'package:stockall/pages/authentication/translations/general.dart';
import 'package:stockall/providers/theme_provider.dart';
import 'package:stockall/services/auth_service.dart';

class LoginDesktop extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool useDemoLogin;

  final ThemeProvider theme;
  const LoginDesktop({
    super.key,
    required this.theme,
    required this.emailController,
    required this.passwordController,
    required this.useDemoLogin,
  });

  @override
  State<LoginDesktop> createState() => _LoginDesktopState();
}

class _LoginDesktopState extends State<LoginDesktop> {
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
      final cleanEmail = widget.emailController.text.trim().toLowerCase();
      final res = await AuthService().signInWithResult(
        cleanEmail,
        widget.passwordController.text,
      );
      if (!mounted) return;
      if (res.ok) {
        setState(() {
          issLoading = false;
          showwSuccess = true;
        });

        Future.delayed(const Duration(seconds: 2), () {
          if (!mounted) return;
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/',
            (_) => false,
          );
        });
      } else {
        setState(() {
          issLoading = false;
        });
        if (res.code == 'email_not_confirmed') {
          showDialog(
            context: context,
            builder: (dialogCtx) {
              return ConfirmationAlert(
                theme: widget.theme,
                title: 'Email Not Verified',
                message: res.message,
                actionButtonText: 'Resend Email',
                action: () async {
                  Navigator.of(dialogCtx).pop();
                  final resend = await AuthService()
                      .resendVerificationLinkWithResult(cleanEmail);
                  if (!mounted) return;
                  showDialog(
                    context: context,
                    builder: (c) => InfoAlert(
                      theme: widget.theme,
                      title: resend.ok ? 'Verification Sent' : 'Resend Failed',
                      message:
                          resend.ok
                              ? 'A verification email has been sent to $cleanEmail. Please verify your email and log in again.'
                              : resend.message,
                    ),
                  );
                },
              );
            },
          );
        } else {
          showDialog(
            context: context,
            builder: (context) {
              return InfoAlert(
                theme: widget.theme,
                message: res.message,
                title: General().authenticationError,
              );
            },
          );
        }
      }
    }
  }

  FocusNode passwordNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.useDemoLogin) {
        widget.passwordController.text = 'test123';
        widget.emailController.text =
            'stockalltest@gmail.com';
        checkInputs();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: DesktopCenterContainer(
            mainWidget: Column(
              children: [
                SizedBox(height: 10),
                Row(
                  spacing: 10,
                  mainAxisAlignment:
                      MainAxisAlignment.center,
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
                              Provider.of<ThemeProvider>(
                                    context,
                                  )
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
                  controller: widget.emailController,
                  theme: widget.theme,
                  onSubmit: (value) {
                    mainLocalLog('Clicked');
                    passwordNode.requestFocus();
                  },
                ),
                SizedBox(height: 15),
                EmailTextField(
                  focusNode: passwordNode,
                  title: General().password,
                  hint: General().enterPassword,
                  isEmail: false,
                  controller: widget.passwordController,
                  theme: widget.theme,
                  onSubmit: (value) {
                    checkInputs();
                  },
                ),

                SizedBox(height: 20),
                Row(
                  spacing: 5,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        mouseCursor:
                            SystemMouseCursors.click,
                        onTap: () {
                          loginDemoAccountAction(
                            context: context,
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(
                            right: 10.0,
                            top: 10,
                            bottom: 10,
                            left: 15,
                          ),
                          child: Text(
                            style: TextStyle(
                              fontSize:
                                  widget
                                      .theme
                                      .mobileTexts
                                      .b3
                                      .fontSize,
                              fontWeight: FontWeight.bold,
                              color:
                                  widget
                                      .theme
                                      .lightModeColor
                                      .secColor100,
                            ),
                            'Login Demo',
                          ),
                        ),
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        mouseCursor:
                            SystemMouseCursors.click,
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
                          padding: const EdgeInsets.only(
                            right: 15.0,
                            top: 10,
                            bottom: 10,
                            left: 10,
                          ),
                          child: Text(
                            style: TextStyle(
                              fontSize:
                                  widget
                                      .theme
                                      .mobileTexts
                                      .b3
                                      .fontSize,
                              fontWeight: FontWeight.bold,
                              color:
                                  widget
                                      .theme
                                      .lightModeColor
                                      .secColor100,
                            ),
                            LoginPageTexts().forgetPassword,
                          ),
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
