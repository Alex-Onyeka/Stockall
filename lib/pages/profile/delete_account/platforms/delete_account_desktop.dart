import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/base_page/base_page.dart';
import 'package:stockall/pages/authentication/components/email_text_field.dart';
import 'package:stockall/pages/authentication/translations/general.dart';
import 'package:stockall/providers/theme_provider.dart';
import 'package:stockall/services/auth_service.dart';

class DeleteAccountDesktop extends StatefulWidget {
  final TextEditingController passwordController;
  const DeleteAccountDesktop({
    super.key,
    required this.passwordController,
  });

  @override
  State<DeleteAccountDesktop> createState() =>
      DeleteAccountDesktopState();
}

class DeleteAccountDesktopState
    extends State<DeleteAccountDesktop> {
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
                                      'Delete Your Account',
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
                                        'Enter your Account Password to confirm you own this account, before deleting account.',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            EmailTextField(
                              controller:
                                  widget.passwordController,
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
                                        title:
                                            'Empty Password Field',
                                      );
                                    },
                                  );
                                } else if (returnUserProvider(
                                          context,
                                          listen: false,
                                        )
                                        .currentUserMain!
                                        .password !=
                                    widget
                                        .passwordController
                                        .text) {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return InfoAlert(
                                        theme: theme,
                                        message:
                                            'The password you entered is incorrect. Please cross-check the password and try again.',
                                        title:
                                            'Incorrect Password',
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
                                            'Are you sure you want to proceed with deleting your account. Please rethink your action before proceeding. Because this action cannot be reversed.',
                                        title:
                                            'Are You Sure?',
                                        action: () async {
                                          Navigator.of(
                                            confirmDialog,
                                          ).pop();
                                          setState(() {
                                            issLoading =
                                                true;
                                          });

                                          await AuthService()
                                              .deleteUserAccount(
                                                context,
                                              );
                                          if (context
                                              .mounted) {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (
                                                  context,
                                                ) {
                                                  return BasePage();
                                                },
                                              ),
                                            );
                                          } else {
                                            await mainLocalLog(
                                              'Context not Mounted',
                                            );
                                          }
                                        },
                                      );
                                    },
                                  );
                                }
                              },
                              text:
                                  'Proceed to delete Account',
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
