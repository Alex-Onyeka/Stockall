import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/providers/theme_provider.dart';

class MainInfoTab extends StatelessWidget {
  final String title;
  final String number;
  final Function()? action;
  final String icon;

  final ThemeProvider theme;

  const MainInfoTab({
    super.key,
    required this.title,
    required this.number,
    this.action,
    required this.icon,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: action,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 7,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade500),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              spacing: 8,
              children: [
                Visibility(
                  visible:
                      MediaQuery.of(context).size.width >
                      335,
                  child: Container(
                    height: 25,
                    width: 25,
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade100,
                    ),
                    child: SvgPicture.asset(icon),
                  ),
                ),
                Text(
                  style: TextStyle(
                    color:
                        theme.lightModeColor.greyColor200,
                    fontSize:
                        screenWidth(context) < 335
                            ? theme.mobileTexts.b3.fontSize
                            : screenWidth(context) > 550
                            ? theme.mobileTexts.b4.fontSize
                            : theme.mobileTexts.b3.fontSize,
                    fontWeight: FontWeight.bold,
                  ),

                  title,
                ),
              ],
            ),
            SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    style: TextStyle(
                      color:
                          theme.lightModeColor.greyColor200,
                      fontSize:
                          theme.mobileTexts.h4.fontSize,
                      fontWeight:
                          theme
                              .mobileTexts
                              .h2
                              .fontWeightBold,
                    ),
                    number,
                  ),
                  Icon(
                    color: Colors.grey.shade400,
                    size: 18,
                    Icons.arrow_forward_ios_rounded,
                  ),
                ],
              ),
            ),
            // Divider(
            //   color: Colors.grey.shade400,
            //   thickness: 1,
            //   height: 10,
            // ),
            // Row(
            //   mainAxisAlignment:
            //       MainAxisAlignment.spaceBetween,
            //   children: [
            //     Text(
            //       style: TextStyle(
            //         color:
            //             theme.lightModeColor.greyColor100,
            //         fontSize: theme.mobileTexts.b3.fontSize,
            //         fontWeight:
            //             theme.mobileTexts.b3.fontWeightBold,
            //       ),
            //       'See All',
            //     ),
            //     Icon(
            //       color: Colors.grey.shade400,
            //       size: 20,
            //       Icons.arrow_forward_ios_rounded,
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}
