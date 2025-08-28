import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockall/constants/constants_main.dart';
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
          'Stay on top of your inventory and monitor sales as they happen, all in one place...',
    },
    {
      'image':
          'assets/images/main_images/splash_image2.png',
      'title': 'Quick Transactions with Barcode Scanner',
      'subtitle':
          'Speed up checkout and reduce errors by scanning products instantly using your camera.',
    },
    {
      'image':
          'assets/images/main_images/splash_image3.png',
      'title': 'Analyse Profits and Get Daily Reports',
      'subtitle':
          'View clear summaries of your earnings and track business performance every day.',
    },
  ];

  void nextPage() {
    setState(() {
      if (currentPage == 2) {
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
        if (constraints.maxWidth < tabletScreenSmall) {
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
            onTap: nextPage,
            pages: pages,
          );
        }
      },
    );
  }
}
