import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/theme_provider.dart';

class VerifyPhoneMobile extends StatefulWidget {
  final ThemeProvider theme;
  final String number;
  final List circles;
  const VerifyPhoneMobile({
    super.key,
    required this.circles,
    required this.theme,
    required this.number,
  });

  @override
  State<VerifyPhoneMobile> createState() =>
      _VerifyPhoneMobileState();
}

class _VerifyPhoneMobileState
    extends State<VerifyPhoneMobile> {
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
                      alignment: Alignment(0.6, -0.9),
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
                      alignment: Alignment(-0.4, -1),
                      child: widget.circles[3],
                    ),
                    Align(
                      alignment: Alignment(0.6, 0.8),
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
                          height: 150,
                          width: 100,
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
                  horizontal: 50.0,
                ),
                child: Column(
                  children: [
                    Text(
                      textAlign: TextAlign.center,
                      'We have sent a code to your Email',
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
                    SizedBox(height: 20),
                    Text(
                      textAlign: TextAlign.center,
                      style:
                          widget
                              .theme
                              .mobileTexts
                              .b1
                              .textStyleNormal,
                      'Check your mail to verify your User Account',
                    ),
                    SizedBox(height: 20),
                    MainButtonP(
                      themeProvider: widget.theme,
                      action: () {},
                      text: 'Proceed to Verify',
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
          ).showLoader('Verifying Email'),
        ),
      ],
    );
  }
}
