import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storrec/components/alert_dialogues/info_alert.dart';
import 'package:storrec/components/buttons/main_button_p.dart';
import 'package:storrec/constants/constants_main.dart';
import 'package:storrec/pages/authentication/components/email_text_field.dart';
import 'package:storrec/pages/authentication/sign_up/signup_two.dart';
import 'package:storrec/providers/theme_provider.dart';

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
                                      'Welcome Back',
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
                                      "Please Fill in The form to Login to your Account",
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 30),
                            EmailTextField(
                              title: 'Email Address',
                              hint: 'Enter Email',
                              isEmail: true,
                              controller:
                                  widget.emailController,
                              theme: widget.theme,
                            ),
                            SizedBox(height: 15),
                            EmailTextField(
                              title: 'Password',
                              hint: 'Enter Password',
                              isEmail: false,
                              controller:
                                  widget.passwordController,
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
                            SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
