import 'package:flutter/material.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/components/email_text_field.dart';
import 'package:stockall/pages/authentication/translations/auth_texts_en.dart';
import 'package:stockall/pages/authentication/translations/general.dart';
import 'package:stockall/pages/authentication/verify_phone/verify_phone.dart';
import 'package:stockall/pages/home/home.dart';
import 'package:stockall/services/auth_service.dart';

class ForgotPasswordMobile extends StatefulWidget {
  final TextEditingController emailController;
  final bool? isMain;
  const ForgotPasswordMobile({
    super.key,
    required this.emailController,
    this.isMain,
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
            isMain: widget.isMain,
            context: context,
            title: ForgetPasswordPageTexts().forgetPassword,
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 25.0,
            ),
            child: Column(
              children: [
                SizedBox(height: 20),
                Text(
                  ForgetPasswordPageTexts().enterEmailBelow,
                ),
                SizedBox(height: 20),
                EmailTextField(
                  controller: widget.emailController,
                  theme: theme,
                  isEmail: true,
                  hint: General().enterEmail,
                  title: General().email,
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
                                ForgetPasswordPageTexts()
                                    .emailCantBeEmpty,
                            title:
                                ForgetPasswordPageTexts()
                                    .emptyEmailField,
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
                                General()
                                    .emailIsBadlyFormatted,
                            title: General().invalidEmail,
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
                  text:
                      ForgetPasswordPageTexts()
                          .sendRecoveryLink,
                ),
                SizedBox(height: 20),
                InkWell(
                  onTap: () {
                    if (widget.isMain != null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return Home();
                          },
                        ),
                      );
                      // performRestart();
                      // Navigator.of(context).pop();
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 10,
                    ),
                    child: Center(
                      child: Text(General().cancelText),
                    ),
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
          ).showLoader(General().loadingText),
        ),
      ],
    );
  }
}
