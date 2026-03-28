import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/providers/theme_provider.dart';

class DialogTemplate extends StatelessWidget {
  final String title;
  final String message;
  final ThemeProvider theme;
  final Function() action;
  final Function()? cancelAction;
  final Widget widget;
  final String? actionButtonText;
  final bool? showBottomActionButtons;
  final bool? showTopSection;
  final Widget? topRightWidget;
  const DialogTemplate({
    super.key,
    required this.theme,
    required this.message,
    required this.title,
    required this.action,
    this.cancelAction,
    required this.widget,
    this.actionButtonText,
    this.showBottomActionButtons,
    this.showTopSection,
    this.topRightWidget,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 15,
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
                  child: Visibility(
                    visible: showTopSection == null,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            Opacity(
                              opacity: 0,
                              child: topRightWidget,
                            ),
                            Text(
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .h3
                                        .fontSize,
                                fontWeight:
                                    theme
                                        .mobileTexts
                                        .h3
                                        .fontWeightBold,
                              ),
                              title,
                            ),
                            Opacity(
                              opacity:
                                  topRightWidget != null
                                      ? 1
                                      : 0,
                              child: topRightWidget,
                            ),
                          ],
                        ),
                        Text(
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b1
                                    .fontSize,
                          ),
                          message,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // SizedBox(height: 5),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 500),
              child: widget,
            ),
            SizedBox(height: 5),
            Visibility(
              visible: showBottomActionButtons == null,
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
                        onTap: () {
                          cancelAction != null
                              ? cancelAction!()
                              : Navigator.of(context).pop();
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
