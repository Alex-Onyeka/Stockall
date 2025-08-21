import 'dart:async';
import 'package:stockall/helpers/clean_up_url.dart';
import 'package:flutter/material.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/buttons/main_button_transparent.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/auth_landing/auth_landing.dart';
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
  bool isExpired = false;

  int time = 120;
  Timer? _timer;

  void startCountDownTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (
      timer,
    ) async {
      if (time > 0) {
        setState(() {
          time--;
        });
      } else {
        timer.cancel();
        setState(() {
          isExpired = true;
        });
        await Future.delayed(Duration(seconds: 2));
        if (context.mounted) {
          await AuthService().signOut(context);
        }
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) {
                return AuthLanding();
              },
            ),
          );
        }
      }
    });
  }

  String formatTime(int time) {
    if (time < 60) {
      return '${time.toString()} secs';
    } else if (time >= 60 && time < 120) {
      return '1:${time - 60} secs';
    } else if (time >= 120 && time < 180) {
      return '2:${time - 120} secs';
    } else {
      return '3:${time - 180} secs';
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    startCountDownTimer();
  }

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
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    spacing: 5,
                    children: [
                      Text('Remaining Token Valid Time'),
                      Text(
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:
                              time < 60
                                  ? theme
                                      .lightModeColor
                                      .errorColor200
                                  : null,
                        ),
                        formatTime(time),
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
                      } else {
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
                                setState(() {
                                  isLoading = true;
                                });

                                var res = await AuthService()
                                    .changePasswordAndUpdateLocal(
                                      newPassword:
                                          widget
                                              .passwordC
                                              .text,
                                      context: safeContex,
                                    );

                                if (res == '422' &&
                                    safeContex.mounted) {
                                  await showDialog(
                                    context: safeContex,
                                    builder: (context) {
                                      return InfoAlert(
                                        theme: theme,
                                        message:
                                            'New password cannot be the same as the old password.',
                                        title:
                                            'Password Not Changed',
                                      );
                                    },
                                  );
                                  setState(() {
                                    isLoading = false;
                                  });
                                  return;
                                }

                                setState(() {
                                  isLoading = false;
                                  showSuccess = true;
                                });

                                cleanUpUrl();

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
                    text: 'Update Passord',
                  ),
                  SizedBox(height: 10),
                  MainButtonTransparent(
                    themeProvider: theme,
                    constraints: BoxConstraints(),
                    text: 'Cancel',
                    action: () async {
                      await AuthService().signOut(context);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
        Visibility(
          visible: isExpired,
          child: Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 60.0,
                ),
                child: Column(
                  spacing: 10,
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color.fromARGB(
                          42,
                          158,
                          158,
                          158,
                        ),
                      ),
                      child: Icon(
                        size: 40,
                        color:
                            theme
                                .lightModeColor
                                .errorColor200,
                        Icons.clear,
                      ),
                    ),
                    Text(
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.h2.fontSize,
                        fontWeight: FontWeight.bold,
                        color:
                            theme.lightModeColor.prColor200,
                      ),
                      'Password Token Expired',
                    ),
                  ],
                ),
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
