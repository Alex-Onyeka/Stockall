import 'package:flutter/material.dart';
import 'package:stockitt/providers/theme_provider.dart';

class ProgressBar extends StatelessWidget {
  final double position;
  final double calcValue;
  final String title;
  final String percent;
  final BoxConstraints constraints;
  const ProgressBar({
    super.key,
    required this.theme,
    required this.constraints,
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
        horizontal: 30,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 2,
        children: [
          Text(
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
            title,
          ),
          SizedBox(height: 3),
          Stack(
            children: [
              Container(
                height: 5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                  color: Colors.grey.shade300,
                ),
              ),
              SizedBox(
                height: 25,
                child: Stack(
                  children: [
                    Container(
                      height: 5,
                      width:
                          constraints.maxWidth * calcValue,
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
                    Align(
                      alignment: Alignment(position, 0),
                      child: Text(
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        percent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
        ],
      ),
    );
  }
}
