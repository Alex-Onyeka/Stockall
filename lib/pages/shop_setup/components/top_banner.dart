import 'package:flutter/material.dart';
import 'package:stockitt/providers/theme_provider.dart';

class TopBanner extends StatelessWidget {
  final ThemeProvider theme;
  final String title;
  final String subTitle;
  const TopBanner({
    super.key,
    required this.subTitle,
    required this.title,
    required this.theme,
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
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 40.0,
          ),
          child: Column(
            children: [
              SizedBox(height: 40),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    spacing: 5,
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        style: TextStyle(
                          color: Colors.white,
                          fontSize:
                              theme.mobileTexts.h3.fontSize,
                          fontWeight:
                              theme
                                  .mobileTexts
                                  .h3
                                  .fontWeightBold,
                        ),
                        title,
                      ),
                      Text(
                        style: TextStyle(
                          color: Colors.white,
                          fontSize:
                              theme.mobileTexts.b2.fontSize,
                        ),
                        subTitle,
                      ),
                    ],
                  ),
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        size: 25,
                        Icons.home_work_outlined,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
