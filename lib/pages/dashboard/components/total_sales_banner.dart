import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:stockitt/constants/calculations.dart';
import 'package:stockitt/constants/constants_main.dart';
import 'package:stockitt/providers/theme_provider.dart';

class DashboardTotalSalesBanner extends StatelessWidget {
  final double value;
  final String? currentUser;
  const DashboardTotalSalesBanner({
    super.key,
    required this.theme,
    required this.value,
    this.currentUser,
  });

  final ThemeProvider theme;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment(0.9, 0.1),
      children: [
        Container(
          padding: EdgeInsets.only(
            left: 25,
            top: 20,
            bottom: 20,
          ),
          decoration: BoxDecoration(
            // gradient: theme.lightModeColor.prGradient,
            color: theme.lightModeColor.prColor300,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b3.fontSize,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    'Today\'s Sale Revenue',
                  ),
                  Row(
                    children: [
                      Text(
                        style: TextStyle(
                          fontSize:
                              theme.mobileTexts.h3.fontSize,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        'N',
                      ),
                      Text(
                        style: TextStyle(
                          fontSize:
                              theme.mobileTexts.h3.fontSize,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        formatLargeNumberDoubleWidgetDecimal(
                          value,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    spacing: 5,
                    children: [
                      // Container(
                      //   padding: EdgeInsets.all(3),
                      //   decoration: BoxDecoration(
                      //     shape: BoxShape.circle,
                      //     color:
                      //         theme
                      //             .lightModeColor
                      //             .secColor200,
                      //   ),
                      // ),
                      Icon(
                        size: 14,
                        color: const Color.fromARGB(
                          255,
                          255,
                          208,
                          67,
                        ),
                        Icons.person,
                      ),
                      Text(
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(
                            255,
                            255,
                            208,
                            67,
                          ),
                          fontSize:
                              theme.mobileTexts.b4.fontSize,
                        ),

                        cutLongText(
                          currentUser ?? 'Not Set',
                          15,
                        ).toUpperCase(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        Lottie.asset(
          welcomeLady,
          height: 90,
          fit: BoxFit.cover,
        ),
        // Image.asset(cctvImage, height: 85),
      ],
    );
  }
}
