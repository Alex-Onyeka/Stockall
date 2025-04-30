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
    return InkWell(
      onTap: action,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: themeProvider.lightModeColor.prGradient,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            style: TextStyle(
              color: Colors.white,
              fontSize:
                  themeProvider.mobileTexts.b1.fontSize,
              fontWeight:
                  themeProvider
                      .mobileTexts
                      .b1
                      .fontWeightRegular,
            ),
            text,
          ),
        ),
      ),
    );
  }
}
