import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:stockitt/classes/temp_user_class.dart';
import 'package:stockitt/constants/calculations.dart';
import 'package:stockitt/constants/constants_main.dart';
import 'package:stockitt/providers/theme_provider.dart';

class DashboardTotalSalesBanner extends StatefulWidget {
  final double? value;
  final TempUserClass? currentUser;
  final double? userValue;
  const DashboardTotalSalesBanner({
    super.key,
    required this.theme,
    required this.value,
    this.currentUser,
    this.userValue,
  });

  final ThemeProvider theme;

  @override
  State<DashboardTotalSalesBanner> createState() =>
      _DashboardTotalSalesBannerState();
}

class _DashboardTotalSalesBannerState
    extends State<DashboardTotalSalesBanner> {
  String setName() {
    if (widget.currentUser != null) {
      return '${cutLongText(widget.currentUser!.name.toUpperCase(), 15)} (${widget.currentUser!.role})';
    } else {
      return 'Not Set';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment(0.9, 0.1),
      children: [
        Container(
          padding: EdgeInsets.only(
            left: 25,
            top: 20,
            bottom: 15,
          ),
          decoration: BoxDecoration(
            // gradient: theme.lightModeColor.prGradient,
            color: widget.theme.lightModeColor.prColor300,
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
                          widget
                              .theme
                              .mobileTexts
                              .b3
                              .fontSize,
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
                              widget
                                  .theme
                                  .mobileTexts
                                  .h3
                                  .fontSize,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        'N',
                      ),
                      Text(
                        style: TextStyle(
                          fontSize:
                              widget
                                  .theme
                                  .mobileTexts
                                  .h3
                                  .fontSize,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        formatLargeNumberDoubleWidgetDecimal(
                          widget.value != null
                              ? widget.value!
                              : 0,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
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
                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
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
                                  widget
                                      .theme
                                      .mobileTexts
                                      .b4
                                      .fontSize,
                            ),

                            setName(),
                          ),
                          Text(
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: const Color.fromARGB(
                                241,
                                255,
                                255,
                                255,
                              ),
                              fontSize:
                                  widget
                                      .theme
                                      .mobileTexts
                                      .b3
                                      .fontSize,
                            ),

                            '$nairaSymbol${formatLargeNumberDoubleWidgetDecimal(widget.userValue ?? 0)}',
                          ),
                        ],
                      ),
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
