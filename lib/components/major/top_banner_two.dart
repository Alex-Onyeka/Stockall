import 'package:flutter/material.dart';
import 'package:stockall/providers/theme_provider.dart';

class TopBannerTwo extends StatelessWidget {
  final ThemeProvider theme;
  final String title;
  final double topSpace;
  final double bottomSpace;
  final bool isMain;
  const TopBannerTwo({
    super.key,
    required this.title,
    required this.theme,
    required this.bottomSpace,
    required this.topSpace,
    required this.isMain,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // gradient: theme.lightModeColor.prGradient,
        color: theme.lightModeColor.prColor300,
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
                right: 20,
                left: 20,
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Visibility(
                    visible: !isMain,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                        child: Icon(
                          color: Colors.white,
                          Icons.arrow_back_ios_new_rounded,
                        ),
                      ),
                    ),
                  ),
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
                  Opacity(
                    opacity: 0,
                    child: Visibility(
                      visible: !isMain,
                      child: InkWell(
                        onTap: () {},
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons
                                .arrow_back_ios_new_rounded,
                          ),
                        ),
                      ),
                    ),
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
