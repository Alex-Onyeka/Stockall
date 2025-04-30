import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockitt/providers/theme_provider.dart';

class SplashScreenWidget extends StatelessWidget {
  final Widget widget;
  final String text;
  final String title;
  final Color color;
  const SplashScreenWidget({
    super.key,
    required this.text,
    required this.color,
    required this.widget,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: color),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 30.0,
          ),
          child: Column(
            spacing: 15,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 300,
                width: 300,
                decoration: BoxDecoration(),
                child: Center(child: widget),
              ),
              Text(
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade900,
                  fontSize: 28,
                  fontWeight:
                      Provider.of<ThemeProvider>(
                        context,
                      ).mobileTexts.h1.fontWeightBold,
                ),
                title,
              ),
              Text(
                textAlign: TextAlign.center,
                style:
                    Provider.of<ThemeProvider>(
                      context,
                    ).mobileTexts.b1.textStyleNormal,
                text,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
