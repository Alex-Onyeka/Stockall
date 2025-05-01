import 'package:flutter/material.dart';
import 'package:stockitt/providers/theme_provider.dart';

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
    return LayoutBuilder(
      builder: (context, constraints) {
        return InkWell(
          onTap: action,
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical:
                  constraints.maxWidth < 600 ? 18 : 15,
            ),
            decoration: BoxDecoration(
              gradient:
                  themeProvider.lightModeColor.prGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                style: TextStyle(
                  color: Colors.white,
                  fontSize:
                      constraints.maxWidth < 600
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
                text,
              ),
            ),
          ),
        );
      },
    );
  }
}
