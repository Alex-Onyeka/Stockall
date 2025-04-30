import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:stockitt/components/splash_screens/splash_screen_widget.dart';
import 'package:stockitt/pages/authentication/auth_landing.dart';
import 'package:stockitt/theme/main_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  MobileTexts mobileTexts = MobileTexts();
  LightModeColor lightModeColor = LightModeColor();
  int currentPage = 0;
  PageController pageController = PageController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            onPageChanged: (value) {
              setState(() {
                currentPage = value;
              });
            },
            controller: pageController,
            children: [
              SplashScreenWidget(
                widget: Center(
                  child: Lottie.asset(
                    'assets/animations/cart_loader.json',
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                title:
                    'Manage Stocks and Track Sales In Real Time',
                text:
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit ut , ',
                color: Colors.grey.shade100,
              ),
              SplashScreenWidget(
                widget: Image.asset(
                  'assets/images/App_Png.png',
                ),
                text:
                    'Quick Transactions with Barcode Scanner',
                title:
                    'Quick Transactions with Barcode Scanner',
                color: Colors.grey.shade100,
              ),
              SplashScreenWidget(
                widget: Text('Widget 3'),
                text:
                    'Analyse Profits and Get Daily Reports',
                title:
                    'Analyse Profits and Get Daily Reports',
                color: Colors.grey.shade100,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Align(
              alignment: Alignment(0, -0.9),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
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
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade500,
                            fontWeight:
                                currentPage != 0
                                    ? FontWeight.w500
                                    : FontWeight.w400,
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
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                          currentPage != 2
                              ? 'Next'
                              : 'Finish',
                        ),
                        Icon(
                          color: Colors.grey,
                          size: 16,
                          Icons.arrow_forward_ios_rounded,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
