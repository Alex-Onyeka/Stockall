import 'package:flutter/material.dart';
import 'package:storrec/components/buttons/main_button_p.dart';
import 'package:storrec/constants/constants_main.dart';
import 'package:storrec/pages/authentication/auth_landing/auth_landing.dart';
import 'package:storrec/pages/authentication/splash_screens/platforms/components/indicator.dart';
import 'package:storrec/providers/theme_provider.dart';

// ignore: must_be_immutable
class SplashDesktop extends StatefulWidget {
  final ThemeProvider themeProvider;
  final BoxConstraints constraints;
  final List<Map<String, dynamic>> pages;
  int? currentPage;
  final Function()? onTap;

  SplashDesktop({
    super.key,
    required this.themeProvider,
    required this.constraints,
    required this.currentPage,
    required this.onTap,
    required this.pages,
  });

  @override
  State<SplashDesktop> createState() =>
      _SplashDesktopState();
}

class _SplashDesktopState extends State<SplashDesktop> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Row(
          children: [
            Expanded(
              child: Stack(
                children: [
                  SizedBox(
                    height: double.infinity,
                    width: double.infinity,
                    child: Image.asset(
                      widget.pages[widget
                          .currentPage!]['image'],
                      fit: BoxFit.cover,
                      // alignment: Alignment.topCenter,
                    ),
                  ),
                  Container(
                    color: const Color.fromARGB(
                      255,
                      0,
                      35,
                      63,
                    ).withAlpha(200),
                    child: Center(
                      child: Row(
                        spacing: 10,
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            logoIconWhite,
                            width: 50,
                          ),
                          Text(
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 35,
                              fontWeight: FontWeight.bold,
                            ),
                            appName,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SizedBox(
                child: Stack(
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 80.0,
                        ),
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              mainLogoIcon,
                              width: 90,
                            ),
                            SizedBox(height: 40),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              spacing: 5,
                              children: [
                                MyIndicator(
                                  number: 0,
                                  onTap: () {
                                    setState(() {
                                      widget.currentPage =
                                          0;
                                    });
                                  },
                                  currentPage:
                                      widget.currentPage!,
                                ),
                                MyIndicator(
                                  number: 1,
                                  onTap: () {
                                    setState(() {
                                      widget.currentPage =
                                          1;
                                    });
                                  },
                                  currentPage:
                                      widget.currentPage!,
                                ),
                                MyIndicator(
                                  number: 2,
                                  onTap: () {
                                    setState(() {
                                      widget.currentPage =
                                          2;
                                    });
                                  },
                                  currentPage:
                                      widget.currentPage!,
                                ),
                              ],
                            ),
                            SizedBox(height: 30),
                            Text(
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize:
                                    widget.themeProvider
                                        .returnPlatform(
                                          widget
                                              .constraints,
                                          context,
                                        )
                                        .h1
                                        .fontSize,
                                fontWeight:
                                    widget.themeProvider
                                        .returnPlatform(
                                          widget
                                              .constraints,
                                          context,
                                        )
                                        .h1
                                        .fontWeightBold,
                              ),
                              widget.pages[widget
                                  .currentPage!]['title'],
                            ),

                            SizedBox(height: 10),
                            Text(
                              textAlign: TextAlign.center,
                              style:
                                  widget
                                      .themeProvider
                                      .desktopTexts
                                      .b1
                                      .textStyleNormal,

                              widget.pages[widget
                                  .currentPage!]['subtitle'],
                            ),

                            SizedBox(height: 15),
                            MainButtonP(
                              themeProvider:
                                  widget.themeProvider,
                              action: widget.onTap,
                              text: 'Next',
                            ),
                            SizedBox(height: 10),
                            InkWell(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            AuthLanding(),
                                  ),
                                );
                              },
                              child: Container(
                                padding:
                                    EdgeInsets.symmetric(
                                      vertical: 15,
                                    ),
                                child: Center(
                                  child: Text(
                                    style: TextStyle(
                                      fontSize:
                                          widget.constraints.maxWidth <
                                                  600
                                              ? widget
                                                  .themeProvider
                                                  .mobileTexts
                                                  .b1
                                                  .fontSize
                                              : widget
                                                  .themeProvider
                                                  .mobileTexts
                                                  .b2
                                                  .fontSize,
                                      fontWeight:
                                          widget
                                              .themeProvider
                                              .returnPlatform(
                                                widget
                                                    .constraints,
                                                context,
                                              )
                                              .b1
                                              .fontWeightRegular,
                                    ),
                                    'Skip',
                                  ),
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
            ),
          ],
        ),
      ),
    );
  }
}
