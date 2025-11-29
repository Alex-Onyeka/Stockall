import 'package:flutter/material.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/components/email_text_field.dart';
import 'package:stockall/pages/authentication/translations/auth_texts_en.dart';
import 'package:stockall/pages/authentication/translations/general.dart';
import 'package:stockall/pages/profile/change_email/code_sent_change/code_sent_page_change.dart';
import 'package:stockall/services/auth_service.dart';

class EnterNewEmailMobile extends StatefulWidget {
  final TextEditingController emailController;
  const EnterNewEmailMobile({
    super.key,
    required this.emailController,
  });

  @override
  State<EnterNewEmailMobile> createState() =>
      EnterNewEmailMobileState();
}

class EnterNewEmailMobileState
    extends State<EnterNewEmailMobile> {
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
            backAction: () {
              Navigator.of(context).pop();
            },
            context: context,
            title: 'Change Email Address',
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 25.0,
            ),
            child: Column(
              children: [
                SizedBox(height: 20),
                Text(
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b2.fontSize,
                  ),
                  'Enter the New Email you want to start using Below, and you will receive an OTP in the email you entered Below.',
                ),
                SizedBox(height: 20),
                EmailTextField(
                  controller: widget.emailController,
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
                      showDialog(
                        context: context,
                        builder: (confirmDialog) {
                          return ConfirmationAlert(
                            theme: theme,
                            message:
                                'Are you sure you want to proceed with sending this OTP to the new Email?',
                            title: 'Proceed to send OTP?',
                            action: () async {
                              Navigator.of(
                                confirmDialog,
                              ).pop();
                              setState(() {
                                isLoading = true;
                              });

                              await AuthService()
                                  .sendEmailResetOtp(
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
                                      return CodeSentPageChange(
                                        user:
                                            returnUserProvider(
                                              context,
                                              listen: false,
                                            ).currentUserMain!,
                                        newEmail:
                                            widget
                                                .emailController
                                                .text,
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
                  text: 'Send Otp',
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
          ).showLoader(message: General().loadingText),
        ),
      ],
    );
  }
}
