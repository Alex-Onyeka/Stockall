import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stockitt/components/buttons/small_button_main.dart';
import 'package:stockitt/main.dart';
import 'package:stockitt/providers/theme_provider.dart';

class EmptyWidgetDisplay extends StatelessWidget {
  final String title;
  final String subText;
  final String buttonText;
  final String? svg;
  final IconData? icon;
  final Function()? action;
  final ThemeProvider theme;
  final double height;

  const EmptyWidgetDisplay({
    super.key,
    required this.title,
    required this.subText,
    required this.buttonText,
    this.svg,
    this.action,
    this.icon,
    required this.theme,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),
                ),
                child: colorWidget(
                  Stack(
                    children: [
                      Visibility(
                        visible: svg != null,
                        child: SvgPicture.asset(
                          svg ?? '',
                          height: 25,
                        ),
                      ),
                      Visibility(
                        visible: icon != null,
                        child: Icon(
                          icon,
                          size: 25,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  true,
                  context,
                ),
              ),

              SizedBox(height: 15),
              Text(
                textAlign: TextAlign.center,
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
              Material(
                child: SmallButtonMain(
                  theme: theme,
                  action: action,
                  buttonText: buttonText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
