import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/components/email_text_field.dart';
import 'package:stockall/pages/authentication/translations/auth_texts_en.dart';
import 'package:stockall/pages/authentication/translations/general.dart';
import 'package:stockall/pages/authentication/verify_phone/verify_phone.dart';
import 'package:stockall/pages/home/home.dart';
import 'package:stockall/providers/theme_provider.dart';
import 'package:stockall/services/auth_service.dart';

class ForgotPasswordDesktop extends StatefulWidget {
  final TextEditingController emailController;
  final bool? isMain;
  const ForgotPasswordDesktop({
    super.key,
    required this.emailController,
    required this.isMain,
  });

  @override
  State<ForgotPasswordDesktop> createState() =>
      _ForgotPasswordDesktopState();
}

class _ForgotPasswordDesktopState
    extends State<ForgotPasswordDesktop> {
  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$",
    );
    return emailRegex.hasMatch(email);
  }

  bool issLoading = false;

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
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
                            Column(
                              spacing: 8,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      style: TextStyle(
                                        color:
                                            theme
                                                .lightModeColor
                                                .shadesColorBlack,
                                        fontSize:
                                            theme
                                                .mobileTexts
                                                .h3
                                                .fontSize,
                                        fontWeight:
                                            theme
                                                .mobileTexts
                                                .h3
                                                .fontWeightBold,
                                      ),
                                      ForgetPasswordPageTexts()
                                          .forgetPassword,
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
                                      ForgetPasswordPageTexts()
                                          .enterEmailBelow,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            EmailTextField(
                              controller:
                                  widget.emailController,
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
                                  widget
                                      .emailController
                                      .text,
                                )) {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return InfoAlert(
                                        theme: theme,
                                        message:
                                            General()
                                                .emailIsBadlyFormatted,
                                        title:
                                            General()
                                                .invalidEmail,
                                      );
                                    },
                                  );
                                } else {
                                  setState(() {
                                    issLoading = true;
                                  });

                                  await AuthService()
                                      .sendPasswordResetEmail(
                                        widget
                                            .emailController
                                            .text
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
                                } else {
                                  Navigator.of(
                                    context,
                                  ).pop();
                                }
                              },
                              child: Container(
                                padding:
                                    EdgeInsets.symmetric(
                                      horizontal: 30,
                                      vertical: 10,
                                    ),
                                child: Center(
                                  child: Text(
                                    General().cancelText,
                                  ),
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
            ),
            Visibility(
              visible: issLoading,
              child: returnCompProvider(
                context,
                listen: false,
              ).showLoader(General().loadingText),
            ),
          ],
        ),
      ),
    );
  }
}
