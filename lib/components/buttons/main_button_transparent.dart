import 'package:flutter/material.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/providers/theme_provider.dart';

class MainButtonTransparent extends StatelessWidget {
  final ThemeProvider themeProvider;
  final Function()? action;
  final BoxConstraints constraints;
  final String text;

  const MainButtonTransparent({
    super.key,
    required this.themeProvider,
    this.action,
    required this.constraints,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: themeProvider.lightModeColor.prColor200,
            width: 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(5),
          onTap: () {
            action!();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical:
                  screenWidth(context) < 600 ? 15 : 12,
            ),

            child: Center(
              child: Text(
                style: TextStyle(
                  color:
                      themeProvider
                          .lightModeColor
                          .prColor300,
                  fontSize:
                      screenWidth(context) < 600
                          ? themeProvider
                              .mobileTexts
                              .b2
                              .fontSize
                          : themeProvider
                              .mobileTexts
                              .b2
                              .fontSize,
                  fontWeight: FontWeight.bold,
                ),
                text,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
