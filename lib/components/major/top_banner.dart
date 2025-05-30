import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stockitt/constants/constants_main.dart';
import 'package:stockitt/main.dart';
import 'package:stockitt/providers/theme_provider.dart';

class TopBanner extends StatelessWidget {
  final ThemeProvider theme;
  final bool? isMain;
  final String title;
  final String subTitle;
  final double topSpace;
  final double bottomSpace;
  final String? iconSvg;
  final IconData? iconData;
  final Color? svgColor;
  const TopBanner({
    super.key,
    required this.subTitle,
    required this.title,
    required this.theme,
    required this.bottomSpace,
    required this.topSpace,
    this.iconSvg,
    this.iconData,
    this.isMain,
    this.svgColor,
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
              padding:
                  isMain != null
                      ? const EdgeInsets.only(right: 20.0)
                      : const EdgeInsets.only(
                        right: 20.0,
                        left: 20,
                      ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Visibility(
                        visible:
                            isMain != null ? true : false,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius:
                                BorderRadius.circular(10),
                            onTap: () {
                              returnExpensesProvider(
                                context,
                                listen: false,
                              ).clearExpenseDate();
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 10,
                              ),
                              child: Icon(
                                Icons
                                    .arrow_back_ios_new_rounded,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Column(
                        spacing: 5,
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            style: TextStyle(
                              color: Colors.white,
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .h4
                                      .fontSize,
                              fontWeight:
                                  theme
                                      .mobileTexts
                                      .h4
                                      .fontWeightBold,
                            ),
                            title,
                          ),
                          Text(
                            style: TextStyle(
                              color: Colors.white,
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b3
                                      .fontSize,
                            ),
                            subTitle,
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child:
                          iconSvg != null
                              ? SvgPicture.asset(
                                // ignore: deprecated_member_use
                                color:
                                    svgColor ??
                                    theme
                                        .lightModeColor
                                        .prColor300,
                                iconSvg ?? productIconSvg,
                                height: 18,
                              )
                              : Icon(size: 22, iconData),
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
