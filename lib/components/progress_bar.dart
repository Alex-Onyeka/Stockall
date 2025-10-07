import 'package:flutter/material.dart';
import 'package:stockall/providers/theme_provider.dart';

class ProgressBar extends StatelessWidget {
  final double position;
  final double calcValue;
  final String title;
  final String percent;
  const ProgressBar({
    super.key,
    required this.theme,
    required this.percent,
    required this.title,
    required this.calcValue,
    required this.position,
  });

  final ThemeProvider theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 2,
        children: [
          Text(
            style: TextStyle(
              fontSize: theme.mobileTexts.b3.fontSize,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
            title,
          ),
          SizedBox(height: 3),
          Expanded(
            child: Stack(
              alignment: Alignment(0, 0),
              children: [
                Align(
                  alignment: Alignment(0, 0),
                  child: Container(
                    height: 5,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                      color: Colors.grey.shade300,
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment(-1, 0),
                        child: Container(
                          height: 5,
                          width:
                              MediaQuery.of(
                                context,
                              ).size.width *
                              calcValue,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                            gradient: LinearGradient(
                              colors:
                                  theme
                                      .lightModeColor
                                      .secGradientColors,
                              begin: Alignment.centerRight,
                              end: Alignment.centerLeft,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment(position, 0),
                        child: Container(
                          padding: EdgeInsets.only(left: 5),
                          color: Colors.grey.shade100,
                          child: Text(
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            percent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
