import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stockall/components/buttons/small_button_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/theme_provider.dart';

class EmptyWidgetDisplay extends StatelessWidget {
  final String title;
  final String subText;
  final String buttonText;
  final String? svg;
  final IconData? icon;
  final Function()? action;
  final ThemeProvider theme;
  final double height;
  final Function()? altAction;
  final String? altActionText;

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
    this.altAction,
    this.altActionText,
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
                padding: EdgeInsets.all(20),
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
              Visibility(
                visible: altAction != null,
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    InkWell(
                      onTap: () {
                        altAction!();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 15,
                        ),
                        child: Row(
                          spacing: 10,
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Text(altActionText ?? ''),
                            Icon(size: 20, Icons.refresh),
                          ],
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
    );
  }
}
