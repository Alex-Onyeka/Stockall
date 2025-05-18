import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stockitt/providers/theme_provider.dart';

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
        // width: 300,
        padding: EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 15,
        ),
        decoration: BoxDecoration(
          // color: Colors.grey.shade100,
          border: Border.all(color: Colors.grey.shade500),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              spacing: 10,
              children: [
                Container(
                  height: 25,
                  width: 25,
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade100,
                  ),
                  child: SvgPicture.asset(icon),
                ),
                Text(
                  style: TextStyle(
                    color:
                        theme.lightModeColor.greyColor200,
                    fontSize: theme.mobileTexts.b2.fontSize,
                    fontWeight:
                        MediaQuery.of(context).size.width <
                                    384 &&
                                title.length > 11
                            ? theme
                                .mobileTexts
                                .b3
                                .fontWeightBold
                            : theme
                                .mobileTexts
                                .b2
                                .fontWeightBold,
                  ),

                  MediaQuery.of(context).size.width < 384 &&
                          title.length > 11
                      ? '${title.substring(0, title.length - 5)}...'
                      : title,
                ),
              ],
            ),
            SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Row(
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
                ],
              ),
            ),
            Divider(
              color: Colors.grey.shade400,
              thickness: 1,
              height: 10,
            ),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  style: TextStyle(
                    color:
                        theme.lightModeColor.greyColor100,
                    fontSize: theme.mobileTexts.b3.fontSize,
                    fontWeight:
                        theme.mobileTexts.b3.fontWeightBold,
                  ),
                  'See All',
                ),
                Icon(
                  color: Colors.grey.shade400,
                  size: 20,
                  Icons.arrow_forward_ios_rounded,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
