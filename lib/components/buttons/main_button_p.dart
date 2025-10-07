import 'package:flutter/material.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/providers/theme_provider.dart';

class MainButtonP extends StatelessWidget {
  const MainButtonP({
    super.key,
    required this.themeProvider,
    required this.action,
    required this.text,
  });

  final String text;
  final Function()? action;

  final ThemeProvider themeProvider;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return Material(
          type: MaterialType.transparency,
          child: Ink(
            decoration: BoxDecoration(
              gradient:
                  themeProvider.lightModeColor.prGradient,
              borderRadius: BorderRadius.circular(5),
            ),
            child: InkWell(
              onTap: () {
                action!();
                FocusManager.instance.primaryFocus
                    ?.unfocus();
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical:
                      screenWidth(context) < 600 ? 15 : 14,
                ),
                child: Center(
                  child: Text(
                    style: TextStyle(
                      color: Colors.white,
                      fontSize:
                          screenWidth(context) < 600
                              ? themeProvider
                                  .mobileTexts
                                  .b2
                                  .fontSize
                              : themeProvider
                                  .mobileTexts
                                  .b3
                                  .fontSize,
                      fontWeight: FontWeight.normal,
                    ),
                    text,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
