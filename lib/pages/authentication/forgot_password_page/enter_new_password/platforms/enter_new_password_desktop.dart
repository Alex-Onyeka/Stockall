import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/buttons/main_button_transparent.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/helpers/clean_up_url/clean_up_url_stub.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/auth_landing/auth_landing.dart';
import 'package:stockall/pages/authentication/components/email_text_field.dart';
import 'package:stockall/pages/authentication/translations/auth_texts_en.dart';
import 'package:stockall/pages/authentication/translations/general.dart';
import 'package:stockall/services/auth_service.dart';

class EnterNewPasswordDesktop extends StatefulWidget {
  final TextEditingController passwordC;
  final TextEditingController confirmPasswordC;
  const EnterNewPasswordDesktop({
    super.key,
    required this.passwordC,
    required this.confirmPasswordC,
  });

  @override
  State<EnterNewPasswordDesktop> createState() =>
      _EnterNewPasswordDesktopState();
}

class _EnterNewPasswordDesktopState
    extends State<EnterNewPasswordDesktop> {
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
          // ignore: use_build_context_synchronously
          await AuthService().signOut(context);
        }
        if (context.mounted) {
          Navigator.pushReplacement(
            // ignore: use_build_context_synchronously
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
                                      EnterNewPasswordTexts()
                                          .changePassword,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 30),
                            SingleChildScrollView(
                              child: Column(
                                children: [
                                  SizedBox(height: 30),
                                  Column(
                                    children: [
                                      EmailTextField(
                                        isEmail: false,
                                        title:
                                            EnterNewPasswordTexts()
                                                .newPassword,
                                        hint:
                                            EnterNewPasswordTexts()
                                                .enterNewPassword,
                                        controller:
                                            widget
                                                .passwordC,
                                        theme: theme,
                                      ),
                                      SizedBox(height: 10),
                                      EmailTextField(
                                        isEmail: false,
                                        title:
                                            EnterNewPasswordTexts()
                                                .confirmPassword,
                                        hint:
                                            EnterNewPasswordTexts()
                                                .confirmNewPassword,
                                        controller:
                                            widget
                                                .confirmPasswordC,
                                        theme: theme,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,
                                    spacing: 5,
                                    children: [
                                      Text(
                                        EnterNewPasswordTexts()
                                            .remainingTokenTime,
                                      ),
                                      Text(
                                        style: TextStyle(
                                          fontWeight:
                                              FontWeight
                                                  .bold,
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
                                      if (widget
                                              .passwordC
                                              .text
                                              .isEmpty ||
                                          widget
                                              .confirmPasswordC
                                              .text
                                              .isEmpty) {
                                        showDialog(
                                          context: context,
                                          builder: (
                                            context,
                                          ) {
                                            return InfoAlert(
                                              theme: theme,
                                              message:
                                                  EnterNewPasswordTexts()
                                                      .nameFieldCantBeEmpty,
                                              title:
                                                  General()
                                                      .emptyFields,
                                            );
                                          },
                                        );
                                      } else if (widget
                                              .passwordC
                                              .text !=
                                          widget
                                              .confirmPasswordC
                                              .text) {
                                        showDialog(
                                          context: context,
                                          builder: (
                                            context,
                                          ) {
                                            return InfoAlert(
                                              theme: theme,
                                              message:
                                                  EnterNewPasswordTexts()
                                                      .passwordsDoNotMatch,
                                              title:
                                                  EnterNewPasswordTexts()
                                                      .passswordMismatch,
                                            );
                                          },
                                        );
                                      } else {
                                        final safeContex =
                                            context;

                                        showDialog(
                                          context:
                                              safeContex,
                                          builder: (
                                            context,
                                          ) {
                                            return ConfirmationAlert(
                                              theme: theme,
                                              message:
                                                  General()
                                                      .areYouSure,
                                              title:
                                                  '${General().proceed}?',
                                              action: () async {
                                                // Navigator.of(context).pop();

                                                setState(() {
                                                  isLoading =
                                                      true;
                                                });

                                                var res = await AuthService().changePasswordAndUpdateLocal(
                                                  newPassword:
                                                      widget
                                                          .passwordC
                                                          .text,
                                                  context:
                                                      safeContex,
                                                );

                                                if (res ==
                                                        '422' &&
                                                    safeContex
                                                        .mounted) {
                                                  await showDialog(
                                                    context:
                                                        safeContex,
                                                    builder: (
                                                      context,
                                                    ) {
                                                      return InfoAlert(
                                                        theme:
                                                            theme,
                                                        message:
                                                            EnterNewPasswordTexts().newPasswordCannotBeTheSame,
                                                        title:
                                                            EnterNewPasswordTexts().passwordNotChanged,
                                                      );
                                                    },
                                                  );
                                                  setState(() {
                                                    isLoading =
                                                        false;
                                                  });
                                                  return;
                                                }

                                                setState(() {
                                                  isLoading =
                                                      false;
                                                  showSuccess =
                                                      true;
                                                });

                                                cleanUpUrl();

                                                if (safeContex
                                                    .mounted) {
                                                  Navigator.pushNamedAndRemoveUntil(
                                                    context,
                                                    '/',
                                                    (
                                                      route,
                                                    ) =>
                                                        false,
                                                  );
                                                }

                                                setState(() {
                                                  isLoading =
                                                      false;
                                                  showSuccess =
                                                      false;
                                                });
                                              },
                                            );
                                          },
                                        );
                                      }
                                    },
                                    text:
                                        EnterNewPasswordTexts()
                                            .updatePassword,
                                  ),
                                  SizedBox(height: 10),
                                  MainButtonTransparent(
                                    themeProvider: theme,
                                    constraints:
                                        BoxConstraints(),
                                    text:
                                        General()
                                            .cancelText,
                                    action: () async {
                                      await AuthService()
                                          .signOut(context);
                                      if (context.mounted) {
                                        Navigator.of(
                                          context,
                                        ).pop();
                                      }
                                    },
                                  ),
                                  SizedBox(height: 30),
                                ],
                              ),
                            ),
                            SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  ],
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
                                theme
                                    .mobileTexts
                                    .h2
                                    .fontSize,
                            fontWeight: FontWeight.bold,
                            color:
                                theme
                                    .lightModeColor
                                    .prColor200,
                          ),
                          EnterNewPasswordTexts()
                              .passwordTokenExpired,
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
              ).showLoader(General().loadingText),
            ),
            Visibility(
              visible: showSuccess,
              child: returnCompProvider(
                context,
                listen: false,
              ).showSuccess(
                EnterNewPasswordTexts()
                    .passwordUpdatedSuccessfully,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
