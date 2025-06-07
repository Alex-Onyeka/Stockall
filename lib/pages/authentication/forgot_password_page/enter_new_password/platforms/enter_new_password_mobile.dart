import 'package:stockall/helpers/clean_up_url.dart';

import 'package:flutter/material.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/buttons/main_button_transparent.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/components/email_text_field.dart';
import 'package:stockall/services/auth_service.dart';

class EnterNewPasswordMobile extends StatefulWidget {
  final TextEditingController passwordC;
  final TextEditingController confirmPasswordC;
  final String? accessToken;

  const EnterNewPasswordMobile({
    super.key,
    required this.passwordC,
    required this.confirmPasswordC,
    this.accessToken,
  });

  @override
  State<EnterNewPasswordMobile> createState() =>
      _EnterNewPasswordMobileState();
}

class _EnterNewPasswordMobileState
    extends State<EnterNewPasswordMobile> {
  bool isLoading = false;
  bool showSuccess = false;

  // late Future<TempUserClass> userFuture;
  // Future<TempUserClass> getUser() async {
  //   var tempUser =
  //       await returnUserProvider(
  //         context,
  //         listen: false,
  //       ).fetchCurrentUser();

  //   return tempUser!;
  // }

  // @override
  // void initState() {
  //   super.initState();
  //   userFuture = getUser();
  // }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Stack(
      children: [
        Scaffold(
          appBar: appBar(
            context: context,
            title: 'Change Password',
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 30.0,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 30),

                  Column(
                    children: [
                      EmailTextField(
                        isEmail: false,
                        title: 'New Password',
                        hint: 'Enter New Password',
                        controller: widget.passwordC,
                        theme: theme,
                      ),
                      SizedBox(height: 10),
                      EmailTextField(
                        isEmail: false,
                        title: 'Confirm Password',
                        hint: 'Confirm New Password',
                        controller: widget.confirmPasswordC,
                        theme: theme,
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  MainButtonP(
                    themeProvider: theme,
                    action: () {
                      if (widget.passwordC.text.isEmpty ||
                          widget
                              .confirmPasswordC
                              .text
                              .isEmpty) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return InfoAlert(
                              theme: theme,
                              message:
                                  'Name field can\'t be empty. Enter all fields and try again.',
                              title: 'Empty Fields',
                            );
                          },
                        );
                      } else if (widget.passwordC.text !=
                          widget.confirmPasswordC.text) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return InfoAlert(
                              theme: theme,
                              message:
                                  'Passwords do not match. Please check the passwords fields and try again.',
                              title: 'Password Mismatch',
                            );
                          },
                        );
                      }
                      // else if (user.password ==
                      //     widget.passwordC.text) {
                      //   showDialog(
                      //     context: context,
                      //     builder: (context) {
                      //       return InfoAlert(
                      //         theme: theme,
                      //         message:
                      //             'New password should be different from the old password.',
                      //         title:
                      //             'Password The Same',
                      //       );
                      //     },
                      //   );
                      // }
                      else {
                        final safeContex = context;

                        showDialog(
                          context: safeContex,
                          builder: (context) {
                            return ConfirmationAlert(
                              theme: theme,
                              message:
                                  'Are you sure you want to proceed?',
                              title: 'Proceed?',
                              action: () async {
                                // Navigator.of(
                                //   safeContex,
                                // ).pop();
                                setState(() {
                                  isLoading = true;
                                });

                                await AuthService()
                                    .changePasswordAndUpdateLocal(
                                      newPassword:
                                          widget
                                              .passwordC
                                              .text,
                                      context: safeContex,
                                    );

                                setState(() {
                                  isLoading = false;
                                  showSuccess = true;
                                });

                                cleanUpUrl('/');

                                if (safeContex.mounted) {
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    '/',
                                    (route) => false,
                                  );
                                }

                                setState(() {
                                  isLoading = false;
                                  showSuccess = false;
                                });
                              },
                            );
                          },
                        );
                      }
                    },
                    text: 'Update Details',
                  ),
                  SizedBox(height: 10),
                  MainButtonTransparent(
                    themeProvider: theme,
                    constraints: BoxConstraints(),
                    text: 'Cancel',
                    action: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  SizedBox(height: 30),
                ],
              ),
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
        Visibility(
          visible: showSuccess,
          child: returnCompProvider(
            context,
            listen: false,
          ).showSuccess('Password Updated Successfully'),
        ),
      ],
    );
  }
}
