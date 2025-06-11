import 'package:flutter/material.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/components/email_text_field.dart';
import 'package:stockall/pages/authentication/verify_phone/verify_phone.dart';
import 'package:stockall/services/auth_service.dart';

class ForgotPasswordMobile extends StatefulWidget {
  final TextEditingController emailController;
  const ForgotPasswordMobile({
    super.key,
    required this.emailController,
  });

  @override
  State<ForgotPasswordMobile> createState() =>
      _ForgotPasswordMobileState();
}

class _ForgotPasswordMobileState
    extends State<ForgotPasswordMobile> {
  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$",
    );
    return emailRegex.hasMatch(email);
  }

  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Stack(
      children: [
        Scaffold(
          appBar: appBar(
            context: context,
            title: 'Forgot Password',
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 25.0,
            ),
            child: Column(
              children: [
                SizedBox(height: 20),
                Text(
                  'Enter your email below and you will receive a password reset token.',
                ),
                SizedBox(height: 20),
                EmailTextField(
                  controller: widget.emailController,
                  theme: theme,
                  isEmail: true,
                  hint: 'Enter Email',
                  title: 'Email',
                ),
                SizedBox(height: 20),
                MainButtonP(
                  themeProvider: theme,
                  action: () async {
                    if (widget
                        .emailController
                        .text
                        .isEmpty) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return InfoAlert(
                            theme: theme,
                            message:
                                'Email Field can\'t be empty. Please enter your email and try again.',
                            title: 'Empty Email Field',
                          );
                        },
                      );
                    } else if (!isValidEmail(
                      widget.emailController.text,
                    )) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return InfoAlert(
                            theme: theme,
                            message:
                                'Email is Invalid. Please enter a vaild email and try again.',
                            title: 'Ivalid Email',
                          );
                        },
                      );
                    } else {
                      setState(() {
                        isLoading = true;
                      });

                      await AuthService()
                          .sendPasswordResetEmail(
                            widget.emailController.text
                                .trim(),
                          );
                      if (context.mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return VerifyPhone();
                            },
                          ),
                        );
                      }
                    }
                  },
                  text: 'Send Recovery Link',
                ),
                SizedBox(height: 20),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 10,
                    ),
                    child: Center(child: Text('Cancel')),
                  ),
                ),
              ],
            ),
          ),
        ),
        Visibility(
          visible: isLoading,
          child: returnCompProvider(
            context,
            listen: false,
          ).showLoader('Loading'),
        ),
      ],
    );
  }
}
