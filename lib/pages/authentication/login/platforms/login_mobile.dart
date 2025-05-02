import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockitt/components/alert_dialogues/info_alert.dart';
import 'package:stockitt/components/buttons/main_button_p.dart';
import 'package:stockitt/constants/constants_main.dart';
import 'package:stockitt/pages/authentication/components/email_text_field.dart';
import 'package:stockitt/pages/authentication/sign_up/signup_two.dart';
import 'package:stockitt/providers/theme_provider.dart';

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
  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$",
    );
    return emailRegex.hasMatch(email);
  }

  void checkInputs() {
    if (widget.emailController.text.isEmpty ||
        widget.passwordController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          var theme = Provider.of<ThemeProvider>(context);
          return InfoAlert(
            theme: theme,
            message: 'Please fill out all Fields',
            title: 'Empty Input',
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
            message:
                'Email Address is Badly Formatted. Please Enter a Valid Email Address',
            title: 'Invalid Email',
          );
        },
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return SignupTwo();
          },
        ),
      );
      widget.emailController.clear();
      widget.passwordController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        'Stockitt',
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
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
                            'Welcome Back',
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
                              "Please Fill in The form to Login to your Account",
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  EmailTextField(
                    title: 'Email Address*',
                    hint: 'Enter Email',
                    isEmail: true,
                    controller: widget.emailController,
                    theme: widget.theme,
                  ),
                  SizedBox(height: 15),
                  EmailTextField(
                    title: 'Password*',
                    hint: 'Enter Password',
                    isEmail: false,
                    controller: widget.passwordController,
                    theme: widget.theme,
                  ),

                  SizedBox(height: 20),
                  MainButtonP(
                    themeProvider: widget.theme,
                    action: () {
                      checkInputs();
                    },
                    text: 'Login',
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
