import 'package:flutter/material.dart';
import 'package:stockall/providers/theme_provider.dart';

class MainButtonTransparent extends StatelessWidget {
  final ThemeProvider themeProvider;
  final Function()? action;
  final BoxConstraints constraints;
  final String text;
  final Color? color;
  final Icon? icon;

  const MainButtonTransparent({
    super.key,
    required this.themeProvider,
    this.action,
    required this.constraints,
    required this.text,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color:
                color ??
                themeProvider.lightModeColor.prColor200,
            width: 1,
          ),
        ),
        child: InkWell(
          mouseCursor: SystemMouseCursors.click,
          borderRadius: BorderRadius.circular(5),
          onTap: () {
            action != null
                ? action!()
                : Navigator.of(context).pop();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10),

            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    style: TextStyle(
                      color:
                          color ??
                          themeProvider
                              .lightModeColor
                              .prColor300,
                      fontSize:
                          themeProvider
                              .mobileTexts
                              .b3
                              .fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                    text,
                  ),
                  Visibility(
                    visible: icon != null,
                    child: Padding(
                      padding: EdgeInsetsGeometry.only(
                        left: 5,
                      ),
                      child: icon,
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
