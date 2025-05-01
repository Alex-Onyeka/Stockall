import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:stockitt/components/buttons/main_button_p.dart';
import 'package:stockitt/constants/constants_main.dart';
import 'package:stockitt/pages/authentication/auth_landing/auth_landing.dart';
import 'package:stockitt/providers/theme_provider.dart';
import 'package:stockitt/theme/main_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  LightModeColor lightModeColor = LightModeColor();
  int currentPage = 0;
  PageController pageController = PageController();
  List pages = [
    {
      'image':
          'assets/images/main_images/loading_image.png',
      'title': 'Manage Stocks and Track Sales in Real Time',
      'subtitle':
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit ut , ',
    },
    {
      'image':
          'assets/images/main_images/loading_image2.png',
      'title': 'Quick Transactions with Barcode Scanner',
      'subtitle':
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit ut , ',
    },
    {
      'image':
          'assets/images/main_images/loading_image3.png',
      'title': 'Analyse Profits and Get Daily Reports',
      'subtitle':
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit ut , ',
    },
  ];

  void nextPage() {
    setState(() {
      currentPage == 2
          ? Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AuthLanding(),
            ),
          )
          : currentPage++;
    });
  }

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context);
    return SafeArea(
      child: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 900) {
              return Stack(
                children: [
                  PageView(
                    onPageChanged: (value) {
                      setState(() {
                        currentPage = value;
                      });
                    },
                    controller: pageController,
                    children: [
                      Container(
                        color: Colors.teal,
                        height: 300,
                        width: 300,
                      ),
                      Container(
                        color: Colors.amber,
                        height: 300,
                        width: 300,
                      ),
                      Container(
                        color: Colors.red,
                        height: 300,
                        width: 300,
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      right: 20.0,
                    ),
                    child: Align(
                      alignment: Alignment(0, -0.9),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.end,
                        children: [
                          MaterialButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return AuthLanding();
                                  },
                                ),
                              );
                            },
                            child: Text('Skip'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment(0, 0.8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30.0,
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          MaterialButton(
                            onPressed: () {
                              pageController.previousPage(
                                duration: Duration(
                                  milliseconds: 500,
                                ),
                                curve: Curves.easeIn,
                              );
                            },
                            child: Row(
                              spacing: 10,
                              children: [
                                Visibility(
                                  visible: currentPage != 0,
                                  child: Icon(
                                    color: Colors.grey,
                                    size: 16,
                                    Icons
                                        .arrow_back_ios_new_rounded,
                                  ),
                                ),
                                Text(
                                  style: TextStyle(
                                    color:
                                        currentPage == 0
                                            ? Colors
                                                .grey
                                                .shade400
                                            : Colors
                                                .grey
                                                .shade500,
                                    fontWeight:
                                        currentPage != 0
                                            ? FontWeight
                                                .w500
                                            : FontWeight
                                                .w400,
                                    fontSize: 14,
                                  ),
                                  'Previous',
                                ),
                              ],
                            ),
                          ),
                          SmoothPageIndicator(
                            controller: pageController,
                            count: 3, // number of pages
                            effect: ExpandingDotsEffect(
                              activeDotColor: Colors.amber,
                              spacing: 5,
                              dotHeight: 5,
                              dotWidth: 8,
                            ),
                          ),
                          MaterialButton(
                            onPressed: () {
                              currentPage != 2
                                  ? pageController.nextPage(
                                    duration: Duration(
                                      milliseconds: 500,
                                    ),
                                    curve: Curves.easeIn,
                                  )
                                  : Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return AuthLanding();
                                      },
                                    ),
                                  );
                            },
                            child: Row(
                              spacing: 10,
                              children: [
                                Text(
                                  style: TextStyle(
                                    color:
                                        Colors
                                            .grey
                                            .shade600,
                                    fontSize: 14,
                                  ),
                                  currentPage != 2
                                      ? 'Next'
                                      : 'Finish',
                                ),
                                Icon(
                                  color: Colors.grey,
                                  size: 16,
                                  Icons
                                      .arrow_forward_ios_rounded,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return Row(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        SizedBox(
                          child: Image.asset(
                            pages[currentPage]['image'],
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
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                  'Stockitt',
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
                              padding:
                                  const EdgeInsets.symmetric(
                                    horizontal: 80.0,
                                  ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .center,
                                children: [
                                  Image.asset(
                                    mainLogoIcon,
                                    width: 90,
                                  ),
                                  SizedBox(height: 40),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,
                                    spacing: 5,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            currentPage = 0;
                                          });
                                        },
                                        child: Container(
                                          height: 5,
                                          width:
                                              currentPage ==
                                                      0
                                                  ? 30
                                                  : 5,
                                          decoration: BoxDecoration(
                                            color:
                                                currentPage ==
                                                        0
                                                    ? Colors
                                                        .amber
                                                    : Colors
                                                        .grey,
                                            borderRadius:
                                                BorderRadius.circular(
                                                  5,
                                                ),
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            currentPage = 1;
                                          });
                                        },
                                        child: Container(
                                          height: 5,
                                          width:
                                              currentPage ==
                                                      1
                                                  ? 30
                                                  : 5,
                                          decoration: BoxDecoration(
                                            color:
                                                currentPage ==
                                                        1
                                                    ? Colors
                                                        .amber
                                                    : Colors
                                                        .grey,
                                            borderRadius:
                                                BorderRadius.circular(
                                                  5,
                                                ),
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            currentPage = 2;
                                          });
                                        },
                                        child: Container(
                                          height: 5,
                                          width:
                                              currentPage ==
                                                      2
                                                  ? 30
                                                  : 5,
                                          decoration: BoxDecoration(
                                            color:
                                                currentPage ==
                                                        2
                                                    ? Colors
                                                        .amber
                                                    : Colors
                                                        .grey,
                                            borderRadius:
                                                BorderRadius.circular(
                                                  10,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 30),
                                  Text(
                                    textAlign:
                                        TextAlign.center,
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
                                    pages[currentPage]['title'],
                                  ),

                                  SizedBox(height: 10),
                                  Text(
                                    textAlign:
                                        TextAlign.center,
                                    style:
                                        themeProvider
                                            .desktopTexts
                                            .b2
                                            .textStyleNormal,

                                    pages[currentPage]['subtitle'],
                                  ),

                                  SizedBox(height: 15),
                                  MainButtonP(
                                    themeProvider:
                                        themeProvider,
                                    action: () {
                                      nextPage();
                                    },
                                    text: 'Next',
                                    constraints:
                                        constraints,
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
                                                constraints.maxWidth <
                                                        600
                                                    ? themeProvider
                                                        .mobileTexts
                                                        .b1
                                                        .fontSize
                                                    : themeProvider
                                                        .mobileTexts
                                                        .b2
                                                        .fontSize,
                                            fontWeight:
                                                themeProvider
                                                    .returnPlatform(
                                                      constraints,
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
              );
            }
          },
        ),
      ),
    );
  }
}
