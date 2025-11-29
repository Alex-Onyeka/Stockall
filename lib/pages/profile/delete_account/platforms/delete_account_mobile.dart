import 'package:flutter/material.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/base_page/base_page.dart';
import 'package:stockall/pages/authentication/components/email_text_field.dart';
import 'package:stockall/pages/authentication/translations/general.dart';
import 'package:stockall/services/auth_service.dart';

class DeleteAccountMobile extends StatefulWidget {
  final TextEditingController passwordController;
  const DeleteAccountMobile({
    super.key,
    required this.passwordController,
  });

  @override
  State<DeleteAccountMobile> createState() =>
      DeleteAccountMobileState();
}

class DeleteAccountMobileState
    extends State<DeleteAccountMobile> {
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
            title: 'Delete Your Account',
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
                  'Enter your Account Password to confirm you own this account, before deleting account.',
                ),
                SizedBox(height: 20),
                EmailTextField(
                  controller: widget.passwordController,
                  theme: theme,
                  isEmail: true,
                  hint: 'Enter Password',
                  title: 'Password',
                ),
                SizedBox(height: 20),
                MainButtonP(
                  themeProvider: theme,
                  action: () async {
                    if (widget
                        .passwordController
                        .text
                        .isEmpty) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return InfoAlert(
                            theme: theme,
                            message:
                                'Password Field cannot be empty. Please enter your password to Proceed',
                            title: 'Empty Password Field',
                          );
                        },
                      );
                    } else if (returnUserProvider(
                          context,
                          listen: false,
                        ).currentUserMain!.password !=
                        widget.passwordController.text) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return InfoAlert(
                            theme: theme,
                            message:
                                'The password you entered is incorrect. Please cross-check the password and try again.',
                            title: 'Incorrect Password',
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
                                'Are you sure you want to proceed with deleting your account. Please rethink your action before proceeding. Because this action cannot be reversed.',
                            title: 'Are You Sure?',
                            action: () async {
                              Navigator.of(
                                confirmDialog,
                              ).pop();
                              setState(() {
                                isLoading = true;
                              });

                              await AuthService()
                                  .deleteUserAccount(
                                    context,
                                  );
                              if (context.mounted) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return BasePage();
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
                  text: 'Proceed to delete Account',
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
