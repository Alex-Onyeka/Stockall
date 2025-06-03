import 'package:flutter/material.dart';
import 'package:storrec/providers/theme_provider.dart';

class MainButtonP extends StatelessWidget {
  const MainButtonP({
    super.key,
    required this.themeProvider,
    required this.action,
    required this.text,
  });

  final String text;
  final Function()? action;

  final ThemeProvider themeProvider;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Material(
          type: MaterialType.transparency,
          child: Ink(
            decoration: BoxDecoration(
              gradient:
                  themeProvider.lightModeColor.prGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: InkWell(
              onTap: () {
                action!();
                FocusManager.instance.primaryFocus
                    ?.unfocus();
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical:
                      constraints.maxWidth < 600 ? 18 : 15,
                ),
                child: Center(
                  child: Text(
                    style: TextStyle(
                      color: Colors.white,
                      fontSize:
                          constraints.maxWidth < 600
                              ? themeProvider
                                  .mobileTexts
                                  .b1
                                  .fontSize
                              : themeProvider
                                  .mobileTexts
                                  .b2
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
      },
    );
  }
}
