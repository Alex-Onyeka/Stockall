import 'package:flutter/material.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/providers/theme_provider.dart';

class ProductionTotalTab extends StatelessWidget {
  final String title;
  final double number;
  final Function()? action;
  final int? entries;
  final IconData icon;
  final Color? color;

  final ThemeProvider theme;

  const ProductionTotalTab({
    super.key,
    required this.title,
    required this.number,
    this.entries,
    this.action,
    required this.icon,
    required this.theme,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (screenWidth(context) < mobileScreen) {
          return ProductionTotalTableMobile(
            title: title,
            number: number,
            icon: icon,
            theme: theme,
            action: action,
            color: color,
            entries: entries,
          );
        } else {
          return ProductionTotalTableDesktop(
            title: title,
            number: number,
            icon: icon,
            theme: theme,
            action: action,
            color: color,
            entries: entries,
          );
        }
      },
    );
  }
}

class ProductionTotalTableMobile extends StatelessWidget {
  final String title;
  final double number;
  final Function()? action;
  final int? entries;
  final IconData icon;
  final Color? color;

  final ThemeProvider theme;
  const ProductionTotalTableMobile({
    super.key,
    required this.title,
    required this.number,
    this.entries,
    this.action,
    required this.icon,
    required this.theme,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(25, 0, 0, 0),
            blurRadius: 10,
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.white,
          ),
          child: InkWell(
            mouseCursor: SystemMouseCursors.click,
            borderRadius: BorderRadius.circular(5),
            onTap: action,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 15,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    spacing: 8,
                    children: [
                      Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade100,
                        ),
                        child: Icon(
                          size: 18,
                          color:
                              color ??
                              theme
                                  .lightModeColor
                                  .secColor200,
                          icon,
                        ),
                      ),
                      Visibility(
                        visible: entries != null,
                        child: Text(
                          style: TextStyle(
                            color:
                                theme
                                    .lightModeColor
                                    .greyColor200,
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b4
                                    .fontSize,
                            fontWeight: FontWeight.w500,
                          ),
                          '${formatLargeNumberDouble(entries?.toDouble() ?? 0)}  ${formatEntries(entries)}',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          style: TextStyle(
                            color:
                                theme
                                    .lightModeColor
                                    .greyColor200,
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b3
                                    .fontSize,
                            fontWeight: FontWeight.bold,
                          ),

                          title,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.only(
                      // left: 10.0,
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          style: TextStyle(
                            color:
                                theme
                                    .lightModeColor
                                    .greyColor200,
                            fontSize:
                                theme
                                    .mobileTexts
                                    .h4
                                    .fontSize,
                            fontWeight:
                                theme
                                    .mobileTexts
                                    .h3
                                    .fontWeightBold,
                          ),
                          formatLargeNumber(
                            number.toString(),
                          ),
                        ),
                        Visibility(
                          visible: action != null,
                          child: Icon(
                            color: Colors.grey.shade400,
                            size: 16,
                            Icons.arrow_forward_ios_rounded,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ProductionTotalTableDesktop extends StatelessWidget {
  final String title;
  final double number;
  final Function()? action;
  final int? entries;
  final IconData icon;
  final Color? color;

  final ThemeProvider theme;
  const ProductionTotalTableDesktop({
    super.key,
    required this.title,
    required this.number,
    this.entries,
    this.action,
    required this.icon,
    required this.theme,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(25, 0, 0, 0),
            blurRadius: 10,
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Ink(
          decoration: BoxDecoration(
            // border: Border.all(color: Colors.grey.shade500),
            borderRadius: BorderRadius.circular(5),
            color: Colors.white,
          ),
          child: InkWell(
            mouseCursor: SystemMouseCursors.click,
            borderRadius: BorderRadius.circular(5),
            onTap: action,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 15,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    spacing: 8,
                    children: [
                      Visibility(
                        visible:
                            MediaQuery.of(
                              context,
                            ).size.width >
                            335,
                        child: Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.shade100,
                          ),
                          child: Icon(
                            size: 22,
                            color:
                                color ??
                                theme
                                    .lightModeColor
                                    .secColor200,
                            icon,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          style: TextStyle(
                            color:
                                theme
                                    .lightModeColor
                                    .greyColor200,
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b3
                                    .fontSize,
                            fontWeight: FontWeight.bold,
                          ),

                          title,
                        ),
                      ),
                      Visibility(
                        visible: entries != null,
                        child: Text(
                          style: TextStyle(
                            color:
                                theme
                                    .lightModeColor
                                    .greyColor200,
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b4
                                    .fontSize,
                            fontWeight: FontWeight.w500,
                          ),
                          '${formatLargeNumberDouble(entries?.toDouble() ?? 0)}  ${formatEntries(entries)}',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 10.0,
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          style: TextStyle(
                            color:
                                theme
                                    .lightModeColor
                                    .greyColor200,
                            fontSize:
                                theme
                                    .mobileTexts
                                    .h3
                                    .fontSize,
                            fontWeight:
                                theme
                                    .mobileTexts
                                    .h3
                                    .fontWeightBold,
                          ),
                          formatLargeNumber(
                            number.toString(),
                          ),
                        ),
                        Visibility(
                          visible: action != null,
                          child: Icon(
                            color: Colors.grey.shade400,
                            size: 18,
                            Icons.arrow_forward_ios_rounded,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String formatEntries(int? entries) {
  if (entries == null) {
    return 'entry';
  } else {
    return entries.toString().length > 1
        ? 'entries'
        : 'entry';
  }
}
