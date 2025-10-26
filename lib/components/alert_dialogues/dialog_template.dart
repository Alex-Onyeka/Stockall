import 'package:flutter/material.dart';
import 'package:stockall/providers/theme_provider.dart';

class DialogTemplate extends StatelessWidget {
  final String title;
  final String message;
  final ThemeProvider theme;
  final Function() action;
  final Widget widget;
  const DialogTemplate({
    super.key,
    required this.theme,
    required this.message,
    required this.title,
    required this.action,
    required this.widget,
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
              width: 320,
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
            SizedBox(height: 5),
            widget,
            SizedBox(height: 5),
            Row(
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
                      onTap: action,
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
                            'Proceed',
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
