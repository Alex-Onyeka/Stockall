import 'package:flutter/material.dart';
import 'package:stockall/providers/theme_provider.dart';

class MainButtonTransparent extends StatelessWidget {
  final ThemeProvider themeProvider;
  final Function()? action;
  final BoxConstraints constraints;
  final String text;

  const MainButtonTransparent({
    super.key,
    required this.themeProvider,
    this.action,
    required this.constraints,
    required this.text,
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
            color: themeProvider.lightModeColor.prColor300,
            width: 1.5,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(5),
          onTap: () {
            action!();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 14),

            child: Center(
              child: Text(
                style: TextStyle(
                  color:
                      themeProvider
                          .lightModeColor
                          .prColor300,
                  fontSize:
                      themeProvider
                          .returnPlatform(
                            constraints,
                            context,
                          )
                          .b1
                          .fontSize,
                  fontWeight:
                      themeProvider
                          .returnPlatform(
                            constraints,
                            context,
                          )
                          .b1
                          .fontWeightRegular,
                ),
                text,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
