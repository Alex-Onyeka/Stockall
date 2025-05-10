import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:stockitt/constants/constants_main.dart';
import 'package:stockitt/providers/comp_provider.dart';
import 'package:stockitt/providers/theme_provider.dart';

class TopNavBar extends StatelessWidget {
  final int notifNumber;
  final String title;
  final String subText;
  final ThemeProvider theme;
  final Function()? openSideBar;

  const TopNavBar({
    super.key,
    required this.notifNumber,
    required this.title,
    required this.subText,
    required this.theme,
    required this.openSideBar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 25,
        bottom: 20,
        left: 30,
        right: 30,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(30, 0, 0, 0),
            blurRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            spacing: 5,
            children: [
              InkWell(
                onTap: openSideBar,
                child: Row(
                  children: [
                    Icon(
                      color: Colors.grey.shade700,
                      size: 28,
                      Icons.menu_rounded,
                    ),
                    SizedBox(width: 10),
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(profileIconImage),
                    ),
                  ],
                ),
              ),
              Column(
                spacing: 3,
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.center,
                    children: [
                      Text(
                        style: TextStyle(
                          fontSize:
                              theme.mobileTexts.b2.fontSize,
                          fontWeight:
                              theme
                                  .mobileTexts
                                  .b2
                                  .fontWeightBold,
                          color: Colors.black,
                        ),
                        title,
                      ),
                      SizedBox(width: 5),
                      SvgPicture.asset(
                        checkIconSvg,
                        height: 18,
                        width: 18,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                  Text(
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b3.fontSize,
                      color:
                          theme.lightModeColor.prColor250,
                      fontWeight: FontWeight.w500,
                    ),
                    subText,
                  ),
                ],
              ),
            ],
          ),
          Stack(
            alignment: Alignment(1.2, -1.8),
            children: [
              InkWell(
                onTap: () {
                  Provider.of<CompProvider>(
                    context,
                    listen: false,
                  ).switchNotif();
                },
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(
                      208,
                      245,
                      245,
                      245,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    height: 25,
                    width: 25,
                    notifIconSvg,
                  ),
                ),
              ),
              Visibility(
                visible:
                    Provider.of<CompProvider>(
                      context,
                    ).newNotif,
                child: Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient:
                        theme.lightModeColor.secGradient,
                  ),
                  child: Center(
                    child: Text(
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                      '$notifNumber',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
