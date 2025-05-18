import 'package:flutter/material.dart';
import 'package:stockitt/constants/calculations.dart';
import 'package:stockitt/constants/constants_main.dart';
import 'package:stockitt/providers/theme_provider.dart';

class DashboardTotalSalesBanner extends StatelessWidget {
  final double value;
  const DashboardTotalSalesBanner({
    super.key,
    required this.theme,
    required this.value,
  });

  final ThemeProvider theme;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment(1, 00.5),
      children: [
        Container(
          padding: EdgeInsets.only(
            left: 25,
            top: 25,
            bottom: 25,
          ),
          decoration: BoxDecoration(
            gradient: theme.lightModeColor.prGradient,
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
                ],
              ),
            ],
          ),
        ),
        Image.asset(cctvImage, height: 85),
      ],
    );
  }
}
