import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_transparent.dart';
import 'package:stockall/components/text_fields/pin_code.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/authentication/base_page/base_page.dart';
import 'package:stockall/providers/theme_provider.dart';
import 'package:stockall/services/auth_service.dart';
import 'package:stockall/main.dart';

class VerifyEmailDesktop extends StatefulWidget {
  final ThemeProvider theme;
  final bool isFirstTime;
  final TempUserClass user;
  final TextEditingController pinController;
  final String userId;
  const VerifyEmailDesktop({
    super.key,
    required this.theme,
    required this.isFirstTime,
    required this.pinController,
    required this.user,
    required this.userId,
  });

  @override
  State<VerifyEmailDesktop> createState() =>
      _VerifyEmailDesktopState();
}

class _VerifyEmailDesktopState
    extends State<VerifyEmailDesktop> {
  bool isLoading = false;
  bool isResendLoading = false;
  int time = 0;
  Timer? _timer;

  void startCountDownTimer() {
    _timer?.cancel();
    setState(() {
      time = 120;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (
      timer,
    ) {
      if (!mounted) {
        timer.cancel();
        return;
      }
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
    }
    final mins = time ~/ 60;
    final secs = (time % 60).toString().padLeft(2, '0');
    return '$mins:$secs secs';
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
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 30),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(
                                    horizontal: 50.0,
                                  ),
                              child: Column(
                                children: [
                                  Text(
                                    textAlign:
                                        TextAlign.center,
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
                                              .h2
                                              .fontSize,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                  // SizedBox(height: 10),
                                  Text(
                                    textAlign:
                                        TextAlign.center,
                                    '(${widget.user.email})',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize:
                                          widget
                                              .theme
                                              .mobileTexts
                                              .b2
                                              .fontSize,
                                      fontWeight:
                                          FontWeight.normal,
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  PinCodeWidget(
                                    controller:
                                        widget
                                            .pinController,
                                    length: 6,
                                    hideText: false,
                                    action: () async {
                                      await verifyOtp(
                                        widget
                                            .pinController
                                            .text,
                                      );
                                      widget.pinController
                                          .clear();
                                    },
                                  ),
                                  SizedBox(height: 5),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,
                                    spacing: 3,
                                    children: [
                                      Text(
                                        textAlign:
                                            TextAlign
                                                .center,
                                        style:
                                            widget
                                                .theme
                                                .mobileTexts
                                                .b1
                                                .textStyleNormal,
                                        'Remaining Time: ',
                                      ),
                                      Text(
                                        textAlign:
                                            TextAlign
                                                .center,
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
                                                  .b1
                                                  .fontSize,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                        time > 0
                                            ? formatTime(
                                              time,
                                            )
                                            : 'OTP Expired',
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Visibility(
                                    visible: time < 1,
                                    child: Material(
                                      color:
                                          Colors
                                              .transparent,
                                      child: InkWell(
                                        mouseCursor:
                                            SystemMouseCursors
                                                .click,
                                        onTap: () async {
                                          if (!isResendLoading && time < 1) {
                                            setState(() {
                                              isResendLoading = true;
                                            });
                                            final res = await AuthService()
                                                .resendVerificationLinkWithResult(
                                                  widget.user.email,
                                                );
                                            if (!mounted) return;
                                            setState(() {
                                              isResendLoading = false;
                                            });
                                            if (res.ok) {
                                              startCountDownTimer();
                                            } else {
                                              showDialog(
                                                context: context,
                                                builder: (context) => InfoAlert(
                                                  theme: widget.theme,
                                                  message: res.message,
                                                  title: 'Resend Failed',
                                                ),
                                              );
                                            }
                                          }
                                        },
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.all(
                                                12.0,
                                              ),
                                          child: Row(
                                            mainAxisSize:
                                                MainAxisSize
                                                    .min,
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
                                                          .b1
                                                          .fontSize,
                                                  fontWeight:
                                                      FontWeight
                                                          .bold,
                                                ),
                                                'Resend OTP To Verify Your Email',
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
                                                      size:
                                                          26,
                                                      color:
                                                          widget.theme.lightModeColor.prColor300,
                                                      Icons
                                                          .arrow_right,
                                                    ),
                                                  ),
                                                  Visibility(
                                                    visible:
                                                        isResendLoading,
                                                    child: SizedBox(
                                                      height:
                                                          15,
                                                      width:
                                                          15,
                                                      child: CircularProgressIndicator(
                                                        color:
                                                            Colors.amber,
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
                                    alignment: Alignment(
                                      0,
                                      0,
                                    ),
                                    children: [
                                      MainButtonTransparent(
                                        themeProvider:
                                            widget.theme,
                                        constraints:
                                            BoxConstraints(),
                                        text: 'Cancel',
                                        action: () async {
                                          Navigator.of(
                                            context,
                                          ).pop();
                                        },
                                      ),
                                      // Text('this'),
                                      Visibility(
                                        visible: isLoading,
                                        child: Container(
                                          height: 39,
                                          width: 200,
                                          color:
                                              Colors.white,
                                          child: Center(
                                            child: SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> verifyOtp(String otp) async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });
      await mainLocalLog('Verification Started');
      final res = await AuthService().verifyOtpWithResult(
        context: context,
        otp: otp,
        user: widget.user,
        userId: widget.userId,
      );
      await mainLocalLog(
        'Verification Ended: ${res.ok ? 'Success' : 'Failed'}',
      );
      if (!mounted) return;
      if (res.ok) {
        await AuthService().client.auth.refreshSession();
        if (!mounted) return;
        await mainLocalLog('Context is Mounted');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const BasePage(),
          ),
          (_) => false,
        );
      } else {
        setState(() {
          isLoading = false;
        });
        showDialog(
          context: context,
          builder: (context) {
            return InfoAlert(
              theme: widget.theme,
              message: res.message,
              title:
                  res.code == 'invalid_otp'
                      ? 'Wrong/Expired Pin'
                      : 'Verification Error',
            );
          },
        );
      }
    }
  }
}
