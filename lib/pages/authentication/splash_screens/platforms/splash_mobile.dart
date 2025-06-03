import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:storrec/constants/constants_main.dart';
import 'package:storrec/main.dart';
import 'package:storrec/pages/authentication/splash_screens/platforms/components/mobile_splash_widget.dart';
import 'package:storrec/providers/theme_provider.dart';

// ignore: must_be_immutable
class SplashMobile extends StatefulWidget {
  final BoxConstraints constraints;
  final ThemeProvider themeProvider;
  int? currentPage;
  final PageController pageController;
  SplashMobile({
    super.key,
    this.currentPage,
    required this.pageController,
    required this.themeProvider,
    required this.constraints,
  });

  @override
  State<SplashMobile> createState() => _SplashMobileState();
}

class _SplashMobileState extends State<SplashMobile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            onPageChanged: (value) {
              setState(() {
                widget.currentPage = value;
              });
            },
            controller: widget.pageController,
            children: [
              MobileSplashWidget(
                title:
                    'Manage Stocks and Track Sales in Real Time',
                subTitle:
                    'Stay on top of your inventory and monitor sales as they happen, all in one place.',
                lottie:
                    'assets/animations/shop_setup_icon.json',
                constraints: widget.constraints,
                themeProvider: widget.themeProvider,
              ),
              MobileSplashWidget(
                title:
                    'Quick Transactions with Barcode Scanner',
                subTitle:
                    'Speed up checkout and reduce errors by scanning products instantly using your camera.',
                lottie:
                    'assets/animations/cart_loader.json',
                constraints: widget.constraints,
                themeProvider: widget.themeProvider,
              ),
              MobileSplashWidget(
                title:
                    'Analyse Profits and Get Daily Reports',
                subTitle:
                    'View clear summaries of your earnings and track business performance every day.',
                lottie: profitAnim,
                constraints: widget.constraints,
                themeProvider: widget.themeProvider,
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
                      returnNavProvider(
                        context,
                        listen: false,
                      ).navigateAuth(1);
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
                      widget.pageController.previousPage(
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
                          visible: widget.currentPage != 0,
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
                                widget.currentPage == 0
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade500,
                            fontWeight:
                                widget.currentPage != 0
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
                    controller: widget.pageController,
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
                      widget.currentPage != 2
                          ? widget.pageController.nextPage(
                            duration: Duration(
                              milliseconds: 500,
                            ),
                            curve: Curves.easeIn,
                          )
                          : returnNavProvider(
                            context,
                            listen: false,
                          ).navigateAuth(1);
                    },
                    child: Row(
                      spacing: 10,
                      children: [
                        Text(
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                          widget.currentPage != 2
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
