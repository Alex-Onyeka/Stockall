import 'package:flutter/material.dart';
import 'package:flutter_polygon_clipper/flutter_polygon_clipper.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/providers/theme_provider.dart';

class ConfirmationAlert extends StatelessWidget {
  final String title;
  final String message;
  final Function()? action;
  final ThemeProvider theme;
  final String? actionButtonText;
  const ConfirmationAlert({
    super.key,
    required this.theme,
    required this.message,
    required this.title,
    required this.action,
    this.actionButtonText,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 0,
      ),
      contentPadding: EdgeInsets.all(15), //
      backgroundColor: Colors.white,
      content: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 0.0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 10,
          children: [
            SizedBox(height: 10),
            SizedBox(
              height: 90,
              // width: 90,
              child: FlutterClipPolygon(
                sides: 8,
                borderRadius: 10,
                rotate: 0.0,
                boxShadows: [
                  PolygonBoxShadow(
                    color: const Color.fromARGB(
                      101,
                      0,
                      0,
                      0,
                    ),
                    elevation: 1.0,
                  ),
                  PolygonBoxShadow(
                    color: const Color.fromARGB(
                      129,
                      158,
                      158,
                      158,
                    ),
                    elevation: 3.0,
                  ),
                ],
                child: Container(
                  color: theme.lightModeColor.errorColor200,
                  child: Center(
                    child: Icon(
                      color: Colors.white,
                      size: 30,
                      Icons.question_mark_outlined,
                    ),
                  ),
                ),
              ),
            ),

            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 500),
              child: SizedBox(
                width: 500,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal:
                        screenWidth(context) < mobileScreen
                            ? 10
                            : 20.0,
                  ),
                  child: Column(
                    children: [
                      Text(
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize:
                              theme.mobileTexts.h3.fontSize,
                          fontWeight:
                              theme
                                  .mobileTexts
                                  .h3
                                  .fontWeightBold,
                        ),
                        title,
                      ),
                      Text(
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize:
                              theme.mobileTexts.b1.fontSize,
                        ),
                        message,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 0.0,
              ),
              child: Row(
                spacing: 15,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Ink(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          5,
                        ),
                        color: Colors.grey.shade200,
                      ),
                      child: InkWell(
                        mouseCursor:
                            SystemMouseCursors.click,
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),

                          child: Center(
                            child: Text(
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b3
                                        .fontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                              'Cancel',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Ink(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          5,
                        ),
                        color:
                            theme
                                .lightModeColor
                                .errorColor200,
                      ),
                      child: InkWell(
                        mouseCursor:
                            SystemMouseCursors.click,
                        onTap: () {
                          action!();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),

                          child: Center(
                            child: Text(
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b3
                                        .fontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              actionButtonText ?? 'Proceed',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
