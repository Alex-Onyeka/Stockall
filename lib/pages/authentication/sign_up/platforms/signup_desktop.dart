import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/buttons/main_button_transparent.dart';
import 'package:stockall/components/major/desktop_center_container.dart';
import 'package:stockall/components/text_fields/general_textfield.dart';
import 'package:stockall/components/text_fields/phone_number_text_field.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/authentication/components/check_agree.dart';
import 'package:stockall/pages/authentication/components/email_text_field.dart';
import 'package:stockall/pages/shop_setup/banner_screen/shop_banner_screen.dart';
import 'package:stockall/providers/comp_provider.dart';
import 'package:stockall/providers/theme_provider.dart';
import 'package:stockall/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupDesktop extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final TextEditingController nameController;
  final TextEditingController phoneNumberController;
  final TextEditingController lastNameController;
  final Function(bool?)? onChanged;
  final Function()? onTap;
  final bool checked;

  final ThemeProvider theme;
  const SignupDesktop({
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
    required this.lastNameController,
  });

  @override
  State<SignupDesktop> createState() =>
      _SignupDesktopState();
}

class _SignupDesktopState extends State<SignupDesktop> {
  bool showSuccess = false;
  bool isLoading = false;
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
        widget.phoneNumberController.text.isEmpty ||
        widget.nameController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return InfoAlert(
            theme: widget.theme,
            message:
                'Please fill out all input Fields before proceeding to create your user account.',
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
    } else if (widget.passwordController.text.length < 6) {
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
            message:
                'You need to Agree to Terms and Conditions before proceeding to create your account.',
            title: 'Check the Box to Continue',
          );
        },
      );
    } else {
      setState(() {
        isLoading = true;
      });
      try {
        var res = await AuthService().signUpAndCreateUser(
          context: context,
          email:
              widget.emailController.text
                  .toLowerCase()
                  .trim(),
          password: widget.passwordController.text,
          user: TempUserClass(
            createdAt: DateTime.now(),
            name: widget.nameController.text.trim(),
            email:
                widget.emailController.text
                    .toLowerCase()
                    .trim(),
            phone: widget.phoneNumberController.text.trim(),
            role: 'Owner',
            password: widget.passwordController.text,
            lastName: widget.lastNameController.text,
          ),
        );

        if (res.user != null) {
          if (!mounted) return;
          setState(() {
            isLoading = false;
            showSuccess = true;
          });

          Future.delayed(Duration(seconds: 2), () {
            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ShopBannerScreen(),
              ),
            );
            setState(() {
              isLoading = false;
              showSuccess = false;
            });
          });
        } else {
          setState(() {
            isLoading = false;
          });
          if (!context.mounted) return;
          showDialog(
            // ignore: use_build_context_synchronously
            context: context,
            builder: (context) {
              return InfoAlert(
                theme: widget.theme,
                message:
                    'An error occurred while creating your account. Please check your details and try again.',
                title: 'An Error Occurred',
              );
            },
          );
        }
      } on AuthException catch (e) {
        setState(() {
          isLoading = false;
        });
        // print(e);
        if (!context.mounted) return;
        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (context) {
            return InfoAlert(
              theme: widget.theme,
              message:
                  e.statusCode == '422'
                      ? 'User already exists. Please use a different email, or try to login.'
                      : e.statusCode == null
                      ? 'No internet connection. Please check your network and try again.'
                      : 'An error occurred. Please try again later.',
              title: 'Authentication Error',
            );
          },
        );
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        if (!context.mounted) return;
        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (context) {
            return InfoAlert(
              theme: widget.theme,
              message: e.toString(),
              title: 'Unexpected Error',
            );
          },
        );
      }

      // Navigator
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: DesktopCenterContainer(
            mainWidget: SingleChildScrollView(
              child: Column(
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
                            'Get Started Now',
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
                            "Let's create you Account",
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    spacing: 10,
                    children: [
                      Expanded(
                        child: GeneralTextField(
                          title: 'First Name*',
                          hint: 'Enter Your First Name',
                          controller: widget.nameController,
                          lines: 1,
                          theme: widget.theme,
                        ),
                      ),
                      Expanded(
                        child: GeneralTextField(
                          title: 'Last Name (Optional)',
                          hint: 'Enter Last Name',
                          controller:
                              widget.lastNameController,
                          lines: 1,
                          theme: widget.theme,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  EmailTextField(
                    title: 'Set Email Address',
                    hint: 'Enter Email',
                    isEmail: true,
                    controller: widget.emailController,
                    theme: widget.theme,
                  ),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    spacing: 10,
                    children: [
                      Expanded(
                        child: EmailTextField(
                          title: 'Set Password',
                          hint: 'Enter Password',
                          isEmail: false,
                          controller:
                              widget.passwordController,
                          theme: widget.theme,
                        ),
                      ),
                      Expanded(
                        child: EmailTextField(
                          title: 'Confirm Password',
                          hint: 'Confirm Password',
                          isEmail: false,
                          controller:
                              widget
                                  .confirmPasswordController,
                          theme: widget.theme,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  PhoneNumberTextField(
                    title: 'User Phone Number*',
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
                  SizedBox(height: 10),
                  MainButtonTransparent(
                    themeProvider: widget.theme,
                    constraints: BoxConstraints(),
                    text: 'Go Back',
                    action: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  SizedBox(height: 10),
                ],
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
    );
  }
}
