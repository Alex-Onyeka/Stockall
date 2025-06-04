import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/splash_screens/platforms/splash_desktop.dart';
import 'package:stockall/pages/authentication/splash_screens/platforms/splash_mobile.dart';
import 'package:stockall/providers/theme_provider.dart';
import 'package:stockall/theme/main_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  LightModeColor lightModeColor = LightModeColor();
  int currentPage = 0;
  PageController pageController = PageController();
  List<Map<String, dynamic>> pages = [
    {
      'image': 'assets/images/main_images/splash_image.png',
      'title': 'Manage Stocks and Track Sales in Real Time',
      'subtitle':
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit ut , ',
    },
    {
      'image':
          'assets/images/main_images/splash_image2.png',
      'title': 'Quick Transactions with Barcode Scanner',
      'subtitle':
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit ut , ',
    },
    {
      'image':
          'assets/images/main_images/splash_image3.png',
      'title': 'Analyse Profits and Get Daily Reports',
      'subtitle':
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit ut , ',
    },
  ];

  void nextPage() {
    setState(() {
      if (currentPage == 2) {
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => AuthLanding(),
        //   ),
        // );
        returnNavProvider(
          context,
          listen: false,
        ).navigateAuth(1);
      } else {
        currentPage++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 900) {
          return SplashMobile(
            constraints: constraints,
            themeProvider: themeProvider,
            pageController: pageController,
            currentPage: currentPage,
          );
        } else {
          return SplashDesktop(
            themeProvider: themeProvider,
            constraints: constraints,
            currentPage: currentPage,
            onTap: () {
              nextPage();
            },
            pages: pages,
          );
        }
      },
    );
  }
}
