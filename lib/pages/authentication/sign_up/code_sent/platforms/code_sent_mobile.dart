import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:stockall/components/buttons/main_button_transparent.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/base_page/base_page.dart';
import 'package:stockall/providers/theme_provider.dart';

class CodeSentMobile extends StatefulWidget {
  final ThemeProvider theme;
  final String email;
  final List circles;
  const CodeSentMobile({
    super.key,
    required this.circles,
    required this.theme,
    required this.email,
  });

  @override
  State<CodeSentMobile> createState() =>
      _CodeSentMobileState();
}

class _CodeSentMobileState extends State<CodeSentMobile> {
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
  void initState() {
    super.initState();
    // if (widget.isFirstVisit) {
    //   startCountDownTimer();
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: Center(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
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
                  vertical: 20,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 20),
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
                              child: widget.circles[0],
                            ),
                            Align(
                              alignment: Alignment(-0.8, 0),
                              child: widget.circles[1],
                            ),
                            Align(
                              alignment: Alignment(-0.1, 1),
                              child: widget.circles[2],
                            ),
                            Align(
                              alignment: Alignment(
                                -0.4,
                                -1,
                              ),
                              child: widget.circles[3],
                            ),
                            Align(
                              alignment: Alignment(
                                0.6,
                                0.8,
                              ),
                              child: widget.circles[4],
                            ),

                            SizedBox(
                              width: double.infinity,
                              child: Container(
                                padding: EdgeInsets.all(40),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      Colors.grey.shade400,
                                ),
                                child: SizedBox(
                                  height: 100,
                                  width: 60,
                                  child: Lottie.asset(
                                    'assets/animations/phone_verify.json',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                        ),
                        child: Column(
                          children: [
                            Text(
                              textAlign: TextAlign.center,
                              'A Confirmation OTP has been sent to your Email',
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
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              textAlign: TextAlign.center,
                              '(${widget.email})',
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
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              textAlign: TextAlign.center,
                              style:
                                  widget
                                      .theme
                                      .mobileTexts
                                      .b1
                                      .textStyleNormal,
                              'Check your mail, copy the code, come back and paste to verify Your Account',
                            ),
                            SizedBox(height: 10),
                            MainButtonTransparent(
                              themeProvider: widget.theme,
                              constraints: BoxConstraints(),
                              text: 'Check Verification',
                              action: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return BasePage();
                                    },
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 30),
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
        Visibility(
          visible: false,
          child: returnCompProvider(
            context,
            listen: false,
          ).showLoader(message: 'Verifying Email'),
        ),
      ],
    );
  }
}
