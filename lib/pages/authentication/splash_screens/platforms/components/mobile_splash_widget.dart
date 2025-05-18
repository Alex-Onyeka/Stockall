import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:stockitt/providers/theme_provider.dart';

class MobileSplashWidget extends StatelessWidget {
  final String title;
  final String subTitle;
  final String lottie;
  final ThemeProvider themeProvider;
  final BoxConstraints constraints;
  const MobileSplashWidget({
    super.key,
    required this.constraints,
    required this.themeProvider,
    required this.lottie,
    required this.subTitle,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 50),
            Lottie.asset(
              lottie,
              width: 170,
              height: 170,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 30.0,
              ),
              child: Column(
                children: [
                  Text(
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize:
                          themeProvider
                              .returnPlatform(
                                constraints,
                                context,
                              )
                              .h2
                              .fontSize,
                      fontWeight:
                          themeProvider
                              .returnPlatform(
                                constraints,
                                context,
                              )
                              .h2
                              .fontWeightBold,
                    ),
                    title,
                  ),

                  SizedBox(height: 20),
                  Text(
                    textAlign: TextAlign.center,
                    style:
                        themeProvider
                            .desktopTexts
                            .b1
                            .textStyleNormal,

                    subTitle,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
