import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/providers/theme_provider.dart';

class CodeSentDesktopChange extends StatefulWidget {
  final ThemeProvider theme;
  final List circles;
  const CodeSentDesktopChange({
    super.key,
    required this.circles,
    required this.theme,
  });

  @override
  State<CodeSentDesktopChange> createState() =>
      _CodeSentDesktopChangeState();
}

class _CodeSentDesktopChangeState
    extends State<CodeSentDesktopChange> {
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
                            SizedBox(
                              height: 300,
                              child: Stack(
                                alignment: Alignment(0, 0),
                                children: [
                                  Align(
                                    alignment: Alignment(
                                      0.6,
                                      -0.9,
                                    ),
                                    child:
                                        widget.circles[0],
                                  ),
                                  Align(
                                    alignment: Alignment(
                                      -0.8,
                                      0,
                                    ),
                                    child:
                                        widget.circles[1],
                                  ),
                                  Align(
                                    alignment: Alignment(
                                      -0.1,
                                      1,
                                    ),
                                    child:
                                        widget.circles[2],
                                  ),
                                  Align(
                                    alignment: Alignment(
                                      -0.4,
                                      -1,
                                    ),
                                    child:
                                        widget.circles[3],
                                  ),
                                  Align(
                                    alignment: Alignment(
                                      0.6,
                                      0.8,
                                    ),
                                    child:
                                        widget.circles[4],
                                  ),

                                  SizedBox(
                                    width: double.infinity,
                                    child: Container(
                                      padding:
                                          EdgeInsets.all(
                                            40,
                                          ),
                                      decoration:
                                          BoxDecoration(
                                            shape:
                                                BoxShape
                                                    .circle,
                                            color:
                                                Colors
                                                    .grey
                                                    .shade400,
                                          ),
                                      child: SizedBox(
                                        height: 150,
                                        width: 100,
                                        child: Lottie.asset(
                                          'assets/animations/phone_verify.json',
                                          fit:
                                              BoxFit
                                                  .contain,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20),
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
                                    'A Confirmation OTP has been sent to your New Email',
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
                                  SizedBox(height: 20),
                                  Text(
                                    textAlign:
                                        TextAlign.center,
                                    style:
                                        widget
                                            .theme
                                            .mobileTexts
                                            .b1
                                            .textStyleNormal,
                                    'Check your new mail, copy the code, come back to verify Your New Email',
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
}
