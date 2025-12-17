import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';

class ComparisonRow extends StatelessWidget {
  final String title;
  final bool? freePlanBool;
  final String? freePlanString;
  final bool? basicPlanBool;
  final String? basicPlanString;
  final bool? standardPlanBool;
  final String? standardPlanString;
  final bool? premiumPlanBool;
  final String? premiumPlanString;

  const ComparisonRow({
    super.key,
    required this.title,
    this.freePlanBool,
    this.freePlanString,
    this.basicPlanBool,
    this.basicPlanString,
    this.standardPlanBool,
    this.standardPlanString,
    this.premiumPlanBool,
    this.premiumPlanString,
  });

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 8,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              style: TextStyle(
                fontSize: theme.mobileTexts.b3.fontSize,
                fontWeight: FontWeight.normal,
              ),
              title,
            ),
          ),
          Expanded(
            flex:
                screenWidth(context) > mobileScreenSmall
                    ? 2
                    : 1,
            child: Center(
              child: Builder(
                builder: (context) {
                  if (freePlanBool == null) {
                    return Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b3.fontSize,
                        fontWeight: FontWeight.normal,
                      ),
                      freePlanString ?? '',
                    );
                  } else {
                    return Icon(
                      size: 17,
                      color:
                          freePlanBool!
                              ? Colors.green
                              : Colors.red,
                      freePlanBool!
                          ? Icons.check
                          : Icons.clear,
                    );
                  }
                },
              ),
            ),
          ),
          Expanded(
            flex:
                screenWidth(context) > mobileScreenSmall
                    ? 2
                    : 1,
            child: Center(
              child: Builder(
                builder: (context) {
                  if (basicPlanBool == null) {
                    return Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b3.fontSize,
                        fontWeight: FontWeight.normal,
                      ),
                      basicPlanString ?? '',
                    );
                  } else {
                    return Icon(
                      size: 17,
                      color:
                          basicPlanBool!
                              ? Colors.green
                              : Colors.red,
                      basicPlanBool!
                          ? Icons.check
                          : Icons.clear,
                    );
                  }
                },
              ),
            ),
          ),
          Expanded(
            flex:
                screenWidth(context) > mobileScreenSmall
                    ? 2
                    : 1,
            child: Center(
              child: Builder(
                builder: (context) {
                  if (standardPlanBool == null) {
                    return Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b3.fontSize,
                        fontWeight: FontWeight.normal,
                      ),
                      standardPlanString ?? '',
                    );
                  } else {
                    return Icon(
                      size: 17,
                      color:
                          standardPlanBool!
                              ? Colors.green
                              : Colors.red,
                      standardPlanBool!
                          ? Icons.check
                          : Icons.clear,
                    );
                  }
                },
              ),
            ),
          ),
          Expanded(
            flex:
                screenWidth(context) > mobileScreenSmall
                    ? 2
                    : 1,
            child: Center(
              child: Builder(
                builder: (context) {
                  if (premiumPlanBool == null) {
                    return Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b3.fontSize,
                        fontWeight: FontWeight.normal,
                      ),
                      premiumPlanString ?? '',
                    );
                  } else {
                    return Icon(
                      size: 17,
                      color:
                          premiumPlanBool!
                              ? Colors.green
                              : Colors.red,
                      premiumPlanBool!
                          ? Icons.check
                          : Icons.clear,
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
