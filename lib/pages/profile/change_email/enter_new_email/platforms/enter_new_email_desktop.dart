import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/components/email_text_field.dart';
import 'package:stockall/pages/authentication/translations/auth_texts_en.dart';
import 'package:stockall/pages/authentication/translations/general.dart';
import 'package:stockall/pages/profile/change_email/code_sent_change/code_sent_page_change.dart';
import 'package:stockall/providers/theme_provider.dart';
import 'package:stockall/services/auth_service.dart';

class EnterNewEmailDesktop extends StatefulWidget {
  final TextEditingController emailController;
  const EnterNewEmailDesktop({
    super.key,
    required this.emailController,
  });

  @override
  State<EnterNewEmailDesktop> createState() =>
      EnterNewEmailDesktopState();
}

class EnterNewEmailDesktopState
    extends State<EnterNewEmailDesktop> {
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
                                      'Change Email Address',
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        style:
                                            Provider.of<
                                                  ThemeProvider
                                                >(context)
                                                .mobileTexts
                                                .b2
                                                .textStyleNormal,
                                        'Enter the New Email you want to start using Below, and you will receive an OTP in the email you entered Below.',
                                      ),
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
                              hint: 'Enter New Email',
                              title: 'New Email',
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
                                  showDialog(
                                    context: context,
                                    builder: (
                                      confirmDialog,
                                    ) {
                                      return ConfirmationAlert(
                                        theme: theme,
                                        message:
                                            'Are you sure you want to proceed with sending this OTP to the new Email?',
                                        title:
                                            'Proceed to send OTP?',
                                        action: () async {
                                          Navigator.of(
                                            confirmDialog,
                                          ).pop();
                                          setState(() {
                                            issLoading =
                                                true;
                                          });

                                          await AuthService()
                                              .sendEmailResetOtp(
                                                widget
                                                    .emailController
                                                    .text
                                                    .trim(),
                                              );
                                          if (context
                                              .mounted) {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (
                                                  context,
                                                ) {
                                                  return CodeSentPageChange(
                                                    user:
                                                        returnUserProvider(
                                                          context,
                                                          listen:
                                                              false,
                                                        ).currentUserMain!,
                                                    newEmail:
                                                        widget.emailController.text,
                                                  );
                                                },
                                              ),
                                            );
                                          } else {
                                            print(
                                              'Context not Mounted',
                                            );
                                          }
                                        },
                                      );
                                    },
                                  );
                                }
                              },
                              text: 'Send Reset OTP',
                            ),
                            SizedBox(height: 20),
                            InkWell(
                              mouseCursor:
                                  SystemMouseCursors.click,
                              onTap: () {
                                Navigator.of(context).pop();
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
              ).showLoader(message: General().loadingText),
            ),
          ],
        ),
      ),
    );
  }
}
