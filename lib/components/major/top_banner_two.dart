import 'package:flutter/material.dart';
import 'package:stockitt/providers/theme_provider.dart';

class TopBannerTwo extends StatelessWidget {
  final ThemeProvider theme;
  final String title;
  final double topSpace;
  final double bottomSpace;
  const TopBannerTwo({
    super.key,
    required this.title,
    required this.theme,
    required this.bottomSpace,
    required this.topSpace,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: theme.lightModeColor.prGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: topSpace),
            Padding(
              padding: const EdgeInsets.only(
                right: 10,
                left: 5,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    style: TextStyle(
                      color: Colors.white,
                      fontSize:
                          theme.mobileTexts.h4.fontSize,
                      fontWeight:
                          theme
                              .mobileTexts
                              .h4
                              .fontWeightBold,
                    ),
                    title,
                  ),
                ],
              ),
            ),
            SizedBox(height: bottomSpace),
          ],
        ),
      ),
    );
  }
}
