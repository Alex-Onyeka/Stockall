import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_transparent.dart';
import 'package:stockall/components/text_fields/pin_code.dart';
import 'package:stockall/pages/authentication/base_page/base_page.dart';
import 'package:stockall/providers/theme_provider.dart';
import 'package:stockall/services/auth_service.dart';

class VerifyEmailMobile extends StatefulWidget {
  final ThemeProvider theme;
  final bool isFirstTime;
  final TempUserClass user;
  final String userId;
  final TextEditingController pinController;
  const VerifyEmailMobile({
    super.key,
    required this.theme,
    required this.isFirstTime,
    required this.pinController,
    required this.user,
    required this.userId,
  });

  @override
  State<VerifyEmailMobile> createState() =>
      _VerifyEmailMobileState();
}

class _VerifyEmailMobileState
    extends State<VerifyEmailMobile> {
  bool isLoading = false;
  bool isResendLoading = false;
  int time = 0;
  Timer? _timer;

  void startCountDownTimer() {
    setState(() {
      time = 120;
    });
    _timer = Timer.periodic(Duration(seconds: 1), (
      timer,
    ) async {
      if (time > 0) {
        setState(() {
          time--;
        });
      } else {
        timer.cancel();
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
    if (widget.isFirstTime) {
      startCountDownTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: Center(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(
                      20,
                      0,
                      0,
                      0,
                    ),
                    blurRadius: 10,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 30,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15.0,
                        ),
                        child: Column(
                          children: [
                            Text(
                              textAlign: TextAlign.center,
                              'Enter Code Below',
                              style: TextStyle(
                                color:
                                    widget
                                        .theme
                                        .lightModeColor
                                        .prColor300,
                                fontSize:
                                    widget
                                        .theme
                                        .mobileTexts
                                        .h3
                                        .fontSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 20),
                            PinCodeWidget(
                              controller:
                                  widget.pinController,
                              length: 6,
                              hideText: false,
                              action: () async {
                                await verifyOtp(
                                  widget.pinController.text,
                                );
                                widget.pinController
                                    .clear();
                              },
                            ),
                            SizedBox(height: 5),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              spacing: 3,
                              children: [
                                Text(
                                  textAlign:
                                      TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize:
                                        widget
                                            .theme
                                            .mobileTexts
                                            .b3
                                            .fontSize,
                                    fontWeight:
                                        FontWeight.normal,
                                  ),
                                  'Remaining Time: ',
                                ),
                                Text(
                                  textAlign:
                                      TextAlign.center,
                                  style: TextStyle(
                                    color:
                                        widget
                                            .theme
                                            .lightModeColor
                                            .secColor200,
                                    fontSize:
                                        widget
                                            .theme
                                            .mobileTexts
                                            .b2
                                            .fontSize,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                  time > 0
                                      ? formatTime(time)
                                      : 'OTP Expired',
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Visibility(
                              visible: time < 1,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () async {
                                    if (time < 20) {
                                      setState(() {
                                        isResendLoading =
                                            true;
                                      });
                                      await AuthService()
                                          .resendVerificationLink(
                                            widget
                                                .user
                                                .email,
                                            widget
                                                .user
                                                .password,
                                          );
                                      setState(() {
                                        isResendLoading =
                                            false;
                                        time = 120;
                                        startCountDownTimer();
                                      });
                                    }
                                  },
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.all(
                                          12.0,
                                        ),
                                    child: Row(
                                      mainAxisSize:
                                          MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment
                                              .center,
                                      spacing: 3,
                                      children: [
                                        Text(
                                          textAlign:
                                              TextAlign
                                                  .center,
                                          style: TextStyle(
                                            color:
                                                widget
                                                    .theme
                                                    .lightModeColor
                                                    .prColor300,
                                            fontSize:
                                                widget
                                                    .theme
                                                    .mobileTexts
                                                    .b2
                                                    .fontSize,
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                          ),
                                          'Resend OTP',
                                        ),
                                        Stack(
                                          alignment:
                                              Alignment(
                                                0,
                                                0,
                                              ),
                                          children: [
                                            Visibility(
                                              visible:
                                                  !isResendLoading,
                                              child: Icon(
                                                size: 26,
                                                color:
                                                    widget
                                                        .theme
                                                        .lightModeColor
                                                        .prColor300,
                                                Icons
                                                    .arrow_right,
                                              ),
                                            ),
                                            Visibility(
                                              visible:
                                                  isResendLoading,
                                              child: SizedBox(
                                                height: 15,
                                                width: 15,
                                                child: CircularProgressIndicator(
                                                  color:
                                                      Colors
                                                          .amber,
                                                  strokeWidth:
                                                      2,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 15),
                            Stack(
                              alignment: Alignment(0, 0),
                              children: [
                                MainButtonTransparent(
                                  themeProvider:
                                      widget.theme,
                                  constraints:
                                      BoxConstraints(),
                                  text: 'Log Out',
                                  action: () async {
                                    await AuthService()
                                        .signOut(context);
                                  },
                                ),
                                // Text('this'),
                                Visibility(
                                  visible: isLoading,
                                  child: Container(
                                    height: 39,
                                    width: 200,
                                    color: Colors.white,
                                    child: Center(
                                      child: SizedBox(
                                        height: 20,
                                        width: 20,
                                        child:
                                            CircularProgressIndicator(
                                              color:
                                                  Colors
                                                      .amber,
                                              strokeWidth:
                                                  3,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 50),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> verifyOtp(String otp) async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });
      var res = await AuthService().verifyOtp(
        otp: otp,
        user: widget.user,
        context: context,
        userId: widget.userId,
      );
      if (res == 1) {
        await AuthService().client.auth.refreshSession();
        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(
            builder: (context) {
              return BasePage();
            },
          ),
        );
      } else {
        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (context) {
            return InfoAlert(
              theme: widget.theme,
              message:
                  'The PIN you entered is Incorrect. Please request for a new PIN, and Try again.',
              title: 'Wrong/Expired Pin',
            );
          },
        );
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}
