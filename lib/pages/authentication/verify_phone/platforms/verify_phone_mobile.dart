import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
// import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/auth_landing/auth_landing.dart';
import 'package:stockall/providers/theme_provider.dart';
import 'package:stockall/services/auth_service.dart';

class VerifyPhoneMobile extends StatefulWidget {
  final ThemeProvider theme;
  final List circles;
  const VerifyPhoneMobile({
    super.key,
    required this.circles,
    required this.theme,
  });

  @override
  State<VerifyPhoneMobile> createState() =>
      _VerifyPhoneMobileState();
}

class _VerifyPhoneMobileState
    extends State<VerifyPhoneMobile> {
  int time = 180;
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
        setState(() {});
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
    return Stack(
      children: [
        Scaffold(
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 50),
              SizedBox(
                height: 300,
                child: Stack(
                  alignment: Alignment(0, 0),
                  children: [
                    Align(
                      alignment: Alignment(0.6, -0.6),
                      child: widget.circles[0],
                    ),
                    Align(
                      alignment: Alignment(-0.7, 0),
                      child: widget.circles[1],
                    ),
                    Align(
                      alignment: Alignment(-0.1, 1),
                      child: widget.circles[2],
                    ),
                    Align(
                      alignment: Alignment(-0.4, -0.7),
                      child: widget.circles[3],
                    ),
                    Align(
                      alignment: Alignment(0.5, 0.7),
                      child: widget.circles[4],
                    ),

                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        padding: EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade100,
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
                padding: const EdgeInsets.only(
                  left: 50.0,
                  right: 50.0,
                  bottom: 60,
                ),
                child: Column(
                  children: [
                    Text(
                      textAlign: TextAlign.center,
                      'A Password Reset Link has been sent to your Email',
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
                    Text(
                      textAlign: TextAlign.center,
                      style:
                          widget
                              .theme
                              .mobileTexts
                              .b1
                              .textStyleNormal,
                      'Check your mail to Reset Your Password',
                    ),
                    SizedBox(height: 20),
                    Column(
                      spacing: 5,
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Text(
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color:
                                widget
                                    .theme
                                    .lightModeColor
                                    .errorColor200,
                            fontWeight: FontWeight.bold,
                          ),
                          'NOTE: ',
                        ),
                        Text(
                          textAlign: TextAlign.center,
                          style:
                              widget
                                  .theme
                                  .mobileTexts
                                  .b1
                                  .textStyleNormal,
                          'The Reset Password Token Time out is already Counting down:',
                        ),
                        Text(
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color:
                                time > 60
                                    ? Colors.grey.shade800
                                    : widget
                                        .theme
                                        .lightModeColor
                                        .errorColor200,
                            fontWeight: FontWeight.bold,
                            fontSize:
                                widget
                                    .theme
                                    .mobileTexts
                                    .h4
                                    .fontSize,
                          ),
                          formatTime(time),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
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
