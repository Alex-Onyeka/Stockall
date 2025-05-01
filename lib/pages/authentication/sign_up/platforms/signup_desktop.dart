import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockitt/components/alert_dialogues/info_alert.dart';
import 'package:stockitt/components/buttons/main_button_p.dart';
import 'package:stockitt/constants/constants_main.dart';
import 'package:stockitt/pages/authentication/components/check_agree.dart';
import 'package:stockitt/pages/authentication/components/email_text_field.dart';
import 'package:stockitt/pages/authentication/sign_up/signup_two.dart';
import 'package:stockitt/providers/theme_provider.dart';

class SignupDesktop extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final Function(bool?)? onChanged;
  final Function()? onTap;
  final bool checked;

  final ThemeProvider theme;
  const SignupDesktop({
    super.key,
    required this.theme,
    required this.confirmPasswordController,
    required this.emailController,
    required this.onChanged,
    required this.onTap,
    required this.passwordController,
    required this.checked,
  });

  @override
  State<SignupDesktop> createState() =>
      _SignupDesktopState();
}

class _SignupDesktopState extends State<SignupDesktop> {
  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$",
    );
    return emailRegex.hasMatch(email);
  }

  void checkInputs() {
    if (widget.emailController.text.isEmpty ||
        widget.passwordController.text.isEmpty ||
        widget.confirmPasswordController.text.isEmpty) {
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
    } else if (widget.passwordController.text !=
        widget.confirmPasswordController.text) {
      showDialog(
        context: context,
        builder: (context) {
          var theme = Provider.of<ThemeProvider>(context);
          return InfoAlert(
            theme: theme,
            message: 'The Password Fields Does not match',
            title: 'Password Mismatch',
          );
        },
      );
    } else if (widget.checked == false) {
      showDialog(
        context: context,
        builder: (context) {
          var theme = Provider.of<ThemeProvider>(context);
          return InfoAlert(
            theme: theme,
            message: 'Agree to Terms and Conditions',
            title: 'Check the Box to Continue',
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
      widget.confirmPasswordController.clear();
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
            image: AssetImage(
              'assets/images/main_images/sign_up_background.jpg',
            ),
            fit:
                BoxFit
                    .cover, // Options: cover, contain, fill, fitWidth, fitHeight
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
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
                        borderRadius: BorderRadius.circular(
                          20,
                        ),
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
                                'Stockitt',
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
                                    'Get Started Now',
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
                                    "Let's create you Account",
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 30),
                          EmailTextField(
                            title: 'Set Email Address',
                            hint: 'Enter Email',
                            isEmail: true,
                            controller:
                                widget.emailController,
                            theme: widget.theme,
                          ),
                          SizedBox(height: 15),
                          EmailTextField(
                            title: 'Set Password',
                            hint: 'Enter Password',
                            isEmail: false,
                            controller:
                                widget.passwordController,
                            theme: widget.theme,
                          ),
                          SizedBox(height: 15),
                          EmailTextField(
                            title: 'Confirm Password',
                            hint: 'Confirm Password',
                            isEmail: false,
                            controller:
                                widget
                                    .confirmPasswordController,
                            theme: widget.theme,
                          ),

                          SizedBox(height: 20),
                          CheckAgree(
                            onChanged: widget.onChanged,
                            checked: widget.checked,
                            theme: widget.theme,
                            onTap: widget.onTap,
                          ),
                          SizedBox(height: 20),
                          MainButtonP(
                            themeProvider: widget.theme,
                            action: () {
                              checkInputs();
                            },
                            text: 'Create Account',
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
