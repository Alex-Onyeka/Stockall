import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockall/classes/temp_user_class.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/text_fields/general_textfield.dart';
import 'package:stockall/components/text_fields/phone_number_text_field.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/pages/authentication/components/check_agree.dart';
import 'package:stockall/pages/authentication/components/email_text_field.dart';
import 'package:stockall/pages/shop_setup/banner_screen/shop_banner_screen.dart';
import 'package:stockall/providers/comp_provider.dart';
import 'package:stockall/providers/theme_provider.dart';
import 'package:stockall/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupMobile extends StatefulWidget {
  final ThemeProvider theme;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final TextEditingController nameController;
  final TextEditingController phoneNumberController;
  final TextEditingController lastNameController;
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
    required this.lastNameController,
  });

  @override
  State<SignupMobile> createState() => _SignupMobileState();
}

bool showSuccess = false;
bool isLoading = false;

class _SignupMobileState extends State<SignupMobile> {
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
          appBar: AppBar(
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: Colors.white,
            leading: InkWell(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 20.0,
                  right: 10,
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
            child: Column(
              children: [
                Expanded(
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
                            SizedBox(height: 15),
                            Column(
                              spacing: 4,
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
                                      'Create User Account',
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
                                      "Let's create your User Account",
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 15),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              spacing: 10,
                              children: [
                                Expanded(
                                  child: GeneralTextField(
                                    title: 'First Name*',
                                    hint:
                                        'Enter Your First Name',
                                    controller:
                                        widget
                                            .nameController,
                                    lines: 1,
                                    theme: widget.theme,
                                  ),
                                ),
                                Expanded(
                                  child: GeneralTextField(
                                    title:
                                        'Last Name (Optional)',
                                    hint: 'Enter Last Name',
                                    controller:
                                        widget
                                            .lastNameController,
                                    lines: 1,
                                    theme: widget.theme,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            EmailTextField(
                              title: 'User Email Address*',
                              hint: 'Enter Email',
                              isEmail: true,
                              controller:
                                  widget.emailController,
                              theme: widget.theme,
                            ),
                            SizedBox(height: 10),
                            EmailTextField(
                              title: 'Set Password*',
                              hint: 'Enter Password',
                              isEmail: false,
                              controller:
                                  widget.passwordController,
                              theme: widget.theme,
                            ),
                            SizedBox(height: 10),
                            EmailTextField(
                              title: 'Confirm Password*',
                              hint: 'Confirm Password',
                              isEmail: false,
                              controller:
                                  widget
                                      .confirmPasswordController,
                              theme: widget.theme,
                            ),
                            SizedBox(height: 10),
                            PhoneNumberTextField(
                              title: 'User Phone Number*',
                              hint:
                                  'Enter your Phone Number',
                              controller:
                                  widget
                                      .phoneNumberController,
                              theme: widget.theme,
                            ),
                            SizedBox(height: 15),
                            CheckAgree(
                              onChanged: widget.onChanged,
                              checked: widget.checked,
                              theme: widget.theme,
                              onTap: widget.onTap,
                            ),
                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 35.0,
                  ),
                  child: Column(
                    children: [
                      MainButtonP(
                        themeProvider: widget.theme,
                        action: () {
                          checkInputs();
                        },
                        text: 'Create User Account',
                      ),
                      SizedBox(height: 15),
                      // MainButtonTransparent(
                      //   themeProvider: widget.theme,
                      //   constraints: BoxConstraints(),
                      //   text: 'Go Back',
                      //   action: () {
                      //     Navigator.of(context).pop();
                      //   },
                      // ),
                    ],
                  ),
                ),
              ],
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
