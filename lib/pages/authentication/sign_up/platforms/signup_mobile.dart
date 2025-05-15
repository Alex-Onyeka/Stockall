import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockitt/classes/temp_user_class.dart';
import 'package:stockitt/components/alert_dialogues/info_alert.dart';
import 'package:stockitt/components/buttons/main_button_p.dart';
import 'package:stockitt/components/text_fields/phone_number_text_field.dart';
import 'package:stockitt/constants/constants_main.dart';
import 'package:stockitt/pages/authentication/components/check_agree.dart';
import 'package:stockitt/pages/authentication/components/email_text_field.dart';
import 'package:stockitt/pages/shop_setup/banner_screen/shop_banner_screen.dart';
import 'package:stockitt/providers/comp_provider.dart';
import 'package:stockitt/providers/theme_provider.dart';
import 'package:stockitt/services/auth_service.dart';

class SignupMobile extends StatefulWidget {
  final ThemeProvider theme;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final TextEditingController nameController;
  final TextEditingController phoneNumberController;
  final Function()? onTap;
  final bool checked;
  final Function(bool?)? onChanged;

  const SignupMobile({
    super.key,
    required this.theme,
    required this.confirmPasswordController,
    required this.emailController,
    required this.passwordController,
    required this.onChanged,
    required this.onTap,
    required this.checked,
    required this.nameController,
    required this.phoneNumberController,
  });

  @override
  State<SignupMobile> createState() => _SignupMobileState();
}

bool showSuccess = false;
bool isLoading = false;

class _SignupMobileState extends State<SignupMobile> {
  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$",
    );
    return emailRegex.hasMatch(email);
  }

  void checkInputs() async {
    if (widget.emailController.text.isEmpty ||
        widget.passwordController.text.isEmpty ||
        widget.confirmPasswordController.text.isEmpty ||
        widget.phoneNumberController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return InfoAlert(
            theme: widget.theme,
            message: 'Please fill out all Fields',
            title: 'Empty Input',
          );
        },
      );
    } else if (!isValidEmail(widget.emailController.text)) {
      showDialog(
        context: context,
        builder: (context) {
          return InfoAlert(
            theme: widget.theme,
            message:
                'Email Address is Badly Formatted. Please Enter a Valid Email Address',
            title: 'Invalid Email',
          );
        },
      );
    } else if (widget.passwordController.text.length < 6 ||
        widget.confirmPasswordController.text.length < 6) {
      showDialog(
        context: context,
        builder: (context) {
          return InfoAlert(
            theme: widget.theme,
            message:
                'Your Password is less than 6 characters, therefore, it is too short... Choose a password that\'s long',
            title: 'Weak Password',
          );
        },
      );
    } else if (widget.passwordController.text !=
        widget.confirmPasswordController.text) {
      showDialog(
        context: context,
        builder: (context) {
          return InfoAlert(
            theme: widget.theme,
            message: 'The Password Fields Does not match',
            title: 'Password Mismatch',
          );
        },
      );
    } else if (widget.checked == false) {
      showDialog(
        context: context,
        builder: (context) {
          return InfoAlert(
            theme: widget.theme,
            message: 'Agree to Terms and Conditions',
            title: 'Check the Box to Continue',
          );
        },
      );
    } else {
      setState(() {
        isLoading = true;
      });
      var res = await AuthService().signUpAndCreateUser(
        context: context,
        email: widget.emailController.text,
        password: widget.passwordController.text,
        user: TempUserClass(
          createdAt: DateTime.now(),
          name: widget.nameController.text,
          email: widget.emailController.text,
          phone: widget.phoneNumberController.text,
          role: 'Owner',
        ),
      );
      if (res.user != null) {
        setState(() {
          isLoading = false;
          showSuccess = true;
        });
        await Future.delayed(Duration(seconds: 3), () {
          Navigator.pushReplacement(
            // ignore: use_build_context_synchronously
            context,
            MaterialPageRoute(
              builder: (context) {
                return ShopBannerScreen();
              },
            ),
          );
        });
      }
      // Navigator
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
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
                      SizedBox(height: 50),
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
                        title: 'Set Email Address*',
                        hint: 'Enter Email',
                        isEmail: true,
                        controller: widget.emailController,
                        theme: widget.theme,
                      ),
                      SizedBox(height: 15),
                      EmailTextField(
                        title: 'Set Password*',
                        hint: 'Enter Password',
                        isEmail: false,
                        controller:
                            widget.passwordController,
                        theme: widget.theme,
                      ),
                      SizedBox(height: 15),
                      EmailTextField(
                        title: 'Confirm Password*',
                        hint: 'Confirm Password',
                        isEmail: false,
                        controller:
                            widget
                                .confirmPasswordController,
                        theme: widget.theme,
                      ),
                      SizedBox(height: 15),
                      PhoneNumberTextField(
                        title: 'Phone Number*',
                        hint: 'Enter your Phone Number',
                        controller:
                            widget.phoneNumberController,
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
                      SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Visibility(
            visible: isLoading,
            child: Provider.of<CompProvider>(
              context,
              listen: false,
            ).showLoader('Loading'),
          ),
          Visibility(
            visible: showSuccess,
            child: Provider.of<CompProvider>(
              context,
              listen: false,
            ).showSuccess('Account Created Successfully'),
          ),
        ],
      ),
    );
  }
}
