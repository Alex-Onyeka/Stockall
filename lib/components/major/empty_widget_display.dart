import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stockitt/components/buttons/small_button_main.dart';
import 'package:stockitt/main.dart';
import 'package:stockitt/providers/theme_provider.dart';

class EmptyWidgetDisplay extends StatelessWidget {
  final String title;
  final String subText;
  final String buttonText;
  final String svg;
  final Function()? action;
  final ThemeProvider theme;
  final double height;

  const EmptyWidgetDisplay({
    super.key,
    required this.title,
    required this.subText,
    required this.buttonText,
    required this.svg,
    this.action,
    required this.theme,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.grey.shade300,
              ),
            ),
            child: colorWidget(
              SvgPicture.asset(svg, height: height),
              true,
              context,
            ),
          ),

          SizedBox(height: 15),
          Text(
            style: TextStyle(
              fontSize: theme.mobileTexts.b1.fontSize,
              fontWeight: FontWeight.bold,
            ),
            title,
          ),
          SizedBox(height: 5),
          Text(
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: theme.mobileTexts.b2.fontSize,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
            subText,
          ),
          SizedBox(height: 20),
          SmallButtonMain(
            theme: theme,
            action: action,
            buttonText: buttonText,
          ),
        ],
      ),
    );
  }
}
